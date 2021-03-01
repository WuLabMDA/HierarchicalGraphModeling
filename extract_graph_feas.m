clearvars;
fea_root = fullfile('./data', 'GlobalGraph');
img_edge_fea_path = fullfile('./data', 'GlobalGraph', 'graph_fea.mat');

subtypes = {'CLL', 'aCLL', 'RT'};
population_img_feas = struct('diagnosis', 'feas');
for ss = 1:length(subtypes)
    diag = subtypes{ss};
    disp(['Graph Edge Features for ', diag]);
    cur_diag_dir = fullfile(fea_root, diag);
    img_list = dir(fullfile(cur_diag_dir, '*.mat'));
    img_graph_feas = struct('name', 'graph_feas');
    for ii = 1:length(img_list)
        disp([num2str(ii), '/', num2str(length(img_list))]);
        cur_graph_info_path = fullfile(cur_diag_dir, img_list(ii).name);
        load(cur_graph_info_path);
        ss_num = 0;
        sl_num = 0;
        ll_num = 0;
        edge_num = length(edges);
        for ee = 1:edge_num
            edge_sum = nodes(edges(ee, 1)) + nodes(edges(ee, 2));
            if edge_sum == 2
                ss_num = ss_num + 1;
            elseif edge_sum == 3
                sl_num = sl_num + 1;
            elseif edge_sum == 4
                ll_num = ll_num + 1;
            else
                disp('Error Edge');
            end
        end
        ss_ratio = ss_num * 1.0 / edge_num;
        sl_ratio = sl_num * 1.0 / edge_num;
        ll_ratio = ll_num * 1.0 / edge_num;
        c1_ratio = sum(nodes == 1) / length(nodes);
        c2_ratio = sum(nodes == 2) /length(nodes);
        [~, basename, ~] = fileparts(img_list(ii).name);
        img_graph_feas(ii).name = basename;
        % Delaunay features
        img_graph_feas(ii).graph_feas = [ss_ratio, sl_ratio, ll_ratio];
        % Voronoi features
        img_graph_feas(ii).graph_feas = voronoi_feas;
        % Delaunay & Voronoi features
        img_graph_feas(ii).graph_feas = [ss_ratio, sl_ratio, ll_ratio, voronoi_feas];
    end
    population_img_feas(ss).diagnosis = diag;
    population_img_feas(ss).feas = img_graph_feas;
end
save(img_edge_fea_path, 'population_img_feas');

