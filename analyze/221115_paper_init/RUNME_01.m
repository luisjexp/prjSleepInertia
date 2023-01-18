function [] = RUNME_01(df_long)
%% INITIATE
    
    % SETTINGS
    cogtask = 'PVT';
    bandname  = 'delta';
    IV = 'deg_w'; 
    DV = 'gpsd'; 
    maxlevel = 3;
    t=1;
    categwthn_condition = true;
    categwthn_subject = true;
    condition2anz = 'control';

    DV_mean =  sprintf('mean_%s',DV);
    IV_mean =  sprintf('mean_%s',IV);        
    IV_level  = sprintf('%s_level',IV);
    desired_vars = [{DV},{IV},experimentalvars()];
    S = subjects(cogtask)  ;      

    % LOAD DATA
    % long to wide data frame
    df     = dflong2wide(df_long, cogtask, {'baseline', 'control','light'}, bandname, t,'keepchannels',true);
    df = df(:,desired_vars);
    
    % categorize the IV
    df= categcolumn(df,IV,maxlevel,"condition",categwthn_condition,"subject",categwthn_subject);
    df.(IV_level) = findgroups(df.(IV_level));
    
    % assess one conditoin only for now
    rows2keep = (df.condition == "baseline" | df.condition ==condition2anz);
    df = df(rows2keep,:);
    df =dfrmcats(df);
    df_mean = groupsummary(df,{'condition','sbj','chan'},'mean',{DV,IV});

    % FIGURE
    close all
    figure('Visible','on')
    T = tiledlayout(3,6);
%     T.Title.String = sprintf('(%s) %s after waking of each channel (%s, %s only) ', bandname, upper(gfn(DV)), cogtask,  condition2anz);
%     T.Title.Interpreter = "none";
%     T.Title.FontWeight = "bold";
     
    
    
 
    %% --------------------------------------------
    % FOR EACH CHANNEL, FOR EACH CONDITION, AND FOR BOTH VARIABLES, PLOT
    % THE DISTRIBUTION OF THE VARIABLE DURING BOTH CONDITIONS. EACH BOX HAS
    % A TOTAL OF [NUM SUBJECT] DATA POINTS.
    getvar = @(var_mean_name,condition,chan) df_mean.(var_mean_name)(df_mean.condition == condition & df_mean.chan == chan);
    runboxplot = @(var_mean_name) boxchart(df_mean.chan,df_mean.(var_mean_name),'GroupByColor',findgroups(df_mean.condition));
    setttitle = @(varname) title(sprintf('%s (%s) of each channel during baseline and control', gfn(varname),bandname));
    setylabel = @(varname) ylabel(sprintf('%s (%s) ', gfn(varname),bandname));

    df_mean_sbj = groupsummary(df,{'condition','chan'},'mean',{DV,IV});

    runtopoplot = @(var_mean_name,condition) topoplot(df_mean_sbj.(var_mean_name)(df_mean_sbj.condition == condition),S.chan,'electrodes','ptsnumbers','maplimits','maxmin');

    pval_set = nan(2,23);
    for varidx = 1:2
        if varidx == 1
            Z_mean = DV_mean;
            Z = DV;            
            ax_box_loc = {1,[1,3]};
            ax_top_bsl_loc = {4,[1,1]} ;
            ax_top_ctr_loc = {5,[1,1]} ;
            
        elseif varidx ==2
            Z_mean = IV_mean;
            Z = IV;            
            ax_box_loc = {7,[1,3]};
            ax_top_bsl_loc = {10,[1,1]} ;
            ax_top_ctr_loc = {11,[1,1]} ;            

        end
        % Box Chart
        nexttile(ax_box_loc{1},ax_box_loc{2}); hold on;
        bx = runboxplot(Z_mean)  ;
        bx(1).BoxFaceColor = 'k';
        setttitle(Z);
        setylabel(Z)
        xlabel('channel')

        n = numel(unique(df.sbj));
        legend({sprintf('Control (n=%d)',n), sprintf('Control (n=%d)',n)})
        

        % TEST    
        for i=1:23
            Zmu_bsl = getvar(Z_mean,'baseline',i) ;
            Zmu_ctr = getvar(Z_mean,'control',i) ;        
            
            [~, p] = ttest(Zmu_bsl,Zmu_ctr);
            pval_set(varidx,i) = p;
            if p<=.05                
                text( i,min(ylim),sprintf('*\n*%d*\n*',i),'Color','m','HorizontalAlignment','center');
                drawnow
            end
        end

        % TOPOPLOTS PLOTS DURING EACH CONDITION
        nexttile(ax_top_bsl_loc{1},ax_top_bsl_loc{2}); hold on;
        runtopoplot(Z_mean,'baseline');
        set(gca,'Visible','on','Color',[.4 .4 .4],'XColor','none','YColor','none')   
        title(sprintf('%s during Baseline',gfn(Z)))
        
        nexttile(ax_top_ctr_loc{1},ax_top_ctr_loc{2}); hold on;
        runtopoplot(Z_mean,'control');
        set(gca,'Visible','on','Color',[.95 .4 .4],'XColor','none','YColor','none')   
        
        title(sprintf('%s during Control',gfn(Z)))
    end



