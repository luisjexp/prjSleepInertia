function D2C = getdist2core(cogtask_set,opts)
    arguments
        cogtask_set
        opts.gamm_set = [0.85, 0.91, 0.98, 1.04, 1.1]; % defeault for all tasks, since they can all run these without error
    end
% Created function that computes the distance's to core with varying
% gamme' thersholds
%  This function creates a table where each row contains a a node's
%  distance's to core, for each task, band, and run, condition and subject.
%  Thus, the table  matches the format and columns of your other 'master'
%  data frame. You should be able to concetinate this data table with the
%  master data, and use the dfmastersplit function to create an analysis
%  data frame.

gamm_set = opts.gamm_set;
for cogtask_idx = 1:numel(cogtask_set)
    cogtask = cogtask_set{cogtask_idx};
    ADJ = dfmasterwpli(cogtask);
    numgamm = numel(gamm_set);


    % Initialize Data Frane
    inittbl_d2c     = table(zeros(23,1),'VariableNames',{'Y'});
    inittbl_cogtask = repmat(table(categorical({cogtask}),'VariableNames',{'cogtest'}),23,1);
    inittbl_chan    = table((1:23)','VariableNames',{'chan'});
    inittbl_sbjdata = @(row) repmat(ADJ(row,{'condition','run','sbj','band_ord'}),23,1);
    inittbl_ntwprop = @(ntwprop) repmat(table(categorical({ntwprop}),'VariableNames',{'ntwprop'}),23,1);
    getsubjtbl      = @(row,ntwprop) cat(2, inittbl_cogtask, inittbl_d2c, inittbl_ntwprop(ntwprop), inittbl_sbjdata(row),inittbl_chan);
    
    D2C = table;        
    fprintf('--- Computing Distances to Core: ')

    % now, ,...compute each
    % node's distance to core
    for row = 1:height(ADJ)
        A  = ADJ.wpli{row};
        if all(A(:) == 0)
            df_empty        = getsubjtbl(row,ntwprop);
            df_norm_empty   = getsubjtbl(row,'d2c_norm');
            D2C = cat(1,D2C, df_empty,df_norm_empty);
            continue
        else
            d2c_mu = zeros(23,1);
            for gamm_idx = 1:numgamm
                gamm    = gamm_set(gamm_idx); 
                ntwprop = sprintf('d2c_g%03d',single(gamm*100));
                
                corenod_idx = core_periphery_dir(A,gamm);
                numcorenodes = sum(corenod_idx);
                if numcorenodes >= 23
                    error('Luis! a gamma threshold of %.02f you want is too low. %d/23 nodes are part of the core.',gamm,numcorenodes);
                elseif numcorenodes < 1
                    error('Luis! a gamma threshold of %.02f is too high. %d/23 nodes are are part of the core.',gamm, numcorenodes);
                end
                df = getsubjtbl(row,ntwprop);                
                d           = distance_wei_floyd(A,'inv');
                df.Y  = sum(d(corenod_idx,:),1)';    
                D2C = cat(1,D2C, df);
                d2c_mu = d2c_mu + df.Y;
            end
            df      = getsubjtbl(row,'d2c_norm');
            df.Y    =  d2c_mu/max(d2c_mu);
            D2C     = cat(1,D2C, df);    
            fprintf('. ');
            if mod(row,35) == 0
                fprintf('\n')
            end
        end
                
    end
    fprintf('\ndone\n')



    


end



            

end