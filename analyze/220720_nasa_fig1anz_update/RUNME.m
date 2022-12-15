% WARNING THE INTERPRETATIONS BELOW ARE WRONG
% RUN THE FIGURES AND YOULL SEE
clear;
DFMASTER = dfmaster();  

clearvars -except DFMASTER   
% CREATE 3 FIGURES, similar to figure 1 in original paper
% but this time, we will run the analysis for all cognitive tasks,
% including KDT, Math and GoNogo.
%
% Will be used for nasa presentation

% this is different from the previous figure 1 analysis subproject used to
% create sfn abstract. 

% - much cleaner code, using newdata frame 
% - prettier figures
% - plenty of descriptions about conditions
% - compacted data: both light and controls runs are shown for each band
%       and task in one figure
% - interpretable: signigicant effects are marked, 
% - comparisons are only drawn between baseline and runs (never between
%   runs)



%-- GPSD ~ Task + condition bands and runs
test_bank = fig1anz_updated4nasa(DFMASTER, 'gpsd');

%-- CLUSTERING ~ Task + condition bands and runs
test_bank = fig1anz_updated4nasa(DFMASTER, 'clust');

%-- PATHLENGTH ~ Task + condition bands and runs
test_bank = fig1anz_updated4nasa(DFMASTER, 'pathl');


