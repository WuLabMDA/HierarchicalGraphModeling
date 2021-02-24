clearvars;

dataset_name = 'RT';
sparse_adjacency_matrix_path = fullfile('./data', 'GlobalGraph', strcat(dataset_name, '_A.txt'));
graph_node_identify_path = fullfile('./data', 'GlobalGraph', strcat(dataset_name, '_graph_indicator.txt'));
graph_label_path = fullfile('./data', 'GlobalGraph', strcat(dataset_name, '_graph_labels.txt'));
graph_node_label_path = fullfile('./data', 'GlobalGraph', strcat(dataset_name, '_node_labels.txt'));

max_edge = 100000;
adjacency_matrix = zeros(max_edge, 2);
max_node = 10000;
node_identifies = zeros(max_node, 1);
graph_labels = zeros(75, 1);
node_labels = zeros(max_node, 1);

disp('Start organization');
subtypes = {'CLL', 'aCLL', 'RT'};
img_ind = 1;
cur_node_pos = 1;
cur_edge_pos = 1;
for ss = 1:length(subtypes)
    diag = subtypes{ss};
    disp(['Work on ', diag]);
    cur_diag_dir = fullfile('./data', 'GlobalGraph', diag);
    img_list = dir(fullfile(cur_diag_dir, '*.mat'));
    for ii = 1:length(img_list)
        % disp([num2str(ii), '/', num2str(length(img_list))]);
        cur_fea_path = fullfile(cur_diag_dir, img_list(ii).name);
        load(cur_fea_path);
        num_edge = size(edges, 1);
        num_node = size(nodes, 1);
        adjacency_matrix(cur_edge_pos:cur_edge_pos+num_edge-1, :) = edges + cur_node_pos - 1;
        node_identifies(cur_node_pos:cur_node_pos+num_node-1) = img_ind;
        graph_labels(img_ind) = ss;
        node_labels(cur_node_pos:cur_node_pos+num_node-1) = nodes;
        cur_edge_pos = cur_edge_pos + num_edge;
        cur_node_pos = cur_node_pos + size(nodes, 1);
        img_ind = img_ind + 1;
    end
end

% DS_A.txt 
adjacency_matrix = adjacency_matrix(1:cur_edge_pos-1, :);
writematrix(adjacency_matrix, sparse_adjacency_matrix_path);
% DS_graph_indicator.txt
node_identifies = node_identifies(1:cur_node_pos-1);
writematrix(node_identifies, graph_node_identify_path);
% DS_graph_labels.txt
writematrix(graph_labels, graph_label_path);
% DS_node_labels.txt
node_labels = node_labels(1:cur_node_pos-1);
writematrix(node_labels, graph_node_label_path);

disp('Finish organization');