% TOPOPLOTS, CHANNEL VALUE IS THE AVERAGE VALUE ACCROSS SUBJECTS
% DV
nexttile(6,[1 1]);
sig_chan = find(pval_set(1,:)<=.05);
topoplot(...
        df_mean_sbj.(DV_mean)(df_mean_sbj.condition == 'control') -...
        df_mean_sbj.(DV_mean)(df_mean_sbj.condition == 'baseline') ,...
        S.chan,...
        'emarker2',{sig_chan,'*','m',20})

title(sprintf('Change in %s\n (Control - Baseline)',gfn(DV)))


% IV
nexttile(12);
sig_chan = find(pval_set(2,:)<=.05);
topoplot(...
        df_mean_sbj.(IV_mean)(df_mean_sbj.condition == 'control') -...
        df_mean_sbj.(IV_mean)(df_mean_sbj.condition == 'baseline') ,...
        S.chan,...
        'emarker2',{sig_chan,'*','m'});

c = colorbar;

title(sprintf('Change in %s\n(Control - Baseline)',gfn(IV)))


%% OLD/SKIP
%     %% PLOT FIT AND SCATTER OF EACH CONDITION HIGHLIGHING THE DV AT THE EXTREMES OF THE IV
%     
%     nexttile
%     [lm,ax_bsl] =  anzcond_scatt(df_bsl, DV,IV,IV_level,'anzexample',example_subject);
%     nexttile;
%     [lm,ax_ctr] =  anzcond_scatt(df_ctr, DV,IV,IV_level,'anzexample',example_subject);
%     
%     % OVERLAY FIT OF BOTH COND
%     ax = nexttile; 
%     ax_bl_2 = copyobj(ax_bsl(2),ax );
%     set(ax_bl_2,'Color','k','LineWidth',5)
%     
%     ax_ctr_2 = copyobj(ax_ctr(2),ax );
%     set(ax_ctr_2,'Color','r','LineWidth',5)
%     
%     
%     legend({sprintf('Nodes with LOW %s during baseline',IV),sprintf('Nodes with High %s during baseline',IV)})
%     drawnow;

end
%% FUNCTIONS

function [lm,ax_lm] =  anzcond_scatt(df_condition, DV,IV,IV_level,opts)
    arguments
        df_condition
        DV
        IV
        IV_level
        opts.anzexample = [];
    end    
    low_level_rows =  df_condition.(IV_level) == 1;
    hgh_level_rows =  df_condition.(IV_level) == max(df_condition.(IV_level));
    mid_level_rows = ~low_level_rows & ~hgh_level_rows;
    
    % fit model
    lm = fitlm(df_condition,"linear","ResponseVar",(DV),"PredictorVars",(IV));
        
    % Plot 
    
    % PLOT LINEAR MODEL
    ax_lm = lm.plot;
    hold on;
    delete(ax_lm([1 3 4]))
    set(ax_lm(2),'LineStyle', '-','Color','k')
    
    % SCATTER PLOT FOR HIGH AND LOW LVELS
    scatter(df_condition(mid_level_rows,:),IV,DV,'MarkerEdgeColor',[.3 .3 .3],'SizeData',10);
    scatter(df_condition(low_level_rows,:),IV,DV,'filled','MarkerFaceColor','b','MarkerEdgeColor','none','SizeData',10);
    scatter(df_condition(hgh_level_rows,:),IV,DV,'filled','MarkerFaceColor','m','MarkerEdgeColor','none','SizeData',10);

    
    % SAME FOR 
    if ~isempty(opts.anzexample)
        eg_sbj_rows=  df_condition.sbj == opts.anzexample;

        
        lm_egsbj = fitlm(df_condition(eg_sbj_rows,:),"linear","ResponseVar",(DV),"PredictorVars",(IV));
        ax_lm_egsbj = lm_egsbj.plot;
        delete(ax_lm_egsbj([1 3 4]))
        set(ax_lm_egsbj(2),'LineStyle', '-','Color','w') 

        scatter(df_condition(low_level_rows & eg_sbj_rows,:),IV,DV,'MarkerFaceColor','b','MarkerEdgeColor','w','Marker','diamond','SizeData',100);    
        scatter(df_condition(hgh_level_rows & eg_sbj_rows,:),IV,DV,'MarkerFaceColor','m','MarkerEdgeColor','w','Marker','diamond','SizeData',100);
    end
