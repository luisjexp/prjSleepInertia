function [df, df_group, df_groupmeans, df_effects, df_effects_group, df_effects_groupmeans] =...
    hyptest_nasa00_getdf(DFMASTER,desired_sbj, desired_cogtest, desired_band,opts )
% - it takes the large 'master data frame' produced by dfgenerate fcn 
% - produces multuiple tables
%     - raw table that is simply the table desired by the user, 
%         - desired cognitive test (one type option only)
%         - desired subjects
%         - desired network prop (one option only)
%         - desire band , multiple options available (see below)
%             - desired frequency bands can be = {'alpha', 'beta', 'delta', 'theta', 'highfs' 'lowfs'}
%                 - 'lowfs' and 'highsf' produce tables that are averaged accross the d+th band, pr alph+bet band, respectively
%         - desired runs, 'multipl options available (see below)
%             - desired runs bands can be = {'1', '2', '3', '4', 'early' 'late', 'all'}
%                 - 'early', 'late', and 'all, produce tables that are averaged accross 
%                     - the 1+2nd run, 3rd+4th run and all 4 runs, respectively            
%         - desir either with or without channel by channel information 
%         - currently this table is not an output but serves to create the other tables...
%     - a group table where the values of the network property are grouped by
%         - by cognitive test, subject, condition and, if desired, by channel 
%         - thus, the desired frequency bands are collapsed
%         - thus, the desired runs are also collapsed
%     - an 'effects' table, where variables are created by subtracting values of different grroups
%         - difference between BL and light
%         - difference between BL and control
%         - difference between light and control
%     - a group table of the effects is also given, where each 'effect variable is averaged
arguments
    DFMASTER,desired_sbj, desired_cogtest, desired_band
    opts.cnd_idx (1,3) = [1 2 3] 
    opts.runstage = 'all'
    opts.avxchan = true;

end

    DFMASTER.runstage = repmat({'baseline'},height(DFMASTER),1);
    DFMASTER.runstage(any((DFMASTER.run == [1 2]),2)) = {'early'};
    DFMASTER.runstage(any((DFMASTER.run == [3 4]),2)) = {'late'};
    DFMASTER.runstage = categorical(DFMASTER.runstage);

    switch  opts.runstage
        case 'late'
            df_desired_runstage_rows = any(DFMASTER.runstage == [categorical("baseline"), 'late'],2);
        case 'early'
            df_desired_runstage_rows = any(DFMASTER.runstage == [categorical("baseline"), 'early'],2) ;      
        case '1'
            df_desired_runstage_rows = DFMASTER.run == 0 | DFMASTER.run == 1 ;                  
        case '2'
            df_desired_runstage_rows = DFMASTER.run == 0 | DFMASTER.run == 2 ;                  
        case '3'
            df_desired_runstage_rows = DFMASTER.run == 0 | DFMASTER.run == 3 ;                              
        case '4'
            df_desired_runstage_rows = DFMASTER.run == 0 | DFMASTER.run == 4 ;                  
            
        case 'all'
            df_desired_runstage_rows = true(height(DFMASTER),1)    ;        
    end

    switch desired_band
        case {'delta', 'theta', 'alpha', 'beta'}
            % do nothing
        case 'highfs'
            desired_band = {'alpha', 'beta'};
        case 'lowfs'
            desired_band = {'delta', 'theta'};
        otherwise
            
            error('LUIS: desired band is not an option')
    end
    df_desired_rows = ismember(DFMASTER.sbj, desired_sbj) & DFMASTER.cogtest == desired_cogtest &...
        DFMASTER.ntwprop == 'clust'& df_desired_runstage_rows & any(DFMASTER.band == desired_band,2);

    df =  DFMASTER(df_desired_rows,:);
    df.condition_idx = opts.cnd_idx(1)*(df.condition=="baseline") + opts.cnd_idx(2)*(df.condition=="control") + opts.cnd_idx(3)*(df.condition=="light");
    

    if opts.avxchan
        groupingvars = {'cogtest', 'sbj', 'condition', 'condition_idx'};
    else
        groupingvars = {'cogtest', 'sbj', 'condition', 'condition_idx', 'chan'};
    end

    df  = varfun(@mean, df, "InputVariables","Y","GroupingVariables",groupingvars);
    makemat = @(tbl) [tbl.mean_Y(tbl.condition == 'baseline',:), tbl.mean_Y(tbl.condition == 'control',:), tbl.mean_Y(tbl.condition == 'light',:)];    
    df_group = array2table(makemat(df), 'VariableNames', {'baseline', 'control', 'light'});
    df_groupmeans  = varfun(@mean, df, "InputVariables","mean_Y","GroupingVariables",{'condition', 'condition_idx'});


    maketbl = @(tbl,p1) table(repmat({desired_cogtest},numel(tbl),1), repmat({p1},numel(tbl),1), tbl(:), 'VariableNames',{'cogtest', 'factor', 'effect'});
    cntlEffect     = maketbl(df_group.control - df_group.baseline, 'control');
    lightEffect    = maketbl(df_group.light - df_group.baseline, 'light');
    df_effects = [cntlEffect; lightEffect];

    df_effects.factor =categorical(df_effects.factor);
    df_effects.cogtest =categorical(df_effects.cogtest);

    df_effects_group = table(cntlEffect.effect, lightEffect.effect, 'VariableNames',{'cntlEffect', 'lightEffect'});
    df_effects_groupmeans  = varfun(@mean, df_effects, "InputVariables","effect","GroupingVariables",{'factor'});
    df_effects_groupmeans.cogtest = repmat(categorical({desired_cogtest}), height(df_effects_groupmeans),1);



end