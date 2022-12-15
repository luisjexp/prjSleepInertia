function test_bank = fig1anz_updated4nasa(DFMASTER, desired_ntwprop)


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
runnames = {'BL', 'T1_c_n_t_l', 'T2_c_n_t_l', 'T3_c_n_t_l', 'T4_c_n_t_l', 'T1_i_n_t','T2_i_n_t','T3_i_n_t','T4_i_n_t'};

% Create plots
test_bank = cell(des_cogtest_numel,4);
for des_cogtest_idx = 1:des_cogtest_numel
    desired_cogtest     = desired_cogtest_list{des_cogtest_idx};
    desired_subjects    = suggestedsubject(desired_cogtest);
    
    for des_band_idx = 1:4 
        desired_band        = desired_band_list{des_band_idx}; 
        [df_groups, df] = dfgetsubset(DFMASTER,desired_subjects, desired_cogtest, desired_ntwprop, desired_band, "addgroupvars",{'run', 'band'});



        % PLOT
        plt_idx = 4 * (des_cogtest_idx -1)  + des_band_idx;
        ax_swarm = subplot(4, 4, plt_idx); hold on;
        scatt_plt = swarmchart(df,"rununique","Y", 'Marker','o', 'SizeData',.5, 'MarkerEdgeAlpha',0.2);
        scatt_plt.CData = df.sbj;
        
        
        scatt_plt = scatter(df_groups,"rununique", "mean_Y", 'Marker','diamond');
        scatt_plt.CData = df_groups.sbj;

        ax_swarm.XTick = 0:8;
        ax_swarm.XTickLabel = {[]};  
        xlabel('')
        ylabel('')
        grid on
        
        axis tight
        
        if strcmpi(desired_ntwprop ,'pathl')
            ylim([min(ylim) 1.2])
        end
        
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
            text(.125, 1.1, 'Control', 'Color','r', 'Units','normalized')
            text(.75, 1.1, 'Blue Light', 'Color','b', 'Units','normalized')
        elseif des_cogtest_idx == des_cogtest_numel
            axis on
            ax_swarm.XTickLabel = runnames;     
            xlabel('Run (test bout)')
        end       


        % Run ttests between BL and runs for each condition
        dfmat_light = getdfmat_bl_lightRuns(df_groups);
        dfmat_cntl = getdfmat_bl_cntlRuns(df_groups);
        dfmat4test =[dfmat_cntl, dfmat_light(:,2:end)];

        [~, P] = testpairs(dfmat4test, 'paired');
        test_bank{des_cogtest_idx, des_band_idx} = P;

        siggroups = P(:,1) < .05;
        
        siggroups_4plot = siggroups*(max(ylim) - 0.1*range(ylim));
        siggroups_4plot(siggroups_4plot==0)  = nan;
        scatter(0:8, siggroups_4plot, '*', 'MarkeredgeColor','r', 'SizeData',100);


        drawnow;
        figure(gcf)
    end
end


% add rectangles and move axis for more space in figure
for i = 1:length(F.Children)

yl = F.Children(i).YLim;
xl = F.Children(i).XLim;
rectangle(F.Children(i), 'Position',[min(xl) min(yl), .95 range(yl)], 'EdgeColor','black')
rectangle(F.Children(i), 'Position',[min(xl)+1.05 min(yl), 3.9, range(yl)], 'EdgeColor',[1 .2 0])
rectangle(F.Children(i), 'Position',[min(xl)+1.05+3.9+.05, min(yl), range(xl)-1.05-3.9-.05, range(yl)], 'EdgeColor','blue')


F.Children(i).Units = "normalized";
F.Children(i).Position(1) = F.Children(i).Position(1)+.05;
end





end