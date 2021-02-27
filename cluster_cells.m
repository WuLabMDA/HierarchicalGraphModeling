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
gscatter(t_feas(:, 1), t_feas(:, 2), ids, 'rg', '', [15, 15]);
fig_save_path = fullfile('./data', 'Demos', 'Cluster', 'cell_cluster.png');
imwrite(getframe(gca).cdata, fig_save_path);
close all;