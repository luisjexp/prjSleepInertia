close all force
cog_task_list = {'PVT'};
DF = dfmaster('cogtestlist',cog_task_list);
D2C = getdist2core(cog_task_list,round(linspace(.8,1.2,3),1));
DF = [DF;D2C];

%% Validate Data Frame
ntwprop_set = unique(DF.ntwprop);

numprops = numel(ntwprop_set);
GC = [];

disp('')
for i = 1:numprops
    df = DF(DF.ntwprop == ntwprop_set(i),:);
    gc = groupsummary(DF,{'sbj','chan'});
    if i ==1
        GC = gc.GroupCount;
    end

    if GC ~= gc.GroupCount
        error('Luis: your df has an error')
    else
        fprintf('.')

    end
end

disp('Data frame is valid')

%%

clearvars -except DF
clc;
cogtask = 'PVT';
bandname  = 'delta';
ntwprop_X = 'deg_w'; 
catvars = 2;
t=1;
df = dfmastersplit(DF, cogtask, {'baseline', 'control','light'}, bandname, t, 'keepchannels',true,'catvars',catvars);
%%
% Get average distance to core, assuming that d2c variables at % different gammas are in master data frame (may or may not be)
clc
close all;
figure;
nexttile;
hold on;


ntwprops_set = df.Properties.VariableNames;
d2cprop_set = ntwprops_set(contains(ntwprops_set,'d2c') & ~contains(ntwprops_set,'level'));

d2c_mu = zeros(height(df),1);
df_d2c = table;
for i = 1:numel(d2cprop_set)
    d2c_level = char(d2cprop_set(i));
    histfit(df.(d2c_level));
end

