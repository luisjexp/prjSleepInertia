function fig2analysis(cogtest, dv_names, sbj2cut, save_figs) 

gpsd    = getglobalpsd(cogtest);
[wpli,betw,pathl,~,~,~,~, ~, clust] = getnetwork(cogtest);

sbj_idx = 1:12;
sbj_cut_str = strrep(num2str(sbj2cut), ' ', '_');
sbj_idx(sbj2cut) = [];

close all;
band_names = {'delta', 'theta', 'alpha', 'beta'};
condition_names = {'baseline', 'controlR1', 'lightR1'};

for dv_idx = 1:numel(dv_names)
    dv_name= upper(dv_names{dv_idx});
    switch dv_name
        case 'GPSD'
            DV = gpsd;    
            [mn, mx] = cellfun(@(x) bounds(x(:)) , DV.psd_fsplit);            
            dvlim = [min(mn) max(mx)];
        case 'PATHL'
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
        case 'BETW'
            DV = betw; 
            x = DV{:,{'delta','theta', 'alpha', 'beta'}};
            x = cellfun(@(x) mean(x), x, 'UniformOutput', false);
            DV.delta = cat(1,x{:,1});
            DV.theta = cat(1,x{:,2});
            DV.alpha = cat(1,x{:,3});
            DV.beta = cat(1,x{:,4});
            [mn, mx] = cellfun(@(x) bounds(x(:)) , DV.raw_df);            
            dvlim = [min(mn) max(mx)];    
        case 'WPLI'
            DV = wpli; 
            x = DV{:,{'delta','theta', 'alpha', 'beta'}};
            x = cellfun(@(x) mean(x), x, 'UniformOutput', false);
            DV.delta = cat(1,x{:,1});
            DV.theta = cat(1,x{:,2});
            DV.alpha = cat(1,x{:,3});
            DV.beta = cat(1,x{:,4});
            [mn, mx] = cellfun(@(x) bounds(x(:)) , DV.raw_df);            
            dvlim = [min(mn) max(mx)];             
            
        otherwise
            error('dv name is incorrect')
            
    end


        bl_idx  = strcmp(DV.condition, 'baseline');
        light_r1_idx = strcmp(DV.condition, 'light') & DV.run == 1;
        cntl_r1_idx = strcmp(DV.condition, 'control') & DV.run == 1;
        allcond_idx = bl_idx | cntl_r1_idx | light_r1_idx   ;    
    
    
        fig_name = sprintf('FIGURE 2 Analysis | CogTest: %s | DV: %s| sbjremoved: %s', cogtest, dv_name, sbj_cut_str);
        F = figure('name', fig_name, 'units', 'normalized','Position',[.1,.1,.9,.8])  ;
        for band_idx = 1:4
            iw_band = band_names{band_idx};
        
            df = DV.(iw_band)(allcond_idx,sbj_idx)';
            [T, P, sigpairs] = testpairs(df);        
            
            axis_handle_boxes = subplot(3,4,band_idx);
            set(axis_handle_boxes,  'PositionConstraint', 'outerposition')  


            plot(df', 'Marker','o', 'LineStyle',':'); hold on;            
            boxplot(axis_handle_boxes, df); 
%             set(axis_handle_boxes, 'YLim', dvlim)            
            title(axis_handle_boxes, iw_band)
            ylabel(axis_handle_boxes, dv_name)
%             ylim(axis_handle_boxes, dvlim)
            set(axis_handle_boxes, 'Xtick', 1:3, 'XTickLabel', condition_names)

            
            axis_handle_ttest = subplot(3,4,4+band_idx);  

            r = sigpairs(:,1);
            c = sigpairs(:,2);
            rcl = sub2ind(size(T), r,c);
            str = cellfun(@(x) sprintf('%.03f',x), num2cell(T(rcl)),    'UniformOutput',    false);
        
        
            set(axis_handle_ttest,'PositionConstraint', 'outerposition')               
            imagesc(axis_handle_ttest, T); hold on    
            text(axis_handle_ttest, r',c',str(:), 'color', 'r', 'FontSize',8)
            plot(axis_handle_ttest,r+.001, c+.001, 'r*', 'MarkerSize',3)
            title(axis_handle_ttest, 'T statistics')
            axis square

            set(axis_handle_ttest, 'Xtick', 1:3, 'XTickLabel', condition_names, 'Ytick', 1:3, 'YTickLabel', condition_names)
            
        end
        if save_figs
            saveas(F,sprintf('%s_fig2_anz_%ssbjcut_%s.jpg', cogtest, dv_name, sbj_cut_str));
            saveas(F,sprintf('%s_fig2_anz_%ssbjcut_%s.fig', cogtest, dv_name,sbj_cut_str));
        end
    

end













end