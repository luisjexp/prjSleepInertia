function [output,pow_baseline,powA,powB] = psd_comparison(psd,f_ind1,f_ind2,n_sub,chan)
% f_ind1 = 1;
% f_ind2 = 41;
n_f = f_ind2-f_ind1+1;
%n_sub = 9;
%chan = [3,4,5,6,9,10]; Vallat et al.
% chan = 17:20; central channel
%% normalizing power by mean power
for i = 1:length(chan)
    for j = 1:n_sub
        
        % baseline
        pow(1:n_f) = psd.baseline(chan(i),f_ind1:f_ind2,j);
        if std(pow)~=0
            pow = (pow-mean(pow))/std(pow);
            pow_baseline(i,:,j) = pow;
            clear pow
        else 
            pow = 0;
            pow_baseline(i,1:n_f,j) = 0;
            clear pow
        end
        
        % A conditions
        for k = 1:4            
            pow(1:n_f) = psd.condA.(sprintf('run%d',k))(chan(i),f_ind1:f_ind2,j);
            if std(pow)~=0
                pow = (pow-mean(pow))/std(pow);
                powA(k,i,:,j) = pow;
                clear pow
            else
                pow = 0;
                powA(k,i,1:n_f,j) = 0;
                clear pow
            end
        end
        
        % B conditions
        for k = 1:4            
            pow(1:n_f) = psd.condB.(sprintf('run%d',k))(chan(i),f_ind1:f_ind2,j);
            if std(pow)~=0
                pow = (pow-mean(pow))/std(pow);
                powB(k,i,:,j) = pow;
                clear pow
            else
                pow = 0;
                powB(k,i,1:n_f,j) = 0;
                clear pow
            end
        end
        
    end
end
 
%% channel and frequency averaging 
% delta 
f1 = 2;
f2 = 5;

check(1:length(chan),1:n_sub) = mean(pow_baseline(:,f1:f2,:),2);
output.delta(1,:) = mean(check,1);
clear check 

for i = 1:4
    check(1:length(chan),1:n_sub) = mean(powA(i,:,f1:f2,:),3);
    output.delta(i+1,:) = mean(check,1);
    clear check 
    
    check(1:length(chan),1:n_sub) = mean(powB(i,:,f1:f2,:),3);
    output.delta(i+5,:) = mean(check,1);
    clear check 
end

% theta 
f1 = 6; % 5 Hz
f2 = 8; % 7 hz

check(1:length(chan),1:n_sub) = mean(pow_baseline(:,f1:f2,:),2);
output.theta(1,:) = mean(check,1);
clear check 

for i = 1:4
    check(1:length(chan),1:n_sub) = mean(powA(i,:,f1:f2,:),3);
    output.theta(i+1,:) = mean(check,1);
    clear check 
    
    check(1:length(chan),1:n_sub) = mean(powB(i,:,f1:f2,:),3);
    output.theta(i+5,:) = mean(check,1);
    clear check 
end

% alpha 
f1 = 9;  %8 Hz
f2 = 13; %12 Hz

check(1:length(chan),1:n_sub) = mean(pow_baseline(:,f1:f2,:),2);
output.alpha(1,:) = mean(check,1);
clear check 

for i = 1:4
    check(1:length(chan),1:n_sub) = mean(powA(i,:,f1:f2,:),3);
    output.alpha(i+1,:) = mean(check,1);
    clear check 
    
    check(1:length(chan),1:n_sub) = mean(powB(i,:,f1:f2,:),3);
    output.alpha(i+5,:) = mean(check,1);
    clear check 
end


% Beta 
f1 = 14;
f2 = 31;

check(1:length(chan),1:n_sub) = mean(pow_baseline(:,f1:f2,:),2);
output.beta(1,:) = mean(check,1);
clear check 

for i = 1:4
    check(1:length(chan),1:n_sub) = mean(powA(i,:,f1:f2,:),3);
    output.beta(i+1,:) = mean(check,1);
    clear check 
    
    check(1:length(chan),1:n_sub) = mean(powB(i,:,f1:f2,:),3);
    output.beta(i+5,:) = mean(check,1);
    clear check 
end

%% figure; 
% subplot(2,2,1),boxplot(output.delta([2,6],1:11)')
% subplot(2,2,2),boxplot(output.theta([2,6],1:11)')
% subplot(2,2,3),boxplot(output.alpha([2,6],1:11)')
% subplot(2,2,4),boxplot(output.beta([2,6],1:11)')