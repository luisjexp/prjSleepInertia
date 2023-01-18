function RUNME_00(df_long)
%% INITIATE
    clearvars -except df_long; clc;

    % SETTINGS
    cogtask = 'GoNogo';
    bandname  = 'theta';
    IV = 'gpsd'; 
    DV = 'clust'; 
    maxlevel = 3;
    t=1;
    categwthn_condition = true;
    categwthn_subject = true;
    condition2anz = 'control';

    DV_mean =  sprintf('mean_%s',DV);
    IV_mean =  sprintf('mean_%s',IV);        
    IV_level  = sprintf('%s_level',IV);
    IV_level_at_bsl = sprintf('%s_at_bsl',IV_level);
    desired_vars = [{DV},{IV},experimentalvars()];
        

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
    [dfxo, dfxo_mean] = unstackvars(df,DV,IV,IV_level,condition2anz,maxlevel);

    % subject info
    sbjid_list = unique(df.sbj);
    numsubj = numel(sbjid_list);

    % INIT FIGS
    close all
    figure('Visible','on')
    T = tiledlayout(4,8);
    T.Title.String = sprintf('[%s %s] after waking (%s, %s only)among nodes with high levels of %s during *baseline*', bandname, upper(gfn(DV)), cogtask,  condition2anz, upper(gfn(IV)));
    T.Title.Interpreter = "none";
    T.Title.FontWeight = "bold";

%------------------------------------------
% ANALYZE MEANS OF SUBJECTS
    bonf = 2;
    sethisttext = @(res_str,fontcolor,iv_lev,ylim) text(iv_lev,max(ylim)*.9,res_str,'Interpreter','none','color',fontcolor,'FontSize',8,'BackgroundColor',[.5 .5 .5]);
    settitle = @(yname) title(sprintf('*Average* %s of channels after waking\n with Low and High %s during baseline',gfn(yname),gfn(IV)),'FontSize',14);
    setxlabel=@() xlabel(sprintf('%s %s level during baseline',bandname, gfn(IV)),'FontSize',14);
    setylabel=@(varname) ylabel(sprintf('%s %s %s',(bandname), gfn(varname)),'FontSize',14);
    
    getvar = @(var_mean_name,condition,iv_ord_level) dfxo_mean.(var_mean_name)(dfxo_mean.condition == condition & dfxo_mean.(IV_level_at_bsl) == iv_ord_level);
    runboxplot = @(var_mean_name) boxchart(dfxo_mean.(IV_level_at_bsl),dfxo_mean.(var_mean_name),'GroupByColor',dfxo_mean.condition);
    setboxticks = @(ax) set(ax,"XTick",[1 maxlevel],'XTickLabel',{'LOW','HIGH'});
    
    for varidx = 1:2
        if varidx == 1
            Z_mean = DV_mean;
            Z = DV;
            ax_loc = {1,[1,4]};
            
        elseif varidx ==2
            Z_mean = IV_mean;
            Z = IV;
            ax_loc = {5,[1,4]};
        end
        % Box Chart
        ax = nexttile(ax_loc{1},ax_loc{2}); hold on;
        bx = runboxplot(Z_mean);
        bx(1).BoxFaceColor = 'k';
        setboxticks(ax)

            
        % Test the effect of wakint at low levels of IV variable
        Zmu_x0_bsl = getvar(Z_mean,'baseline',1) ;
        Zmu_x0_ctr = getvar(Z_mean,'control',1) ;        
        nx0 = numel(Zmu_x0_ctr);
        [tst_str,fntclr] = testsbjmeans(Zmu_x0_bsl,Zmu_x0_ctr,bonf);
        
        
        sethisttext(tst_str,fntclr,1,ylim)
        settitle(Z) 
        setxlabel();
        setylabel(Z);
        
        % Test the effect of waking at High levels of the IV            
        Zmu_x1_bsl = getvar(Z_mean,'baseline',maxlevel) ;
        Zmu_x1_ctr = getvar(Z_mean,'control',maxlevel) ;     
        nx1 = numel(Zmu_x1_ctr);
  
        [tst_str,fntclr] = testsbjmeans(Zmu_x1_bsl,Zmu_x1_ctr,bonf);
        sethisttext(tst_str,fntclr,maxlevel,ylim)

        settitle(Z) 
        setxlabel();
        setylabel(Z);  

        legend({'Channels during: baseline',strcat('during :', condition2anz)},'Location','north');
%         text(.5,.7,sprintf('n_l_o_w=%d\nn_h_i_g_h=%d',nx0,nx1),'HorizontalAlignment','center','Units','normalized')
        

    end
    
    
