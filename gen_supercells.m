clearvars;

% test_type = 'CLL';
% test_name = '137';
% test_type = 'aCLL';
% test_name = '52';
test_type = 'RT';
test_name = '14';

fea_path = fullfile('./data', 'ImgCellFeas', test_type, strcat(test_name, '.mat'));
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

% show the nuclei clouds
imshow(I);
hold on;
% calualte the cluster centers
cell_coors = data_pts(:,1:2)';
cluster_coors = zeros(2, length(cluster_centers));
for i=1:size(cluster_coors, 2)
    cluster_coors(:,i) = mean(cell_coors(:, idx==i), 2);
end

cmap=[0 1 0; 1 0 0; 0 0 1;1 1 0; 1 0 1; 0 1 1; 1 1 1];
num_cells = size(cell_coors, 2);
for k = 1 : num_cells
    % draw all the cells
    plot(nuclei{k}(:,2), nuclei{k}(:,1), ... 
        'Color', cmap(mod(idx(k),size(cmap,1))+1,:), 'LineWidth', 3);
    %draw the clusters
    plot([cluster_coors(1,idx(k)), cell_coors(1,k)], [cluster_coors(2,idx(k)), cell_coors(2,k)], ...
        'Color', cmap(mod(idx(k), size(cmap,1))+1,:), 'LineWidth',3); 
end
hold off;

fig_save_path = fullfile('./data', 'Demos', 'SuperCells', strcat(test_type, test_name, '.png'));
saveas(gcf, fig_save_path);
close all;