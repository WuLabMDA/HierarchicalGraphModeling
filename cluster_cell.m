clearvars;
rng(123)
fea_root = './data/ImgCellFeas';
chosen_num = 3000;

% feature fusing
fea_path = fullfile(fea_root, 'CLL.mat');
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
% perform spectral clustering to have 2 cluster
