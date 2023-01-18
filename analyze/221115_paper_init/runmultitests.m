function [res_str,res_summ_str,res_num] = runmultitests(df,ntwprop, opts)
    arguments
        df; 
        ntwprop
        opts.printAllResults = 'on'
        opts.printSummResults = 'off'
        opts.printSummDF = 'off';
        opts.plotHist = 'off'
        opts.plotAvovaTbl = 'off'
        opts.compareconditions = false;
    end
    
    % Validate
    % All three conditions must be present in the data set
    if all(ismember({'baseline','control','light'},df.condition))
        bl      = df.(ntwprop)( df.condition == "baseline");
        cntl    = df.(ntwprop)( df.condition == "control");
        light   = df.(ntwprop)( df.condition == "light");
        bl_vs_cntl = df( ismember(df.condition , {'baseline', 'control'}),:);
        bl_vs_light = df( ismember(df.condition , {'baseline', 'light'}),:);        
    else
        error('HEY LUIS!!: to run your distribution tests, the data frames must have samples from each of the three conditions');

    end


    [res_str_cntl, res_summ_str_cntl,control_ranktest_p, control_ttest_p, control_signranktest_p] = runalltests(bl,cntl,bl_vs_cntl,ntwprop,'plotAvovaTbl',opts.plotAvovaTbl,'Xname','BL','Yname','CTRL') ;
    [res_str_light, res_summ_str_light,light_ranktest_p, light_ttest_p, light_signranktest_p] = runalltests(bl,light,bl_vs_light,ntwprop,'plotAvovaTbl', opts.plotAvovaTbl,'Xname','BL','Yname','LIGHT') ;
    
    res_num.control.ranktest_p = control_ranktest_p;
    res_num.control.ttest_p = control_ttest_p;
    res_num.control.signranktest_p = control_signranktest_p;
    
    res_num.light.ranktest_p = light_ranktest_p;
    res_num.light.ttest_p = light_ttest_p;
    res_num.light.signranktest_p = light_signranktest_p;
    

    res_str = sprintf('BL vs CTRL | %s\nBL vs LIGHT | %s\n',res_str_cntl,res_str_light);
    res_summ_str = sprintf('BL vs CTRL:%s\nBL vs LIGHT:%s\n',res_summ_str_cntl,res_summ_str_light);

    if opts.compareconditions
        ctrl_vs_light = df( ismember(df.condition , {'control', 'light'}),:);        
        [res_str_cnd, res_summ_str_cnd,cnd_ranktest_p, cnd_ttest_p] = runalltests(cntl,light,ctrl_vs_light,ntwprop,'plotAvovaTbl', opts.plotAvovaTbl,'Xname','CTRL','Yname','LIGHT') ;
        res_num.controlVslight.cnd_ranktest_p = cnd_ranktest_p;
        res_num.controlVslight.ttest_p = cnd_ttest_p;

        res_str = sprintf('BL vs CTRL | %s\nBL vs LIGHT | %s\nCTRL vs LIGHT | %s\n',res_str_cntl,res_str_light,res_str_cnd);
        res_summ_str = sprintf('BL vs CTRL:%s\nBL vs LIGHT:%s\nCTRL vs LIGHT:%s\n',res_summ_str_cntl,res_summ_str_light,res_summ_str_cnd);        
    end



    % Display the results of each test
    if strcmpi(opts.printAllResults,'ON')
        disp(res_str)
    end

    % Print the summary results (critical findings)
    if strcmpi(opts.printSummResults ,'ON')
        disp(res_summ_str)       
    end

    % Print the data frame information
    if strcmpi(opts.printSummDF ,'ON')
        disp(groupsummary(df, "condition",{"mean", "std", "median", "min","max", "range"}, ntwprop))       
    end

    % Plot 3 histograms
    if strcmpi(opts.plotHist,'ON')
        figure
        ax = nexttile;
        hold on;
        binlim = [min(df.(ntwprop)) max(df.(ntwprop))];
        histogram(bl, 'FaceColor',[0 0 0], 'BinLimits',binlim, 'NumBins',15);
        histogram(cntl, 'FaceColor','r', 'BinLimits',binlim,'NumBins',15);
        histogram(light, 'FaceColor','y', 'BinLimits',binlim,'NumBins',15);
        ax.Color = [.5 .5 .5];
        title(ax, res_str)
    end    
 
