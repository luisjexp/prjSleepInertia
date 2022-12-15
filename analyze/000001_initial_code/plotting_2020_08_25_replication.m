%% REPLICATING PLOTTING SCRIPT: FIGURE 1
clear;
S = subjects('PVT');
data_path = S.path_data;

%% #####################################
%% REPLICATE INITIAL VARIABLES

% HER OUTPUT
clc;
load([data_path, 'dchanlocs_rev.mat']);
load([data_path, 'B_cond.mat']);
load([data_path, 'A_cond.mat']);
load([data_path, 'C_cond.mat']);
f1 = [2,6,9,14]; % band start frequncy +1
f2 = [5,8,13,31]; % band end frequency +1
n_sub = 12;
[her_psd] = extracting_psd_light_copy_scratch(A_cond,B_cond, S.path_data_cog_test);
[~,~,~,~,~,~,mm] = extracting_wpli_light_copy_scratch(A_cond,B_cond, S.path_data_cog_test);
[~,her_pow_baseline,~,her_powB] = psd_comparison(her_psd,1,251,n_sub,1:23);

a_sub = 1:12; 
n = length(a_sub);

clear her_BS her_P1 her_P2 her_P3 her_P4 her_bs her_p1 her_p2 her_p3 her_p4
for i = 1:4    
    s = f1(i);
    e = f2(i);      
    her_BS(:,i,1:n) = squeeze(mean(her_pow_baseline(:,s:e,a_sub),2)); % baseline
    her_P1(:,i,1:n) = squeeze(mean(her_powB(1,:,s:e,a_sub),3)); % T1 placebo
    her_P2(:,i,1:n) = squeeze(mean(her_powB(2,:,s:e,a_sub),3)); % T2 placebo
    her_P3(:,i,1:n) = squeeze(mean(her_powB(3,:,s:e,a_sub),3)); % T3 placebo
    her_P4(:,i,1:n) = squeeze(mean(her_powB(4,:,s:e,a_sub),3)); % T4 placebo
    

    her_bs(:,i,1:n)= mm.baseline(i,:,a_sub);
    her_p1(:,i,1:n)= mm.condB.run1(i,:,a_sub);
    her_p2(:,i,1:n)= mm.condB.run2(i,:,a_sub);
    her_p3(:,i,1:n)= mm.condB.run3(i,:,a_sub);
    her_p4(:,i,1:n)= mm.condB.run4(i,:,a_sub);
end

% MY OUTPUT....
clear my_BS my_P1 my_P2 my_P3 my_P4 my_bs my_p1 my_p2 my_p3 my_p4

my_psd          = getglobalpsd('PVT');
my_pow_baseline = my_psd.centered_psd{strcmp(my_psd.condition, 'baseline')};
my_powB = catcenteredpsd(my_psd, 'control'); % annoying, but to match her output, i need to concatenate my data from each run

[~,~,~,~,~,~,my_mm, ~] = getnetwork('PVT');

for i = 1:4    
    s = f1(i);
    e = f2(i);      
    my_BS(:,i,1:n) = squeeze(mean(my_pow_baseline(:,s:e,a_sub),2)); % baseline
    my_P1(:,i,1:n) = squeeze(mean(my_powB(1,:,s:e,a_sub),3)); % T1 placebo
    my_P2(:,i,1:n) = squeeze(mean(my_powB(2,:,s:e,a_sub),3)); % T2 placebo
    my_P3(:,i,1:n) = squeeze(mean(my_powB(3,:,s:e,a_sub),3)); % T3 placebo
    my_P4(:,i,1:n) = squeeze(mean(my_powB(4,:,s:e,a_sub),3)); % T4 placebo
    

end
my_bs = permute (my_mm.raw_df{strcmp(my_mm.condition, 'baseline')}, [2 1 3] );
my_p1 = permute (my_mm.raw_df{strcmp(my_mm.condition, 'control') & my_mm.run == 1}, [2 1 3]);
my_p2 = permute(my_mm.raw_df{strcmp(my_mm.condition, 'control') & my_mm.run == 2}, [2 1 3]);
my_p3 = permute(my_mm.raw_df{strcmp(my_mm.condition, 'control') & my_mm.run == 3}, [2 1 3]);
my_p4 = permute(my_mm.raw_df{strcmp(my_mm.condition, 'control') & my_mm.run == 4}, [2 1 3]);



