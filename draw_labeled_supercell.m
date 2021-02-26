clearvars;

% test_type = 'CLL';
% test_name = '137';
% test_type = 'aCLL';
% test_name = '205';
test_type = 'RT';
test_name = '14';

fea_path = fullfile('./data', 'All', 'ImgCellFeas', test_type, strcat(test_name, '.mat'));
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
cell_clf_para_path = fullfile('./data', 'All', 'Models', 'cell_clf_para.mat');
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
supercell_clf_para_path = fullfile('./data', 'All', 'Models', 'supercell_clf_para.mat');
load(supercell_clf_para_path);


% visulize labeled supercell
% calualte the cluster centers
cell_coors = data_pts(:,1:2)';
cluster_coors = zeros(2, length(cluster_centers));
for i=1:size(cluster_coors, 2)
    cluster_coors(:,i) = mean(cell_coors(:, idx==i), 2);
end

imshow(I);
hold on;
cmap=[0 1 0; 1 0 0; 0 0 1;1 1 0; 1 0 1; 0 1 1; 1 1 1];
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
    polygon_supercell = convhull(cell_xs, cell_ys);
    polygon_mask = poly2mask(cell_xs(polygon_supercell), cell_ys(polygon_supercell), size(I,1), size(I,2));
    supercell_fea =regionprops('table',polygon_mask,im2gray(I),'Area','Perimeter','Circularity','Eccentricity','EquivDiameter',...
        'MajorAxisLength','MinorAxisLength','Orientation','Solidity','MeanIntensity');
    super_cell_feas(1, 23:32) = table2array(supercell_fea);    
    
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

fig_save_path = fullfile('./data', 'All', 'Demos', 'LabeledSuperCells', strcat(test_type, test_name, '.png'));
imwrite(getframe(gca).cdata, fig_save_path);
close all;
