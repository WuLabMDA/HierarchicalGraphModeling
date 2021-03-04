clearvars;
fea_root = fullfile('./data', 'ImgCellFeas');

feature_names = {'Area','Perimeter','MajorAxisLength','EquivDiameter','IntegratedIntensity',...
    'MinorAxisLength','MeanOutsideBoundaryIntensity','NormalizedBoundarySaliency',...
    'NormalizedOutsideBoundaryIntensity','MeanInsideBoundaryIntensity'};
        
subtypes = {'CLL', 'aCLL', 'RT'};
cmap=[1 0 0; 0 1 0; 0 0 1];
for ss = 1:length(subtypes)
    diag = subtypes{ss};
    disp(['Global Graph for ', diag]);
    cur_diag_dir = fullfile(fea_root, diag);
    cur_globalgraph_dir = fullfile('./data', 'GlobalGraph', diag);
    if ~exist(cur_globalgraph_dir, 'dir')
        mkdir(cur_globalgraph_dir)
    end      
    
    img_list = dir(fullfile(cur_diag_dir, '*.mat'));
    for ii = 1:length(img_list)
        disp([num2str(ii), '/', num2str(length(img_list))]);
        [~, basename, ~] = fileparts(img_list(ii).name);
%         if ~strcmp(basename, '205')
%             continue
%         end
        cur_fea_path = fullfile(cur_diag_dir, img_list(ii).name);
        load(cur_fea_path);
        img_cell_feas = zeros(length(feature_names), length(properties));
        for ff=1:length(feature_names)
            img_cell_feas(ff,:) = [properties.(feature_names{ff})];
        end
        img_cell_feas = img_cell_feas';

        % load cell classifier paramters
        cell_clf_para_path = fullfile('./data', 'Models', 'cell_clf_para.mat');
        load(cell_clf_para_path);

        % normalize data
        norm_fea = bsxfun(@minus, img_cell_feas, cell_fea_mu);
        norm_fea = bsxfun(@rdivide, norm_fea, cell_fea_sd);
        % label prediction
        labels = predict(cell_clf_model, norm_fea);

        % create cell features for graph construction
        data_pts = zeros(length(properties), 3);
        centroids = [properties.Centroid];
        data_pts(:,1) = centroids(1:2:end);
        data_pts(:,2) = centroids(2:2:end);
        data_pts(:,3) = labels;
        
