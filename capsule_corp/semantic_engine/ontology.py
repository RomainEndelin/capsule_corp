from rdflib import Graph, Namespace
from tempfile import mktemp
import os
import __main__


# FIXME Deal with the sleepycat file location
ONTOLOGY_DIR = ('%s/resources/eye' %
                os.path.dirname(os.path.abspath(__main__.__file__)))

path = mktemp()

graph = Graph('Sleepycat', identifier='home_ontology')
graph.open(path, create=True)

graph.parse('%s/load-init.n3' % ONTOLOGY_DIR, format='n3')
graph.parse('%s/load-home.n3' % ONTOLOGY_DIR, format='n3')
graph.parse('%s/load-model.n3' % ONTOLOGY_DIR, format='n3')

qol = Namespace("file://%s/load-model#" % ONTOLOGY_DIR)
home = Namespace("file://%s/load-home#" % ONTOLOGY_DIR)
