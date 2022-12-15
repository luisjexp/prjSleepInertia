function T = fig2analysis(cogtest, dv_names, sbj2cut, opts) 
    arguments
        cogtest         % name of cognitive test, case sensitive: 
                        %   only 4 possible: 'PVT', 'KDT', 'Math', 'GoNogo'
                        %   must be a string
        dv_names        % names of dependent variables 
                        %   currently only accepts: 'gpsd', 'pathl', 'clust', 'betw', 'wpli';
                        %   must be cell, can be one DV or many eg {'gpsd', 'pathl'}     
        sbj2cut         % subject IDs that you want to remove from the analysis. 
                        %   All tests require this. some sbj data is just bad.
        opts.testtype        = 'paired' % independent or dependent sample ttest
        opts.printfigs       = false % true to print/save figures, false otherwise
    end
    gpsd    = getglobalpsd(cogtest);
    [wpli,betw,pathl,~,~,~,~, ~, clust] = getnetwork(cogtest);
    
    sbj_idx = 1:12;
    sbj_cut_str = strrep(num2str(sbj2cut), ' ', '_');
    sbj_idx(sbj2cut) = [];
    
    band_names = {'delta', 'theta', 'alpha', 'beta'};
    condition_names = {'baseline', 'controlR1', 'lightR1'};
    T = table;
    for dv_idx = 1:numel(dv_names)
        dv_name= upper(dv_names{dv_idx});
        switch dv_name
            case 'GPSD'
                DV = gpsd;    
            case 'PATHL'
                DV = pathl;   
            case 'CLUST'
                DV = clust; 
                x = DV{:,{'delta','theta', 'alpha', 'beta'}};
                x = cellfun(@(x) mean(x), x, 'UniformOutput', false);
                DV.delta = cat(1,x{:,1});
                DV.theta = cat(1,x{:,2});
                DV.alpha = cat(1,x{:,3});
                DV.beta = cat(1,x{:,4});
            case 'BETW'
                DV = betw; 
                x = DV{:,{'delta','theta', 'alpha', 'beta'}};
                x = cellfun(@(x) mean(x), x, 'UniformOutput', false);
                DV.delta = cat(1,x{:,1});
                DV.theta = cat(1,x{:,2});
                DV.alpha = cat(1,x{:,3});
                DV.beta = cat(1,x{:,4});
            case 'WPLI'
                error('this network property needs processing')
            case 'EFF'
                error('this netowrk prop needs to be processed')
                
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
                [tstat, P, sigpairs] = testpairs(df, opts.testtype);      
                
                axis_handle_boxes = subplot(3,4,band_idx);
                set(axis_handle_boxes,  'PositionConstraint', 'outerposition')  
    
    
                plot(df', 'Marker','o', 'LineStyle',':'); hold on;            
                boxplot(axis_handle_boxes, df); 
                title(axis_handle_boxes, iw_band)
                ylabel(axis_handle_boxes, dv_name)
                set(axis_handle_boxes, 'Xtick', 1:3, 'XTickLabel', condition_names)
    
                
                axis_handle_ttest = subplot(3,4,4+band_idx);  
                r = sigpairs(:,1);
                c = sigpairs(:,2);
                rcl = sub2ind(size(tstat), r,c);
                str = cellfun(@(x) sprintf('%.03f',x), num2cell(tstat(rcl)),    'UniformOutput',    false);
            
            
                set(axis_handle_ttest,'PositionConstraint', 'outerposition')               
                imagesc(axis_handle_ttest, tstat); hold on    
                text(axis_handle_ttest, r',c',str(:), 'color', 'r', 'FontSize',8)
                plot(axis_handle_ttest,r+.001, c+.001, 'r*', 'MarkerSize',3)
                title(axis_handle_ttest, 'T statistics')
                axis square
    
                set(axis_handle_ttest, 'Xtick', 1:3, 'XTickLabel', condition_names, 'Ytick', 1:3, 'YTickLabel', condition_names)
                
                T = [T; cell2table({{tstat}, {P}, {sigpairs}, dv_name, iw_band})];
              
            end
            if opts.printfigs
                saveas(F,sprintf('%s_fig2_anz_%ssbjcut_%s.jpg', cogtest, dv_name, sbj_cut_str));
                saveas(F,sprintf('%s_fig2_anz_%ssbjcut_%s.fig', cogtest, dv_name,sbj_cut_str));
            end
        
    
    end




T.Properties.VariableNames = {'tstat', 'pval', 'sigpairs', 'ntwprop','band'};









end