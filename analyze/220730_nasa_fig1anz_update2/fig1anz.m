function fig1anz(DFMASTER, desired_ntwprop)


% initialize settings
desired_cogtest_list    = {'PVT', 'KDT', 'Math', 'GoNogo'};
desired_band_list       = {'delta', 'theta', 'alpha', 'beta'};
des_cogtest_numel       = numel(desired_cogtest_list);


% functions for reshaping data
getdfbl                     = @(X) X.mean_Y(X.run == 0 | X.condition == 'baseline') ;
getdfruns                   = @(X, r, cnd) X.mean_Y(X.run == r & X.condition == cnd);
getdfmat_bl_lightRuns       = @(X) [getdfbl(X), getdfruns(X,1,'light'), getdfruns(X,2,'light'), getdfruns(X,3,'light'), getdfruns(X,4,'light')];
getdfmat_bl_cntlRuns        = @(X) [getdfbl(X), getdfruns(X,1,'control'), getdfruns(X,2,'control'), getdfruns(X,3,'control'), getdfruns(X,4,'control')];



% init plots
F = figure('Position',get(0, 'ScreenSize'));
runnames = {'BL', 'T1', 'T2', 'T3','T4'};

% Create plots
for des_cogtest_idx = 1:des_cogtest_numel
    desired_cogtest     = desired_cogtest_list{des_cogtest_idx};
    desired_subjects    = suggestedsubject(desired_cogtest);
    
    for des_band_idx = 1:4 
        desired_band        = desired_band_list{des_band_idx}; 
        [df_groups, df] = dfgetsubset(DFMASTER,desired_subjects, desired_cogtest, desired_ntwprop, desired_band, "addgroupvars",{'run', 'band'});

        % Run ttests between BL and runs for each condition
        df_groups.sigdiff = nan(height(df_groups),1);
        
        dfmat_light = getdfmat_bl_lightRuns(df_groups);
        dfmat_cntl = getdfmat_bl_cntlRuns(df_groups);
        
        [~, P_light] =  testpairs(dfmat_light, 'paired');
        siggroups_light = P_light(2:end,1) < .05; 
        [~, P_cntl] =  testpairs(dfmat_cntl, 'paired');
        siggroups_cntl = P_cntl(2:end,1) < .05; 

        siggroups = [siggroups_cntl; siggroups_light];




        % EVERYTHING BELOW IS FOR PLOTTING
        plt_idx = 4 * (des_cogtest_idx -1)  + des_band_idx;
        ax_swarm = subplot(4, 4, plt_idx); hold on;

        b = boxchart(df_groups.run, df_groups.mean_Y, 'GroupByColor',df_groups.condition, 'MarkerStyle','+', 'MarkerSize',3);
        b(1).SeriesIndex = 5;

        b(2).WhiskerLineColor =b(2).BoxFaceColor;
        
        b(3).SeriesIndex= 1;
        b(3).WhiskerLineColor =b(3).BoxFaceColor;

        ax_swarm.XTick = ax_swarm.XTick +  b(2).BoxWidth/2;

        ax_swarm.XTickLabel = {[]};  
        ax_swarm.YLim = [min(df_groups.mean_Y), max(df_groups.mean_Y)];
        xlabel('')
        ylabel('')
        grid on
        
        axis tight
        
        
        if des_cogtest_idx == 1 && des_band_idx == 1
            ntwprop_str =  sprintf('%s', upper(desired_ntwprop));
            text(-1,1.1,ntwprop_str, 'units', 'normalized', 'HorizontalAlignment','left', 'VerticalAlignment','middle', 'FontSize',40, 'FontWeight','bold', 'Color','k', 'BackgroundColor','w')
        end

        if des_band_idx == 1
            cogtest_str =  sprintf('%s', upper(desired_cogtest));
            text(-.4,.5,cogtest_str, 'units', 'normalized', 'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontSize',20, 'FontWeight','bold','Color','k', 'BackgroundColor','w')
        end

        if des_cogtest_idx == 1 
            title(upper(desired_band), 'FontSize',18, 'Color','k', 'BackgroundColor','w') 

        elseif des_cogtest_idx == des_cogtest_numel
            axis on
            ax_swarm.XTick = [0 1 2 3 4];            
            ax_swarm.XTickLabel = runnames;     
            xlabel('Run (test bout)')
        end       

        

        % lets hardcode for specific cases
        if strcmp(desired_cogtest, 'PVT')
            if strcmpi(desired_ntwprop,'GPSD')
                ylim([1.5, 3])
            end

        end


        h = (min(ylim) + 0.05*range(ylim));
        h = (max(ylim) - 0.05*range(ylim));
        
        [ycntl, ylight] = deal(nan(4,1));

        ycntl(siggroups_cntl) = h;
        ylight(siggroups_light) = h;

        plotsiggroup = @(y, x, color ) scatter(x, y, '*', 'MarkeredgeColor',color, 'SizeData',85);
            
  
%         plotsiggroup(ycntl,1:4,b(2).BoxFaceColor); 
        plotsiggroup(ycntl,1:4,'r'); 
        
%         plotsiggroup(ylight,1.3:1:4.3,b(3).BoxFaceColor);
        plotsiggroup(ylight,1.3:1:4.3,'b');
        

        drawnow;
        figure(gcf)
    end
end
 legend({'baseline','control','light','sig effect of control', 'sig effect of light'}, 'Location','best', 'FontSize',6)

% add rectangles and move axis for more space in figure
for i = 1:length(F.Children)

% yl = F.Children(i).YLim;
% xl = F.Children(i).XLim;


F.Children(i).Units = "normalized";
F.Children(i).Position(1) = F.Children(i).Position(1)+.05;
end





end