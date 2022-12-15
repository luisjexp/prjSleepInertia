function df = df4linmodelparse(ntwpropname, cogtestname , cndname, bandname, sbjidlist)
    arguments
        ntwpropname         
        cogtestname 
        cndname     
        bandname   
        sbjidlist 
    end

    DF = df4linmodel;
    cogtest_rows = ismember(DF.cogtest, cogtestname);
    ntwprop_rows = ismember(DF.ntwprop, ntwpropname);
    band_rows = ismember(DF.band, bandname);
    cond_rows = ismember(DF.condition, cndname);
    bl_rows  = ismember(DF.condition, 'baseline');
    run1_rows = DF.run == 1;
    run2_rows = DF.run == 2;
    run3_rows = DF.run == 3;
    run4_rows = DF.run == 4;
    sbj_rows = ismember(DF.sbjid, sbjidlist);
    
    bl_idx = cogtest_rows & ntwprop_rows & bl_rows & band_rows & sbj_rows;
    r1_idx = cogtest_rows & ntwprop_rows & cond_rows & band_rows & run1_rows & sbj_rows;
    r2_idx = cogtest_rows & ntwprop_rows & cond_rows & band_rows & run2_rows & sbj_rows;
    r3_idx = cogtest_rows & ntwprop_rows & cond_rows & band_rows & run3_rows & sbj_rows;
    r4_idx = cogtest_rows & ntwprop_rows & cond_rows & band_rows & run4_rows & sbj_rows;
    
    df_bl = DF(bl_idx,:);
    df_r1 = DF(r1_idx,:);
    df_r2 = DF(r2_idx,:);
    df_r3 = DF(r3_idx,:);
    df_r4 = DF(r4_idx,:);
    df = [df_bl; df_r1; df_r2; df_r3; df_r4];


end