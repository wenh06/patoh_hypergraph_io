"""
"""

import re
from typing import Tuple

import numpy as np
from scipy.sparse import lil_matrix


__all__ = ["read_hypergraph_file",]


_HEADER_PATTERN = "^(?P<start_val>[\d]{1})[\s]+(?P<n_vertex>[\d]+)[\s]+(?P<n_edge>[\d]+)[\s]+(?P<n_pin>[\d]+)(?:[\s]+(?P<weight_mode>[\d]{1}))?(?:[\s]+(?P<n_constraint>[\d]+))?$"


def read_hypergraph_file(path:str) -> Tuple[lil_matrix, np.ndarray, np.ndarray]:
    """

    Parameters
    ----------
    path: str,
        path to the PaToH hypergraph file

    Returns
    -------
    hyp: lil_matrix,
        the hypergraph, a sparse matrix of shape (n_vertex, n_edge)
    vertex_weight: ndarray,
        weight matrix of vertices, of shape (n_vertex, n_constraint),
        default values are 1
    edge_weight: ndarray,
        weight vector of hyperedges (nets), of shape (n_edge, 1),
        default values are 1
    """
    with open(path, "r") as f:
        content = f.read().splitlines()
    content = [l.strip() for l in content if not l.startswith("%")]
    start_val, n_vertex, n_edge, n_pin, weight_mode, n_constraint = re.findall(_HEADER_PATTERN, content[0])[0]
    start_val, n_vertex, n_edge, n_pin = int(start_val), int(n_vertex), int(n_edge), int(n_pin)
    try:
        weight_mode = int(weight_mode)
    except:
        weight_mode = 0
    try:
        n_constraint = int(n_constraint)
    except:
        n_constraint = 1
    edge_weight = np.ones((n_edge, 1))
    vertex_weight = np.ones((n_vertex, n_constraint))
    
    hyp = lil_matrix((n_vertex, n_edge))
    
    if weight_mode in [2,3]:
        for idx, line in enumerate(content[1:1+n_edge]):
            line = line.split()
            edge_weight[idx,0] = int(line[0])  # TODO: should consider float?
            for j in line[1:]:
                hyp[int(j)-start_val,idx] = 1
    elif weight_mode in [0, 1,]:
        for idx, line in enumerate(content[1:1+n_edge]):
            for j in line.split():
                hyp[int(j)-start_val,idx] = 1
    if weight_mode in [1,3]:
        vertex_weight = np.array([])
        for line in content[1+n_edge:]:
            vertex_weight = np.concatenate((vertex_weight, np.fromstring(line, sep=" ")))
        vertex_weight = vertex_weight.reshape((n_vertex, n_constraint))
    return hyp, vertex_weight, edge_weight
