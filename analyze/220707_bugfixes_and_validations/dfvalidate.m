function [tstatpairs, tstat_og, tstat_bl] = dfvalidate(cogtestname, ntwpropname, conditionname, bandName, sbjidlist)
    % Replicate part of figure 1 analysis , using a regression on the data frame
    %   lets  replicate results of a network propery in some band during a specified condition
    %   the tests are *independent* ttest which is NOT the same as original analysis,
    %   but it is needed to compare with regression that assumes independent samples

    % get data frame
    df     = df4linmodelparse(ntwpropname, cogtestname , conditionname ,bandName, sbjidlist);
        
    % make sure we model using dummy variable as IV...
    %   ie each combination of condition and run has a unique value
    df_bl = df( df.rundummy == 0,: ); % in both control and light, baseline is always zero 
    switch upper(conditionname)
        case 'LIGHT'
            df_blVsR1 = [df_bl; df( df.rundummy == 1,:  )]; % in light condition, r1 is dummy coded as 1
            df_blVsR2 = [df_bl; df( df.rundummy == 2,:  )]; % in light condition, r2 is dummy coded as 2
            df_blVsR3 = [df_bl; df( df.rundummy == 3,:  )]; % in light condition, r3 is dummy coded as 3
            df_blVsR4 = [df_bl; df( df.rundummy == 4 ,: )]; % in light condition, r4 is dummy coded as 4            
        case 'CONTROL'
            df_blVsR1 = [df_bl; df( df.rundummy == 5,:  )]; % in control, r1 is dummy coded as 5
            df_blVsR2 = [df_bl; df( df.rundummy == 6,:  )]; % in control, r2 is dummy coded as 6
            df_blVsR3 = [df_bl; df( df.rundummy == 7,:  )]; % in control, r3 is dummy coded as 7
            df_blVsR4 = [df_bl; df( df.rundummy == 8 ,: )]; % in control, r4 is dummy coded as 8
    end

    % Run Models
    lm_blVsR1   = fitlm(df_blVsR1,'Y~run');  % baseline vs run 1
    lm_blVsR2   = fitlm(df_blVsR2,'Y~run');  % baseline vs run 2
    lm_blVsR3   = fitlm(df_blVsR3,'Y~run');  % contro run1 run 3
    lm_blVsR4   = fitlm(df_blVsR4,'Y~run');  % contro run1 run 4
    
    % now get t values
    tstatpairs = abs([lm_blVsR1.Coefficients.tStat(2); lm_blVsR2.Coefficients.tStat(2);  lm_blVsR3.Coefficients.tStat(2); lm_blVsR4.Coefficients.tStat(2)]);
    
    % Get T values from original analysis. Technically its not original, bc its with independent (vs paired) ttest 
    T = fig1analysis_udpate(cogtestname, ntwpropname, sbjidlist, testtype= 'independent');
    tstat_og = T.tstat{ ismember(T.band,bandName) & ismember(T.condition, conditionname) };
    tstat_bl = abs(tstat_og(2:end,1));
    
    if  round(tstatpairs,4) == round(tstat_bl,4)
        fprintf('\nReplication is almost perfect!!!, t values are almost identical\n')
    elseif  round(tstatpairs,3) == round(tstat_bl,3)
        fprintf('\nReplication highly successfull!, differences are less than .001\n')
    elseif round(tstatpairs,2) == round(tstat_bl,2)
        fprintf('\nReplication successfull, differences are less than .01\n')
    elseif  round(tstatpairs,1) == round(tstat_bl,1)
        fprintf('\nReplication  somwhat successfull., differences are less than .1\n')
    else 
        fprintf('\nReplication failed!!! check your code\n')
    end

end