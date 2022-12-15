clear; cogtest = 'KDT';
gpsd    = getglobalpsd(cogtest);
[wpli,~,pathl,~,~,~,~, ~, clust] = getnetwork(cogtest);
sbj_idx = [1, 2, 3, 4, 5, 6, 8, 9, 10, 11]; % for KDT remove 7 , and note there is no subject 12


clearvars -except  gpsd wpli pathl clust sbj_idx


% there are only 11 subjects in the KDT data set

close all;
dv_names = {'gpsd', 'pathlength', 'clust'};
condition_names = {'light', 'control'}; 
band_names = {'delta', 'theta', 'alpha', 'beta'};
run_names = {'baseline', 'r1', 'r2', 'r3', 'r4'};

dflims = [];
for dv_idx = 1:numel(dv_names)
    dv_name= upper(dv_names{dv_idx});
    switch dv_name
        case 'GPSD'
            DV = gpsd;    
            [mn, mx] = cellfun(@(x) bounds(x(:)) , DV.psd_fsplit);            
            dvlim = [min(mn) max(mx)];

        case 'PATHLENGTH'
            DV = pathl;   
             [mn, mx] = cellfun(@(x) bounds(x(:)) , DV.raw_df);            
            dvlim = [min(mn) max(mx)];           
        case 'CLUST'
            DV = clust; 
            x = DV{:,{'delta','theta', 'alpha', 'beta'}};
            x = cellfun(@(x) mean(x), x, 'UniformOutput', false);
            DV.delta = cat(1,x{:,1});
            DV.theta = cat(1,x{:,2});
            DV.alpha = cat(1,x{:,3});
            DV.beta = cat(1,x{:,4});
            [mn, mx] = cellfun(@(x) bounds(x(:)) , DV.raw_df);            
            dvlim = [min(mn) max(mx)];
            
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
        figure('name', fig_name)  
        for band_idx = 1:4
            iw_band = band_names{band_idx};
        
            df = DV.(iw_band)(allcond_idx,sbj_idx)';
            [T, P, sigpairs] = testpairs(df);        
            
            axis_handle_boxes = subplot(3,4,band_idx);
            set(axis_handle_boxes, 'PositionConstraint', 'outerposition', 'Xtick', 1:5, 'XTickLabel', run_names)  


            boxplot(axis_handle_boxes, df)
            set(axis_handle_boxes, 'YLim', dvlim)            
            title(axis_handle_boxes, iw_band)
            ylabel(axis_handle_boxes, dv_name)
            ylim(axis_handle_boxes, dvlim)
            

            axis_handle_ttest = subplot(3,4,4+band_idx);  
            
            testpairs_plotsigpairs(T, run_names, sigpairs, axis_handle_ttest )

        end
        

    end

end










