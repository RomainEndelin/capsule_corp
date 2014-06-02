import mosquitto
import logging
import json
from datetime import datetime

import pandas as pd
from pandas.tseries import offsets

from naive_engine import naive_guess

log = logging.getLogger('test')
log.setLevel(logging.INFO)
log.addHandler(logging.StreamHandler())

activities = pd.Series()

engines = {'naive': naive_guess}
inferences = pd.DataFrame(columns=[engine for engine in engines.keys()])

ended = False


def analyze_sensor_event(sensor, event):
    log.debug("Now ready to anayze event %s on sensor '%s'" % (sensor, event))
    event['sensor'] = sensor
    event['date'] = datetime.strptime(event['date'],
                                      '%Y-%m-%d %H:%M:%S')
    s = pd.Series()
    for name, engine in engines.items():
        infered = engine(event)
        log.info("Engine '%s' - Inferred: %s" % (name, infered))
        s[name] = infered
    inferences.loc[event['date']] = s


def feedback():
    results = pd.concat([activities, inferences],
                        axis=1).rename(columns={0: 'ground_truth'})
    # fill values forward, change je frequency
    freq = offsets.DateOffset(seconds=5)
    results = results.fillna(method='pad').asfreq(freq, method='pad')
    log.debug(results)

    inference_cols = [col for col in results.columns
                      if col not in ['ground_truth']]

    func_score = (lambda x:
                  len(x[x == results['ground_truth']]) / float(len(x)))
    scores = results[inference_cols].apply(func_score)

    log.info(scores)
    return scores


def route_message(category, subject, data):
    if category == "sensor":
        log.info("Sensor '%s' sends %s" % (subject, data))
        analyze_sensor_event(subject, data)
    elif category == "item":
        log.debug("Item '%s' sends %s" % (subject, data))
        pass  # TODO Store items uses?
    elif category == "person":
        log.info("Person '%s' sends %s" % (subject, data))
        pass  # TODO Store person movements?
    elif category == "activity":
        log.info("Activity '%s' sends %s" % (subject, data))
        date = datetime.strptime(data['date'],
                                 '%Y-%m-%d %H:%M:%S')
        activities[date] = subject
    elif category == "system" and subject == "stop":
        global ended
        ended = datetime.strptime(data['date'],
                                  '%Y-%m-%d %H:%M:%S')


def on_message(mosquitto, obj, msg):
    log.debug("Message received on topic %s with QoS %s and payload %s"
              % (msg.topic, str(msg.qos), msg.payload))

    # Retrieving the content of the message as a json object
    data = json.loads(msg.payload.decode('utf-8'))

    parsed_topic = msg.topic.split('/')
    # category: sensor, item...
    # designation: A1...
    (category, subject) = parsed_topic[-2:]

    route_message(category, subject, data)


def main():
    client = mosquitto.Mosquitto("test-client")
    client.connect("127.0.0.1", port=8000)
    client.subscribe("house/2/simu/+/+", 1)
    client.on_message = on_message

    while(not ended):
        client.loop()

    log.info("TERMINATED | %s" % ended)

    feedback()
    # TODO Add some engines
    # * Thibaut's inference
    # * DS
    # * Naive Bayes
    # * Bayesian network
    # * HMM
    # * Markov Logic Chain
    # TODO Include statistical/reinforcement datasets
    # TODO Stop the loop at the end of the simulation, and perform statistics

if __name__ == '__main__':
    main()
