function W = dfmasterwpli(cogtask)
% <u> Extrtact Raw WPLI for each subject,task, run, condition and band
%
%   created a function that extract thw raw WPLI matrix from the original
%   structured data set and convert it into a table with info about each
%   subject,task, run, condition and band. note that this table cannot be
%   concatenated with the master data frame because each row contains the
%   wpli matrix composed of 23 channels. However, it is usefull because for
%   each row it has a corresponding task, band, and subject and run and
%   condition. This makes it simple to create any desired property from the
%   matrix. this is how i created a table where each row had the node's
%   distances to the core function 

    A = getnetwork(cogtask);
    A.condition = categorical(A.condition);
    
    W = table;
    cond_set = {'baseline','control','light'};
    band_set = {'delta','theta','alpha','beta'};
    
    getmat = @(cond, band, run) squeeze(num2cell( A.(band){A.condition == cond & A.run == run},[1 2]));
    getsbjids = @(cond, run) A.sbjid(A.condition == cond & A.run == run,:)';
    
    maketbl = @(cond, band,run) table(...
        repmat(categorical({cond}),numel(getsbjids(cond,run)),1),...    
        repmat(categorical({band}),numel(getsbjids(cond,run)),1),...
        repmat(run,numel(getsbjids(cond,run)),1),...
        getsbjids(cond,run),...
        'VariableNames',{'condition', 'band_ord', 'run','sbj'});
    for cnd_idx = 1:3   
        if strcmp(cond_set{cnd_idx} , 'baseline')
            runset = 0;
        else
            runset = 1:4;
        end
    
        for run_idx = 1:numel(runset)
            for band_idx=1:4
                cond =   cond_set{cnd_idx};
                band    = band_set{band_idx};
                run     = runset(run_idx);
                df      = getmat(cond, band, run);
                tbl_tmp = [table(df,'VariableNames',{'wpli'}) maketbl(cond, band,run) ];
                W      = [W;tbl_tmp];  
            end
        end
    end

    W.band_ord = categorical(W.band_ord,'Ordinal',true);
    W.band_ord = reordercats(W.band_ord,{'delta','theta','alpha','beta'}) ;




end