clearvars;
rng('default');
img_edge_fea_path = fullfile('./data', 'GlobalGraph', 'graph_fea.mat');
load(img_edge_fea_path, 'population_img_feas');
fea_num = 15;
cll_graph_info = population_img_feas(1).feas;
acll_graph_info = population_img_feas(2).feas;
rt_graph_info = population_img_feas(3).feas;
cll_graph_feas = zeros(20, fea_num);
acll_graph_feas = zeros(20, fea_num);
rt_graph_feas = zeros(20, fea_num);
for ii = 1:20
    cll_graph_feas(ii, :) = cll_graph_info(ii).graph_feas;
    acll_graph_feas(ii, :) = acll_graph_info(ii).graph_feas;
    rt_graph_feas(ii, :) = rt_graph_info(ii).graph_feas;
end
labels = zeros(60, 1);
labels(1:20) = 1;
labels(21:40) = 2;
labels(41:60) = 3;
all_feas = zeros(60, fea_num);
all_feas(1:20, :) = cll_graph_feas;
all_feas(21:40, :) = acll_graph_feas;
all_feas(41:60, :) = rt_graph_feas;

rand_times = 100;
acc_rates = zeros(rand_times, 1);
auc_rates = zeros(rand_times, 1);
specificities = zeros(rand_times, 1);
sensitivities = zeros(rand_times, 1);
for rr=1:rand_times
    data_partition = cvpartition(labels,'KFold', 5); % Create a random partition for stratified 5-fold cross-validation.
    svm_cv_model = fitcecoc(all_feas, labels, 'CVPartition', data_partition, ...
        'Learners', templateSVM('Standardize',true), 'ClassNames', {'1','2','3'});
    % svm_errs = kfoldLoss(svm_cv_model, 'mode','individual');
    svm_errs = kfoldLoss(svm_cv_model, 'mode','average');
    svm_accs = 1.0 - svm_errs;
    cur_acc = mean(svm_accs);
    acc_rates(rr) = cur_acc;
    
    [~, posterior] = kfoldPredict(svm_cv_model);
    [fpr1,tpr1,~,auc1] = perfcurve(labels, posterior(:,1), svm_cv_model.ClassNames(1));
    [fpr2,tpr2,~,auc2] = perfcurve(labels, posterior(:,2), svm_cv_model.ClassNames(2));
    [fpr3,tpr3,~,auc3] = perfcurve(labels, posterior(:,3), svm_cv_model.ClassNames(3));
    cur_auc = (auc1 + auc2 + auc3) / 3.0;
    auc_rates(rr) = cur_auc;
    mid_ind1 = ceil(length(fpr1)/2);
    mid_ind2 = ceil(length(fpr2)/2);
    mid_ind3 = ceil(length(fpr2)/3);
    cur_specificity = 1.0 - (fpr1(mid_ind1) + fpr2(mid_ind2) + fpr3(mid_ind3)) / 3.0;
    specificities(rr) = cur_specificity;
    cur_sensitivity = (tpr1(mid_ind1) + tpr2(mid_ind2) + tpr3(mid_ind3)) / 3.0;
    sensitivities(rr) = cur_sensitivity;
end
disp(['The 100 randomized cross valiation         mean auc: ', num2str(mean(auc_rates))]);
disp(['The 100 randomized cross valiation          std auc: ', num2str(std(auc_rates))]);
disp(['The 100 randomized cross valiation         mean acc: ', num2str(mean(acc_rates))]);
disp(['The 100 randomized cross valiation          std acc: ', num2str(std(acc_rates))]);
disp(['The 100 randomized cross valiation mean specificity: ', num2str(mean(specificities))]);
disp(['The 100 randomized cross valiation  std specificity: ', num2str(std(specificities))]);
disp(['The 100 randomized cross valiation mean sensitivity: ', num2str(mean(sensitivities))]);
disp(['The 100 randomized cross valiation  std sensitivity: ', num2str(std(sensitivities))]);


%% Cell Voronoi
%% Cell Flock-Centroid
%% Cell Flock-AreaIntensity

% %% Supercell Delaynay
% The cross valiation mean acc: 0.83333
% The cross valiation std acc: 0.058926
% %% Voronoi
% The cross valiation mean acc: 0.78333
% The cross valiation std acc: 0.095015
% %% Delaynay + Voronoi
% The cross valiation mean acc: 0.86667
% The cross valiation std acc: 0.045644
