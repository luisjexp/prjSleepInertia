function df_new = dfmastersplit(DF, cogtask, condition_set, fsband, run_set, opts)
    arguments
        DF % this must be the master data frame
        cogtask % only one task is allowed
        condition_set
        fsband % for now only one fs is allowed, to avoid averaging accross them
        run_set
        opts.grouping_vars = [];
        opts.keepchannels = true;
        opts.suppresswarnings = false;
        opts.catvars = 0;
    end
    dbstop if error

    % VALIDATE
    if ~any(strcmp(cogtask,{'PVT','GoNogo','Math','KDT'})) || ~ischar(cogtask)
        error('LUIS! only one cognitive task can be in the data frame, remember they are case sensitive');
    end

    if ~any(strcmp(fsband,{'delta','theta','alpha','beta'})) || ~ischar(cogtask)
        error('LUIS! only one fs band task can be included in the data frame');
    end    

    % WARNINGS
    if ~opts.suppresswarnings
        fprintf('\n!!!!!Note that only "good" subjects from the %s task are in this data frame\n',cogtask);
    end    

    if opts.keepchannels
        if ~opts.suppresswarnings
            fprintf('!!!!!Path length variable IS NOT included in this data frame because you want data from each channel\n');
        end
    else 
        if ~opts.suppresswarnings
            fprintf('!!!!!Note that you have averaged accross channels. Path length var is included in the data frame\n');        
        end
    end

    % if desire baseline condition, make sure to include t = 0
    if ismember('baseline', condition_set) && not(any(run_set==0))
        run_set = [0 run_set];
    end


    % GROUP BY VARIABLES
    if isempty(opts.grouping_vars) && (opts.keepchannels)
        % keep raw table, do not group by any variables
        gv = DF.Properties.VariableNames(~ismember(DF.Properties.VariableNames,{'Y'}));
        
    elseif isempty(opts.grouping_vars) && not(opts.keepchannels)
        % Only average accross channels
        gv = DF.Properties.VariableNames(~ismember(DF.Properties.VariableNames,{'chan', 'Y'}));
    else
        % AVerage accross desired variables
        gv = opts.grouping_vars;
    end    


    % CREATE A COLUMN FOR EACH VARIABLE, THE CONCATENATE
    % Get the Standard Networl Properties
    catvars = opts.catvars;
    df_gpsd = extntwproptbl(DF,'gpsd',cogtask,condition_set,fsband,run_set,gv,catvars);
    df_clust = extntwproptbl(DF,'clust',cogtask,condition_set,fsband,run_set,gv,catvars);
    df_betw = extntwproptbl(DF,'betw',cogtask,condition_set,fsband,run_set,gv,catvars);
    df_deg_w = extntwproptbl(DF,'deg_w',cogtask,condition_set,fsband,run_set,gv,catvars);
    
    
    df_new = cat(2,df_gpsd,df_clust,df_betw,df_deg_w);
    
    % Get average distance to core, assuming that d2c variables at
    % different gammas are in master data frame (may or may not be)
    ntwprops_set = unique(DF.ntwprop);
    d2cprop_set = ntwprops_set(contains(cellstr(ntwprops_set),'d2c'));
    if ~isempty(d2cprop_set)
        df_d2c = table;
        df_d2c_mu = zeros(height(df_new),1);
        for i = 1:numel(d2cprop_set)
            ntwprop = char(d2cprop_set(i));
            d2c_g       = extntwproptbl(DF,ntwprop,cogtask,condition_set,fsband,run_set,gv,catvars);
            df_d2c      = cat(2,df_d2c, d2c_g);
            df_d2c_mu   = df_d2c_mu + d2c_g.(ntwprop);
        end
        df_new = cat(2,df_gpsd,df_clust,df_betw,df_deg_w,df_d2c);
    end

    % get binarized degree variable, but only if we have data from each
    % channels. otherwise an average binarized degree will always be the
    % same accross all subjects
    if opts.keepchannels
        df_deg_bt8 = extntwproptbl(DF,'deg_bt8',cogtask,condition_set,fsband,run_set,gv,catvars);
        df_new = cat(2,df_new,df_deg_bt8);
    end
    
    % get the path length variable, but only if averaged accross channels    
    if not(opts.keepchannels) 
        df_pathl = extntwproptbl(DF,'pathl',cogtask,condition_set,fsband,run_set,gv,catvars);
        df_new = cat(2,df_new,df_pathl);
    end

    % Get columns of exp controlled, or fixed variables.
    df_fixed = extntwproptbl(DF,'fixedvars',cogtask,condition_set,fsband,run_set,gv,catvars);
    df_new = cat(2,df_new,df_fixed);
    
    % remove unused levels of categorical variables (eg,task,frequency band ,condition,etc)
    df_new =  dfrmcats(df_new);
    df_new.cogtest = categorical(repmat({cogtask},height(df_new),1));


    
