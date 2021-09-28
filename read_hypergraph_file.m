function [hyp, vertex_weight, edge_weight, n_constraint] = read_hypergraph_file(path)
    %  
    %  Input Arguments:
    %  path: path to the PaToH hypergraph file
    %  
    %  Output Arguments:
    %  
    %  hyp: the hypergraph which is a sparse matrix of size (n_vertex, n_edge)
    %  vertex_weight: weight matrix of the vertices, of size (n_vertex, n_constraint)
    %  edge_weight: weight vector of the hyperedges(nets), of size (n_edge, 1)
    %  n_constraint: number of constraints for each vertex
    %  
    fid = fopen(path, "r");
    while true
        tline = fgetl(fid);
        tline = strtrim(tline);
        if tline(1) == "%"
            continue
        end
        tline = str2num(tline);
        tline = num2cell(tline);
        [start_val, n_vertex, n_edge, n_pin] = tline{1,1:4};
        weight_mode = 0;
        n_constraint = 1;
        if length(tline) >= 5
            weight_mode = tline{1,5};
        end
        if length(tline) == 6
            n_constraint = tline{1,6};
        end
        break
    end
    hyp = sparse(n_vertex, n_edge);
    edge_weight = ones(n_edge,1);
    i = 1;
    while true
        tline = fgetl(fid);
        if tline(1) == -1
            break
        end
        tline = strtrim(tline);
        if tline(1) == "%"
            continue
        end
        tline = str2num(tline);
        if any(weight_mode == [2 3])
            edge_weight(i,1) = tline(1,1);
            for j = 2:length(tline)
                hyp(tline(1,j)-start_val+1,i) = 1;
            end
        elseif any(weight_mode == [0 1])
            for j = 1:length(tline)
                hyp(tline(1,j)-start_val+1,i) = 1;
            end
        end
        if i == n_edge
            break
        end
        i = i+1;
    end
    
    if any(weight_mode == [1 3])
        vertex_weight = [];
        while true
            tline = fgetl(fid);
            if tline(1) == -1
                break
            end
            tline = strtrim(tline);
            if tline(1) == "%"
                continue
            end
            tline = str2num(tline);
            if length(tline) == 0
                break
            end
            vertex_weight = cat(2,vertex_weight,tline);
        end
        vertex_weight = reshape(vertex_weight,n_vertex,n_constraint);
    else
        vertex_weight = ones(n_vertex,n_constraint);
    end
    fclose(fid);
