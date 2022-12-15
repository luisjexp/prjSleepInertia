clear;
DFM = dfmaster();  

clearvars -except DFM   


%%
% clustering of low frequency components changes only while engaging in
% pvt task, but not during other tasks. In contrast, clustering of high
% frequency bands changes only during the math task
close all
figanz_cogtestcmp(DFM, 'PVT', 'Math', 'clust', 'beta', 'control')
exportgraphics(gcf,'fig_clust_pvt_vs_math_beta_cntl.png','Resolution',100)


figanz_cogtestcmp(DFM, 'PVT', 'Math', 'clust', 'delta', 'control')
exportgraphics(gcf,'fig_clust_pvt_vs_math_delta_cntl.png','Resolution',100)



%%
figanz_cogtestcmp(DFM, 'PVT', 'Math', 'pathl', 'beta', 'control')
exportgraphics(gcf,'fig_pathl_pvt_vs_math_beta_cntl.png','Resolution',100)

figanz_cogtestcmp(DFM, 'PVT', 'Math', 'pathl', 'delta', 'control')
exportgraphics(gcf,'fig_pathl_pvt_vs_math_delta_cntl.png','Resolution',100)

%% Supplentary Figure: Plot figure 1 but for all tasks 
fig1anz(DFM, 'gpsd')
exportgraphics(gcf,'fig_fig1Original_gpsd.png','Resolution',100)

fig1anz(DFM, 'clust')
exportgraphics(gcf,'fig_fig1Original_clust.png','Resolution',100)

fig1anz(DFM, 'pathl')
exportgraphics(gcf,'fig_fig1Original_pathl.png','Resolution',100)
