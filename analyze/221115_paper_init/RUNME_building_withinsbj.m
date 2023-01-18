%% CONDITION TOPOPLOTS*

%% First retreive Master Data Set

cog_task_list = {'PVT'};
df_long =  dflong('cogtestlist',cog_task_list,'getd2cdf',false);

%% INITIATE
clearvars -except df_long; clc;


% SETTINGS
cogtask = 'PVT';
bandname  = 'alpha';
IV = 'deg_w'; 
DV = 'gpsd'; 
numlevels = 3;
t=1;
bonfcorrect = 2;
categwthn_condition = true;
categwthn_subject = true;

% INIT
DV_mean =  sprintf('mean_%s',DV);
IV_level  = sprintf('%s_level',IV);
desired_vars = [{DV},{IV},experimentalvars()];

% LOAD DATA
df     = dflong2wide(df_long, cogtask, {'baseline', 'control','light'}, bandname, t,'keepchannels',true);
df = df(:,desired_vars);

% CATEGORIZE THE IV.
df= categcolumn(df,IV,numlevels,"condition",categwthn_condition,"subject",categwthn_subject);
df.(IV_level) = findgroups(df.(IV_level));
[df_bsl, df_ctr, df_lgt] = splitdfbycondition(df);



% SUBJECT IDS
sbjid_list = unique(df.sbj);
numsubj = numel(sbjid_list);
example_subject = sbjid_list(1);

% FUNCTIONS
getsbjdf        = @(df,sbjid) df(df.sbj == sbjid,:);
chan_ivlevel    = @(df,desiredlevel) df.chan(df.(IV_level) == desiredlevel & df.condition == unique(df.condition)); 

getrows         = @(df_sbj_ctr, ch_IV_low_bsl) ismember(df_sbj_ctr.chan, ch_IV_low_bsl);
getDV           = @(df,desired_chan) df.(DV)(getrows(df, desired_chan));



% -------------ANALYSIS:1.1 ----------------------- 
% ANALYSIS:1.1 For each subject, get Differences in DV among nodes with high
% IV during their respective conditions, HEY1!!!. you cant run this
% analysis, because for a given subject, there may be more nodes with high
% IV in one condition vs the others. for each subject you need to average
% the channels with high IV first, then vaerage those with low IV, then
% compare. Thus each subject will have one two data points for each
% condition. obviously the difference cannot be tested.



% ------------------------------------ 
% ANALYSIS 1.2
% 
% Differences in DV among nodes with high IV during baseline, VS among
% nodes with high IV during control AVERAGING WITHIN SUBJECTS

clc;
close all;
figure('GraphicsSmoothing','off');

% FIRST
% BOX PLOT
testtype = 'signrank';
anzcond_box(df,DV,IV,IV_level,testtype);

% PLOT HISTOGRAM COMPARING THE DV OF LOW IV NODES
df_bsl_mean = groupsummary(df_bsl,{'condition',IV_level,'sbj'},'mean',DV);
df_ctr_mean = groupsummary(df_ctr,{'condition',IV_level,'sbj'},'mean',DV);


df_bsl_iv_lev_min = df_bsl_mean.(DV_mean)(df_bsl_mean.(IV_level) == 1,:);
df_ctr_iv_lev_min = df_ctr_mean.(DV_mean)(df_ctr_mean.(IV_level) == 1,:);

p = signrank(df_bsl_iv_lev_min,df_ctr_iv_lev_min);


nexttile;
hold on;
histogram(df_bsl_iv_lev_min,10,'FaceColor','k');
histogram(df_ctr_iv_lev_min,10);

if p<.05/2
    text(.3,.8,'Significant using rank sign','Color','g','FontSize',12,'Units','normalized')
else
    text(.3,.9,'NS (using rank sign)','Color','r','FontSize',8,'Units','normalized')
