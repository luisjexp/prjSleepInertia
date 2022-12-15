function [df, T, P, sigpairs] = anzfig1(cogtest, sbj_idx, dv_name, condition_name, band_name, varargin)


switch upper(dv_name)
    case 'GPSD'
        DV = getglobalpsd(cogtest);    
    case 'PATHLENGTH'
        [~,~,DV,~,~,~,~, ~, ~] = getnetwork(cogtest);        
    case 'CLUST'
        [~,~,~,~,~,~,~, ~, DV] = getnetwork(cogtest);                
        x = DV{:,{'delta','theta', 'alpha', 'beta'}};
        x = cellfun(@(x) mean(x), x, 'UniformOutput', false);
        DV.delta = cat(1,x{:,1});
        DV.theta = cat(1,x{:,2});
        DV.alpha = cat(1,x{:,3});
        DV.beta = cat(1,x{:,4});
    otherwise
        error('Unkown dependent variable')
end

bl_idx  = strcmp(DV.condition, 'baseline');
r1_idx = strcmp(DV.condition, condition_name) & DV.run == 1;
r2_idx = strcmp(DV.condition, condition_name) & DV.run == 2;
r3_idx = strcmp(DV.condition, condition_name) & DV.run == 3;
r4_idx = strcmp(DV.condition, condition_name) & DV.run == 4;
allcond_idx = bl_idx | r1_idx | r2_idx | r3_idx | r4_idx;    



df = DV.(band_name)(allcond_idx,sbj_idx)';
[T, P, sigpairs] = testpairs(df);        

if nargin ==6
    run_plots = varargin{1};
    if run_plots
        run_names = {'baseline', 'r1', 'r2', 'r3', 'r4'};
    
        info_str = sprintf('Fig 1 Analysis\n CogTest: %s\n n = %d\n DV: %s\n Condition: %s\n Band: %s', cogtest, numel(sbj_idx), dv_name, condition_name, band_name);
        
        figure;
    
        subplot(3,3,4)
        text(0,1,info_str, 'FontSize', 12, 'Units','normalized')
        axis off
    
        subplot(3,3,5)
        boxplot(df)
        set(gca, 'Xtick', 1:5, 'XTickLabel', run_names)  
        ylabel(dv_name)
        axis tight square
    
        subplot(3,3,6)
        testpairs_plotsigpairs(T, run_names, sigpairs)
    end
else
    disp('no plots were generated')
end