%
%------------------------------------------
% ANALYSIS (Accross subjects)
    
% [AVERAGE VALUE OF NODES WITH HIGH IV VALUES FOR EACH SUBJECT] VS.
% [AVERAGE VALUE OF NODES WITH *LOW* IV VALUES FOR EACH SUBJECT][ALL NODES
% OF ALL SUBJECTS WITH LOW IV VALUES DURING BASELINE]. WE USE T-TEST (LOOKS
% NORMAL, AND DEPENDENT SAMPLES):

    bonf = 4;
    % Init repeating Box plots functions
    runboxplot = @(var_mean_name) boxchart(dfxo.(IV_level_at_bsl),dfxo.(var_mean_name),'GroupByColor',dfxo.condition);        
    setboxylabel=@(varname) ylabel(sprintf('%s %s',(bandname), gfn(varname)),'FontSize',14);
    setboxxlabel=@() xlabel(sprintf('%s',gfn(IV)),'FontSize',14);
    setboxtitle = @(yname) title(sprintf('%s of channels with\n Low and High %s*',gfn(yname),gfn(IV)),'FontSize',14);
    
    
    % Init repeating histogram function    
    runhistplots = @(Z_x_bsl,Z_x_ctr) [histogram(Z_x_bsl,'NumBins',15,'FaceColor','k'); histogram(Z_x_ctr,'NumBins',15,'FaceColor','r')];
    sethisttitle = @(dv_name,iv_lev_string) title(sprintf('%s of channels with a\n %s level of %s',gfn(dv_name),iv_lev_string,gfn(IV)),'FontSize',14);
    sethisttext = @(res_str,fontcolor,ylim) text(.5,.9,res_str,'Interpreter','none','color',fontcolor,'FontSize',8,'BackgroundColor',[.5 .5 .5],'Units','normalized','HorizontalAlignment','center');        
    sethistxlabel=@(varname) xlabel(sprintf('%s %s @t=(%d)',(bandname), gfn(varname),t),'FontSize',14);
    sethistylabel=@() ylabel('Count','FontSize',14);

    getvar = @(var_name,condition,iv_ord_level) dfxo.(var_name)(dfxo.condition == condition & dfxo.(IV_level_at_bsl) == iv_ord_level);
          

    for varidx = 1:2
       if varidx == 1
            Z = DV;
            ax_box_loc = {9,[1,4]};
            ax_hist1_loc = {17,[1,2]};
            ax_hist2_loc = {19,[1,2]};
        elseif varidx == 2
            Z = IV;
            ax_box_loc = {13,[1,4]};
            ax_hist1_loc = {21,[1,2]};
            ax_hist2_loc = {23,[1,2]};                
        end            
        % BOX CHARTS OF THE VARIABLES
        axbx = nexttile(ax_box_loc{1},ax_box_loc{2}); hold on;
            % Clean
            bx =runboxplot(Z);
            bx(1).BoxFaceColor = 'k';
            setboxylabel(Z) 
            setboxticks(gca)
            setboxxlabel()
            setboxtitle(Z)
            legend({sprintf('Baseline'),strcat('during-', condition2anz)},'Location','best');
            

        % Hist of effects at low levels of the IV
        Y_x0_ctr = getvar(Z,'control',1);   
        Y_x0_bsl = getvar(Z,'baseline',1); 
        [tst_str,fntclr] = testaccrosssubj(Y_x0_bsl,Y_x0_ctr,bonf);
        nx0 = numel(Y_x0_ctr);
            % Hist
            nexttile(ax_hist1_loc{1},ax_hist1_loc{2}); hold on;
            runhistplots(Y_x0_bsl,Y_x0_ctr)

            % Clean
            sethisttitle(Z,'LOW')   
            sethisttext(tst_str,fntclr,ylim) 
            sethistxlabel(DV)
            sethistylabel();
            legend({sprintf('Baseline'),strcat('during-', condition2anz)},'Location','best');

        % Hist of effects at HIGH levels of the IV
        Y_x1_ctr = getvar(Z,'control',maxlevel);  
        Y_x1_bsl = getvar(Z,'baseline',maxlevel); 
        nx1 = numel(Y_x1_ctr);

        [tst_str,fntclr] = testaccrosssubj(Y_x1_ctr,Y_x1_bsl,bonf);
       
            % Hist
            nexttile(ax_hist2_loc{1},ax_hist2_loc{2}); hold on;
            runhistplots(Y_x1_ctr,Y_x1_bsl)

            % Clean 
            sethisttitle(Z,'HIGH')            
            sethisttext(tst_str,fntclr,ylim) 
            sethistxlabel(Z)
            sethistylabel();
            legend({sprintf('Baseline'),strcat('during-', condition2anz)},'Location','best');

        % Clean more
        text(axbx,.5,.7,sprintf('n_l_o_w=%d\nn_h_i_g_h=%d',nx0,nx1),'HorizontalAlignment','center','Units','normalized')

    end