clf;
% COMPARE
% first compare PSD
subplot(2,5,1)
compare_data(her_BS, my_BS)

subplot(2,5,2)
compare_data(her_P1, my_P1)

subplot(2,5,3)
compare_data(her_P2, my_P2)

subplot(2,5,4)
compare_data(her_P3, my_P3)

subplot(2,5,5)
compare_data(her_P4, my_P4)


% Then compare strg
subplot(2,5,6)
compare_data(her_bs, my_bs)

subplot(2,5,7)
compare_data(her_p1, my_p1)

subplot(2,5,8)
compare_data(her_p2, my_p2)

subplot(2,5,9)
compare_data(her_p3, my_p3)

subplot(2,5,10)
compare_data(her_p4, my_p4)

figure(gcf)



%% #####################################
% FIGURE 1 REPLICATION ATTEMPt
%% FIGURE1: PANEL A 
% Global PSD Analysis: for each band, compare the global PSD during
% baseline to the AVERAGE of the global PSD on the next two runs????

%%% HER OUTPUT
her_x1 = squeeze(mean(her_BS(:,1,:),1) );
her_y1 = [squeeze(mean(her_P1(:,1,:),1)),squeeze(mean(her_P2(:,1,:),1))];
her_x2 = squeeze(mean(her_BS(:,2,:),1));
her_y2 = [squeeze(mean(her_P1(:,2,:),1)),squeeze(mean(her_P2(:,2,:),1))];
her_x3 = squeeze(mean(her_BS(:,3,:),1));
her_y3 = [squeeze(mean(her_P1(:,3,:),1)),squeeze(mean(her_P2(:,3,:),1))];
her_x4 = squeeze(mean(her_BS(:,4,:),1));
her_y4 = [squeeze(mean(her_P1(:,4,:),1)),squeeze(mean(her_P2(:,4,:),1))];

her_t = [];

[~,her_t(1),~,~] = ttest(her_x1,mean(her_y1,2)); 
[~,her_t(2),~,~] = ttest(her_x2,mean(her_y2,2)); 
[~,her_t(3),~,~] = ttest(her_x3,mean(her_y3,2)); 
[~,her_t(4),~,~] = ttest(her_x4,mean(her_y4,2)); 

% TRY REPLICATING

bl_idx = strcmp(my_psd.condition, 'baseline');
cntl_r1_idx = strcmp(my_psd.condition, 'control') & my_psd.run == 1;
cntl_r2_idx = strcmp(my_psd.condition, 'control') & my_psd.run == 2;

my_x1 = my_psd.("delta")(bl_idx,:)';
my_y1 = [ my_psd.("delta")(cntl_r1_idx,:)', my_psd.("delta")(cntl_r2_idx,:)'];
my_x2 = my_psd.("theta")(bl_idx,:)';
my_y2 = [ my_psd.("theta")(cntl_r1_idx,:)', my_psd.("theta")(cntl_r2_idx,:)'];
my_x3 = my_psd.("alpha")(bl_idx,:)';
my_y3 = [ my_psd.("alpha")(cntl_r1_idx,:)', my_psd.("alpha")(cntl_r2_idx,:)'];
my_x4 = my_psd.("beta")(bl_idx,:)';
my_y4 = [ my_psd.("beta")(cntl_r1_idx,:)', my_psd.("beta")(cntl_r2_idx,:)'];

my_t = [];
[~,my_t(1),~,~] = ttest(my_x1,mean(my_y1,2)); 
[~,my_t(2),~,~] = ttest(my_x2,mean(my_y2,2)); 
[~,my_t(3),~,~] = ttest(my_x3,mean(my_y3,2)); 
[~,my_t(4),~,~] = ttest(my_x4,mean(my_y4,2)); 


