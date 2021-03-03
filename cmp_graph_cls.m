clearvars;
rng('default');

method_name = 'Global';
fea_name = strcat('pool_', method_name, '_fea.mat');
fea_path = fullfile('./data', 'CmpGraphFeas', fea_name);
load(fea_path);

all_feas = pooldata;
labels = idx;

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

disp(method_name);
disp(['The 100 randomized cross valiation         mean auc: ', num2str(mean(auc_rates))]);
disp(['The 100 randomized cross valiation          std auc: ', num2str(std(auc_rates))]);
disp(['The 100 randomized cross valiation         mean acc: ', num2str(mean(acc_rates))]);
disp(['The 100 randomized cross valiation          std acc: ', num2str(std(acc_rates))]);
% disp(['The 100 randomized cross valiation mean specificity: ', num2str(mean(specificities))]);
% disp(['The 100 randomized cross valiation  std specificity: ', num2str(std(specificities))]);
disp(['The 100 randomized cross valiation mean sensitivity: ', num2str(mean(sensitivities))]);
disp(['The 100 randomized cross valiation  std sensitivity: ', num2str(std(sensitivities))]);