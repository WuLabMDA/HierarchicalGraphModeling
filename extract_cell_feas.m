clearvars;
fea_root = fullfile('./data', 'ImgCellFeas');

subtypes = {'CLL', 'aCLL', 'RT'};
feature_names = {'Area','Perimeter','MajorAxisLength','EquivDiameter','IntegratedIntensity',...
    'MinorAxisLength','MeanOutsideBoundaryIntensity','NormalizedBoundarySaliency',...
    'NormalizedOutsideBoundaryIntensity','MeanInsideBoundaryIntensity'};

for ss = 1:length(subtypes)
    diag = subtypes{ss};
    disp(['Draw segmentation on ', diag]);
    cur_diag_fea = struct('name', 'fea');
    cur_diag_dir = fullfile(fea_root, diag);
    img_list = dir(fullfile(cur_diag_dir, '*.mat'));
    for ii = 1:length(img_list)
        [~, basename, ~] = fileparts(img_list(ii).name);
        cur_fea_path = fullfile(cur_diag_dir, img_list(ii).name);
        load(cur_fea_path, 'properties');
        cell_feas = zeros(length(feature_names), length(properties));
        for ff=1:length(feature_names)
            cell_feas(ff,:) = [properties.(feature_names{ff})];
        end
        cell_feas = cell_feas';
        cur_diag_fea(ii).name = basename;
        cur_diag_fea(ii).fea = cell_feas;
    end
    cur_diag_fea_path = fullfile(fea_root, strcat(diag, '.mat'));
    save(cur_diag_fea_path, 'cur_diag_fea');
end
        
    