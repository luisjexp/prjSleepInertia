function [psd] = extractpsd(cog_test)
    % %% for light vs placebo
    S = subjects(cog_test);
    
    subname_list = S.sbj_idS_str;
    subname_num_list = S.sbj_idS_num;
%     pathname = S.path_data_cog_test;
    
    load(fullfile(S.path_data, 'A_cond'))
    load(fullfile(S.path_data, 'B_cond'))
    
%     chan = 23;
    
    init_runs = nan(23,251,S.sbj_numel);
    runs = struct('run1',init_runs, 'run2', init_runs, 'run3',init_runs, 'run4', init_runs);
    psd = struct('baseline', init_runs, 'condA', runs, 'condB', runs);
    
    fprintf('##########\nGetting GPSD during %s Task', upper(cog_test))
    for i = 1:(S.sbj_numel)
        fprintf('. ')    
        sbj_name_num = subname_num_list(i);
    
        sbj_psd = S.loadsbj(sbj_name_num);
        for run_idx =1:4
            rstr =sprintf('run%d',run_idx);
            psd.baseline(1:23,1:251,i) = sbj_psd.baseline;
            psd.condA.(rstr)(1:23,1:251,i) = sbj_psd.condA.(rstr);
            psd.condB.(rstr)(1:23,1:251,i) = sbj_psd.condB.(rstr);
        end
    
    end
    fprintf('\n\tDONE\n')    
    
    psd.subjects = subname_list;
    


end