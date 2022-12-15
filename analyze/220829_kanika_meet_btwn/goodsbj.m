function desiredsbj = suggestedsubject(cogtest)
    % outputs a list of subjects that have 'good' data for a particular
    % cognitive test. These subjects are the ones used in the initial
    % analysis for submitted the SFN abstract. 
    S = subjects(cogtest);
    desiredsbj = S.sbj_idS_num;
    
    switch cogtest
        case 'KDT'
            desiredsbj(7) = []; % 12 does not exist here
        case 'PVT'
            desiredsbj(8) = [];
        case 'Math'
            desiredsbj([8 5 10]) = [];        
        case 'GoNogo'
            desiredsbj([5 7 8]) = [];
        otherwise
            error('LUIS: there is no cognitive test named %s (remember it is case sensitive',cogtest)
    end

end