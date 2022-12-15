function DF = df_generate(opts)
    arguments
        % unless specified, all cog tests will be added to the data frame        
        opts.cogtestlist = {'PVT', 'KDT', 'Math', 'GoNogo'}; 
    end


    numcogtest  = numel(opts.cogtestlist);
    ntwproplist = {'gpsd', 'pathl', 'clust', 'betw'};
    numntwprops = numel(ntwproplist);

    runlist = 0:9;
    conditionlist = {'baseline', 'control','control','control','control', 'light','light','light','light'};
    
    band_names  = {'delta', 'theta', 'alpha', 'beta'}; 
    numfs       = 4;
    fstart = [2,6,9,14]; % band start frequncy +1
    fstop = [5,8,13,31]; % band end frequency +1
       

    chanlist = 1:23;
    num_chan = 23;

    DF = table();
    for cogidx = 1:numcogtest
        cogtest     = opts.cogtestlist{cogidx};
        gpsd    = getglobalpsd(cogtest);
        [~,betw,pathl,~,~,~,~, ~, clust] = getnetwork(cogtest);    
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
                        % this data frame contains WITHIN AND BETWEEN graph information ...
                        % Size = NODES (23) X LOCAL FREQ (251) X SUBJECT (11 or 12)
                        % all i do here is collapse the many frequency channels in 4 bands
                        Ynf             = squeeze( mean( Yn(:, fstart(fsidx):fstop(fsidx),:),2 ) ); 
                        df_init         = repmat(df_info, numsbj * num_chan,1);
                        df_chan_rows    = repmat(chanlist', numsbj,1);
                        df_sbj_rows     = repmat(sbjid_list, num_chan,1);

                    elseif tblgenmethod == 2
                        % this data frame only contains BETWEEN GRAPH information: BAND (4) X SUBJECT (11 or 12)
                        % all i do here is collapse the many frequency channels in 4 bands
                        % no averaging is done here
                        Ynf = Yn(fsidx,:);
                        df_init = repmat(df_info, numsbj,1);
                        df_chan_rows = nan(numsbj,1);
                        df_sbj_rows = sbjid_list';

                    elseif tblgenmethod == 3
                        % this data frame also contains BOTH WTHN and BTWN info: BAND (4) X NODE (23) SUBJECT (11 or 12)
                        % so no need to do anything here either
                        Ynf = squeeze( Yn(fsidx,:,:) );
                        df_init         = repmat(df_info, numsbj * num_chan,1);
                        df_chan_rows    = repmat(chanlist', numsbj,1);
                        df_sbj_rows     = repmat(sbjid_list, num_chan,1);                    
                    end
                    df_tmp = cell2table( [num2cell(Ynf(:))  df_init num2cell(df_chan_rows) num2cell(df_sbj_rows(:))] );
                    df_tmp.Properties.VariableNames = {'Y', 'ntwprop', 'cogtest', 'condition', 'rununique', 'band', 'chan', 'sbj'};
                    DF = [DF; df_tmp];

                end

            end

        end
    end



    DF.ntwprop = categorical(DF.ntwprop);
    DF.condition = categorical(DF.condition);  
    DF.cogtest = categorical(DF.cogtest);
    DF.band = categorical(DF.band);

    DF.run = nan(height(DF),1);
    DF.run( DF.condition == "baseline") = 0;
    DF.run( DF.condition == "control" & DF.rununique == 1   ) = 1;
    DF.run( DF.condition == "control" & DF.rununique == 2   ) = 2;
    DF.run( DF.condition == "control" & DF.rununique == 3   ) = 3;
    DF.run( DF.condition == "control" & DF.rununique == 4   ) = 4;    
    DF.run( DF.condition == "light" & DF.rununique == 5   ) = 1;
    DF.run( DF.condition == "light" & DF.rununique == 6   ) = 2;
    DF.run( DF.condition == "light" & DF.rununique == 7   ) = 3;
    DF.run( DF.condition == "light" & DF.rununique == 8   ) = 4;
    
    % Validate
    dfsumm = summary(DF);
    if (dfsumm.rununique.NumMissing >0) || (dfsumm.run.NumMissing >0)
        error('LUIS: one of the variables in your data frame has an error')    
    end

end