%COMPARE
clf;
subplot(1,1,1)
compare_data(my_t, her_t)

title(sprintf('Pow: BS vs P1-2,p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f\nBS vs P1-2,p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',...
    her_t(1),her_t(2),her_t(3),her_t(4),...
    my_t(1),my_t(2),my_t(3),my_t(4)));

figure(gcf)
%% TRY REPLICATING FIGURE1:  PANEL B (TOPOGRAPHIC PLOTS, i dont have these functions)
% LOCAL PSD Analysis: for each band, compare each of its channel's PSD
% during baseline to the AVERAGE of the channel's PSD on the next two
% runs

%%% HER OUTPUT
clear her_tb her_b1 her_b2 her_b3 her_tb_freq

her_tb_freq = {};
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        her_b1 = squeeze(mean(her_pow_baseline(j,s:e,a_sub),2));
        her_b2 = squeeze(mean(her_powB(1,j,s:e,a_sub),3));
        her_b3 = squeeze(mean(her_powB(2,j,s:e,a_sub),3));
        [her_tb(1,j),her_tb(2,j),~,sts] = ttest(her_b1,mean([her_b2,her_b3],2));
        her_tb(3,j) = sts.tstat;
    end

    her_tb_freq{i} = her_tb;
end

her_tb_freq = [her_tb_freq{:}];

%%% MY OUTPUT
clear my_tb my_b1 my_b2 my_b3 my_tb_freq

my_tb_freq = {};
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        my_b1 = squeeze(mean(my_pow_baseline(j,s:e,a_sub),2));
        my_b2 = squeeze(mean(my_powB(1,j,s:e,a_sub),3));
        my_b3 = squeeze(mean(my_powB(2,j,s:e,a_sub),3));
        [my_tb(1,j),my_tb(2,j),~,sts] = ttest(my_b1,mean([my_b2,my_b3],2));
        my_tb(3,j) = sts.tstat;
    end

    my_tb_freq{i} = my_tb;
end

my_tb_freq = [my_tb_freq{:}];


%%% COMPARE OUTPUTS
clf;
subplot(1,1,1)
compare_data(my_tb_freq, her_tb_freq)

figure(gcf)



%% TRY REPLICATING FIGURE1:  PANEL C 
% stoll not sure what strg variable is ( NEED TO ASK KANIKA WHAT THIS IS)
% may be the clutering coefficient?
% ANALYSIS: same as global PSD analysis above but with strg variable

% HER CODE
figure;
her_x1 = squeeze(mean(her_bs(:,1,:),1));
her_y1 = [squeeze(mean(her_p1(:,1,:),1)),squeeze(mean(her_p2(:,1,:),1))];
her_x2 = squeeze(mean(her_bs(:,2,:),1));
her_y2 = [squeeze(mean(her_p1(:,2,:),1)),squeeze(mean(her_p2(:,2,:),1))];
her_x3 = squeeze(mean(her_bs(:,3,:),1));
her_y3 = [squeeze(mean(her_p1(:,3,:),1)),squeeze(mean(her_p2(:,3,:),1))];
her_x4 = squeeze(mean(her_bs(:,4,:),1));
her_y4 = [squeeze(mean(her_p1(:,4,:),1)),squeeze(mean(her_p2(:,4,:),1))];


her_vals2plot = [her_x1,mean(her_y1,2),her_x2,mean(her_y2,2),her_x3,mean(her_y3,2),her_x4,mean(her_y4,2)];

