clearvars;

% add nuclei segmentation package
addpath(genpath('../nuclei_seg'));

img_root = fullfile('./demo', 'Imgs');
overlay_root = fullfile('./demo', 'Overlays');
img_list = dir(fullfile(img_root, '*.png'));
for ii = 1:length(img_list)
    cur_img_path = fullfile(img_root, img_list(ii).name);
    [~, basename, ~] = fileparts(img_list(ii).name);
    I = imread(cur_img_path);
    I = I(351:650, 251:750, 1:end);
    raw_img_path = fullfile(overlay_root, strcat(basename, '_raw.png'));
    [I_norm, ~, ~] = normalizeStaining(I); 
    imwrite(I_norm, raw_img_path);
    I_normRed=I_norm(:,:,1);
    p.scales=3:2:10; % the scale of nuclei
    [nuclei, properties] = nucleiSegmentationV2(I_normRed, p); 
    
    imshow(I);
    hold on;
    for k = 1:length(nuclei)
        plot(nuclei{k}(:,2), nuclei{k}(:,1), 'r-', 'LineWidth', 1);
    end
    hold off;     
    
    overlay_img_path = fullfile(overlay_root, strcat(basename, '_cell.png'));
    imwrite(getframe(gca).cdata, overlay_img_path);
    close all;
end