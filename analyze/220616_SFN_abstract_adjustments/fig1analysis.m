function fig1analysis(cogtest, dv_names, sbj2cut, printfigs) 

gpsd    = getglobalpsd(cogtest);
[wpli,betw,pathl,~,~,~,~, ~, clust] = getnetwork(cogtest);

sbj_idx = 1:12;

sbj_cut_str = strrep(num2str(sbj2cut), ' ', '_');
sbj_idx(sbj2cut) = [];

close all;
condition_names = {'light', 'control'}; 
band_names = {'delta', 'theta', 'alpha', 'beta'};
run_names = {'baseline', 'r1', 'r2', 'r3', 'r4'};

for dv_idx = 1:numel(dv_names)
    dv_name= upper(dv_names{dv_idx});
    switch dv_name
        case 'GPSD'
            DV = gpsd;    

        case 'PATHL'
            DV = pathl;   
        case 'CLUST'
            DV = clust; 
            x = DV{:,band_names};
            x = cellfun(@(x) mean(x), x, 'UniformOutput', false);
            DV.delta = cat(1,x{:,1});
            DV.theta = cat(1,x{:,2});
            DV.alpha = cat(1,x{:,3});
            DV.beta = cat(1,x{:,4});
        case 'BETW'
            DV = betw; 
            x = DV{:,band_names};
            x = cellfun(@(x) mean(x), x, 'UniformOutput', false);
            DV.delta = cat(1,x{:,1});
            DV.theta = cat(1,x{:,2});
            DV.alpha = cat(1,x{:,3});
            DV.beta = cat(1,x{:,4});
        case 'WPLI'
            DV = wpli; 
            x = DV{:,band_names};
            x = cellfun(@(x) mean(x), x, 'UniformOutput', false);
            DV.delta = cat(1,x{:,1});
            DV.theta = cat(1,x{:,2});
            DV.alpha = cat(1,x{:,3});
            DV.beta = cat(1,x{:,4});
        otherwise
            error('dv name is incorrect')
            
    end


    for cond_idx = 1:2
        cnd_name = condition_names{cond_idx};
        bl_idx  = strcmp(DV.condition, 'baseline');
        r1_idx = strcmp(DV.condition, cnd_name) & DV.run == 1;
        r2_idx = strcmp(DV.condition, cnd_name) & DV.run == 2;
        r3_idx = strcmp(DV.condition, cnd_name) & DV.run == 3;
        r4_idx = strcmp(DV.condition, cnd_name) & DV.run == 4;
        allcond_idx = bl_idx | r1_idx | r2_idx | r3_idx | r4_idx;    
    
    
        fig_name = sprintf('FIGURE 1 Analysis | CogTest: %s | DV: %s| Condition: %s| sbjremoved: %s', cogtest, dv_name, cnd_name, sbj_cut_str);
        F = figure('name', fig_name, 'units', 'normalized','Position',[.1,.1,.9,.8])  ;
        for band_idx = 1:4
            iw_band = band_names{band_idx};
        
            df = DV.(iw_band)(allcond_idx,sbj_idx)';
            [T, P, sigpairs] = testpairs(df);        
            
            axis_handle_boxes = subplot(3,4,band_idx); hold on;
            set(axis_handle_boxes, 'PositionConstraint', 'outerposition')


            boxplot(axis_handle_boxes, df)
            title(axis_handle_boxes, iw_band)
            ylabel(axis_handle_boxes, dv_name)
            set(axis_handle_boxes, 'Xtick', 1:5, 'XTickLabel', run_names)  

            pmn = @(idx) mean(df(:,idx));
            plot(1:5, repmat( pmn(1),1,5 ), ':k', 2, pmn(2), '.g',3, pmn(3), '.g',4, pmn(4), '.g',5, pmn(5), '.g')
            axis tight

            axis_handle_ttest = subplot(3,4,4+band_idx);  
            
            testpairs_plotsigpairs(T, run_names, sigpairs, axis_handle_ttest )

        end
        
        if printfigs
            saveas(F,sprintf('%s_fig1_anz_%s_%s_sbjcut_%s.jpg', cogtest, dv_name, cnd_name, sbj_cut_str));
            saveas(F,sprintf('%s_fig1_anz_%s_%s_sbjcut_%s.fig', cogtest, dv_name, cnd_name,sbj_cut_str));
        end

    end

end













end