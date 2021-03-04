clearvars;
rng('default');

method_name = 'FLocK';
fea_name = strcat('pool_', method_name, '_fea.mat');
fea_path = fullfile('./data', 'CmpGraphFeas', fea_name);
load(fea_path);

all_feas = pooldata;
labels = idx;

% perfrom 100 times randomization
rand_times = 100;
acc_rates = zeros(rand_times, 1);
auc_rates = zeros(rand_times, 1);
specificities = zeros(rand_times, 1);
sensitivities = zeros(rand_times, 1);
auc1_rates = zeros(rand_times, 1);
auc2_rates = zeros(rand_times, 1);
auc3_rates = zeros(rand_times, 1);
for rr=1:rand_times
    % Create a random partition for stratified 5-fold cross-validation.
    data_partition = cvpartition(labels,'KFold', 5); 
    svm_cv_model = fitcecoc(all_feas, labels, 'CVPartition', data_partition, ...
        'Learners', templateSVM('Standardize',true), 'ClassNames', {'1','2','3'});
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
    auc1_rates(rr) = auc1;
    auc2_rates(rr) = auc2;
    auc3_rates(rr) = auc3;    
end

disp(method_name);
disp([num2str(rand_times), ' Randomized CV  mean acc: ', num2str(mean(acc_rates))]);
disp([num2str(rand_times), ' Randomized CV   std acc: ', num2str(std(acc_rates))]);
disp([num2str(rand_times), ' Randomized CV mean auc1: ', num2str(mean(auc1_rates))]);
disp([num2str(rand_times), ' Randomized CV  std auc1: ', num2str(std(auc1_rates))]);
disp([num2str(rand_times), ' Randomized CV mean auc2: ', num2str(mean(auc2_rates))]);
disp([num2str(rand_times), ' Randomized CV  std auc2: ', num2str(std(auc2_rates))]);
disp([num2str(rand_times), ' Randomized CV mean auc3: ', num2str(mean(auc3_rates))]);
disp([num2str(rand_times), ' Randomized CV  std auc3: ', num2str(std(auc3_rates))]);