end
xlabel(DV_mean)
legend({sprintf('Nodes with LOW %s during BASELINE',IV),sprintf('Nodes with LOW %s during control',IV)})
drawnow

% PLOT HISTOGRAM COMPARING THE DV OF HIGH IV NODES

df_bsl_iv_lev_max = df_bsl_mean.(DV_mean)(df_bsl_mean.(IV_level) == numlevels,:);
df_ctr_iv_lev_max = df_ctr_mean.(DV_mean)(df_ctr_mean.(IV_level) == numlevels,:);

p = signrank(df_bsl_iv_lev_max,df_ctr_iv_lev_max);

nexttile;
hold on;
histogram(df_bsl_iv_lev_max,10,'FaceColor','k');
histogram(df_ctr_iv_lev_max,10);

if p<.05/2
    text(.3,.8,'Significant using rank sign','Color','g','FontSize',12,'Units','normalized')
else
    text(.3,.9,'NS (using rank sign)','Color','r','FontSize',8,'Units','normalized')
end
xlabel(DV_mean)
legend({sprintf('Nodes with LOW %s during BASELINE',IV),sprintf('Nodes with LOW %s during control',IV)})
drawnow


% ------------------------------------ 
% ANALYSIS 1.3
% 
% Differences in DV among nodes with high IV during baseline, VS among
% nodes with high IV during control NO AVERAGING. WE USE RANK SUM BECAUSE
% SAMPLES ARE NOT PAIRED (EG HIGH LEVEL NODES CANT BE DIFFERENT IN ONE
% CONDITION)
nexttile
df_mean = groupsummary(df,{'chan',IV_level,'condition','sbj'},'mean',DV);
df_mean = df_mean(ismember(df_mean.(IV_level),[1,numlevels]),:);

getdfdv = @(df_mean,dv,condition,ivlevel) df_mean.(dv)(df_mean.condition == condition & df_mean.(IV_level) == ivlevel);

% COMPARE NODES WITH LOW LEVELS OF THE IV
xbsl_min = getdfdv(df_mean,DV_mean,'baseline',1);
xctr_min = getdfdv(df_mean,DV_mean,'control',1);
xlgt_min = getdfdv(df_mean,DV_mean,'light',1);

signrank
boxchart(df_mean.(IV_level),df_mean.(DV_mean), 'GroupByColor',df_mean.condition)
legend




%%
% SCATTER/FIT 
nexttile;
[lm_bsl, ax_bsl] = anzcond_scatt(df_bsl, DV,IV,IV_level,'anzexample',example_subject);
title('BASELINE')

nexttile
[lm_ctr, ax_ctr] = anzcond_scatt(df_ctr, DV,IV,IV_level,'anzexample',example_subject);
title('CONTROL')

% OVERLAY FIT OF BOTH COND
ax = nexttile; 
ax_bl_2 = copyobj(ax_bsl(2),ax );
set(ax_bl_2,'Color','k','LineWidth',5)

ax_ctr_2 = copyobj(ax_ctr(2),ax );
set(ax_ctr_2,'Color','r','LineWidth',5)


legend({sprintf('Nodes with LOW %s during baseline',IV),sprintf('Nodes with High %s during baseline',IV)})
drawnow;

%% ------------------------------------ 
% ANALYSIS: 

% Differences in DV among nodes with high IV during baseline only
inittable_anz2 = @(ch_list, DV_dif,sbjid,desired_iv_level) table(...
    ch_list,...    
    repmat(sbjid,numel(ch_list),1),...
    DV_dif,...
    repmat(desired_iv_level,numel(ch_list),1)...
    );

T_ivlev_bsl = table;
T_ivlev_within = table;