end
%% FUNTIONS FUNCTIONS
%% MAKE STUPID DATA FRAME 
function [dfxo, dfxo_mean,u] = unstackvars(df,DV,IV,IV_level,condition,iv_level_set)

    % FURTHER UNSTACK VARIABLES
    channames = cellstr(compose("ch%02d",1:23));
    X_bsl = unstack(df(df.condition == 'baseline', {'chan','sbj',IV}),{IV},'chan','NewDataVariableNames',channames);
    X_ctr = unstack(df(df.condition == 'control', {'chan','sbj',IV}),{IV},'chan','NewDataVariableNames',channames);
    Y_bsl = unstack(df(df.condition == 'baseline', {'chan','sbj',DV}),{DV},'chan','NewDataVariableNames',channames);
    Y_ctr = unstack(df(df.condition == 'control', {'chan','sbj',DV}),{DV},'chan','NewDataVariableNames',channames);
    c_bsl = unstack(df(df.condition == 'baseline', {'chan','sbj',IV_level}),{IV_level},'chan','NewDataVariableNames',channames);
    c_ctr = unstack(df(df.condition == 'control', {'chan','sbj',IV_level}),{IV_level},'chan','NewDataVariableNames',channames);
    

    Y_bsl = sortrows(Y_bsl, 'sbj');
    Y_ctr = sortrows(Y_ctr, 'sbj');
    c_bsl = sortrows(c_bsl, 'sbj');

    X_ctr = sortrows(X_ctr, 'sbj');
    X_bsl = sortrows(X_bsl, 'sbj');
    
    c_ctr = sortrows(c_ctr, 'sbj');
    

    Y_bsl.sbj = [];
    X_bsl.sbj = [];
    c_bsl.sbj = [];

    Y_ctr.sbj = [];
    X_ctr.sbj = [];
    c_ctr.sbj = [];
    
    u.Y_bsl=Y_bsl{:,:};
    u.Y_ctr=Y_ctr{:,:};
    u.cx_bsl=c_bsl{:,:};
    u.X_ctr=X_ctr{:,:};
    u.cx_ctr=c_ctr{:,:};
    u.X_bsl=X_bsl{:,:};

    dfxo = table();
    for iv_lev_idx = 1:numel(iv_level_set)
        iv_lev = iv_level_set(iv_lev_idx);
        df_bsl_xord = makedf(u,DV, IV,IV_level, 'baseline',iv_lev);
    
        df_ctr_xord = makedf(u,DV, IV,IV_level,condition,iv_lev);    
        dfxo = vertcat(dfxo,df_bsl_xord,df_ctr_xord);
    end
    
    dfxo_mean = groupsummary(dfxo,{'chan','condition','sbj'},'mean',{DV,IV});


end

%% ALL NODE DATA
function df_xord = makedf(u,DV_name,IV_name, iv_ord_name,condition,iv_ord_level)
    if strcmp(condition,'baseline')
        Y = u.Y_bsl;
        X = u.X_bsl;
    elseif strcmp(condition,'control')
        Y = u.Y_ctr;
        X = u.X_ctr;
    end
            

    numsbj  = size(u.cx_bsl,1);
    sbj_cnd = repmat((1:numsbj)',1,23);  
    cond_set= repmat({condition},numsbj,23);

    % Get the channels that have high (or low) levels of the IV during
    % baseline;
    d       = ones(1,size(u.cx_bsl,1)); 
    chan_xord_idx = u.cx_bsl== iv_ord_level ;       
    chan_xord = cellfun(@(chan) find(chan),mat2cell(chan_xord_idx,d),'UniformOutput',false);     
    
    
    % get the data (IV and DV) of the channels that have high (or low)
    % values of the IV **during baseline**
    varatchan = @(z) cellfun(@(Y,chan) Y(chan), mat2cell(z,d),chan_xord,'UniformOutput',false);        
    cnd_xord  = varatchan(cond_set);
    sbj_xord  = varatchan(sbj_cnd);
    Y_xord    = varatchan(Y);
    X_xord    = varatchan(X);
    xord_list = ones(sum(chan_xord_idx,'all'),1)*iv_ord_level;

    % Make Table
    mc = @(v) vertcat(reshape([v{:}],[],1));        
    df_xord = table(mc(sbj_xord),mc(cnd_xord),mc(chan_xord),mc(Y_xord),mc(X_xord),xord_list);
    df_xord.Properties.VariableNames ={'sbj','condition','chan',DV_name,IV_name, strcat(iv_ord_name,'_at_bsl')};
    df_xord.condition = categorical(df_xord.condition);        
end



%% FIX SIG STAR
function fixsigstar(h,p,bonfcorrect)

    if p<.05/(bonfcorrect)
            set(h(3),'String','*SIG!*')
            set(h(3),'Color','g',"FontSize",8)    
        else
            set(h(3),'String','n.s.')
            set(h(3),'Color','r',"FontSize",8)    
            set(h(3),'LineStyle',':','Color',[.3 .3 .3])        
    end
end