%------------------------------------------
%% ANALYSIS (within subject)

    % FOR EACH SUBJECT [ALL NODES WITH HIGH IV VALUES DURING BASELINE]  VS.
    % [ALL NODES WITH LOW IV VALUES DURING BASELINE]. WE USE TTEST, DUE TO
    % SAMPLES BEING DEPENDENT
    

    % Data and FX to extrack them
    bnf = 1;
    dfx0= dfxo(dfxo.(IV_level_at_bsl) == 1 ,:)   ;     
    dfx1= dfxo(dfxo.(IV_level_at_bsl) == maxlevel,:)   ;     

    getdf_x1_sbj = @(sbjidx,ZV,condition) dfx1.(ZV)(dfx1.sbj == sbjidx & dfx1.condition == condition);        
    getdf_x0_sbj = @(sbjidx,ZV,condition) dfx0.(ZV)(dfx0.sbj == sbjidx & dfx0.condition == condition);
   
    ttest_xord_0 = @(j,Z) ttest(getdf_x0_sbj(j,Z,'baseline'),getdf_x0_sbj(j,Z,'control'));
    ttest_xord_1 = @(j,Z) ttest(getdf_x1_sbj(j,Z,'baseline'),getdf_x1_sbj(j,Z,'control'));
    

    % Init plots
    runbox = @(dfx0,DV) boxchart(dfx0.sbj,dfx0.(DV),'GroupByColor',dfx0.condition);        
    settitle = @(varname,iv_lev) title(sprintf('%s (%s) of channels with\n %s %s during baseline',gfn(varname),bandname,iv_lev,gfn(IV)),'Interpreter','none','FontSize',14);    
    
    setylabel = @(varname) ylabel(sprintf('%s (%s)',gfn(varname),bandname),'Interpreter','none','FontSize',14);    

    setxlabel = @() xlabel(sprintf('Subject'),'FontSize',14); 

    % Tests
    
    for varidx = 1:2
        if varidx == 1
            ax_x0 = nexttile(25,[1 2]); hold on;
            ax_x1 = nexttile(27,[1,2]); hold on;
            Z = DV;
        elseif varidx ==2
            ax_x0 = nexttile(29,[1 2]); hold on;
            ax_x1 = nexttile(31,[1,2]); hold on;
            Z = IV;
            
        end

        axes(ax_x0)
        bx = runbox(dfx0,Z);
        bx(1).BoxFaceColor = 'k';
        setylabel(Z);
        settitle(Z,'LOW')
        setxlabel() 
    
        for j = 1:numsubj
            [~, pval_x0] = ttest_xord_0(j,Z); 
            if pval_x0 <= (.05)/bnf
                sigstar({[j-.1 j+.1]});
            end
        end


        axes(ax_x1)
        bx = runbox(dfx1,Z)    ;    
        bx(1).BoxFaceColor = 'k';
        setylabel(Z);
        settitle(Z,'HIGH')
        setxlabel() 
        for j = 1:numsubj
            [~, pval_x1] = ttest_xord_1(j,Z);       
            if pval_x1 <= (.05)/bnf
                sigstar({[j-.1 j+.1]});
            end

        end

    end

    % Add legend to the middle plot of the subject plots row
    legend({sprintf('Baseline channels with HIGH %s',IV),...
        sprintf('Same channels but during control condition'),...
        sprintf('ttest(dependent) | bonf=%d',bnf)},'Location','best','Interpreter','none','FontSize',12);














end

