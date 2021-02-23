clearvars;
rng(123)
fea_root = './data/ImgCellFeas';
chose_num = 3000;

% Fusing features from CLL/aCLL/RT
% select features from CLL
cll_fea_path = fullfile(fea_root, 'CLL.mat');
load(cll_fea_path);
num_cll_img = length(img_feas);
all_cll_feas = cell(num_cll_img,1);
for ii=1:num_cll_img
    all_cll_feas{ii} = img_feas(ii).fea;
end
all_cll_feas = cell2mat(all_cll_feas);
chose_cll_idx = randperm(size(all_cll_feas, 1), chose_num);
chose_cll_feas = all_cll_feas(chose_cll_idx, :);
clear img_feas all_cll_feas chose_cll_idx;
% select features from aCLL
acll_fea_path = fullfile(fea_root, 'aCLL.mat');
load(acll_fea_path);
num_acll_img = length(img_feas);
all_acll_feas = cell(num_acll_img,1);
for ii=1:num_acll_img
    all_acll_feas{ii} = img_feas(ii).fea;
end
all_acll_feas = cell2mat(all_acll_feas);
chose_acll_idx = randperm(size(all_acll_feas, 1), chose_num);
chose_acll_feas = all_acll_feas(chose_acll_idx, :);
clear img_feas all_acll_feas chose_acll_idx;

% select features from RT
rt_fea_path = fullfile(fea_root, 'RT.mat');
load(rt_fea_path);
num_rt_img = length(img_feas);
all_rt_feas = cell(num_rt_img,1);
for ii=1:num_rt_img
    all_rt_feas{ii} = img_feas(ii).fea;
end
all_rt_feas = cell2mat(all_rt_feas);
chose_rt_idx = randperm(size(all_rt_feas, 1), chose_num);
chose_rt_feas = all_rt_feas(chose_rt_idx, :);
clear img_feas all_rt_feas chose_rt_idx;

% combine data
combine_data = cat(1, chose_cll_feas, chose_acll_feas, chose_rt_feas);
%t-sne
t_feas = tsne(combine_data, 'Perplexity', 50, 'Standardize', true);
%spectral-clustering to obtain labels;
[labels, ~, ~] = spectralcluster(t_feas, 2);
% gscatter(t_feas(:, 1), t_feas(:, 2), labels, 'rg', '', [15, 15]);

id1_set = find(labels == 1);
id2_set = find(labels == 2);
id1_set_idx = randperm(size(id1_set, 1), 2100);
id2_set_idx = randperm(size(id2_set, 1), 900);
select_idx = cat(2, id1_set_idx, id2_set_idx);
select_combine_data = combine_data(select_idx, :);
select_labels = labels(select_idx, :);

[norm_data, cell_fea_mu, cell_fea_sd] = zscore(select_combine_data); 
% Build classification model
cell_clf_model = fitcensemble(norm_data, select_labels, 'Method', 'Bag');
% Save the cell 
cell_clf_para_path = fullfile('./data', 'Models', 'cell_clf_para.mat');
save(cell_clf_para_path, 'cell_clf_model', 'cell_fea_mu', 'cell_fea_sd');