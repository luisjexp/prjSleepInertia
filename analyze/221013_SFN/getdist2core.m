function D2C = getdist2core(cogtask_set,gamm_set)
    arguments
        cogtask_set
        gamm_set
    end
% <u> Created function that computes the distance's to core with varying
% gamme' thersholds
%  This function creates a table where each row contains a a node's
%  distance's to core, for each task, band, and run, condition and subject.
%  Thus, the table  matches the format and columns of your other 'master'
%  data frame. You should be able to concetinate this data table with the
%  master data, and use the dfmastersplit function to create an analysis
%  data frame.

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
    for gamm_idx = 1:numgamm
        gamm    = gamm_set(gamm_idx);
        ntwprop = sprintf('d2c_g%03d',single(gamm*100));
        fprintf('. ');
        for row = 1:height(ADJ)
            df = getsubjtbl(row,ntwprop);
            A  = ADJ.wpli{row};
        
            if all(A(:) == 0)
                D2C = cat(1,D2C, df);
                continue
            end
            corenod_idx = core_periphery_dir(A,gamm);
            d           = distance_wei_floyd(A,'inv');
            df.Y        = sum(d(corenod_idx,:),1)';    
            D2C = cat(1,D2C, df);
        end
    end
end
    fprintf('done\n')

            

end