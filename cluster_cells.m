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

% save the cell clustering 
cell_cluster_dir = fullfile('./data', 'Cluster');
if ~exist(cell_cluster_dir, 'dir')
    mkdir(cell_cluster_dir)
end  
fig_save_path = fullfile(cell_cluster_dir, 'cell_cluster.png');
imwrite(getframe(gca).cdata, fig_save_path);
close all;