%% Try Creating Topoplots
desired_cogtest     = 'PVT';
desired_ntwpropname = 'clust';
desired_bandname    = 'delta';
S                   = subjects(desired_cogtest);
sbjlist             = S.sbj_idS_num;
desired_sbjnames    = sbjlist([1:7, 9:12]);


DF              = df_generate('cogtestlist', {desired_cogtest});
df_cogtest_rows = DF.cogtest == desired_cogtest;
df_ntwprop_rows = DF.ntwprop == desired_ntwpropname; 
df_band_rows    = DF.band == desired_bandname;
df_light_rows   = DF.condition == 'light';
df_cntl_rows    = DF.condition == 'control';
df_bl_rows      = DF.condition == 'baseline';
df_sbj_rows     = ismember(DF.sbj , desired_sbjnames);

df_light=  DF(df_cogtest_rows & df_ntwprop_rows & df_light_rows & df_band_rows & df_sbj_rows,:) ;
df_cntl =  DF(df_cogtest_rows & df_ntwprop_rows & df_cntl_rows & df_band_rows & df_sbj_rows,:) ;
df_bl   =  DF(df_cogtest_rows & df_ntwprop_rows & df_bl_rows & df_band_rows & df_sbj_rows,:) ;
df = [df_bl; df_light; df_cntl];
df = df_removeunusedcats(df);

Y = varfun(@mean, df, "InputVariables","Y","GroupingVariables",{'sbj', 'run'}) ;


rows_desired =  df_cogtest_rows & df_ntwprop_rows & df_cnd_rows & df_band_rows & df_sbj_rows & df_sbj_rows;
df_bl = DF(rows_desired, :);
df_cat_stripped = df_removeemptycats(df);


%%
ch = S.chan;
numsbj = numel(desired_sbjnames);

close all; figure;
sbj_chan_vals_mat = [];
for sbjidx = 1:numsbj
    sbj_name =  desired_sbjnames(sbjidx) ;
    sbj_row = df_bl.sbj == sbj_name;
    sbj_df = df_bl(sbj_row,:);
    sbj_chan_vals =  sbj_df.Y;
    sbj_chan_vals_mat(:,sbjidx) = sbj_chan_vals;
    nexttile
    topoplot(sbj_chan_vals, ch)

    drawnow; figure(gcf)
end
nexttile; 
nexttile;
topoplot(mean(sbj_chan_vals_mat,2), ch)
