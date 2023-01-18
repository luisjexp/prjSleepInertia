function dfsbj = splitdfbysubject(df)
    arguments
        df
    end

    sbj_list = unique(df.sbj) ;

    dfsbj = cell(1,numel(sbj_list));
    for i= 1:numel(sbj_list)
        dfsbj{i} = df(df.sbj == sbj_list(i),:);
    end



end