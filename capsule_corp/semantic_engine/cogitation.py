import glob
import subprocess
from rdflib import Graph, Namespace, Literal

from capsule_corp.semantic_engine import motion_estimator


DUMP_FILE = 'dump-ubi.n3'
EULER_DIR = './eye/'
EULER_BIN = 'eye'
EULER_KERNEL = ''

# FIXME The following part is temporary
from tempfile import mktemp
path = mktemp()
graph = Graph('Sleepycat', identifier='home_ontology')
graph.open(path, create=True)
graph.parse('./eye/load-init.n3', format='n3')
graph.parse('./eye/load-home.n3', format='n3')
qol = Namespace("file:///home/kilik/phd/playground/2014/data_analysis/"
                "capsule_corp/eye/load-model#")
home = Namespace("file:///home/kilik/phd/playground/2014/data_analysis/"
                 "capsule_corp/eye/load-home#")


def save_to_ontology(event):
    # graph.parse('./eye/load-init.n3', format='n3')

    graph.set((home['clock'],
               qol['hasCurrentState'],
               Literal(event['signal'])))
    subject = home[event['sensor'].lower()]
    graph.set((subject, qol['lastUpdate'], Literal(event['date'])))

    if 'signal' in event:
        # if we deal with a sensor event
        graph.set((subject, qol['hasCurrentState'], Literal(event['signal'])))


def think():
    # List required ontologies
    rule_files = glob.glob('%s/infer*.n3')
    query_files = glob.glob('%s/query*.n3')

    # Call euler
    euler_cmd = ("%s %s %s --think --query %s --nope %s" %
                 (EULER_BIN,
                  DUMP_FILE,
                  ' '.join(rule_files),
                  ' '.join(query_files),
                  EULER_KERNEL))
    subprocess.call(euler_cmd, shell=True)


def save():
    dump_graph = Graph()
    dump_graph.parse(DUMP_FILE)
    ts = Namespace("file:///home/kilik/phd/playground/2014/data_analysis/"
                   "capsule_corp/eye/infer-triplestore#")

    # TODO: Check that formulae work
    for action, formula in dump_graph.predicate_object(ts['n3store']):
        for s, p, o in formula.triples((None, None, None)):
            if action == ts['update']:
                graph.set((s, p, o))
            elif action == ts['add']:
                graph.add((s, p, o))
            elif action == ts['remove']:
                graph.remove((s, p, o))


def read_activity():
    for subject, activity in graph.predicates(qol['believedToDo']):
        # TODO get more information on the subject
        return activity


def infer_from_ontology(event):
    save_to_ontology(event)
    motion_estimator.estimate_motion()
    think()
    save()
    return read_activity()
    # TODO Close the graph at some time
