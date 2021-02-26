clearvars;

img_edge_fea_path = fullfile('./data', 'All', 'GlobalGraph', 'edge_connection_fea.mat');
load(img_edge_fea_path, 'population_img_feas');

subtypes = {'CLL', 'aCLL', 'RT'};
figure('Renderer', 'painters', 'Position', [10 10 1200 600])
for ss = 1:length(subtypes)
    subplot(1,3,ss);
    edge_feas = population_img_feas(ss).img_feas;
    ss_list = zeros(length(edge_feas), 1);
    sl_list = zeros(length(edge_feas), 1);
    ll_list = zeros(length(edge_feas), 1);
    for ii=1:length(edge_feas)
        ss_list(ii) = edge_feas(ii).edge_feas(1);
        sl_list(ii) = edge_feas(ii).edge_feas(2);
        ll_list(ii) = edge_feas(ii).edge_feas(3);
    end
    
    boxplot([ss_list, sl_list, ll_list], 'Notch', 'on', 'Labels',{'SS', 'SL', 'LL'});
    ylim([0.0 1.0]);
    title(subtypes{ss});
end
suptitle('Edge Connection Ratio Boxplot');
fig_save_path = fullfile('./data', 'All', 'Demos', 'EdgeFeas', 'edge_connection_ratios.png');
imwrite(getframe(gcf).cdata, fig_save_path);
close all;