function [T, P, sig_pairs] = testpairs(df)

num_cmp = size(df,2);

P = nan(num_cmp, num_cmp);
T = nan(num_cmp, num_cmp);
for i = 1:num_cmp
    xi = df(:,i);
    for j = 1:num_cmp
        xj = df(:,j);
        
        [~, P(i,j), ~, s] = ttest(xi,xj);
        T(i,j) = s.tstat;

    end
end



[r,c] = ind2sub( size(P), find(P<=.05));
sig_pairs = [r c];

end