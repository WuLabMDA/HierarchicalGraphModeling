clearvars;
rng('default');

img_edge_fea_path = fullfile('./data', 'GlobalGraph', 'graph_fea.mat');
load(img_edge_fea_path, 'population_img_feas');

test_ratio = 0.2;
graph_fea_num = 4;
num_boot_strap = 100;

cll_feas = zeros(length(population_img_feas(1).feas), graph_fea_num);
for ff=1:length(cll_feas)
    cll_feas(ff, :) = population_img_feas(1).feas(ff).graph_feas(1:graph_fea_num);
end
acll_feas = zeros(length(population_img_feas(2).feas), graph_fea_num);
for ff=1:length(acll_feas)
    acll_feas(ff, :) = population_img_feas(2).feas(ff).graph_feas(1:graph_fea_num);
end
rt_feas = zeros(length(population_img_feas(3).feas), graph_fea_num);
for ff=1:length(rt_feas)
    rt_feas(ff, :) = population_img_feas(3).feas(ff).graph_feas(1:graph_fea_num);
end

train_acc_list = zeros(num_boot_strap, 1);
test_acc_list = zeros(num_boot_strap, 1);
for bb = 1:num_boot_strap
    cll_labels = ones(length(cll_feas), 1);
    cll_cv = cvpartition(size(cll_feas,1),'HoldOut', test_ratio);
    idx = cll_cv.test;
    cll_train_feas = cll_feas(~idx, :);
    cll_train_labels = cll_labels(~idx, :);
    cll_test_feas = cll_feas(idx, :);
    cll_test_labels = cll_labels(idx, :);

    acll_labels = ones(size(acll_feas, 1), 1) * 2;
    acll_cv = cvpartition(size(acll_feas,1),'HoldOut', test_ratio);
    idx = acll_cv.test;
    acll_train_feas = acll_feas(~idx, :);
    acll_train_labels = acll_labels(~idx, :);
    acll_test_feas = acll_feas(idx, :);
    acll_test_labels = acll_labels(idx, :);

    rt_labels = ones(size(rt_feas, 1), 1) * 3;
    rt_cv = cvpartition(size(rt_feas,1),'HoldOut', test_ratio);
    idx = rt_cv.test;
    rt_train_feas = rt_feas(~idx, :);
    rt_train_labels = rt_labels(~idx, :);
    rt_test_feas = rt_feas(idx, :);
    rt_test_labels = rt_labels(idx, :);

    train_feas = [cll_train_feas; acll_train_feas; rt_train_feas];
    train_labels = [cll_train_labels; acll_train_labels; rt_train_labels];
    test_feas = [cll_test_feas; acll_test_feas; rt_test_feas];
    test_labels = [cll_test_labels; acll_test_labels; rt_test_labels];
    
    % build classifier
    % Bootstrap Aggregation (Bagging) 
    % img_clf_model = fitcensemble(train_feas, train_labels, 'Method', 'Bag');
    % Fit multiclass models for support vector machines
    img_clf_model = fitcecoc(train_feas, train_labels);
    % Fit discriminant analysis classifier
    % img_clf_model = fitcdiscr(train_feas, train_labels);

    % evaluate on the train
    pred_labels = predict(img_clf_model, train_feas);
    train_conf_mat = confusionmat(train_labels, pred_labels);
    train_acc = trace(train_conf_mat) / sum(train_conf_mat, 'all');
    disp(['Train acc: ', num2str(train_acc)]);
    train_acc_list(bb) = train_acc;
        
    % evaluate on the test
    pred_labels = predict(img_clf_model, test_feas);
    test_conf_mat = confusionmat(test_labels, pred_labels);
    test_acc = trace(test_conf_mat) / sum(test_conf_mat, 'all');
    disp(['Test acc: ', num2str(test_acc)]);
    test_acc_list(bb) = test_acc;
end

disp(['Mean train acc is: ', num2str(mean(train_acc_list)), '+', ...
    num2str(std(train_acc_list))]);
disp(['Mean test acc is: ', num2str(mean(test_acc_list)), '+', ...
    num2str(std(test_acc_list))]);
