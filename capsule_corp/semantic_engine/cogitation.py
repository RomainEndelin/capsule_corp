import glob
import subprocess
from rdflib import Graph, Namespace, Literal

from capsule_corp.semantic_engine import motion_estimator
from capsule_corp.semantic_engine.ontology import (graph, qol, home,
                                                   ONTOLOGY_DIR)


DUMP_FILE = '%s/dump-ubi.n3' % ONTOLOGY_DIR
EULER_BIN = 'eye'
EULER_KERNEL = ''


def save_to_ontology(event):
    """Saving an event into the graph"""
    graph.set((home['clock'],
               qol['hasCurrentState'],
               Literal(event['signal'])))
    subject = home[event['sensor'].lower()]
    graph.set((subject, qol['lastUpdate'], Literal(event['date'])))

    if 'signal' in event:
        # if we deal with a sensor event
        graph.set((subject, qol['hasCurrentState'], Literal(event['signal'])))


def think():
    """Runs the euler reasoning"""
    # Serialize the triple store in DUMP_FILE
    graph.serialize(DUMP_FILE, format='n3')

    # List required ontologies
    rule_files = glob.glob('%s/infer*.n3' % ONTOLOGY_DIR)
    query_files = glob.glob('%s/query*.n3' % ONTOLOGY_DIR)

    euler_cmd = ([EULER_BIN, DUMP_FILE] +
                 rule_files +
                 ['--think', '--query'] +
                 query_files +
                 ['--nope'])

    # Call euler
    process = subprocess.Popen(euler_cmd,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE)
    return process.communicate


def save():
    """Place the euler output into the ontology"""
    dump_graph = Graph()
    dump_graph.parse(DUMP_FILE, format='n3')
    ts = Namespace("file://%s/infer-triplestore#" % ONTOLOGY_DIR)

    # TODO: Check that formulae work
    for action, formula in dump_graph.predicate_objects(ts['n3store']):
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
    think()
    save()
    return read_activity()
    # TODO Close the graph at some time
