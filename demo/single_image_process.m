clearvars;

% add nuclei segmentation package
addpath(genpath('../nuclei_seg'));

img_name = '205';
demo_img_path = fullfile('./Imgs', strcat(img_name, '.png'));
% read the image
I = imread(demo_img_path);
% crop the central part
I = I(251:750, 251:750, 1:end);
[I_norm, ~, ~] = normalizeStaining(I); 
I_normRed=I_norm(:,:,1);
p.scales=3:2:10; % the scale of nuclei
[nuclei, properties] = nucleiSegmentationV2(I_normRed, p);