subplot(2,2,1)
boxplot(her_vals2plot,'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[~,t21,~,~] = ttest(her_x1,mean(her_y1,2)); 
[~,t22,~,~] = ttest(her_x2,mean(her_y2,2)); 
[~,t23,~,~] = ttest(her_x3,mean(her_y3,2)); 
[~,t24,~,~] = ttest(her_x4,mean(her_y4,2)); 
title(sprintf('Con: BS vs P1-2, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

% REPLICATION ATTEMPT
bl_idx = strcmp(strg_me.condition,'baseline');
cntl_r1_idx = strcmp(strg_me.condition,'control') & strg_me.run == 1;
cntl_r2_idx = strcmp(strg_me.condition,'control') & strg_me.run == 2;

x1_me   = mean(strg_me.delta{bl_idx})';
y1_me    = [mean(strg_me.delta{cntl_r1_idx})', mean(strg_me.delta{cntl_r2_idx})'];
x2_me   = mean(strg_me.theta{bl_idx})';
y2_me   = [mean(strg_me.theta{cntl_r1_idx})', mean(strg_me.theta{cntl_r2_idx})'];
x3_me   = mean(strg_me.alpha{bl_idx})';
y3_me    = [mean(strg_me.alpha{cntl_r1_idx})', mean(strg_me.alpha{cntl_r2_idx})'];
x4_me = mean(strg_me.beta{bl_idx})';
y4_me    = [mean(strg_me.beta{cntl_r1_idx})', mean(strg_me.beta{cntl_r2_idx})'];


subplot(2,2,3)
my_vals2plot = [x1_me,mean(y1_me,2),x2_me,mean(y2_me,2),x3_me,mean(y3_me,2),x4_me,mean(y4_me,2)];
boxplot(my_vals2plot,'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[~,t21_me,~,~] = ttest(x1_me,mean(y1_me,2)); 
[~,t22_me,~,~] = ttest(x2_me,mean(y2_me,2)); 
[~,t23_me,~,~] = ttest(x3_me,mean(y3_me,2)); 
[~,t24_me,~,~] = ttest(x4_me,mean(y4_me,2)); 
title(sprintf('REPLICATE: Con: BS vs P1-2, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21_me,t22_me,t23_me,t24_me));

% COMPARE
subplot(1,2,2)
compare_data(her_vals2plot, my_vals2plot);
xlabel('her output')
ylabel('my output')

%% TRY REPLICATING FIGURE1:  PANEL D
% ANALYSIS: same as local PSD analysis above but with strg variable

%%% HER CODE
close all; clf
clear her_tb
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23      
        clear her_b1 her_b2 her_b3
        her_b1 = squeeze(mm.baseline(i,j,a_sub));
        her_b2 = squeeze(mm.condB.run1(i,j,a_sub));
        her_b3 = squeeze(mm.condB.run2(i,j,a_sub));
        [her_tb(1,j),her_tb(2,j),~,sts] = ttest(her_b1,mean([her_b2,her_b3],2));
        her_tb(3,j) = sts.tstat;
    end
    subplot(2,4,i); hold on;
    plot(1:23, her_tb(3,:), 'r', 'LineWidth',2)
    title(sprintf('Con: BS vs P3-4'));
end


%%% MY CODE
clear tb_me
band_names = {'delta', 'theta', 'alpha', 'beta'};
bl_idx = strcmp(strg_me.condition,'baseline');
cntl_r3_idx = strcmp(strg_me.condition,'control') & strg_me.run == 1;
cntl_r4_idx = strcmp(strg_me.condition,'control') & strg_me.run == 2;


for i = 1:4
    bnd = band_names{i};
    for j = 1:23      
        clear b1_me b2_me b3_me
        b1_me = strg_me.(bnd){bl_idx}(j,:);
        b2_me = strg_me.(bnd){cntl_r3_idx}(j,:);
        b3_me = strg_me.(bnd){cntl_r4_idx}(j,:);
        [tb_me(1,j),tb_me(2,j),~,sts] = ttest(b1_me,mean([b2_me;b3_me]));
        tb_me(3,j) = sts.tstat;
    end
    subplot(2,4,i),
    plot(1:23, tb_me(3,:), 'Color',[0 1 .6 .25], 'LineWidth',10)
    title(sprintf('Con: BS vs P3-4'));
end
legend({'her t-values', 'my t values'})
figure(gcf)


% COMPARE
subplot(2,5,8)
compare_data(tb_me, her_tb)

xlabel('my t values')
ylabel('her t values')