for j = 1:numsubj
    sbjid =  sbjid_list(j);
    df_sbj_bsl = getsbjdf(df_bsl,sbjid);
    df_sbj_ctr = getsbjdf(df_ctr,sbjid);
    
    ch_ivlow_bsl  = chan_ivlevel(df_sbj_bsl,1 );  
    ch_ivhgh_bsl  = chan_ivlevel(df_sbj_bsl,numlevels );   

    % Change in DV for nodes with low IV during baseline
    dDV_ivlow_bsl = getDV(df_sbj_ctr,ch_ivlow_bsl)  - getDV(df_sbj_bsl,ch_ivlow_bsl) ;
    t_ivlow_bsl = inittable_anz2(ch_ivlow_bsl,dDV_ivlow_bsl,sbjid,1);
    
    % Change in DV for nodes with High IV during baseline
    dDV_ivhgh_bsl = getDV(df_sbj_ctr,ch_ivhgh_bsl)  - getDV(df_sbj_bsl,ch_ivhgh_bsl) ;
    t_ivhgh_bsl = inittable_anz2(ch_ivhgh_bsl,dDV_ivhgh_bsl,sbjid,numlevels);

    T_ivlev_bsl = [T_ivlev_bsl;t_ivlow_bsl;t_ivhgh_bsl];

end

T_ivlev_bsl.Properties.VariableNames = {'chan','sbj',sprintf('%s_diff_ctrl',DV),sprintf('%s_at_baseline',IV)};
close all
figure;

% ANALYSIS: FOR EACH SUBJECT [ALL NODES WITH HIGH IV VALUES DURING BASELINE]
% VS. [ALL NODES WITH LOW IV VALUES DURING BASELINE]. WE USE RANK SUM TEST,
% DUE TO LOW SAMPLE SIZE, AND DEPENDENT (ALTHOUGH THIS IS DEBATABLE)

nexttile
boxchart(T_ivlev_bsl.sbj,T_ivlev_bsl.("gpsd_diff_ctrl"),'GroupByColor',T_ivlev_bsl.deg_w_at_baseline);
hold on;
for j = 1:numsubj
    sbjid = sbjid_list(j);
    tsbj = T_ivlev_bsl(T_ivlev_bsl.sbj == sbjid,:);
    x = T_ivlev_bsl.("gpsd_diff_ctrl")( (tsbj.("deg_w_at_baseline") == 1));
    y = T_ivlev_bsl.("gpsd_diff_ctrl")( (tsbj.("deg_w_at_baseline") == numlevels));
    p = signrank(x,y);

    h = sigstar({[sbjid-.3 sbjid+.3]});
    if p<.05/(bonfcorrect)
        set(h(2),'String',sprintf('*SIG!*(%d)',sbjid))
        set(h(2),'Color','g',"FontSize",12)    
        
    else
        set(h(2),'String',sprintf('n.s.\n(%d)\n\n',sbjid))
        set(h(2),'Color','r',"FontSize",8)    
        set(h(1),'LineStyle',':','Color',[.3 .3 .3])        
    end
end
ylabel(sprintf('Change in %s after waking (control)',DV))
xlabel('Subject ID')
legend( {sprintf('Nodes w/ "LOW" %s',upper(IV)), sprintf('Nodes w/ "HIGH" %s',upper(IV))},'Location','best');


% ANALYSIS: [ALL NODES OF ALL SUBJECTS WITH HIGH IV VALUES DURING BASELINE]
% VS. [ALL NODES OF ALL SUBJECTS WITH LOW IV VALUES DURING BASELINE].
% WE USE T-TEST (LOOKS NORMAL, AND DEPENDENT SAMPLES):
ax = nexttile;
boxchart(T_ivlev_bsl.("deg_w_at_baseline"),T_ivlev_bsl.("gpsd_diff_ctrl"));

x = T_ivlev_bsl.("gpsd_diff_ctrl")( (T_ivlev_bsl.("deg_w_at_baseline") == 1));
y = T_ivlev_bsl.("gpsd_diff_ctrl")( (T_ivlev_bsl.("deg_w_at_baseline") == numlevels));
p = ttest(x,y);

