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
for rr=1:rand_times
    data_partition = cvpartition(labels,'KFold', 5); % Create a random partition for stratified 5-fold cross-validation.
    svm_cv_model = fitcecoc(all_feas, labels, 'CVPartition', data_partition, ...
        'Learners', templateSVM('Standardize',true), 'ClassNames', {'1','2','3'});
    svm_errs = kfoldLoss(svm_cv_model, 'mode','individual');
    svm_accs = 1.0 - svm_errs;
    cur_acc = mean(svm_accs);
    acc_rates(rr) = cur_acc;
end
disp(['The cross valiation mean acc: ', num2str(mean(acc_rates))]);
disp(['The cross valiation std acc: ', num2str(std(acc_rates))]);


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
