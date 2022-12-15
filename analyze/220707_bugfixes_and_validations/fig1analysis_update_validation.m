function fig1analysis_update_validation(ntwpropname, cogtest, conditionname,bandName, ttesttype)
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
    
    % first run the analysis using the original figure1 function. This
    % requires you to specify the SUBJECT INDECES THAT WILL BE REMOVED
    T_og = fig1analysis(cogtest, ntwpropname, sbj2remove, testtype= ttesttype);
    tstat_og = T_og.tstat{ ismember(T_og.band,bandName) & ismember(T_og.condition, conditionname) };
    tstat_bl_og = abs(tstat_og(2:end,1));

    % Next run the analysis using the updated, safer bersion of the figure1 function. This
    % requires you to specify the SUBJECT INDENTIFIERS THAT WILL KEPT
    T_upd       = fig1analysis_udpate(cogtest, ntwpropname, sbjidlist, testtype= ttesttype);
    tstat_upd   = T_upd.tstat{ ismember(T_upd.band,bandName) & ismember(T_upd.condition, conditionname) };
    tstat_bl_upd = abs(tstat_upd(2:end,1));


    
    
    if  round(tstat_bl_upd,4) == round(tstat_bl_og,4)
        fprintf('\nReplication is almost perfect!!!, t values are almost identical\n')
    elseif  round(tstat_bl_upd,3) == round(tstat_bl_og,3)
        fprintf('\nReplication highly successfull!, differences are less than .001\n')
    elseif round(tstat_bl_upd,2) == round(tstat_bl_og,2)
        fprintf('\nReplication successfull, differences are less than .01\n')
    elseif  round(tstat_bl_upd,1) == round(tstat_bl_og,1)
        fprintf('\nReplication  somwhat successfull., differences are less than .1\n')
    else 
        fprintf('\nReplication failed!!! check your code\n')
    end


end