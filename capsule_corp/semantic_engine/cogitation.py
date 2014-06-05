import glob
import subprocess
from tempfile import mktemp
from rdflib import Graph, Namespace, Literal
from rdflib.plugins import sparql

from capsule_corp.semantic_engine import motion_estimator
from capsule_corp.semantic_engine.ontology import (graph, qol, home,
                                                   ONTOLOGY_DIR)


EULER_BIN = 'eye'

event_query = sparql.prepareQuery(
    """SELECT DISTINCT ?state ?sensor
    WHERE {
        ?sensorClass rdfs:subClassOf* qol:Sensor .
        ?sensor rdf:type ?sensorClass .
        ?sensor rdfs:label ?sensorLabel .
        ?sensorClass qol:hasPossibleState ?state .
        ?state rdfs:label ?stateLabel .
        } LIMIT 1""",
    initNs={'qol': qol})


def save_to_ontology(event):
    """Saving an event into the graph"""
    graph.set((home['clock'],
               qol['hasValue'],
               Literal(event['date'])))

    if 'signal' in event:
        # if we deal with a sensor event
        sparql_event = graph.query(
            event_query,
            initBindings={'sensorLabel': Literal(event['sensor']),
                          'stateLabel': Literal(event['signal'])})

        for row in sparql_event:
            graph.set((row.sensor, qol['lastUpdate'], Literal(event['date'])))
            graph.set((row.sensor, qol['hasLastUpdate'], Literal(True)))
            graph.set((row.sensor, qol['hasCurrentState'], row.state))


def think():
    """Runs the euler reasoning"""
    # Serialize the triple store in DUMP_FILE
    dump_file = mktemp('.n3')
    graph.serialize(dump_file, format='n3')

    # List required ontologies
    rule_files = glob.glob('%s/infer*.n3' % ONTOLOGY_DIR)
    query_files = glob.glob('%s/query*.n3' % ONTOLOGY_DIR)

    euler_cmd = ([EULER_BIN, dump_file] +
                 rule_files +
                 ['--think', '--query'] +
                 query_files +
                 ['--nope'])

    # Call euler
    process = subprocess.Popen(euler_cmd,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE)
    return process.communicate()


def save(eye_dump):
    """Place the euler output into the ontology"""
    dump_graph = Graph()
    dump_graph.parse(data=eye_dump, format='n3')
    ts = Namespace("file://%s/infer-triplestore#" % ONTOLOGY_DIR)

    for action, formula in dump_graph.predicate_objects(ts['n3store']):
        if action in (ts['update'], ts['add'], ts['remove']):
            for s, p, o in formula:
                if action == ts['update']:
                    graph.set((s, p, o))
                elif action == ts['add']:
                    graph.add((s, p, o))
                elif action == ts['remove']:
                    graph.remove((s, p, o))


def read_activity():
    """Retrieve the current activity in the ontology"""
    # TODO make the subject more generic
    activity = graph.value(home['johndoe'], qol['believedToDo'])

    labels = graph.preferredLabel(activity, lang='en')
    if labels:
        return labels[0][1].toPython()
    return None


def infer_from_ontology(event):
    """For a new event, infer the activity, with ontological reasoning"""
    save_to_ontology(event)
    motion_estimator.estimate_motion()
    out, err = think()
    save(out)
    return read_activity()
    # TODO Close the graph at some time
