clearvars;
rng(123);
fea_root = './data/ImgCellFeas';
chosen_num = 3000;

% feature fusing
fea_path = fullfile(fea_root, 'RT.mat');
load(fea_path);

num_img = length(img_feas);
all_feas = cell(num_img,1);
for ii=1:num_img
    all_feas{ii} = img_feas(ii).fea;
end
all_feas = cell2mat(all_feas);
chosen_idx = randperm(size(all_feas, 1), chosen_num);
chosen_feas = all_feas(chosen_idx, :);

% perform t-sne
t_feas = tsne(chosen_feas, 'Perplexity', 100, 'Standardize', true);
% scatter(t_feas(:, 1), t_feas(:, 2), 'filled');
% title('2D t-SNE Embedding');

% perform spectral clustering to have 2 cluster

[ids, ~, ~] = spectralcluster(t_feas, 2);


% cell_clf_para_path = fullfile('./data', 'Models', 'cell_clf_para.mat');
% load(cell_clf_para_path, 'cell_fea_mu', 'cell_fea_sd');
% norm_fea = bsxfun(@minus, chosen_feas, cell_fea_mu);
% norm_fea = bsxfun(@rdivide, norm_fea, cell_fea_sd);
% num_fea = 6;
% fea_s1 = norm_fea(ids==1, 1:num_fea);
% fea_s2 = norm_fea(ids==2, 1:num_fea);
% fea_data = cell(num_fea, 2);
% for ii=1:size(fea_data, 1)
%     s1{ii} = fea_s1(:, ii);
%     s2{ii} = fea_s2(:, ii);
% end
% fea_data = vertcat(s1, s2);
% feature_names = {'Area','Perimeter','MajorAxisLength','EquivDiameter','IntegratedIntensity',...
%     'MinorAxisLength','MeanOutsideBoundaryIntensity','NormalizedBoundarySaliency',...
%     'NormalizedOutsideBoundaryIntensity','MeanInsideBoundaryIntensity'};
% feature_names = feature_names(1:num_fea);
% multiple_boxplot(fea_data', feature_names, {'Cell l1', 'Cell T2'})

str_labels = cell(length(ids), 1);
for ii=1:length(ids)
    if ids(ii) == 1
        str_labels{ii} = 'Cell l1';
    elseif ids(ii) == 2
        str_labels{ii} = 'Cell l2';
    end
end
gscatter(t_feas(:, 2), t_feas(:, 1), str_labels, 'rg', '', [15, 15], 'off');
lg = legend(unique(char(str_labels),'rows'),'location','northwest','FontSize',20);
set(lg,'Box','off');
xlim([-20, 16]);
fig_save_path = fullfile('./data', 'Demos', 'Cluster', 'cell_cluster.png');
imwrite(getframe(gca).cdata, fig_save_path);
close all;