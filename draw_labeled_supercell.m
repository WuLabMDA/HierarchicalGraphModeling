clearvars;

% fea_path = fullfile('./data', 'ImgCellFeas', 'CLL', '137.mat');
fea_path = fullfile('./data', 'ImgCellFeas', 'aCLL', '52.mat');
% fea_path = fullfile('./data', 'ImgCellFeas', 'RT', '14.mat');
load(fea_path);
feature_names = {'Area','Perimeter','MajorAxisLength','EquivDiameter','IntegratedIntensity',...
    'MinorAxisLength','MeanOutsideBoundaryIntensity','NormalizedBoundarySaliency',...
    'NormalizedOutsideBoundaryIntensity','MeanInsideBoundaryIntensity'};
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

% graph construction
[cluster_centers,idx,cluster2data]= ROC(data_pts, 0.9, 10);

% Save the supercell classifier 
supercell_clf_para_path = fullfile('./data', 'Models', 'supercell_clf_para.mat');
load(supercell_clf_para_path);


% visulize labeled supercell
imshow(I);
hold on;
% calualte the cluster centers
cell_coors = data_pts(:,1:2)';
cluster_coors = zeros(2, length(cluster_centers));
for i=1:size(cluster_coors, 2)
    cluster_coors(:,i) = mean(cell_coors(:, idx==i), 2);
end
cmap=[1 0 0; 0 1 0; 0 0 1;1 1 0; 1 0 1; 0 1 1; 1 1 1];

% extract supercell features 
for cc=1:length(cluster2data)
    % mean of indivisual cel
    cluster_idx = cluster2data{cc};
    if length(cluster_idx) < 5
        continue;
    end
    super_cell_feas = zeros(1, 24);
    
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
    clusetr_label = predict(supercell_clf_model, norm_fea);
    % draw all the cells
    
    % draw supercells
    for k = 1: length(cluster_idx)
        % draw cells
        plot(nuclei{cluster_idx(k)}(:,2), nuclei{cluster_idx(k)}(:,1), ... 
            'Color', cmap(clusetr_label, :), 'LineWidth', 3);
        % connect cells to center
        plot([cluster_coors(1,cc), data_pts(cluster_idx(k),1)], [cluster_coors(2,cc), data_pts(cluster_idx(k),2)], ...
            'Color', cmap(clusetr_label, :), 'LineWidth',3); 
    end
end
hold off;