end


%% FUNCTIONS
function df_new = extntwproptbl(DF,ntwprop,cogtask,conditon,fsbands,runs,gv,catvars)
    arguments
        DF,ntwprop,
        cogtask,conditon,fsbands,runs,gv
        catvars
    end    

    if strcmp(ntwprop, 'fixedvars')
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
    
        df_grouped  = varfun(@mean, dfsubset, 'InputVariables', "Y", 'GroupingVariables', gv);

    % Get a table of experimentally controlled, or fixed variables and add
    % them back to the data frame. all tables should have these variable in
    % common
    if getfixedvarsonly
        df_new = df_grouped(:,~ismember(gv, {'ntwprop','cogtest'}));      
        df_new =  dfrmcats(df_new);
    else
        df_grouped_renamed      = renamevars(df_grouped, 'mean_Y', ntwprop);
        ntwprop_tbl  = df_grouped_renamed(:,ntwprop);

         if catvars > 1
             ntwprop_tbl = cat(2,ntwprop_tbl, makecat(ntwprop_tbl,ntwprop,catvars));
         end

        df_new =  dfrmcats(ntwprop_tbl);
    end
    
end

%% Categorize variables
function df_cat = makecat(df,ntwprop,catvars,opts)
    arguments
        df
        ntwprop
        catvars
        opts.newname = ntwprop;

    end
    

    Y = df.(ntwprop);
    Y_cat_name = sprintf('%s_level',opts.newname);
    df_cat.(Y_cat_name) = cell(size(Y,1),1);

    if catvars == 2
            Y_1  = Y <= prctile(Y,50);
            Y_2  = Y > prctile(Y,50);
            df_cat.(Y_cat_name)(Y_1)= {'1'};
            df_cat.(Y_cat_name)(Y_2)   = {'2'};
            df_cat.(Y_cat_name) = categorical(df_cat.(Y_cat_name),'Ordinal',true);    
            df_cat.(Y_cat_name) = reordercats(df_cat.(Y_cat_name),{'1','2'});         
    elseif catvars == 3
            Y_1  = Y <= prctile(Y,33);
            Y_2  = (Y> prctile(Y,33)) & (Y <= prctile(Y,66));
            Y_3  = Y > prctile(Y,66);

            df_cat.(Y_cat_name)(Y_1)= {'1'};
            df_cat.(Y_cat_name)(Y_2)   = {'2'};
            df_cat.(Y_cat_name)(Y_3)    = {'3'};
            df_cat.(Y_cat_name) = categorical(df_cat.(Y_cat_name),'Ordinal',true);    
            df_cat.(Y_cat_name) = reordercats(df_cat.(Y_cat_name),{'1','2','3'});            

      elseif catvars == 4
            Y_1  = Y <= prctile(Y,25);
            Y_2  = (Y> prctile(Y,25)) & (Y <= prctile(Y,50));
            Y_3  = (Y> prctile(Y,50)) & (Y <= prctile(Y,75));
            Y_4  = Y > prctile(Y,75);

            df_cat.(Y_cat_name)(Y_1)= {'1'};
            df_cat.(Y_cat_name)(Y_2)   = {'2'};
            df_cat.(Y_cat_name)(Y_3)    = {'3'};
            df_cat.(Y_cat_name)(Y_4)    = {'4'};
            
            df_cat.(Y_cat_name) = categorical(df_cat.(Y_cat_name),'Ordinal',true);    
            df_cat.(Y_cat_name) = reordercats(df_cat.(Y_cat_name),{'1','2','3','4'});                
    end



    df_cat = struct2table(df_cat);
    % i run this code to remove unused categories as a sanity check
    df_cat =  dfrmcats(df_cat);



end