function fig1analysis_update_validation(ntwpropname, cogtest, bandName)
    % a sanity check for ensuring that your updated figure 1 analysis works and
    % replicates the original analysis
    S = subjects(cogtest);
    sbjidlist = S.sbj_idS_num;
    
    switch cogtest
        case 'KDT'
            sbj2remove = [7 12];
            sbjidlist(7) = []; % 12 does not exist here
        case 'PVT'
            sbj2remove = 8;
            sbjidlist(8) = [];
        case 'Math'
            sbj2remove = [8 5 10];
            sbjidlist([8 5 10]) = [];        
        case 'GoNogo'
            sbj2remove = [5 7 8];
            sbjidlist([5 7 8]) = [];
        otherwise
            error('')
    end
    
    % first run the analysis using the original figure1 function
    T_og        = fig1analysis_og(cogtest, {ntwpropname}, sbj2remove, testtype= 'dependent');
    tstat_light_og    = T_og.tstat{ ismember(T_og.band,bandName) & ismember(T_og.condition, 'light') };
    tstat_cntl_og    = T_og.tstat{ ismember(T_og.band,bandName) & ismember(T_og.condition, 'control') };
    tstat_og = [tstat_cntl_og(:);tstat_light_og(:)];
    tstat_og(isnan(tstat_og)) = [];


    % Next run the analysis using the new data frame, where each sample
    % corresponds a channel of a particular subject. to replicate the
    % original analysis one must retreive the subject's data, which is
    % computed by averaging accross channels. This is what is done in the
    % following code. It also works for path length and other variables
    % where there is no data by channel (only a single nan value for
    % channel). all we have too do is average accross channels. 
    DF              = df_generate('cogtestlist', {cogtest});
    df_cogtest_rows = DF.cogtest == cogtest;
    df_ntwprop_rows = DF.ntwprop == ntwpropname; 
    df_band_rows    = DF.band == bandName;
    df_light_rows   = DF.condition == 'light';
    df_cntl_rows    = DF.condition == 'control';
    df_bl_rows      = DF.condition == 'baseline';
    df_sbj_rows     = ismember(DF.sbj , sbjidlist);
    
    df_light=  DF(df_cogtest_rows & df_ntwprop_rows & df_light_rows & df_band_rows & df_sbj_rows,:) ;
    df_cntl =  DF(df_cogtest_rows & df_ntwprop_rows & df_cntl_rows & df_band_rows & df_sbj_rows,:) ;
    df_bl   =  DF(df_cogtest_rows & df_ntwprop_rows & df_bl_rows & df_band_rows & df_sbj_rows,:) ;
    
    Y = varfun(@mean, [df_bl; df_light; df_cntl], "InputVariables","Y","GroupingVariables",{'sbj', 'run'}) ;
    C = [Y.mean_Y(Y.run == 0), Y.mean_Y(Y.run == 1), Y.mean_Y(Y.run == 2), Y.mean_Y(Y.run == 3), Y.mean_Y(Y.run == 4)];
    L = [Y.mean_Y(Y.run == 0), Y.mean_Y(Y.run == 5), Y.mean_Y(Y.run == 6), Y.mean_Y(Y.run == 7), Y.mean_Y(Y.run == 8)];
    
    [tstat_light_upd, ~, ~] = testpairs(L, 'dependent') ;
    [tstat_cntl_upd, ~, ~] = testpairs(C, 'dependent') ;
    tstat_upd = [tstat_cntl_upd(:);tstat_light_upd(:)];
    tstat_upd(isnan(tstat_upd)) = [];

    if  round(tstat_upd(:),4) == round(tstat_og(:),4)
        fprintf('\nReplication is almost perfect!!!, t values are almost identical\n')
    elseif  round(tstat_upd(:),3) == round(tstat_og(:),3)
        fprintf('\nReplication highly successfull!, differences are less than .001\n')
    elseif round(tstat_upd(:),2) == round(tstat_og(:),2)
        fprintf('\nReplication successfull, differences are less than .01\n')
    elseif  round(tstat_upd(:),1) == round(tstat_og(:),1)
        fprintf('\nReplication  somwhat successfull., differences are less than .1\n')
    else 
        fprintf('\nReplication failed!!! check your code\n')
    end


end