h = sigstar({[1 numlevels]});
if p<.05/(bonfcorrect)
    set(h(2),'String',sprintf('***SIGNIFICANT! %.03f',p))
    set(h(2),'Color','g')
else
    set(h(2),'String',sprintf('NOT SIG (%.03f)',p))
    set(h(2),'Color','r')    
    set(h(1),'LineStyle',':','Color',[.3 .3 .3])        
end


ax.XTick =  [1  numlevels]; 
ax.XTickLabel = {sprintf('Nodes w/ "LOW" %s',upper(IV)), sprintf('Nodes w/ "HIGH" %s',upper(IV))};
ylabel(sprintf('Change in %s after waking (control)',DV))
xlabel('NODE LEVEL DURING BASELINE')


% ANALYSIS: [AVERAGE VALUE OF NODES WITH HIGH IV VALUES FOR EACH SUBJECT]
% VS. [AVERAGE VALUE OF NODES WITH *LOW* IV VALUES FOR EACH SUBJECT][ALL
% NODES OF ALL SUBJECTS WITH LOW IV VALUES DURING BASELINE]. WE USE T-TEST
% (LOOKS NORMAL, AND DEPENDENT SAMPLES):
ax = nexttile;
T_sbj_mean = groupsummary(T_ivlev_bsl,["sbj","deg_w_at_baseline"],"mean",["gpsd_diff_ctrl"]); 

boxchart(T_sbj_mean.("deg_w_at_baseline"),T_sbj_mean.("mean_gpsd_diff_ctrl"));

x = T_sbj_mean.("mean_gpsd_diff_ctrl")( (T_sbj_mean.("deg_w_at_baseline") == 1));
y = T_sbj_mean.("mean_gpsd_diff_ctrl")( (T_sbj_mean.("deg_w_at_baseline") == numlevels));
p = ttest(x,y);

h = sigstar({[1 numlevels]});
if p<.05/(bonfcorrect)
    set(h(2),'String',sprintf('***SIGNIFICANT! %.03f',p))
    set(h(2),'Color','g')
else
    set(h(2),'String',sprintf('NOT SIG (%.03f)',p))
    set(h(2),'Color','r')    
    set(h(1),'LineStyle',':','Color',[.3 .3 .3])        
end


ax.XTick =  [1  numlevels]; 
ax.XTickLabel = {sprintf('Nodes w/ "LOW" %s',upper(IV)), sprintf('Nodes w/ "HIGH" %s',upper(IV))};
ylabel(sprintf('Change in %s after waking (control)',DV))
xlabel('NODE LEVEL DURING BASELINE')




%% ____________________________________
% Next we need to get data for each channel

IV_bsl = sprintf('%s_bsl',IV);
IV_ctr = sprintf('%s_ctr',IV);
IV_diff = sprintf('%s_diff',IV);
IV_diff_pval = strcat(IV_diff, '_pval');

IV_level_bsl = sprintf('%s_bsl',IV_level);
IV_level_ctr = sprintf('%s_ctr',IV_level);
IV_level_diff = sprintf('%s_diff',IV_level);

DV_bsl = sprintf('%s_bsl',DV);
DV_ctr = sprintf('%s_ctr',DV);
DV_diff = sprintf('%s_diff',DV);
DV_diff_pval = strcat(DV_diff, '_pval');



