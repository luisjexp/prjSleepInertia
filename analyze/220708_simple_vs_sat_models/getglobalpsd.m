function gpsd = getglobalpsd(cog_test)
% provides same output as original psd compare function, but in table format
% i built it so that i can understand the analysis better bc initially
% i was confused. also provides a good format to analyze data

    psd             = extractpsd(cog_test);
    
    BL_global       = getgpsd(psd.baseline, 0, 'baseline');
    light_global    = [];
    cnt_global      = [];
    
    for r = 1:4
        rstr = sprintf('run%d',r);    
        light_global = [light_global; getgpsd(psd.condA.(rstr), r, 'light')];
        cnt_global = [cnt_global; getgpsd(psd.condB.(rstr), r, 'control')];    
    end

    sbjIds = cellfun(@(n) str2num(n), psd.subjects);
    
    BL_global.sbjid = sbjIds;
    light_global.sbjid = repmat(sbjIds, 4,1);
    cnt_global.sbjid = repmat(sbjIds, 4,1);
    
    gpsd = [BL_global; light_global; cnt_global];

end


function gpsd = getgpsd(psdmat, run, condition_name)
    df_var_names = {'condition', 'run', 'centered_psd', 'psd_fsplit', 'delta', 'theta', 'alpha', 'beta'};
    
    f1 = [2,6,9,14]; % band start frequncy +1
    f2 = [5,8,13,31]; % band end frequency +1
   
    get_global_psd = @(centered_psd, f_min,f_max) squeeze ( mean( mean( centered_psd(:,f_min:f_max,:),2) ) )';
   
    psd_centered = center_psdmat(psdmat);

    psd_delta = get_global_psd(psd_centered,f1(1),f2(1));
    psd_theta = get_global_psd(psd_centered,f1(2),f2(2));
    psd_alpha = get_global_psd(psd_centered,f1(3),f2(3));
    psd_beta  = get_global_psd(psd_centered,f1(4),f2(4));
    
    psd_freq_split  = [psd_delta; psd_theta; psd_alpha; psd_beta];
    gpsd            = cell2table({condition_name, run, psd_centered, psd_freq_split, psd_delta, psd_theta, psd_alpha, psd_beta} );
    gpsd.Properties.VariableNames = df_var_names;



end