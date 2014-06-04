import mosquitto
import logging
import json
from datetime import datetime

import data_processing as dp


log = logging.getLogger('test')
log.setLevel(logging.INFO)
log.addHandler(logging.StreamHandler())

ended = False


def route_message(category, subject, data):
    if category == "sensor":
        log.info("Sensor '%s' sends %s" % (subject, data))
        dp.analyze_sensor_event(subject, data)
    elif category == "item":
        log.debug("Item '%s' sends %s" % (subject, data))
        pass  # TODO Store items uses?
    elif category == "person":
        log.info("Person '%s' sends %s" % (subject, data))
        pass  # TODO Store person movements?
    elif category == "activity":
        log.info("Activity '%s' sends %s" % (subject, data))
        dp.analyze_activities(subject, data)
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

    dp.feedback()
    # TODO Add some engines
    # * Thibaut's inference
    # * DS
    # * Naive Bayes
    # * Bayesian network
    # * HMM
    # * Markov Logic Chain
    # TODO Include statistical/reinforcement datasets

if __name__ == '__main__':
    main()
