from json.decoder import JSONDecodeError
import queue
import json
from dijkstar import Graph, find_path
import sys

def chargeStructure(jsonfile,graph):
    for node in jsonfile["List"]:
        graph.add_edge(node["node"], node["to"], node["cost"])

if __name__ == "__main__":
    graph = Graph()
    jsonfile = open(sys.argv[1]).read()
    structure = json.loads(jsonfile)
    chargeStructure(structure,graph)
    print(find_path(graph, 1, 4))
    