%% FUNCTIONS FUNCTIONS FUNCTIONS
%% MAKE STUPID DATA FRAME 
function [dfxo, dfxo_mean,u] = unstackvars(df,DV,IV,IV_level,condition,maxlevel)

    % FURTHER UNSTACK VARIABLES
    channames = cellstr(compose("ch%02d",1:23));
    X_bsl = unstack(df(df.condition == 'baseline', {'chan','sbj',IV}),{IV},'chan','NewDataVariableNames',channames);
    X_ctr = unstack(df(df.condition == 'control',  {'chan','sbj',IV}),{IV},'chan','NewDataVariableNames',channames);
    Y_bsl = unstack(df(df.condition == 'baseline', {'chan','sbj',DV}),{DV},'chan','NewDataVariableNames',channames);
    Y_ctr = unstack(df(df.condition == 'control',  {'chan','sbj',DV}),{DV},'chan','NewDataVariableNames',channames);
    c_bsl = unstack(df(df.condition == 'baseline', {'chan','sbj',IV_level}),{IV_level},'chan','NewDataVariableNames',channames);
    c_ctr = unstack(df(df.condition == 'control',  {'chan','sbj',IV_level}),{IV_level},'chan','NewDataVariableNames',channames);
    

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


    df_bsl_x0 = makedf(u,DV, IV,IV_level,'baseline',1);    
    df_bsl_x1 = makedf(u,DV, IV,IV_level, 'baseline',maxlevel);
    df_ctr_x0 = makedf(u,DV, IV,IV_level,condition,1)   ; 
    df_ctr_x1 = makedf(u,DV, IV,IV_level,condition,maxlevel);

    IV_level_at_bsl = sprintf('%s_at_bsl',IV_level);

    dfxo = vertcat(df_bsl_x0,df_bsl_x1,df_ctr_x0,df_ctr_x1);
    dfxo_mean = groupsummary(dfxo,{IV_level_at_bsl,'condition','sbj'},'mean',{DV,IV});


end
%% SUBJECT MEANS: GET DATA FOR MEANS OF SUBJECTS
function [Zmu_x0_bsl, Zmu_x0_ctr, Zmu_x1_bsl, Zmu_x1_ctr]=getmeansubj(u,var_name,max_level)
    
    [Z_x0_bsl, Z_x0_ctr, Z_x1_bsl, Z_x1_ctr]=getnodedata(u,var_name,max_level);

    Zmu_x0_bsl = cellfun(@mean, Z_x0_bsl) ;
    Zmu_x0_ctr = cellfun(@mean, Z_x0_ctr) ;
    Zmu_x1_bsl = cellfun(@mean, Z_x1_bsl) ;
    Zmu_x1_ctr = cellfun(@mean, Z_x1_ctr) ;
end


%% SUBJECT MEANS: PLT BOXES OF MEANS OF SUBJECTS
function plotsmeansbox(Ymu_x0_bsl,Ymu_x0_ctr,Ymu_x1_bsl,Ymu_x1_ctr,maxlevel,DV_name, IV_name,bonf,ax)
    p = @(Y) zeros(numel(Y),1);

    axes(ax); hold on;
    % Low IVs
    boxchart(1+p(Ymu_x0_bsl)-.15, Ymu_x0_bsl,'BoxFaceColor','k','BoxWidth',.1);
    boxchart(1+p(Ymu_x0_ctr)+.15, Ymu_x0_ctr,'BoxFaceColor','r','BoxWidth',.1);

    text(1,max(ylim),res_str,'Interpreter','none','color',fontcolor,'FontSize',8,'BackgroundColor',[[.5 .5 .5]]);
    title(sprintf('Difference in %s among nodes with HIGH levels of',upper(DV_name),upper(IV_name)));

    % High
    boxchart(maxlevel+p(Ymu_x1_bsl)-.15, Ymu_x1_bsl,'BoxFaceColor','k','BoxWidth',.1);
    boxchart(maxlevel+p(Ymu_x1_ctr)+.15, Ymu_x1_ctr,'BoxFaceColor','r','BoxWidth',.1);

    [res_str,fontcolor] = testsbjmeans(Ymu_x1_bsl,Ymu_x1_ctr,bonf);
    text(maxlevel,max(ylim),res_str,'Interpreter','none','color',fontcolor,'FontSize',8,'BackgroundColor',[.5 .5 .5]);

    xlabel(sprintf('Channel''s level of %s',upper(IV_name)))
    ylabel(sprintf('%s', DV_name));
    title(sprintf('Difference in %s among nodes with HIGH levels of',upper(DV_name),upper(IV_name)));

