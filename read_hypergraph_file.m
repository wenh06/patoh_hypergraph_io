function [hyp, vertex_weight, edge_weight] = read_hypergraph_file(path)
    %  
    %  Input Arguments:
    %  path: path to the PaToH hypergraph file
    %  
    %  Output Arguments:
    %  
    %  hyp: the hypergraph which is a sparse matrix of size (n_vertex, n_edge)
    %  vertex_weight: weight matrix of the vertices, of size (n_vertex, n_constraint)
    %  edge_weight: weight vector of the hyperedges(nets), of size (n_edge, 1)
    %  
    fid = fopen(path, "r");
    while true
        tline = fgetl(fid);
        tline = strtrim(tline);
        if tline(1) == "%"
            continue
        end
        tline = split(tline);
        [start_val, n_vertex, n_edge, n_pin] = tline{1:4,1};
        start_val = str2num(start_val);
        n_vertex = str2num(n_vertex);
        n_edge = str2num(n_edge);
        n_pin = str2num(n_pin);
        weight_mode = 0;
        n_constraint = 1;
        if length(tline) >= 5
            weight_mode = str2num(tline{5,1});
        end
        if length(tline) == 6
            n_constraint = str2num(tline{6,1});
        end
        break
    end
    hyp = sparse(n_vertex, n_edge);
    edge_weight = zeros(n_edge,1);
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
        tline = split(tline);
        if any(weight_mode == [2 3])
            edge_weight(i,1) = str2num(tline{1,1});
            for j = 2:length(tline)
                hyp(str2num(tline{j,1})-start_val+1,i) = 1;
            end
        elseif any(weight_mode == [0 1])
            for j = 1:length(tline)
                hyp(str2num(tline{j,1})-start_val+1,i) = 1;
            end
        end
        if i == n_edge
            break
        end
        i = i+1;
    end
    
    if any(weight_mode == [1 3])
        vertex_weight = zeros(n_vertex*n_constraint,1);
        pos = 0;
        while true
            tline = fgetl(fid);
            if tline(1) == -1
                break
            end
            tline = strtrim(tline);
            if tline(1) == "%"
                continue
            end
            tline = split(tline);
            if length(tline) == 0
                break
            end
            for i = 1:length(tline)
                vertex_weight(pos+i,1) = str2num(tline{i,1});
            end
            pos = pos+length(tline);
        end
        vertex_weight = reshape(vertex_weight,n_vertex,n_constraint);
    else
        vertex_weight = ones(n_vertex,n_constraint);
    end
    fclose(fid);
