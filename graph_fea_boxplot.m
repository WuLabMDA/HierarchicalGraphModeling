clearvars;

img_edge_fea_path = fullfile('./data', 'GlobalGraph', 'graph_fea.mat');
load(img_edge_fea_path, 'population_img_feas');

subtypes = {'CLL', 'aCLL', 'RT'};
figure('Renderer', 'painters', 'Position', [10 10 1500 600])
for ss = 1:length(subtypes)
    subplot(1,3,ss);
    feas = population_img_feas(ss).feas;
    ss_list = zeros(length(feas), 1);
    sl_list = zeros(length(feas), 1);
    ll_list = zeros(length(feas), 1);
    for ii=1:length(feas)
        ss_list(ii) = feas(ii).graph_feas(1);
        sl_list(ii) = feas(ii).graph_feas(2);
        ll_list(ii) = feas(ii).graph_feas(3);
    end
    
    boxplot([ss_list, sl_list, ll_list], ...,
        'Notch', 'on', 'Labels',{'SS', 'SL', 'LL'});
    ylim([0.0 1.0]);
    title(subtypes{ss});
end
suptitle('Edge Connection Ratio Boxplot');
fig_save_path = fullfile('./data', 'GlobalGraph', 'graph_feas.png');
imwrite(getframe(gcf).cdata, fig_save_path);
close all;