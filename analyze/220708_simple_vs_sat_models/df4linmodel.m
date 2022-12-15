function DF = df4linmodel(opts)
    % the dataframe for the hypothesized linear model
    % this an early version. only {'gpsd', 'pathl', 'clust', 'betw'}
    % are added to the table (other variables need to be processed, see readme)
    arguments
        % unless specified, all cog tests will be added to the data frame        
        opts.cogtestlist = {'PVT', 'KDT', 'Math', 'GoNogo'}; 
    end


    numcogtest  = numel(opts.cogtestlist);
    ntwproplist = {'gpsd', 'pathl', 'clust', 'betw'};
    numntwprops = numel(ntwproplist);

    cndlist     = {'baseline', 'light', 'control'};
    numcnd      = 3;
    band_names  = {'delta', 'theta', 'alpha', 'beta'}; 
    numfs       = 4;

    DF = table();
    k = 0;    
    
    for cogidx = 1:numcogtest
        cogtest     = opts.cogtestlist{cogidx};
        gpsd    = getglobalpsd(cogtest);
        [~,betw,pathl,~,~,~,~, ~, clust] = getnetwork(cogtest);        
        for ntwidx = 1:numntwprops
            ntwpropname = ntwproplist{ntwidx};

            switch upper(ntwpropname)
                case 'GPSD'
                    Y = gpsd;    
                case 'PATHL'
                    Y = pathl;   
                case 'CLUST'
                    Y = collapse(clust);
                case 'BETW'
                    Y = collapse(betw);                    
                otherwise
                    error('dv name is incorrect')
                    
            end
            
            
            for cndidx = 1:numcnd
                cnd_name    = cndlist(cndidx); 
                cndrow      = ismember(Y.condition , cnd_name);
    
                runlist = Y{cndrow,'run'};
                numruns = numel(runlist);
                
                for runidx = 1:numruns
                    runval = runlist(runidx);
                    runrow = Y{:,'run'} == runval;
                    for fsidx = 1:numfs
                        fsname      = band_names{fsidx};  
                        sbjidname = 'sbjid';

                        yvals =  Y{cndrow & runrow, {fsname}};
                        sbjid_list = Y{cndrow & runrow, sbjidname};
                        
                        numsbj = numel(sbjid_list);
                        if numsbj~= numel(yvals)
                            error('LUIS: your variable is off. Each subject should have only 1 data point here')
                        end
                        for sbjidx = 1:numel(sbjid_list)
                            k = k+1;
                            sbjname = sbjid_list(sbjidx);
                            y = yvals(sbjidx);
                            tbl_tmp = cell2table([y,{ntwpropname}, {cogtest}, cnd_name, runval, {fsname}, sbjname]);
                            DF = [DF; tbl_tmp];
                        end
                    end
                end

            end
        end
    end
    
DF.Properties.VariableNames = {'Y', 'ntwprop', 'cogtest', 'condition', 'run', 'band', 'sbjid'};

% need to give a code to each unique combination of condition and run for
% regression 
DF.rundummy = nan(height(DF),1);
DF.rundummy( ismember(DF.condition, 'baseline'))  = 0;  
DF.rundummy( ismember(DF.condition, 'light') &  DF.run  == 1)  = 1;  
DF.rundummy( ismember(DF.condition, 'light') &  DF.run  == 2 )  = 2;  
DF.rundummy( ismember(DF.condition, 'light') &  DF.run  == 3 )  = 3;  
DF.rundummy( ismember(DF.condition, 'light') &  DF.run  == 4 )  = 4;  
DF.rundummy( ismember(DF.condition, 'control') &  DF.run  == 1 )  = 5;  
DF.rundummy( ismember(DF.condition, 'control') &  DF.run  == 2 )  = 6;  
DF.rundummy( ismember(DF.condition, 'control') &  DF.run  == 3 )  = 7;  
DF.rundummy( ismember(DF.condition, 'control') &  DF.run  == 4 )  = 8;  

end


function newY = collapse(Y)
    newY        = Y;
    ybands      =  Y{:,{'delta', 'theta', 'alpha', 'beta'}};
    ybandscollapsed = cellfun(@(y) mean(y), ybands, 'UniformOutput', false);
    newY.delta = cat(1,ybandscollapsed{:,1});
    newY.theta = cat(1,ybandscollapsed{:,2});
    newY.alpha = cat(1,ybandscollapsed{:,3});
    newY.beta = cat(1,ybandscollapsed{:,4}); 
end