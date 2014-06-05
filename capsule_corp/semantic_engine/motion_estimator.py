from rdflib import Literal
from rdflib.namespace import RDF
import datetime

from capsule_corp.semantic_engine.ontology import graph, qol, home


TIME_WINDOW = datetime.timedelta(minutes=1)


class Room(object):
    def __init__(self, room):
        self.room = room
        self.sensors = []
        self.motion = 0

    def add_sensor(self, sensor):
        self.sensors.append(sensor)


class Sensor(object):
    def __init__(self, sensor, room):
        self.room = room
        self.sensor = sensor
        self.on_states = []
        self.room.add_sensor(self)


#  INIT
house = graph.value(predicate=RDF.type, object=qol['House'])

room_query = graph.query(
    """SELECT DISTINCT ?room
    WHERE {
        ?room rdf:type ?class .
        ?class rdfs:subClassOf* qol:Room .
        ?room qol:partOf ?house .
    }""",
    initBindings={'house': house},
    initNs={'qol': qol})
rooms = {row.room: Room(row.room)
         for row in room_query}

# We don't care of door sensors here
sensor_query = graph.query(
    "SELECT DISTINCT ?sensor ?room WHERE { ?sensor qol:deployedIn ?room . }",
    initNs={'qol': qol})
sensors = {row.sensor: Sensor(row.sensor, rooms[row.room])
           for row in sensor_query}


def estimate_motion():
    """Saves the motion level of the patient into the ontology"""
    clock = graph.value(home['clock'], qol['hasValue']).toPython()

    # set the room motions in the window frame
    for room in rooms.values():
        room.motion = 0
        for sensor in room.sensors:
            # We exclude the old states
            sensor.on_states = [state
                                for state in sensor.on_states
                                if clock - state <= TIME_WINDOW]
            room.motion = room.motion + len(sensor.on_states)

    # integrate new updates to the room motions
    for uri, sensor in sensors.items():
        try:
            last_update = graph.value(uri, qol['lastUpdate']).toPython()
        except AttributeError:
            last_update = None

        if not sensor.on_states or last_update != sensor.on_states[-1]:
            state = graph.value(uri, qol['hasCurrentState'])

            if (state is not None and
                (state, qol['indicateLocation'], Literal(True)) in graph):
                sensor.on_states.append(last_update)
                sensor.room.motion = sensor.room.motion + 1

    # update the ontology with the room motions
    for uri, room in rooms.items():
        graph.set((uri, qol['motionMeasured'], Literal(room.motion)))

    # update the ontology with the house motion
    home_motion = sum([room.motion for room in rooms.values()])
    graph.set((house, qol['motionMeasured'], Literal(home_motion)))
