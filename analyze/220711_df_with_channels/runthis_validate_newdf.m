% RunS the analysis using the new data frame, where each sample corresponds
% a channel of a particular subject. Goal is to to replicate the original
% analysis. To do this, I create the new data frame, and from it, retreive
% the subject's data by computing by averaging accross channels. It also
% works for path length and other variables where there is no data by
% channel (only a single nan value for channel). all we have too do is
% average accross channels. It produces the same results for all tests,
% network properties , conditions, subjects, and bands!!!
% this new data frame format is usefull to analyze channel by channel

fig1analysis_update_validation('clust', 'PVT', 'alpha')
fig1analysis_update_validation('pathl', 'Math', 'delta')
fig1analysis_update_validation('gpsd', 'KDT','theta')
fig1analysis_update_validation('clust', 'GoNogo','beta')