S = subjects(cogtask);
df_test = table;
df_chan = table();
for i = 1:23   
    for j = 1:numsubj
        df_init = table;
        df_init.chan = i;
        df_init.sbj = sbjid_list(j);

        % BASELINE 
        bsl_rows = df.condition == 'baseline' & df.chan == i & df.sbj == sbjid_list(j);                        
        df_init.(DV_bsl) = df.(DV)(bsl_rows);
        df_init.(IV_bsl) = df.(IV)(bsl_rows);
        df_init.(IV_level_bsl) = df.(IV_level)(bsl_rows);

        % CONTROL
        ctr_rows = df.condition == 'control' & df.chan == i & df.sbj == sbjid_list(j);        
        df_init.(DV_ctr) = df.(DV)(ctr_rows);
        df_init.(IV_ctr) = df.(IV)(ctr_rows);
        df_init.(IV_level_ctr) = df.(IV_level)(ctr_rows);

        % CHANGE
        df_init.(DV_diff) = df.(DV)(ctr_rows) - df.(DV)(bsl_rows);
        df_init.(IV_diff) = df.(IV)(ctr_rows) - df.(IV)(bsl_rows);
        df_init.(IV_level_diff) = df.(IV_level)(ctr_rows) - df.(IV_level)(bsl_rows);

        df_chan = [df_chan; df_init];
    end

    % RUN TESTS
    c_i = df_chan.chan == i;

    df_init = table;    
    df_init.chan = i;   
    
    df_init.(DV_diff_pval) = signrank(df_chan.(DV_ctr)(c_i),df_chan.(DV_bsl)(c_i));  
    df_init.(IV_diff_pval)  = signrank(df_chan.(IV_ctr)(c_i),df_chan.(IV_bsl)(c_i));  

    df_test= [df_test; df_init];

end



% Get means of values for each channel

df_sbj_stats = groupsummary(df_chan,{'chan','sbj'},{'mean'});
        IV_bsl_mean = strcat('mean_',IV_bsl);
        IV_level_bsl_mean = strcat('mean_',IV_level_bsl);
        IV_level_ctr_mean = strcat('mean_',IV_level_ctr);
        
        IV_ctr_mean = strcat('mean_',IV_ctr);        
        IV_diff_mean = strcat('mean_',IV_diff);
 
        DV_bsl_mean = strcat('mean_',DV_bsl);        
        DV_ctr_mean = strcat('mean_',DV_ctr);
        DV_diff_mean = strcat('mean_',DV_diff);    

%%
close all;
F= figure('GraphicsSmoothing','off');

numanz = 5;
F_t = tiledlayout(numanz,numsubj);
F_sbj_plot_idx = reshape(1:numsubj*numanz,numsubj,numanz)';


for j = 10:numsubj+1

    if j > numsubj
        figure;
        df_stats = df_sbj_stats;
        j = 1;
    else
        sbj_rows = df_sbj_stats.sbj == sbjid_list(j);
        df_stats = df_sbj_stats(sbj_rows,:);
    end

    % get baseline data of channels with high IV
    df_rows_iv_high_at_bl = df_stats.(IV_level_bsl_mean) == numlevels;
    df_sbj_iv_high_at_bl = df_stats(df_rows_iv_high_at_bl,:);
    
    % get control data of channels with high IV
    df_rows_iv_high_at_ctr = df_stats.(IV_level_ctr_mean) == numlevels;
    df_sbj_iv_high_at_ctrl = df_stats(df_rows_iv_high_at_ctr,:);

    % get data of channels with high IV in both conditions
    df_rows_iv_high_at_both = df_rows_iv_high_at_bl&df_rows_iv_high_at_ctr;
    numchan_with_iv_high_at_both = sum(df_rows_iv_high_at_ctr);
    df_sbj_iv_high_at_both = df_stats(df_rows_iv_high_at_both,:);

    % PLOTS PLOTS PLOTS

    % PLOT 1
    nexttile(F_sbj_plot_idx(1,j));     
    topoplot(df_stats.(DV_bsl_mean), S.chan,'style','map','emarker2',{df_sbj_iv_high_at_bl.chan,'diamond','w'});
    title(sprintf('%s of nodes with high %s during BL', DV,IV))

    % PLOT 2
    nexttile(F_sbj_plot_idx(2,j));     
    topoplot(df_stats.(DV_ctr_mean), S.chan,'style','map','emarker2',{df_sbj_iv_high_at_ctrl.chan,'diamond','w'});
    title(sprintf('%s of nodes with high %s during BL', DV,IV))
    
    % PLOT 3
    nexttile(F_sbj_plot_idx(3,j));         
    topoplot(df_stats.mean_gpsd_diff, S.chan,'style','map','emarker2',{df_sbj_iv_high_at_both.chan,'diamond','w'});
    