%         % Draw cell types on empty images
%         I_empty = zeros(1000, 1000);
%         imshow(I_empty);
%         hold on;
%         for cc=1:length(nuclei)
%             if data_pts(cc, 3) == 1
%                 plot(nuclei{cc}(:,2), nuclei{cc}(:,1), 'r-', 'LineWidth', 1);
%             elseif data_pts(cc, 3) == 2
%                 plot(nuclei{cc}(:,2), nuclei{cc}(:,1), 'g-', 'LineWidth', 1);
%             else
%                 disp('Unknow label');
%             end
%         end
%         hold off;
%         cur_cell_seg_path = fullfile('./data', 'Demos', 'CellSeg', diag, strcat(basename, '_cell.png'));
%         imwrite(getframe(gca).cdata, cur_cell_seg_path);
        % graph construction
        [cluster_centers,idx,cluster2data]= ROC(data_pts, 0.9, 10);

        % Save the supercell classifier 
        supercell_clf_para_path = fullfile('./data', 'Models', 'supercell_clf_para.mat');
        load(supercell_clf_para_path);
        % calualte the cluster centers
        cell_coors = data_pts(:,1:2)';
        cluster_coors = zeros(2, length(cluster_centers));
        for i=1:size(cluster_coors, 2)
            cluster_coors(:,i) = mean(cell_coors(:, idx==i), 2);
        end

        % collect graph nodes
        graph_nodes = zeros(length(cluster2data), 3);
        node_ind = 1;
        % extract supercell features 
        for cc=1:length(cluster2data)
            % mean of indivisual cel
            cluster_idx = cluster2data{cc};
            if length(cluster_idx) < 5
                continue;
            end
            super_cell_feas = zeros(1, size(supercell_fea_mu, 2));
            cell_feas = mean(img_cell_feas(cluster_idx, :), 1);
            super_cell_feas(1, 1:10) = cell_feas;
            % supercell voronoi features 
            cell_xs = data_pts(cluster_idx, 1)';
            cell_ys = data_pts(cluster_idx, 2)';
            v_feas = compute_voronoi_feas(cell_xs, cell_ys);
            super_cell_feas(1, 11:22) = v_feas;
            % supercell features
            super_cell_feas(1, 23) = length(cluster_idx);
            cluster_center = cluster_centers(cc, 1:2);
            cell_coors = data_pts(cluster_idx, 1:2);
            cell_center_vec = cluster_center - cell_coors;
            avg_cell_center_len = mean(vecnorm(cell_center_vec, 2, 2));
            super_cell_feas(1, 24) = avg_cell_center_len;
            % normalize data
            norm_fea = bsxfun(@minus, super_cell_feas, supercell_fea_mu);
            norm_fea = bsxfun(@rdivide, norm_fea, supercell_fea_sd);
            % label prediction
            cluster_label = predict(supercell_clf_model, norm_fea);
            graph_nodes(node_ind, 1:2) = cluster_center;
            graph_nodes(node_ind, 3) = cluster_label;

            node_ind = node_ind + 1;
        end
        graph_nodes = graph_nodes(1:node_ind-1, :);
        
        % build the delaunay graph
        DT = delaunay(graph_nodes(:, 1), graph_nodes(:, 2));
        edges = zeros(size(DT, 1) * 3, 2);
        for dd=0:size(DT, 1)-1
            node_list = sort(DT(dd+1, :));
            edges(dd*3 + 1, 1) = node_list(1);
            edges(dd*3 + 1, 2) = node_list(2);
            edges(dd*3 + 2, 1) = node_list(1);
            edges(dd*3 + 2, 2) = node_list(3);
            edges(dd*3 + 3, 1) = node_list(2);
            edges(dd*3 + 3, 2) = node_list(3);    
        end
        edges = unique(edges, 'rows');
        nodes = graph_nodes(:, 3);
        voronoi_feas = compute_voronoi_feas(graph_nodes(:, 1), graph_nodes(:, 2));
        
        % save global graph features
        cur_graph_info_path = fullfile(cur_globalgraph_dir, img_list(ii).name);
        save(cur_graph_info_path, 'edges', 'nodes', 'voronoi_feas');
        
        % plot built delaunay graph
        I_empty = ones(1000, 1000);
        imshow(I_empty);
        hold on;
        % plot all nodes 
        for gg=1:length(graph_nodes)
            if graph_nodes(gg, 3) == 1
                scatter(graph_nodes(gg, 1), graph_nodes(gg, 2), 300, 'MarkerFaceColor', 'red');
            elseif graph_nodes(gg, 3) == 2
                scatter(graph_nodes(gg, 1), graph_nodes(gg, 2), 300, 'MarkerFaceColor', 'green');
            else
                disp('Unknow node');
            end     
        end
        % plot all edges
        for ee=1:length(edges)
            pa = edges(ee, 1);
            pb = edges(ee, 2);
            edge_sum = nodes(pa) + nodes(pb);
            plot([cluster_centers(pa,1), cluster_centers(pb,1)], [cluster_centers(pa,2), cluster_centers(pb,2)], ...
                'Color', cmap(edge_sum-1,:), 'LineWidth',3); 
        end
        hold off;
        set(gca, 'color', 'none');
        cur_supercell_edge_path = fullfile(cur_globalgraph_dir, strcat(basename, '_delaunay.png'));
        imwrite(getframe(gca).cdata, cur_supercell_edge_path);
        close all;

        % draw voronoi graph
        voronoi(graph_nodes(:, 1), graph_nodes(:, 2));
        axis equal;
        xlim([0 1000]);
        ylim([0 1000]);
        set(gca,'xtick',[], 'ytick', []);
        img_supercell_voronoi_path = fullfile(cur_globalgraph_dir, strcat(basename, '_voronoi.png'));
        imwrite(getframe(gca).cdata, img_supercell_voronoi_path);
        close all;
        
        
    end
end

