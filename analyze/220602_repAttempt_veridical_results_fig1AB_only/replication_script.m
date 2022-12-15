% load data frames
gpsd    = getglobalpsd('PVT');
[wpli,~,pathl,~,~,~,~, ~] = getnetwork('PVT');
%% TRY REPLICATING TESTS FROM
% FIGURE 1A (GLOBAL PSD) AND FIGB(PATHLENGTH)
% FROM MAIN (CONTROL) AND SUPPLEMENTAL(LIGHT)
clearvars -except  band_names gpsd pathl wpli strg modul

ttest_veridical_ = ones;

sbj_idx = [1:7, 9:12]; % 8 needs to be skipped, must the reason why they only have 11 subjects
close all;
dv_names = {'gpsd', 'pathlength'};
condition_names = {'light', 'control'}; % light figures are in supplemental
band_names = {'delta', 'theta', 'alpha', 'beta'};

run_names = {'baseline', 'r1', 'r2', 'r3', 'r4'};


for dv_idx = 1:numel(dv_names)
    dv_name= upper(dv_names{dv_idx});
    switch dv_name
        case 'GPSD'
            DV = gpsd;    
            fig_name = ''; 
        case 'PATHLENGTH'
            DV = pathl;    
    end


    for cond_idx = 1:2
        cnd_name = condition_names{cond_idx};
        bl_idx  = strcmp(DV.condition, 'baseline');
        r1_idx = strcmp(DV.condition, cnd_name) & DV.run == 1;
        r2_idx = strcmp(DV.condition, cnd_name) & DV.run == 2;
        r3_idx = strcmp(DV.condition, cnd_name) & DV.run == 3;
        r4_idx = strcmp(DV.condition, cnd_name) & DV.run == 4;
        allcond_idx = bl_idx | r1_idx | r2_idx | r3_idx | r4_idx;    
    
    
        fig_name = sprintf('FIGURE 1 | DV: %s|Condition: %s', dv_name, cnd_name);
        figure      ('name', fig_name)  
        for band_idx = 1:4
            iw_band = band_names{band_idx};

        
            % get the gpsd of a frequency band from all 4 runs
        
            df = DV.(iw_band)(allcond_idx,sbj_idx)';
            subplot(3,4,band_idx);    
            [T, P, sigpairs] = testpairs(df);        
        
        
            boxplot(df)
            title(iw_band)
            set(gca, 'Xtick', 1:5, 'XTickLabel', run_names)  
            ylabel(dv_name)
            
            subplot(3,4,4+band_idx)
            testpairs_plotsigpairs(T, run_names, sigpairs)
        end
        
        subplot(3,3,8)
        get_veridical_figures(dv_name, cnd_name)        

        figure(gcf)

    end

end