%     % PLOT 3
    nexttile(F_sbj_plot_idx(4,j));        
    hold on;
    scatter(df_sbj_iv_high_at_both, DV_bsl_mean,DV_ctr_mean,'filled','ColorVariable','chan');
    xlabel(sprintf('%s nodes during BL',DV))
    ylabel(sprintf('%s nodes during CTRL',DV))

    

    if j == numsubj
        title(sprintf('%s of nodes with high %s in both conditions',DV,IV));    
        legend({sprintf('%s during BL', DV),sprintf('%s during CTRL', DV)})
    elseif j == numsubj+1


    end


    nexttile(F_sbj_plot_idx(5,j)); 
    histogram(df_sbj_iv_high_at_both.(DV_diff_mean))
    histogram(df_sbj_iv_high_at_both.(DV_diff_mean))    
    xlabel(sprintf('change in %s',DV))

    
    drawnow
end



    nexttile

    yyaxis left
    ax = histogram(df_sbj_iv_high_at_bl.chan, 'BinMethod','integers');
%     [gc_sort,chan_sort] = sort(ax.Values);
%     stem(chan_sort, gc_sort);
    ylabel(sprintf('# of times chan had\n high %s during BL',IV),'Interpreter','none')
    
    yyaxis right
    ax = histogram(df_sbj_iv_high_at_ctrl.chan, 'BinMethod','integers');
%     [gc_sort,chan_sort] = sort(ax.Values);
%     stem(chan_sort, gc_sort);
    ylabel(sprintf('# of times chan had\n high %s during Control',IV),'Interpreter','none')
    xlabel('Channel')
    

%% PLOT AGGREGATE AVERAGE DIFFERENCES
    



% ________PLOTS__________% ________PLOTS__________
df_chan_mean = groupsummary(df_chan,{'chan'},{'mean'});

close all
F_anat_test = figure('GraphicsSmoothing','off');
F_t = tiledlayout(5,3);
F_t.Title.String = sprintf('Effect of waking on %s and %s ',DV,IV);  


