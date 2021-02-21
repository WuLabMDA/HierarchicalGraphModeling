clearvars;
figure('visible', 'off')

% set folders
img_root = fullfile('./data', 'LymphImgs');
fea_root = fullfile('./data', 'ImgCellFeas');
overlay_root = fullfile('./data', 'CellOverlay');
subtypes = {'CLL', 'aCLL', 'RT'};

for ss = 1:length(subtypes)
    diag = subtypes{ss};
    disp(['Draw segmentation on ', diag]);
    cur_img_dir = fullfile(img_root, diag);
    cur_fea_dir = fullfile(fea_root, diag);
    img_list = dir(fullfile(cur_img_dir, '*.png'));
    for ii = 1:length(img_list)
            1q  adisp([num2str(ii), '/', num2str(length(img_list))]);
        cur_img_path = fullfile(cur_img_dir, img_list(ii).name);
        I = imread(cur_img_path);
        [~, basename, ~] = fileparts(img_list(ii).name);
        cur_fea_path = fullfile(cur_fea_dir, strcat(basename, '.mat'));
        load(cur_fea_path, 'nuclei');
        % draw cells
        imshow(I);
        hold on;
        for k = 1:length(nuclei)
            plot(nuclei{k}(:,2), nuclei{k}(:,1), 'r-', 'LineWidth', 1);
        end
        hold off;     
        overlay_img_path = fullfile(overlay_root, diag, strcat(basename, '.png'));
        imwrite(getframe(gca).cdata, overlay_img_path);
    end
end