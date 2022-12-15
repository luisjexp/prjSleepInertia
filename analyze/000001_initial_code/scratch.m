% scratch 05 16 2022

cd /home/luis/Dropbox/DEVCOM/projects/2205_sleepInertia
cd /Users/Luis/Dropbox/DEVCOM/projects/2205_sleepInertia/
clc
clear;
load('A_cond.mat')
load('B_cond.mat')
subname = {'2952','2954','2956','2957','2958','2959','2961','2963','2967','2968','2969'}; 
pathname = fullfile('/home/luis/Dropbox/DEVCOM/projects/2205_sleepInertia/PVT');
pathname = fullfile('C:\Users\Luis\Dropbox\DEVCOM\projects\2205_sleepInertia\PVT\');

nchan = 23;
subid = [1:11];
 
for i = 1:length(subname)
    f = sprintf('RCM%s_metrics_050322_PVT_ASR5_nodyn.mat',subname{i});
    f_f = strcat(pathname,'/',f);
    load(f_f);
    night_no = A_cond(subid(i),2);
    sprintf('night%d',night_no);
    psd.baseline(1:nchan,1:251,i) = data.(sprintf('night%d',night_no))(1).psd.power;    
end


BL = psd.baseline;

%% 
cd /Users/Luis/Dropbox/DEVCOM/projects/2205_sleepInertia/
clc
clear;
subname = {'2952','2954','2956','2957','2958','2959','2961','2963','2967','2968','2969'}; 

load('A_cond.mat')
load('B_cond.mat')

psd         = extracting_psd_light_copy_scratch(A_cond, B_cond);
num_chan    = 23;
delta_bands = 2:5;
theta_bands = 32:71;
alpha_bands = 81:121;
beta_bands = 126:251;


%% normalizing power by mean power
chan = 1:23;
f_ind1 = 1;
f_ind2 = 251;
n_f = f_ind2-f_ind1+1;
clear BL
for i = 1:(num_chan)
    for j = 1:length(subname)
        % baseline
        pow(1:n_f) = psd.baseline(chan(i),f_ind1:f_ind2,j);
        if std(pow)~=0
            pow = (pow-mean(pow))/std(pow);
            BL(i,:,j) = pow;
            clear pow
        else 
            pow = 0;
            BL(i,1:n_f,j) = 0;
            clear pow
        end
    end 
    i
end
size(BL)
%%


t1_A = psd.condA.run1;
t1_B = psd.condB.run1;


BL_delta = (BL(1:num_chan, delta_bands,:));
BL_delta = squeeze( mean(BL_delta) );
BL_delta = mean( BL_delta ); 



clf;
boxplot([BL_delta]')
figure(gcf)
line(xlim, [mean(BL_delta), mean(BL_delta)]);