% --- PLOTS OF THE DV DV DV DV


    %  BASELINE PLOTS OF THE DV

        % TOPOPLOTS BASELINE
        nexttile(1)
        topoplot(df_chan_mean.(DV_bsl_mean), S.chan,'style','map','electrodes','ptsnumbers')  ;
        title(sprintf('MEAN %s during BL (%s)',IV, DV_bsl_mean))

        % SCATTER PLOTS BASELINE
        ax = nexttile(4);
        hold on;
        stem(df_chan_mean.chan, df_chan_mean.(DV_bsl_mean));
        xlabel('channel')
        ylabel(DV_bsl_mean)
        

    %  CONTROL PLOTS OF THE DV
        % TOPO: 
        nexttile(2)
        topoplot(df_chan_mean.(DV_ctr_mean), S.chan,'style','map','electrodes','ptsnumbers') ;
        title(sprintf('MEAN %s during CTRL (%s)',IV, DV_ctr_mean));
        
        % SCATTER
        ax = nexttile(5);
        stem(df_chan_mean.chan, df_chan_mean.(DV_ctr_mean));
        xlabel('channel')
        ylabel(DV_ctr_mean)

 

    % CHANGE IN DV AFTER WAKING
        dv_sig_change = find(df_test.(DV_diff_pval)<=.05);

        % TOPO: 
        nexttile(3)
        topoplot(df_chan_mean.(DV_diff_mean), S.chan,'style','map','emarker2',{dv_sig_change,'*','r'},'electrodes','ptsnumbers')  ;
        title(sprintf('MEAN CHANGE in %s after waking (%s)',IV, DV_diff_mean));

        % SCATTER
        ax = nexttile(6);
        hold on;
        stem(df_chan_mean.chan, df_chan_mean.(DV_diff_mean));
        scatter(dv_sig_change,zeros(numel(dv_sig_change),1), 'r*')
        xlabel('channel')
        ylabel(DV_diff_mean)

        
 % --- PLOTS OF THE IV IV IV IV 

    %  BASELINE PLOTS OF THE IV

        % TOPOPLOTS BASELINE
        nexttile(10)
        topoplot(df_chan_mean.(IV_bsl_mean), S.chan,'style','map','electrodes','ptsnumbers')  ;
        title(sprintf('MEAN %s during BL (%s)',IV, IV_bsl_mean))

        % SCATTER 
        ax = nexttile(13);
        hold on;
        stem(df_chan_mean.chan, df_chan_mean.(IV_bsl_mean));
        xlabel('channel')
        ylabel(IV_bsl_mean)
        
    %  CONTROL PLOTS OF THE IV

        % TOPO: 
        nexttile(11)
        topoplot(df_chan_mean.(IV_ctr_mean), S.chan,'style','map','electrodes','ptsnumbers') ;
        title(sprintf('MEAN %s during CTRL (%s)',IV, IV_ctr_mean));
        
        % SCATTER
        ax = nexttile(14);
        stem(df_chan_mean.chan, df_chan_mean.(IV_ctr_mean));
        xlabel('channel')
        ylabel(IV_ctr_mean)

 

    % CHANGE IN IV AFTER WAKING
        IV_sig_change = find(df_test.(IV_diff_pval)<=.05);

        % TOPO: 
        nexttile(12)
        topoplot(df_chan_mean.(IV_diff_mean), S.chan,'style','map','emarker2',{IV_sig_change,'*','r'},'electrodes','ptsnumbers')  ;
        title(sprintf('MEAN CHANGE in %s after waking (%s)',IV, IV_diff_mean));

        % SCATTER
        ax = nexttile(15);
        hold on;
        stem(df_chan_mean.chan, df_chan_mean.(IV_diff_mean));
        scatter(IV_sig_change,zeros(numel(IV_sig_change),1), 'r*')
        xlabel('channel')
        ylabel(IV_diff_mean)

        
 

    
%%
% ________SCATTERS__________

% SCATTER OF THE DV     
    % SCATTER 

%     lm_dDV_vs_dIV = fitlm(df_chan,'linear','ResponseVar',DV_dif,'PredictorVars',IV_dif);


    % PLOT LINEAR MODEL    
    ax_lm_dDV_vs_dIV = plot(lm_dDV_vs_dIV);
    delete(ax_lm_dDV_vs_dIV([1 3 4]))
    set(ax_lm_dDV_vs_dIV(2),'LineStyle', '-')
    xlabel(sprintf('Change in %s after waking',IV));
    ylabel(sprintf('Change in %s after waking',DV)) 

%%

% ANALYZE RELATIONSHIP OF DIFFERENCES
       



    % TOPOPLOT AND RANK SIGN TEST OF EACH CHANNEL
%     nexttile
%     topoplot(cj_dDV, S.chan,'style','map','emarker2',{find(cj_dDV < 0),'diamond','m'},'electrodes','ptsnumbers')  ;


%%
% --------------------
% PLOTS FOR INDIVIDUAL SUBJECTS
close all
figure('WindowStyle','normal')

settings_str = sprintf('%s task | %s %s | when t = %d',cogtask, bandname, DV, t);
anzinfo_str = sprintf('Change in %s %s after waking for each "good" subject',bandname, DV);
title_str = sprintf('%s\n%s',anzinfo_str, settings_str);


plotspersbj = 1;
T_ivlev_bsl = tiledlayout(ceil(numsubj/2),plotspersbj*2);
T_ivlev_bsl.Title.String = title_str;


