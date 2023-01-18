function df_wide = dflong2wide(df_long, cogtask, condition_set, fsband, run_set, opts)
    % This function converts the 'long' form data frame into a 'wide' form
    % data set.
    arguments
        df_long % this must be the long data frame
        cogtask {mustBeMember(cogtask,{'PVT','GoNogo','Math'})} 
        condition_set 
        fsband {mustBeMember(fsband,{'delta','theta','alpha','beta'})}  % for now only one fs is allowed, to avoid averaging accross them (which is proabably never gonna happen
        run_set
        opts.grouping_vars = [];
        opts.keepchannels = true;
        opts.suppresswarnings = true;
    end

    dbstop if error


    %% WARNINGS
    appendt0=ismember('baseline', condition_set) && not(any(run_set==0));

    if ~opts.suppresswarnings
        % warn about tossing bad subjects 
        fprintf('\nLUIS!!!!!Note that only "good" subjects from the %s task are in this data frame\n',cogtask);

        % warn about channel data
        if opts.keepchannels
            fprintf('\nLUIS!!!!!Path length variable IS NOT included in this data frame because you want data from each channel\n');
        else 
            fprintf('\nLUIS!!!!!Note that you have averaged accross channels. Path length var is included in the data frame\n');        
        end

        
        % if desire baseline condition, make sure to include t = 0
        if appendt0
            fprintf('\nLUIS!!!!!*Data during "run 0" will be included*, because yoy want data from the *baseline condition*\n');        
            run_set = [0 run_set];
        end        
    end    


    % if desire baseline condition, make sure to include t = 0
    if appendt0
        run_set = [0 run_set];
    end


    %% SET UP WHICH VARIABLES WILL BE USED TO GROUP
    if isempty(opts.grouping_vars) && (opts.keepchannels)
        % option 1: keep raw table, do not group by any variables (default)
        gv = df_long.Properties.VariableNames(~ismember(df_long.Properties.VariableNames,{'Y'}));
        
    elseif isempty(opts.grouping_vars) && not(opts.keepchannels)
        % option 2: Only average accross channels
        gv = df_long.Properties.VariableNames(~ismember(df_long.Properties.VariableNames,{'chan', 'Y'}));
    else
        % option 3: AVerage accross desired variables
        gv = opts.grouping_vars;
    end    


    %% CREATE A COLUMN FOR EACH VARIABLE, THE CONCATENATE
    % first Get the Standard Networl Properties
    df_gpsd = extntwproptbl(df_long,'gpsd',cogtask,condition_set,fsband,run_set,gv);
    df_clust = extntwproptbl(df_long,'clust',cogtask,condition_set,fsband,run_set,gv);
    df_betw = extntwproptbl(df_long,'betw',cogtask,condition_set,fsband,run_set,gv);
    df_deg_w = extntwproptbl(df_long,'deg_w',cogtask,condition_set,fsband,run_set,gv);
    
    df_wide = cat(2,df_gpsd,df_clust,df_betw,df_deg_w);
    
    % Get average distance to core, assuming that d2c variables at
    % different gammas are in master data frame (may or may not be)
    ntwprops_set = unique(df_long.ntwprop);
    d2cprop_set = ntwprops_set(contains(cellstr(ntwprops_set),'d2c'));
    if ~isempty(d2cprop_set)
        df_d2c = table;
        df_d2c_mu = zeros(height(df_wide),1);
        for i = 1:numel(d2cprop_set)
            ntwprop = char(d2cprop_set(i));
            d2c_g       = extntwproptbl(df_long,ntwprop,cogtask,condition_set,fsband,run_set,gv);
            df_d2c      = cat(2,df_d2c, d2c_g);
            df_d2c_mu   = df_d2c_mu + d2c_g.(ntwprop);
        end
        df_wide = cat(2,df_gpsd,df_clust,df_betw,df_deg_w,df_d2c);
    end

    % get binarized degree variable, but only if we have data from each
    % channels. otherwise an average binarized degree will always be the
    % same accross all subjects
    if opts.keepchannels
        df_deg_bt8 = extntwproptbl(df_long,'deg_bt8',cogtask,condition_set,fsband,run_set,gv);
        df_wide = cat(2,df_wide,df_deg_bt8);
    end
    
    % get the path length variable, but only if averaged accross channels    
    if not(opts.keepchannels) 
        df_pathl = extntwproptbl(df_long,'pathl',cogtask,condition_set,fsband,run_set,gv);
        df_wide = cat(2,df_wide,df_pathl);
    end

    % Get columns of exp controlled, or fixed variables.
    df_fixed = extntwproptbl(df_long,'fixedvars',cogtask,condition_set,fsband,run_set,gv);
    df_wide = cat(2,df_wide,df_fixed);
    
    % remove unused levels of categorical variables (eg,task,frequency band ,condition,etc)
    df_wide =  dfrmcats(df_wide);
    df_wide.cogtest = categorical(repmat({cogtask},height(df_wide),1));

end


%% F(X) AVERAGE A VARIABLE ACCROSS OTHER VARIABLES
function df_new = extntwproptbl(DF,ntwprop,cogtask,conditon,fsbands,runs,gv)
    arguments
        DF,ntwprop,
        cogtask,conditon,fsbands,runs,gv
    end    

    if strcmp(ntwprop, 'fixedvars')
        % if user wants table of experimentally controlled, or fixed
        % variables, then we we'll create the data frame in the same way as
        % we would create any other one. so here we choose an arbitray
        % networl property, but not that we could have choses any other one
        ntwprop = 'clust'; 
        getfixedvarsonly = true;
    else
        getfixedvarsonly = false;
    end

    % get a grouped data frame
    dfsubset = DF(...
        (DF.cogtest == cogtask)...
        & ismember(DF.sbj, goodsbj(cogtask))...
        & any((DF.condition == conditon),2)...
        & any(DF.band_ord == fsbands,2)...
        & any(DF.run == runs,2) &...
        (ismember(DF.ntwprop,ntwprop)),:);
    
    if isempty(dfsubset)
        error('LUIS: could not create wide data frame because it is empty, check your inputs')
    end
    df_grouped  = varfun(@mean, dfsubset, 'InputVariables', "Y", 'GroupingVariables', gv);


    if getfixedvarsonly
        % Get a table of experimentally controlled, or fixed variables and add
        % them back to the data frame. all tables should have these variable in
        % common. 
        varsexcept_ntwprop_cogtest = ~ismember(gv, {'ntwprop','cogtest'});
        df_new = df_grouped(:,varsexcept_ntwprop_cogtest);      
        df_new =  dfrmcats(df_new);
    else
        % OR we create a data frame where the network property is averaged
        % accross certain variables
        df_grouped_renamed      = renamevars(df_grouped, 'mean_Y', ntwprop);
        ntwprop_tbl  = df_grouped_renamed(:,ntwprop);


        df_new =  dfrmcats(ntwprop_tbl);
    end
    
end

