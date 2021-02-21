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
%spectral-clustering to obtain labels;


[norm_data, fea_mu, fea_sd] = zscore(combine_data); 
% Build classification model
cell_clf_model = fitcensemble(norm_data, labels, 'Method', 'Bag');
% Save the cell 
save('cell_clf_para.mat', 'cell_clf_model', 'fea_mu', 'fea_sd');