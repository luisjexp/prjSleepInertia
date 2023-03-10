function df = dflong(opts)
    arguments
        % unless specified, all cog tests will be added to the data frame        
        opts.cogtestlist = {'PVT', 'GoNogo', 'Math'}; 
        opts.getd2cdf = false;
    end
    dbstop if error

    if ischar(opts.cogtestlist)
        opts.cogtestlist = {opts.cogtestlist};
    end    
    numcogtest  = numel(opts.cogtestlist);
    ntwproplist = {'gpsd', 'pathl', 'clust', 'betw','deg_w','deg_bt8'};
    numntwprops = numel(ntwproplist);

    runlist = 0:9;
    conditionlist = {'baseline', 'control','control','control','control', 'light','light','light','light'};
    
    band_names  = {'delta', 'theta', 'alpha', 'beta'}; 
    numfs       = 4;
    fstart = [2,6,9,14]; % band start frequncy +1
    fstop = [5,8,13,31]; % band end frequency +1
       

    chanlist = 1:23;
    num_chan = 23;


    df = table();
    for cogidx = 1:numcogtest
        cogtest     = opts.cogtestlist{cogidx};
        gpsd    = getglobalpsd(cogtest);
        [wpli,betw,pathl,~,~,~,~, ~, clust,deg_w, deg_bt8] = getnetwork(cogtest);    
        for ntwidx = 1:numntwprops
            for runidx = 1:9
                for fsidx = 1:numfs
                    ntwpropname = ntwproplist{ntwidx};
                    fsname      = band_names(fsidx);
                    conditionname = conditionlist(runidx);
                    runval      = runlist(runidx);
                    df_info     = [{ntwpropname}, {cogtest}, conditionname, runval, fsname];
                    
                    
                    switch upper(ntwpropname)
                        case 'GPSD'  % has within graph data
                            dfrow = (gpsd.rununique ==runval);
                            Yn = gpsd.centered_psd{dfrow};  
                            sbjid_list = gpsd.sbjid(dfrow,:);
                            tblgenmethod =1;
                            
                        case 'PATHL' % does NOT have within graph data
                            dfrow = (pathl.rununique ==runval);                            
                            Yn = pathl.raw_df{dfrow};  
                            sbjid_list = pathl.sbjid(dfrow,:);    
                            tblgenmethod =2;

                        case 'CLUST' % has within graph data
                            dfrow   = (clust.rununique ==runval);                                                        
                            Yn      = clust.raw_df{dfrow};
                            sbjid_list = clust.sbjid(dfrow,:);    
                            tblgenmethod =3;
                        case 'DEG_W'                            
                            dfrow   = (deg_w.rununique ==runval);                                                        
                            Yn          = deg_w.raw_df{dfrow};
                            sbjid_list  = deg_w.sbjid(dfrow,:);    
                            tblgenmethod =3;
                       case 'DEG_BT8'                            
                            dfrow   = (deg_bt8.rununique ==runval);                                                        
                            Yn          = deg_bt8.raw_df{dfrow};
                            sbjid_list  = deg_bt8.sbjid(dfrow,:);    
                            tblgenmethod =3;                            
                        case 'BETW' % has within graph data
                            dfrow   = (betw.rununique ==runval);                                                        
                            Yn      = betw.raw_df{dfrow};
                            sbjid_list = betw.sbjid(dfrow,:);    
                            tblgenmethod =3;   

                        otherwise
                            error('dv name is incorrect')
                    end

                    numsbj      = numel(sbjid_list);

                    
                    if tblgenmethod == 1
                        % this data frame contains WITHIN AND BETWEEN graph
                        % information ... Size = NODES (23) X LOCAL FREQ
                        % (251) X SUBJECT (depents on task) all i do here
                        % is collapse the many frequency channels in 4
                        % bands
                        Ynf             = squeeze( mean( Yn(:, fstart(fsidx):fstop(fsidx),:),2 ) ); 
                        df_init         = repmat(df_info, numsbj * num_chan,1);
                        df_chan_rows    = repmat(chanlist', numsbj,1);
                        df_sbj_rows     = repmat(sbjid_list, num_chan,1);

                    elseif tblgenmethod == 2
                        % this data frame only contains BETWEEN GRAPHA
                        % information: BAND (4) X SUBJECT (depents on task)
                        % all i do here is collapse the many frequency
                        % channels in 4 bands no averaging is done here
                        Ynf = Yn(fsidx,:);
                        df_init = repmat(df_info, numsbj,1);
                        df_chan_rows = nan(numsbj,1);
                        df_sbj_rows = sbjid_list';

                    elseif tblgenmethod == 3
                        % this data frame also contains BOTH WTHN and BTWN
                        % info: BAND (4) X NODE (23) SUBJECT (depents on
                        % task) so no need to do anything here either
                        Ynf = squeeze( Yn(fsidx,:,:) );
                        df_init         = repmat(df_info, numsbj * num_chan,1);
                        df_chan_rows    = repmat(chanlist', numsbj,1);
                        df_sbj_rows     = repmat(sbjid_list, num_chan,1);                    
                    end
                    df_tmp = cell2table( [num2cell(Ynf(:))  df_init num2cell(df_chan_rows) num2cell(df_sbj_rows(:))] );
                    df_tmp.Properties.VariableNames = {'Y', 'ntwprop', 'cogtest', 'condition', 'rununique', 'band', 'chan', 'sbj'};
                    df = [df; df_tmp];

                end

            end

        end
    end



    df.ntwprop = categorical(df.ntwprop);
    df.condition = categorical(df.condition);
    df.condition = reordercats(df.condition,{'baseline','control','light'});
    df.cogtest = categorical(df.cogtest);
    

    df.run = nan(height(df),1);
    df.run( df.condition == "baseline") = 0;
    df.run( df.condition == "control" & df.rununique == 1   ) = 1;
    df.run( df.condition == "control" & df.rununique == 2   ) = 2;
    df.run( df.condition == "control" & df.rununique == 3   ) = 3;
    df.run( df.condition == "control" & df.rununique == 4   ) = 4;    
    df.run( df.condition == "light" & df.rununique == 5   ) = 1;
    df.run( df.condition == "light" & df.rununique == 6   ) = 2;
    df.run( df.condition == "light" & df.rununique == 7   ) = 3;
    df.run( df.condition == "light" & df.rununique == 8   ) = 4;

    df.band_ord = categorical(df.band,{'delta','theta','alpha','beta'}, 'Ordinal',true);
       
    df = removevars(df,{'rununique','band'});  % these needs to go, causes bugs when averaging accross groups, see readme
    df = dfrmcats(df);

    
    if opts.getd2cdf
        D2C = getdist2core(opts.cogtestlist);
        df = [df;D2C];
    end
    
    % Validate
    dfsumm = summary(df);
    if (dfsumm.run.NumMissing >0)
        error('LUIS: one of the variables in your data frame has an error')    
    end

end