end
%% SUBJECT MEANS: PLOT HISTOGRAMS OF MEANS OF SUBJECTS
function plotsmeanshist(Zmu_x0_bsl,Zmu_x0_ctr,Zmu_x1_bsl,Zmu_x1_ctr,DV_name, IV_name,bonf,ax_x0,ax_x1)
        sethisttitle = @(ax,dv_name,iv_lev_string,iv_name) title(ax,sprintf('%s at %s levels of %s',dv_name,iv_lev_string,iv_name));

        axes(ax_x0); hold on;
        histogram(Zmu_x0_bsl,'FaceColor','k');
        histogram(Zmu_x0_ctr,'FaceColor','r');
        sethisttitle(gca,DV_name,'LOW',IV_name)

        [res_str,fontcolor] = testsbjmeans(Zmu_x0_bsl,Zmu_x0_ctr,bonf);
        text(.3,.9,res_str,'Interpreter','none','color',fontcolor,'FontSize',8,'Units','normalized','BackgroundColor',[.5 .5 .5]);
        xlabel(sprintf('%s', upper(DV_name)))
        legend({'Channels during-baseline','during control'})
        

        % Histogram % High IVs
        axes(ax_x1); hold on;
        histogram(Zmu_x1_bsl,'FaceColor','k');
        histogram(Zmu_x1_ctr,'FaceColor','r');
        sethisttitle(gca,DV_name,'HIGH',IV_name)
        [res_str,fontcolor] = testsbjmeans(Zmu_x1_bsl,Zmu_x1_ctr,bonf);
        text(.3,.9,res_str,'Interpreter','none','color',fontcolor,'FontSize',8,'Units','normalized','BackgroundColor',[.5 .5 .5]);
        xlabel(sprintf('%s', upper(DV_name)))   
end

%% SUBJECT MEANS: TEST 
 function [res_str,fontcolor] = testsbjmeans(bsl,ctr,bonf)
        [~, p] = ttest(bsl,ctr);
    
        if p<(.05/bonf)
            res_str = sprintf('(SIG!!!,p:%.02f,bonf=2)',p);
            fontcolor = 'g';
        else
            res_str = sprintf('n.s',p);
            fontcolor = 'k';
        end
    end     

%% ACCROSS SUBJECTS:  GET NODES OF ALL SUBJECTS (NO AVERAGING)
function [Z_x0_bsl, Z_x0_ctr, Z_x1_bsl, Z_x1_ctr]=getnodedata(u,var_name,max_level)
    switch var_name
        case 'DV'
            Z_ctr = u.Y_bsl;
            Z_bsl = u.Y_ctr;        
        case 'IV'
            Z_ctr = u.X_bsl;
            Z_bsl = u.X_ctr;
    end
    
    d = ones(1,size(u.cx_bsl,1));
    
    chan_x0 = cellfun(@(chan) find(chan),mat2cell(u.cx_bsl== 1,d),'UniformOutput',false);
    chan_x1 = cellfun(@(chan) find(chan),mat2cell(u.cx_bsl== max_level,d),'UniformOutput',false);
    
    Z_x0_bsl = cellfun(@(Y,chan_x) Y(chan_x), mat2cell(Z_bsl,d), chan_x0,'UniformOutput',false) ;
    Z_x0_ctr = cellfun(@(Y,chan_x) Y(chan_x), mat2cell(Z_ctr,d), chan_x0,'UniformOutput',false) ;
    Z_x1_bsl = cellfun(@(Y,chan_x) Y(chan_x), mat2cell(Z_bsl,d), chan_x1,'UniformOutput',false) ; 
    Z_x1_ctr = cellfun(@(Y,chan_x) Y(chan_x), mat2cell(Z_ctr,d), chan_x1,'UniformOutput',false) ;


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

%% ACCROSS SUBJECTS: TEST NODES ACCROSS SUBJECTS
function [res_str,fontcolor] = testaccrosssubj(bsl,ctr,bonf)
    [~, p] = ttest2(bsl,ctr);

    if p<(.05/bonf)
        res_str = sprintf('!SIG!,p:%.02f,bonf=%d,ttest,independent',p,bonf);
        fontcolor = 'g';
    else
        res_str = sprintf('n.s,p:%.02f,bonf=%d,ttest2,independent',p,bonf);
        fontcolor = 'k';
    end
end



%% WITHIN SUBJECT: TEST WITHIN SUBJECT
function testwithinsbj(j,Z_zord_bsl,Z_xord_ctr,chan,bonfcorect,ax)
    axes(ax); hold on;
    
    % TEST DV
    [~, p] = ttest(Z_zord_bsl(j,chan),Z_xord_ctr(j,chan));
    h = sigstar({[j-.1 j+.1]});
    fixsigstar(h,p,bonfcorect,'ax',ax)      
end



%% WITHIN SUBJECT: FIX SIG STAR
function fixsigstar(h,p,bonfcorrect,opts)
    arguments
    h,p,bonfcorrect,
    opts.test_type ='';
    opts.ax = nexttile;
    end

    axes(opts.ax);
    if p<.05/(bonfcorrect)
            set(h(2),'String',strcat('* SIG * ',opts.test_type))
            set(h(2),'Color','g',"FontSize",12)    
        else
            set(h(2),'String',strcat('n.s',opts.test_type))
            set(h(2),'Color','r',"FontSize",8)    
            set(h(1),'LineStyle',':','Color',[.3 .3 .3])        
    end
end

