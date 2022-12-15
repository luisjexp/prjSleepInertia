function [T, P, sig_pairs] = testpairs(df, type)
% [T, P, sig_pairs] = testpairs(df, type)
num_cmp = size(df,2);

P = nan(num_cmp, num_cmp);
T = nan(num_cmp, num_cmp);
for i = 1:num_cmp
    xi = df(:,i);
    for j = 1:num_cmp
        xj = df(:,j);
        
        switch upper(type)
            case upper({'dependent', 'paired'})
            [~, P(i,j), ~, s] = ttest(xi,xj);
            case upper({'independent'})
            [~, P(i,j), ~, s] = ttest2(xi,xj);
            otherwise
                error('LUIS: need to specify ttest type, paired or independent sample')
        end
        T(i,j) = s.tstat;

    end
end



[r,c] = ind2sub( size(P), find(P<=.05));
sig_pairs = [r c];

end