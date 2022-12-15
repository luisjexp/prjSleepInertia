function [df_grouped, df_ungrouped] =...
    dfgetsubset(DF,desired_sbj, desired_cogtest, desired_ntwprop, desired_band,opts )
    % - it takes the large 'master data frame' produced by dfgenerate fcn 
    % - produces 2 tables
    %     - raw/ungrouped table that is simply the rows of data frame desired, which include 
    %         - desired cognitive test (one type option only)
    %         - desired subjects 
    %         - desired network prop 
    %            - one option only
    %         - desire band, one option only
    %             - options include = {'alpha', 'beta', 'delta', 'theta', 'highfs' 'lowfs'}
    %                 - 'lowfs' and 'highsf' produce tables that are averaged accross the dlt+th band, and alph+bet band, respectively
    %         - desired runstage/test bout: '
    %             - options include = {'1', '2', '3', '4', 'early' 'late', 'all'}
    %                 - 'early', 'late', and 'all, produce tables that are averaged accross 
    %                     - the 1+2nd run, 3rd+4th run and all 4 runs, respectively            
    %     - Most importantly a grouped table is produced where the values of the network property are grouped by
    %         - subjects, condition and run 
    %         - if desired, values can be grouped by additional variables
    %         (but will always be grouped by subject+condition+run
        
    arguments
        DF,
        desired_sbj 
        desired_cogtest {mustBeMember(desired_cogtest, ["PVT","Math","GoNogo", "KDT"])}
        desired_ntwprop {mustBeMember(desired_ntwprop, ["gpsd","clust","pathl"])}
        desired_band    {mustBeMember(desired_band, ["alpha", "beta", "delta", "theta", "highfs", "lowfs", "all"])}
        opts.runstage   = 'all'
        opts.addgroupvars  = {};
        
    end

    DF.runstage = repmat({'baseline'},height(DF),1);
    DF.runstage(any((DF.run == [1 2]),2)) = {'early'};
    DF.runstage(any((DF.run == [3 4]),2)) = {'late'};
    DF.runstage = categorical(DF.runstage);

    switch  opts.runstage
        case 'late'
            df_desired_runstage_rows = any(DF.runstage == [categorical("baseline"), 'late'],2);
        case 'early'
            df_desired_runstage_rows = any(DF.runstage == [categorical("baseline"), 'early'],2) ;      
        case '1'
            df_desired_runstage_rows = DF.run == 0 | DF.run == 1 ;                  
        case '2'
            df_desired_runstage_rows = DF.run == 0 | DF.run == 2 ;                  
        case '3'
            df_desired_runstage_rows = DF.run == 0 | DF.run == 3 ;                              
        case '4'
            df_desired_runstage_rows = DF.run == 0 | DF.run == 4 ;                  
        case 'all'
            df_desired_runstage_rows = true(height(DF),1)    ;   
    end

    switch desired_band
        case {'delta', 'theta', 'alpha', 'beta'}
            % do nothing
        case 'highfs'
            desired_band = {'alpha', 'beta'};
        case 'lowfs'
            desired_band = {'delta', 'theta'};
        case 'all'
            desired_band = {'delta', 'theta', 'alpha', 'beta'}  ;   
            
        otherwise
            error('LUIS: desired band is not an option')
    end

    df_desired_rows = ismember(DF.sbj, desired_sbj) & DF.cogtest == desired_cogtest &...
        DF.ntwprop == desired_ntwprop & df_desired_runstage_rows & any(DF.band == desired_band,2);

    df_ungrouped =  DF(df_desired_rows,:);
    
    groupingvars_default = {'cogtest', 'sbj', 'condition', 'run', 'rununique'};
    groupingvars = [groupingvars_default, opts.addgroupvars];

    df_grouped       = varfun(@mean, df_ungrouped, "InputVariables","Y","GroupingVariables",groupingvars);




end