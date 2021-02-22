clearvars;
fea_root = fullfile('./data', 'ImgCellFeas');

feature_names = {'Area','Perimeter','MajorAxisLength','EquivDiameter','IntegratedIntensity',...
    'MinorAxisLength','MeanOutsideBoundaryIntensity','NormalizedBoundarySaliency',...
    'NormalizedOutsideBoundaryIntensity','MeanInsideBoundaryIntensity'};

% load cell classifier paramters
cell_clf_para_path = fullfile('./data', 'Models', 'cell_clf_para.mat');
load(cell_clf_para_path);

population_supercell_feas = struct('diagnosis', 'img_feas');
subtypes = {'CLL', 'aCLL', 'RT'};
for ss = 1:length(subtypes)
    diag = subtypes{ss};
    disp(['Extract features from ', diag]);
    img_supercell_feas = struct('name', 'supercell_feas');
    cur_diag_dir = fullfile(fea_root, diag);
    img_list = dir(fullfile(cur_diag_dir, '*.mat'));
    for ii = 1:length(img_list)
        [~, basename, ~] = fileparts(img_list(ii).name);
        cur_fea_path = fullfile(cur_diag_dir, img_list(ii).name);
        load(cur_fea_path, 'properties');
        % obtain all cells' features 
        img_cell_feas = zeros(length(feature_names), length(properties));
        for ff=1:length(feature_names)
            img_cell_feas(ff,:) = [properties.(feature_names{ff})];
        end
        img_cell_feas = img_cell_feas';        
        % normalize data
        norm_fea = bsxfun(@minus, img_cell_feas, fea_mu);
        norm_fea = bsxfun(@rdivide, norm_fea, fea_sd);
        % label prediction
        labels = predict(cell_clf_model, norm_fea);
        % create cell features for graph construction
        data_pts = zeros(length(properties), 3);
        centroids = [properties.Centroid];
        data_pts(:,1) = centroids(1:2:end);
        data_pts(:,2) = centroids(2:2:end);
        data_pts(:,3) = labels;
        % graph construction
        [cluster_centers,idx,cluster2data]= ROC(data_pts, 0.9, 10);        
        % extract supercell features 
        super_cell_feas = zeros(32, 10);
        % TODO
        % save supercell features
        img_supercell_feas(ii).name = basename;
        img_supercell_feas(ii).supercell_feas = super_cell_feas;        
    end
    population_supercell_feas.diagnosis = diag;
    population_supercell_feas.img_feas = img_supercell_feas;
end
population_supercell_fea_path = fullfile('./data', 'ImgCellFeas', 'population_supercell.mat');
save(population_supercell_fea_path, 'population_supercell_feas');
    