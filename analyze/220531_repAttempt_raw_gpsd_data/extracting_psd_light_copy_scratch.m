function [psd] = extracting_psd_light_copy_scratch(A_cond,B_cond, pvt_data_path)
% %% for light vs placebo
% subname = {'2952','2954','2956','2957','2958','2959','2961','2962',...
%     '2963','2967','2968','2969'}; 

%%% for peppermint placebo %
% i added number 62 to this data set, which they did not include in their
% paper (df = 10). It needs to be include so that the 'conditions' table
% match up. i cannot replicate results until i know which subject is
% missing. once i do i can drop the subject data as well has their
% corresponding row in the conditions table

subname = {'2952','2954','2956','2957','2958','2959','2961','2962',...
    '2963','2967','2968','2969'}; 

subid = 1:12;
% these were the subjects used in the original
%%% code, except for subject 2962
% subname = {'2952','2954','2956','2957','2958','2959','2961',...
%     '2963','2967','2968','2969'}; % EDIT LUIS: added subject that was in my data set
% subid = [1:11];

%% for mint vs placebo
chan = 23;

for i = 1:length(subname)
    i
    f = sprintf('RCM%s_metrics_050322_PVT_ASR5_nodyn.mat',subname{i});
    f_f =  strcat(pvt_data_path,f);
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

% % running for the baseline of sub 2956, which was extracted later;
% i = 3;
% night_no = A_cond(subid(i),2);
% % Baseline
% if ~isempty(data.(sprintf('night%d',night_no))(1).psd)
%     psd.baseline(1:chan,1:251,i) = data.(sprintf('night%d',night_no))(1).psd.power;
% else
%     psd.baseline(1:chan,1:251,i)=zeros(chan,251);
% end
% 
% psd.subjects = subname;