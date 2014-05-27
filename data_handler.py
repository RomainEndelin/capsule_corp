import mosquitto
import logging
import json

from naive_engine import naive_guess

log = logging.getLogger('test')
log.setLevel(logging.INFO)
log.addHandler(logging.StreamHandler())


engines = {'naive': naive_guess}


def analyze_sensor_event(sensor, event):
    log.debug("Now ready to anayze event %s on sensor '%s'" % (sensor, event))
    event['sensor'] = sensor
    for name, engine in engines.items():
        log.info("Engine '%s' - Inferred: %s" % (name, engine(event)))


def route_messages(mosq, obj, msg):
    log.debug("Message received on topic %s with QoS %s and payload %s"
              % (msg.topic, str(msg.qos), msg.payload))
    data = json.loads(msg.payload.decode('utf-8'))
    parsed_topic = msg.topic.split('/')
    category = parsed_topic[-2]
    subject = parsed_topic[-1]
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
        pass  # TODO Store person activities, so we can check the inferences


def main():
    client = mosquitto.Mosquitto("test-client")
    client.connect("127.0.0.1", port=8000)
    client.subscribe("house/2/simu/+/+", 1)
    client.on_message = route_messages
    client.loop_forever()
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
