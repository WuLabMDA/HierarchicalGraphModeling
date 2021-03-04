clearvars;

% add nuclei segmentation package
addpath(genpath('./nuclei_seg'));

img_root = fullfile('./data', 'LymphImgs');
fea_root = fullfile('./data', 'ImgCellFeas');
subtypes = {'CLL', 'aCLL', 'RT'};
for ss = 1:length(subtypes)
    diag = subtypes{ss};
    disp(['Extract ', diag]);
    cur_img_dir = fullfile(img_root, diag);
    cur_fea_dir = fullfile(fea_root, diag);
    if ~exist(cur_fea_dir, 'dir')
        mkdir(cur_fea_dir)
    end
    img_list = dir(fullfile(cur_img_dir, '*.png'));
    for ii = 1:length(img_list)
        disp([num2str(ii), '/', num2str(length(img_list))]);
        cur_img_path = fullfile(cur_img_dir, img_list(ii).name);
        I = imread(cur_img_path);
        [I_norm, ~, ~] = normalizeStaining(I);
        I_normRed=I_norm(:,:,1);
        p.scales=3:2:10; % the scale of nuclei
        [nuclei, properties] = nucleiSegmentationV2(I_normRed, p); 
        [~, basename, ~] = fileparts(img_list(ii).name);
        cur_fea_path = fullfile(cur_fea_dir, strcat(basename, '.mat'));
        save(cur_fea_path, 'I', 'nuclei', 'properties');
    end
end