function DF = df4linmodel()
    % the dataframe for the hypothesized linear model
    % this is the first version. only {'gpsd', 'pathl', 'clust', 'betw'}
    % are added to the table (other variables need to be processed, see readme)


    cogtestlist = {'PVT', 'KDT', 'Math', 'GoNogo'};
    numcogtest  = 4;
    ntwproplist = {'gpsd', 'pathl', 'clust', 'betw'};

    numntwprops = numel(ntwproplist);
    cndlist     = {'baseline', 'light', 'control'};
    numcnd      = 3;
    band_names  = {'delta', 'theta', 'alpha', 'beta'}; 
    numfs       = 4;

    DF = table();
    k = 0;    
    
    for cogidx = 1:numcogtest
        cogtest     = cogtestlist{cogidx};
        gpsd    = getglobalpsd(cogtest);
        [wpli,betw,pathl,eff,~,~,~, ~, clust] = getnetwork(cogtest);        
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
                case 'WPLI'
                    error('this needs fixing, getting errors')
                case 'EFF'
                    error('this needs fixing, getting errors')                    
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