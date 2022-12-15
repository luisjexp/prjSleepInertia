%% RUN THROUGH ON REPLICATING PSD COMPARE FUNCTION  
clc;
clear
load("A_cond.mat")
load("B_cond.mat")

f1 = [2,6,9,14]; % band start frequncy +1
f2 = [5,8,13,31]; % band end frequency +1
N = 23;
n_sub = 12; 

%% ATTEMPT TO REPLICATE RAW PSD OUTPUT (SUCCESS!!!)
% HER PSDCOMPARE FUNCTION
 % start by extracting pdf light
pvt_data_path = fullfile([pwd,filesep, 'PVT', filesep]); % make sure PVT data folder is in current folder
[her_psd] = extracting_psd_light_copy_scratch(A_cond,B_cond,pvt_data_path);


% MY PSDCOMPARE OUTPUT
my_psd = extractpsd('PVT');

% COMPARE
close all
subplot(3,1,1);
compare_data(my_psd.baseline, her_psd.baseline);   
axis square
ylabel(sprintf('RAW PSD for BASELING CONDITION\nall channels\nall frequencies\nall subjects'))

for r = 1:4
    runstr = sprintf('run%d',r);
    subplot(3,4,4+r);
    compare_data(her_psd.condA.(runstr), my_psd.condA.(runstr))

    if r ==1
        ylabel(sprintf('RAW PSD for LIGHT CONDITION\nall channels\nall frequencies\nall subjects\n1 pannel for each run. '))
    end

    subplot(3,4,8+r);
    compare_data(her_psd.condB.(runstr), my_psd.condB.(runstr))

    if r ==1
        ylabel(sprintf('RAW PSD for CONTROL CONDITION\nall channels\nall frequencies\nall subjects\n1 pannel for each run. '))
    end    
end
figure(gcf)

%___________________________
%% ATTEMPT to REPLICATE NORMALIED PSD (SUCCESS!!!)
% HER NORMALIZED PSD
[~,her_pow_baseline,her_powA,her_powB] = psd_comparison(her_psd,1,251,n_sub,1:23);

% MY NORMALIZED PSD
df_global_psd = getglobalpsd('PVT');
my_pow_baseline = df_global_psd.centered_psd{1};

my_powA = catcenteredpsd(my_centered_psd, 'light')
my_powA = df_global_psd {strcmp(df_global_psd.condition, 'light'),'centered_psd'};
my_powA = permute( cat(4, my_powA{:}), [4, 1, 2,3] ) ;
my_powB = df_global_psd {strcmp(df_global_psd.condition, 'control'),'centered_psd'};
my_powB = permute( cat(4, my_powB{:}), [4, 1, 2,3] ) ;

% COMPARE NORMALIZED GLOBAL PSD MATRICES
clc; clf
subplot(3,1,1)
compare_data(her_pow_baseline, my_pow_baseline)
title('normalized baseline psd with all channels, frequencies and all subjects')

for r = 1:4
    her_a = squeeze ( her_powA(r,:,:,:) );
    my_a = squeeze ( my_powA(r,:,:,:) );

    subplot(3,4,4+r); hold on
    compare_data(her_a, my_a)
    title(sprintf('Run # %d',r))
    if r == 1
        ylabel(sprintf('LIGHT CONDITION\nNORMALIZED PSD\nall channels\nall frequencies\nall subjects\n1 pannel for each run. '))
    end

    her_b = squeeze ( her_powB(r,:,:,:) );
    my_b = squeeze ( my_powB(r,:,:,:) );    
    subplot(3,4,8+r); hold on
    compare_data(her_b, my_b)
    if r == 1
        ylabel(sprintf('CONTROL CONDITION\nNORMALIZED PSD\nall channels\nall frequencies\nall subjects\n1 pannel for each run. '))
    end
    
end





figure(gcf)
%% ATTEMPT to REPLICATE NORMALIZED PSDS OF EACH FREQUENCY BAND (SUCCESS!!!)
% HER GPSDs OF EACH BAND
[her_output,~,~,~] = psd_comparison(her_psd,1,251,n_sub,1:23);

% MY GPSDs OF EACH BAND
df_global_psd = getglobalpsd('PVT');

band_names = {'delta', 'theta', 'alpha', 'beta'};
close all;

for fs = 1:4
    her = her_output.(band_names{fs});
    me = df_global_psd{:, band_names{fs}};

    subplot(1,4,fs); hold on
    compare_data(her, me)

end
figure(gcf)






