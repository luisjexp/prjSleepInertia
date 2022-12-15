function [psd] = extracting_psd_light(A_cond,B_cond)
% %% for light vs placebo
% subname = {'2952','2954','2956','2957','2958','2959','2961','2962',...
%     '2963','2967','2968','2969'}; 

%%% for peppermint placebo
subname = {'2952','2954','2956','2957','2958','2959','2961',...
    '2963','2967','2968','2969'}; 

% *** Note Luis
% here will loop from 1:12, but there are only 11 subjects.
% not sure why this is the case. but note that there will only be 11
% subject's data in this gpsd data frame
subid = [1:12];

%% for mint vs placebo
% subname = {'2952','2954','2956','2957','2958','2959','2961',...
%     '2963','2967','2968','2969'}; 
% subid = [1:7,9:12];
chan = 23;
%pathname = fullfile('C:\Users\kanik\Dropbox\Box Sync\Sleep_inertia_study\Data\Data_06_24_2020\SIS_metrics');
%pathname = ('/Users/kanika/Dropbox/Box Sync/Sleep_inertia_study/Data/Data_06_24_2020/SIS_metrics');
% pathname = fullfile('C:\Users\DoD_Admin\Documents\Box Sync\Sleep_inertia_study\Data\Manually_cleaned_ravi');
%pathname = fullfile('C:\Users\DoD_Admin\Dropbox\Box Sync\Sleep_inertia_study\Data\Data_06_24_2020\SIS_metrics');
pathname = fullfile('C:\Users\DoD_Admin\Dropbox\Box Sync\Sleep_inertia_study\Data\Data_09_03_2021_corrected_pathlength\fixpathlength'); % changed on Jan 18, 2022

% luis edit: path name of data frame
pathname = fullfile(cd); % changed on Jan 18, 2022

for i = 1:length(subname)
    i
    %f = sprintf('RCM%s_metrics_04272020_nydyn_band.mat',subname{i});
    %f = sprintf('RCM%s_metrics_051220_justpow.mat',subname{i});
    %f = sprintf('RCM%s_metrics_052820_noart.mat',subname{i});
    % f = sprintf('RCM%s_metrics_062320_PVT_ASR5_nodyn.mat',subname{i}); 

    
    % **** edit Luis: 
    % had to change the names of the files to match mine; 
    % but this one was originally uncommented...
    % f = sprintf('fixpathL_RCM%s_metrics_090321_PVT_ASR5_nodyn.mat',subname{i}); 
    f = sprintf('RCM%s_metrics_050322_PVT_ASR5_nodyn.mat ',subname{i}); 
     
    f_f = strcat(pathname,'\',f);
    load(f_f);
    night_no = A_cond(subid(i),2)
    
    % Baseline
    if ~isempty(data.(sprintf('night%d',night_no))(1).psd)
        psd.baseline(1:chan,1:251,i) = data.(sprintf('night%d',night_no))(1).psd.power;
    else
        psd.baseline(1:chan,1:251,i)=zeros(chan,251);
    end
    
    % cond A 
    run = 4*(A_cond(subid(i),3)-1)+3;
    count = 1;
    for j = run:run+3
        if j > length(data.(sprintf('night%d',night_no)))
            psd.condA.(sprintf('run%d',count))(1:chan,1:251,i) = zeros(chan,251);
        else
            if ~isempty(data.(sprintf('night%d',night_no))(j).psd)
                psd.condA.(sprintf('run%d',count))(1:chan,1:251,i) = data.(sprintf('night%d',night_no))(j).psd.power;
            else 
                psd.condA.(sprintf('run%d',count))(1:chan,1:251,i) = zeros(chan,251);
            end
        end
        count = count+1;
    end
     
    % cond B 
    run = 4*(B_cond(subid(i),3)-1)+3;
    count = 1;
    for j = run:run+3
        if j > length(data.(sprintf('night%d',night_no)))
            psd.condB.(sprintf('run%d',count))(1:chan,1:251,i) = zeros(chan,251);
        else
            if ~isempty(data.(sprintf('night%d',night_no))(j).psd)
                psd.condB.(sprintf('run%d',count))(1:chan,1:251,i) = data.(sprintf('night%d',night_no))(j).psd.power;
            else 
                psd.condB.(sprintf('run%d',count))(1:chan,1:251,i) = zeros(chan,251);
            end
        end
        count = count+1;
    end
    
end

% running for the baseline of sub 2956, which was extracted later;
i = 3;
% edit Luis: this is the data set i had; 
% but this one was originally uncommented...
% f = sprintf('fixpathL_RCM%s_metrics_090321_PVT_ASR5_nodyn.mat',subname{i}); 
f = sprintf('RCM%s_metrics_050322_PVT_ASR5_nodyn.mat ',subname{i}); 
f_f = strcat(pathname,'\',f);
load(f_f);
night_no = A_cond(subid(i),2);
% Baseline
if ~isempty(data.(sprintf('night%d',night_no))(1).psd)
    psd.baseline(1:chan,1:251,i) = data.(sprintf('night%d',night_no))(1).psd.power;
else
    psd.baseline(1:chan,1:251,i)=zeros(chan,251);
end

psd.subjects = subname;