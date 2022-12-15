%%
% load data frames
clear;clc;
cogtest = 'Math';
sbj_idx = [1:6, 8:11];
dv_name = 'GPSD';
condition_name = 'control';
band_name = 'theta';
run_plots = true;
[df, T, ~, sigpairs] = anzfig1(cogtest, sbj_idx, dv_name, condition_name, band_name, run_plots);



close all;
dv_names = {'gpsd', 'pathlength', 'clust'};
condition_names = {'light', 'control'}; 
band_names = {'delta', 'theta', 'alpha', 'beta'};
run_names = {'baseline', 'r1', 'r2', 'r3', 'r4'};
cogtest = 'KDT';
sbj_idx = [1:6, 8:11];


for dv_idx = 1:numel(dv_names)
    dv_name= upper(dv_names{dv_idx});

    for cond_idx = 1:2
        condition_name = condition_names{cond_idx};
        fig_name = sprintf('FIGURE 1 | DV: %s| Condition: %s', dv_name, cnd_name);
        figure      ('name', fig_name)  
        for band_idx = 1:4
            band_name = band_names{band_idx};
            [df, T, ~, sigpairs] = anzfig1(cogtest, sbj_idx, dv_name, condition_name, band_name);

            subplot(3,4,band_idx);  
            
            boxplot(df)
            title(band_name)
            set(gca, 'Xtick', 1:5, 'XTickLabel', run_names)  
            ylabel(dv_name)
            
            subplot(3,4,4+band_idx)
            testpairs_plotsigpairs(T, run_names, sigpairs)
            drawnow
            figure(gcf)
            
        end
        


    end

end




figure(gcf)

