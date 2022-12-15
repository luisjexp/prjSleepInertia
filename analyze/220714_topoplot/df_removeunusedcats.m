function df_cat_stripped = df_removeunusedcats(df)
vartypes = varfun(@class,df,'OutputFormat','cell');
%     B = removecats(A) removes unused categories from each variable in the
%     table, that is, categories that not are actually present as the value
%     of some element of A.  Usefull instead of manually removing
%     categories from each categorical variable, one by one. Also important
%     to do this when running a regression- in matlab, regressing on a
%     categorical variable with unused categories still includes the
%     categories as predictors.
varnames = df.Properties.VariableNames;
for i = 1:numel(vartypes)

    if strcmp(vartypes{i}, 'categorical')
        df.(varnames{i}) = removecats(df.(varnames{i})); 
    end

df_cat_stripped = df;
end