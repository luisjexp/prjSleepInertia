function figanz_cogtestcmp(DFMASTER, desired_cogtest_I, desired_cogtest_J, desired_ntwprop , desired_band, desired_condition, opts)
    arguments
        DFMASTER
        desired_cogtest_I
        desired_cogtest_J
        desired_ntwprop
        desired_band
        desired_condition
        opts.usecommonsubjects = false % still building
    end
    
    % #############################################
    % GET DATA
    [df_I_bl_cntl_groups, sigruns_cogtest_I] = getgroupdf(desired_cogtest_I, desired_condition);
    [df_J_bl_cntl_groups, sigruns_cogtest_J] = getgroupdf(desired_cogtest_J, desired_condition);
    
    % #############################################
    % PLOT
    figure('Position',get(0, 'ScreenSize')/3.5 + 100);
    ax_handle = subplot(1,1,1);
    hold on;    
   
    plotcogtest(df_I_bl_cntl_groups, sigruns_cogtest_I, -0.1, 4, ax_handle);
    plotcogtest(df_J_bl_cntl_groups, sigruns_cogtest_J, 0.1, 2, ax_handle);
    
    ax_handle.XTick         = (0:4);
    ax_handle.XTickLabel    = {'BaseLine', 'T1', 'T2', 'T3','T4'}  ;
    ax_handle.YLabel.String = desired_ntwprop;
    ax_handle.Color = .8*[1 1 1];
    ax_legend = legend(ax_handle,{desired_cogtest_I, sprintf('significant test bout during %s', desired_cogtest_I), desired_cogtest_J, sprintf('significant test bout during %s', desired_cogtest_J)}) ;   
    ax_legend.Location = 'best';
    title_str = sprintf('Comparing %s in the %s band during %s and %s\n during the %s condition',...
        upper(desired_ntwprop), upper(desired_band), upper(desired_cogtest_I), upper(desired_cogtest_J), upper(desired_condition));
    title(title_str);
%     figure(gcf);
    
    % #############################################
    % FUNCTION TO GET DATA
    function [df_bl_cntl_groups, sigruns_cogtest] = getgroupdf(desired_cogtest, desired_condition)
        % more functions to get subset of data
        getdfcntl      = @(df) df(df.condition == 'baseline' | df.condition == desired_condition,:);
        getYbl         = @(df) df.mean_Y(df.run == 0 | df.condition == 'baseline') ;
        getYrun        = @(df, run) df.mean_Y(df.run == run & df.condition == desired_condition);
        getYforTest    = @(df) [getYbl(df), getYrun(df,1), getYrun(df,2), getYrun(df,3), getYrun(df,4)];
        
        df_groups               = dfgetsubset(DFMASTER, suggestedsubject(desired_cogtest), desired_cogtest, desired_ntwprop, desired_band, "addgroupvars",{'run', 'band'});
        df_bl_cntl_groups       = getdfcntl(df_groups);
        [~,P]                   = testpairs(getYforTest(df_bl_cntl_groups), 'paired');
        sigruns_cogtest = find( P(2:end,1) <= .05 );
    end


    % #############################################
    % FUNCTION TO PLOT DATA
    function plotcogtest(df, sigruns_cogtest, shift, color_style, ax_handle)
        plotbox         = @(df,clr) boxchart(ax_handle, df.run, df.mean_Y, 'BoxWidth',.1, 'MarkerStyle','+',  'MarkerSize',3, 'SeriesIndex',clr);
        pltshiftrunbox  = @(bx, shift)   set(bx, 'XData', bx.XData+shift );
        plotsiggroupstar= @(y,color, shift ) scatter(ax_handle, (1:4)+shift, y, '*','MarkeredgeColor',color, 'SizeData',400);
        
        % PLOT AND POSITION BOX CHARTS    
        ax_bx = plotbox(df, color_style); 
        pltshiftrunbox(ax_bx, shift);    

        % STAR GROUPS SIGNIFICANTLY DIFFERENT FROM THEIR BASELIN
        y = nan(4,1);
        y(sigruns_cogtest) = max(ylim) - 0.3*range(ylim);
        plotsiggroupstar(y,ax_bx.BoxFaceColor, shift);
        
    end

end

