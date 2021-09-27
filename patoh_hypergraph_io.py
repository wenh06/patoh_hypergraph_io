"""
"""

import re
from typing import Tuple

import numpy as np
from scipy.sparse import lil_matrix


__all__ = ["read_hypergraph_file",]


def read_hypergraph_file(path:str) -> Tuple[lil_matrix, np.ndarray, np.ndarray]:
    """
    """
    with open(path, "r") as f:
        content = f.read().splitlines()
    content = [l.strip() for l in content if not l.startswith("%")]
    start_val, n_vertex, n_edge, n_pin, weight_mode, n_constraint = re.findall(pattern, content[0])[0]
    start_val, n_vertex, n_edge, n_pin = int(start_val), int(n_vertex), int(n_edge), int(n_pin)
    try:
        weight_mode = int(weight_mode)
    except:
        weight_mode = None
    try:
        n_constraint = int(n_constraint)
    except:
        n_constraint = 1
    edge_weight = None
    vertex_weight = None
    
    hyp = lil_matrix((n_vertex, n_edge))
    
    if weight_mode in [2,3]:
        edge_weight = []
        for idx, line in enumerate(content[1:1+n_edge]):
            line = line.split()
            edge_weight.append(int(line[0]))
            for j in line[1:]:
                hyp[int(j)-start_val,idx] = 1
        edge_weight = np.array(edge_weight)
    elif weight_mode in [1,] or weight_mode is None:
        for idx, line in enumerate(content[1:1+n_edge]):
            for j in line.split():
                hyp[int(j)-start_val,idx] = 1
    if weight_mode in [1,3]:
        vertex_weight = []
        for line in content[1+n_edge:]:
            vertex_weight.extend([int(i) for i in line.split()])
        vertex_weight = np.array(vertex_weight)
        vertex_weight = vertex_weight.reshape((n_vertex, n_constraint))
    return hyp, vertex_weight, edge_weight
