function [lm,ax_lm] =  anzcond_scatt(df, DV,IV,IV_level,opts)
    arguments
        df
        DV
        IV
        IV_level
        opts.anzexample = [];
    end    
    low_level_rows =  df.(IV_level) == 1;
    hgh_level_rows =  df.(IV_level) == max(df.(IV_level));
    mid_level_rows = ~low_level_rows & ~hgh_level_rows;
    
    % fit model
    lm = fitlm(df,"linear","ResponseVar",(DV),"PredictorVars",(IV));
        
    % Plot 
    
    % PLOT LINEAR MODEL
    ax_lm = lm.plot;
    hold on;
    delete(ax_lm([1 3 4]))
    set(ax_lm(2),'LineStyle', '-','Color','k')
    
    % SCATTER PLOT FOR HIGH AND LOW LVELS
    scatter(df(mid_level_rows,:),IV,DV,'MarkerEdgeColor',[.3 .3 .3],'SizeData',10);
    scatter(df(low_level_rows,:),IV,DV,'filled','MarkerFaceColor','b','MarkerEdgeColor','none','SizeData',10);
    scatter(df(hgh_level_rows,:),IV,DV,'filled','MarkerFaceColor','m','MarkerEdgeColor','none','SizeData',10);

    
    % SAME FOR 
    if ~isempty(opts.anzexample)
        eg_sbj_rows=  df.sbj == opts.anzexample;

        
        lm_egsbj = fitlm(df(eg_sbj_rows,:),"linear","ResponseVar",(DV),"PredictorVars",(IV));
        ax_lm_egsbj = lm_egsbj.plot;
        delete(ax_lm_egsbj([1 3 4]))
        set(ax_lm_egsbj(2),'LineStyle', '-','Color','w') 

        scatter(df(low_level_rows & eg_sbj_rows,:),IV,DV,'MarkerFaceColor','b','MarkerEdgeColor','w','Marker','diamond','SizeData',100);    
        scatter(df(hgh_level_rows & eg_sbj_rows,:),IV,DV,'MarkerFaceColor','m','MarkerEdgeColor','w','Marker','diamond','SizeData',100);
    end
end