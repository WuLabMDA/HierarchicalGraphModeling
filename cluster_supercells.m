clearvars;
rng(123);

supercell_fea_path = fullfile('./data', 'ImgCellFeas', 'population_supercell.mat');
load(supercell_fea_path);
% Collect all CLL supercells
CLL_supercell_feas = population_supercell_feas(1).img_feas;
num_cll_imgs = length(CLL_supercell_feas);
cll_feas = cell(num_cll_imgs, 1);
for ii=1:num_cll_imgs
    cll_feas{ii} = CLL_supercell_feas(ii).supercell_feas;
end
cll_feas = cell2mat(cll_feas);
% Collect all aCLL supercells
aCLL_supercell_feas = population_supercell_feas(2).img_feas;
num_acll_imgs = length(aCLL_supercell_feas);
acll_feas = cell(num_acll_imgs, 1);
for ii=1:num_acll_imgs
    acll_feas{ii} = aCLL_supercell_feas(ii).supercell_feas;
end
acll_feas = cell2mat(acll_feas);
% Collect all RT supercells
RT_supercell_feas = population_supercell_feas(3).img_feas;
num_rt_imgs = length(RT_supercell_feas);
rt_feas = cell(num_rt_imgs, 1);
for ii=1:num_rt_imgs
    rt_feas{ii} = RT_supercell_feas(ii).supercell_feas;
end
rt_feas = cell2mat(rt_feas);
% merge CLL/aCLL/RT supercell featuers
all_supercell_feas = cat(1, cll_feas, acll_feas, rt_feas);

% perform t-sne
t_feas = tsne(all_supercell_feas, 'Perplexity', 1000, 'Standardize', true);
% scatter(t_feas(:, 1), t_feas(:, 2), 'filled');
% title('2D t-SNE Embedding');

% perform spectral clustering
[ids, ~, ~] = spectralcluster(t_feas, 2);
str_labels = cell(length(ids), 1);
for ii=1:length(ids)
    if ids(ii) == 1
        str_labels{ii} = 'Supercell C1';
    elseif ids(ii) == 2
        str_labels{ii} = 'Supercell C2';
    end
end

gscatter(t_feas(:, 1), t_feas(:, 2), str_labels, 'rg', '', [15, 15], 'off');
lg = legend(unique(char(str_labels),'rows'),'location','best','FontSize',20);
set(lg,'Box','off');
xlim([-3, 10]);
ylim([-10, -2]);

% save the supercell clustering 
cell_cluster_dir = fullfile('./data', 'Cluster');
if ~exist(cell_cluster_dir, 'dir')
    mkdir(cell_cluster_dir)
end  
fig_save_path = fullfile(cell_cluster_dir, 'supercell_cluster.png');
imwrite(getframe(gca).cdata, fig_save_path);
close all;