ax_tp_nodexy_idx = 1;
for j = 1:3% sbj_numel
    sbj_id  = sbjid_list(j);
    sbj_clr = rand(1,3);

    % plots 4 control
    ax_ctrl = nexttile;    
    hold on;

    % plot the cth channel of the jth subject 
    cj_dDV = ch_ctr_dDV(j,:);
    cj_dIV = ch_ctr_dIV(j,:);


    topoplot(cj_dDV, S.chan,'style','map','emarker2',{find(cj_dDV < 0),'diamond','m'},'electrodes','ptsnumbers')  ;
% 
    
    set(ax_ctrl,'Visible','off','Color',sbj_clr,'XColor','none','YColor','none')
    drawnow    

    if j == 1 || j == numsubj
        colorbar

    end

end





figure(gcf)


%% LIKELYHOODS
clearvars -except df_long
clc;
cogtask = 'PVT';
bandname  = 'beta';
IV = 'deg_w'; 
DV = 'gpsd'; 
numlevels = 3;
t=1;
categwthn_condition = true;
categwthn_subject = true;


DV_mean =  sprintf('mean_%s',DV);
IV_level  = sprintf('%s_level',IV);
desired_vars = [{DV},{IV},experimentalvars()];

settings_str = sprintf('%s task | %s %s | when t = %d',cogtask, bandname, IV, t);
anzinfo_str = sprintf('Change in %s %s after waking for each "good" subject',bandname, IV);
title_str = sprintf('%s\n%s',anzinfo_str, settings_str);

% LOAD DATA
df     = dflong2wide(df_long, cogtask, {'baseline', 'control','light'}, bandname, t,'keepchannels',true);
df = df(:,desired_vars);

% CATEGORIZE NETWORK PROPERTIES. 
df= categcolumn(df,IV,numlevels,"condition",categwthn_condition,"subject",categwthn_subject);
df.(IV_level) = findgroups(df.(IV_level));

[df_bsl, df_ctr, df_lgt] = splitdfbycondition(df);
df_wake = [df_ctr];

% PLOT
close all
figure('WindowStyle','docked')
tiledlayout(2,2)


ax_jointp = nexttile(1,[1,2]);
x = df_wake.("chan");
y = df_wake.(IV_level);

h = histogram2(x,y,'DisplayStyle','bar3','FaceColor','flat');
h.BinMethod = 'integers'; 
ax_jointp.YTick  = 1:numlevels;
ax_jointp.YTickLabel  =cellstr(num2str([1:numlevels]'));

xlabel('channel')
ylabel(IV_level)
set(gca, 'YDir','normal')
view(2)

title('Joint Frequency Distribution: P(chan=i & K=j)','Interpreter','none')
colorbar
axis equal
figure(gcf)
F = [h.Values];

% PLOT LIKELYHOOD;
ax_img = nexttile(3); 

L = F./repmat(sum(F),23,1);
imagesc(L');


dv_str = sprintf('P( Node | %s = 1...%d)',IV_level, numlevels);
ylabel(dv_str,'Interpreter','none')
title(sprintf('LIKELYHOOD: %s',dv_str),'Interpreter','none')
xlabel('channel')
ylabel(IV_level)

ax_img.YTick  = 1:numlevels;
ax_img.YTickLabel  =cellstr(num2str([1:numlevels]'));
colorbar
set(gca, 'YDir','normal')


% FACET
nexttile(4)
L = F./repmat(sum(F),23,1);
varnames = cellfun(@(x) sprintf('P(chan | %s = %d)',IV, x), num2cell(1:numlevels), 'UniformOutput',false);
rownames = cellfun(@(x) sprintf('channel %d',x), num2cell(1:23), 'UniformOutput',false);

Lt =  array2table(L,VariableNames=varnames,RowNames=rownames);
ax_p = stackedplot(Lt,Lt.Properties.VariableNames(end:-1:1));
xlabel('channel')

figure(gcf)