end

%% Run Distribution Tests
function [res_str,res_str_keyresults,ranksumtest_p, ttest_p,signranktest_p] = runalltests(X,Y,catXY,ntwprop,opts)
    arguments
        X, Y, catXY, ntwprop
        opts.plotAvovaTbl = 'off';
        opts.Xname = 'X';
        opts.Yname = 'Y';
    end

    % VARIANCE AND NORMALITY TESTS
    % Lets see if the distributions are normal using the Kolmogorov-Smirnov
    % test
    [kstest_h_X,kstest_p_X] = kstest(X);
    [kstest_h_Y,kstest_p_Y] = kstest(Y);
    kstest_str = sprintf('KS: is %s normal?: %d (p=%.03f) | is %s normal?: %d (p=%.03f)\n',opts.Xname, kstest_h_X==0,kstest_p_X,opts.Yname,kstest_h_Y==0,kstest_p_Y);

    % Barletss test if the WITHIN group variance between groups are similar. we
    % are not testing the variance of between groups. This is a test of the
    % null hypothesis that the columns of X come from normal distributions
    % with the same variance, against the alternative that they come from
    % normal distributions with different variances.
    bar_p_XvY = vartestn(catXY.(ntwprop), double(catXY.condition),'Display','off');
    bartest_str = sprintf('\tbarlett: "Are W/IN FRP variances different" (assuming both normal)? %d (p = %.04f)\n' ,bar_p_XvY<=.05, bar_p_XvY);
    
    % we can also use levenes method test if the WITHIN group variance of
    % each group are similar. un like the Barletts test, This test is not
    % sensitive to departures from normality
    lev_p_XvsY = vartestn(catXY.(ntwprop), double(catXY.condition), 'TestType', 'LeveneAbsolute','Display',opts.plotAvovaTbl); 
    levtest_str = sprintf('levene: "Are W/IN GRP variances the different?" (ignoring normality) %d (p = %.04f)\n',lev_p_XvsY<=.05, lev_p_XvsY);

    % LOCATION TESTS
    % if both presleep and control are normal and have the same variance
    % the run a ttest
    if size(X,1) == size(Y,1) 
        [ttest_h,ttest_p] = ttest(X,Y);
        ttesttype = 'paired';
    else
        [ttest_h,ttest_p] = ttest2(X,Y);
        ttesttype = 'unpaired';
    end
    ttest_str = sprintf('ttest(%s): Are MEANS different (assuming both normal + same spread)? %d (p=%.04f)\n',ttesttype, ttest_h, ttest_p);       
    % otherwise, we run a rank sum test that checks if two independent
    % samples come from distributions with equal medians.  
    [ranksumtest_p, ranktest_h] = ranksum(X, Y);
    ranksumtest_str = sprintf('ranksum: "Are MEDIANS different?" (assume:cont+samemean+samespread+independ): %d (p=%.04f)\n',ranktest_h,ranksumtest_p);


    % OR, we run Ansari-Bradley test is a nonparametric alternative
    % to the two-sample F test. It does not require the assumption that X
    % and Y come from normal distributions. But it does assume that the
    % medians are the same. But I want to know if the medians
    % are different, so this is not a relevent test. This is weird to
    % understand, but i guess two distributions could have the same medians
    % but different means? Ill ignore this for now.
    [~, ans_p_XvY] = ansaribradley(X-median(X), Y-median(Y));
    abtest_str = sprintf('ab: Are MEANS different (assuming same means + same spread)?:  %.04f \n',ans_p_XvY);


    % or, sign rank wchich is like rank sum but for dependent samples
    [signranktest_p, signranktest_h] = signrank(X, Y);
    signranktest_str = sprintf('sign rank:: %d (p=%.04f)\n',signranktest_h,signranktest_p);
    
    % Store Detailed Results
    res_str = strjoin( {kstest_str,bartest_str,levtest_str,ranksumtest_str, signranktest_str, ttest_str} );

    % Only get Ttest and rank sign test results
    res_str_keyresults = sprintf('\n%s%s',signranktest_str,ttest_str);        
    


end