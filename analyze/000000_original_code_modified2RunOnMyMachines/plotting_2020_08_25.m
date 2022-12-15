%% loading files
load('dchanlocs_rev.mat');
load('B_cond.mat');
load('A_cond.mat');
load('C_cond.mat');
[psd] = extracting_psd_light(A_cond,B_cond);
%[psd] = extracting_psd_light(A_cond,C_cond);
[wpli,betw,pathl,eff,ecc,rad,strg] = extracting_wpli_light(A_cond,B_cond);
%[wpli,betw,pathl,eff,ecc,rad,strg] = extracting_wpli_light(A_cond,C_cond);
%% defining variables
f1 = [2,6,9,14]; % band start frequncy +1
f2 = [5,8,13,31]; % band end frequency +1
N = 23;

% *** EDIT LUIS
% the gpsd extraction code above only provides outputs to 11 subjects. I
% will not modify since this is just to replicate the script. this
% means that i have to change 2 things variables:
% sbj = 12 to sbj = 11
% a_sub = [1,2,3,4:7,9:12] to a_sub = 1:11 

sub = 11;
a_sub = [1:11]
% sub = 12;
% a_sub = [1,2,3,4:7,9:12];


[output,pow_baseline,powA,powB] = psd_comparison(psd,1,251,sub,1:23);
%a_sub = [1:6,8:10];
n = length(a_sub);
mm = strg; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% another round of plotting added Dec 28, 2020 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:4    
    s = f1(i);
    e = f2(i);      
    BS(:,i,1:n) = squeeze(mean(pow_baseline(:,s:e,a_sub),2)); % baseline
    P1(:,i,1:n) = squeeze(mean(powB(1,:,s:e,a_sub),3)); % T1 placebo
    P2(:,i,1:n) = squeeze(mean(powB(2,:,s:e,a_sub),3)); % T2 placebo
    P3(:,i,1:n) = squeeze(mean(powB(3,:,s:e,a_sub),3)); % T3 placebo
    P4(:,i,1:n) = squeeze(mean(powB(4,:,s:e,a_sub),3)); % T4 placebo
    
    bs(:,i,1:n)= mm.baseline(i,:,a_sub);
    p1(:,i,1:n)= mm.condB.run1(i,:,a_sub);
    p2(:,i,1:n)= mm.condB.run2(i,:,a_sub);
    p3(:,i,1:n)= mm.condB.run3(i,:,a_sub);
    p4(:,i,1:n)= mm.condB.run4(i,:,a_sub);
end

%% Figure 1
%%% panel A
figure;
x1 = squeeze(mean(BS(:,1,:),1));
y1 = [squeeze(mean(P1(:,1,:),1)),squeeze(mean(P2(:,1,:),1))];
x2 = squeeze(mean(BS(:,2,:),1));
y2 = [squeeze(mean(P1(:,2,:),1)),squeeze(mean(P2(:,2,:),1))];
x3 = squeeze(mean(BS(:,3,:),1));
y3 = [squeeze(mean(P1(:,3,:),1)),squeeze(mean(P2(:,3,:),1))];
x4 = squeeze(mean(BS(:,4,:),1));
y4 = [squeeze(mean(P1(:,4,:),1)),squeeze(mean(P2(:,4,:),1))];
d
boxplot([x1,mean(y1,2),x2,mean(y2,2),x3,mean(y3,2),x4,mean(y4,2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(x1,mean(y1,2)); 
[t12,t22,~,sts2] = ttest(x2,mean(y2,2)); 
[t13,t23,~,sts3] = ttest(x3,mean(y3,2)); 
[t14,t24,~,sts4] = ttest(x4,mean(y4,2)); 

title(sprintf('Pow: BS vs P1-2,p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% Panel B 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mean(pow_baseline(j,s:e,a_sub),2));
        b2 = squeeze(mean(powB(1,j,s:e,a_sub),3));
        b3 = squeeze(mean(powB(2,j,s:e,a_sub),3));
        [tb(1,j),tb(2,j),~,sts] = ttest(b1,mean([b2,b3],2));
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Pow: BS vs P1-2'));
end

%%% Panel C
figure;
x1 = squeeze(mean(bs(:,1,:),1));
y1 = [squeeze(mean(p1(:,1,:),1)),squeeze(mean(p2(:,1,:),1))];
x2 = squeeze(mean(bs(:,2,:),1));
y2 = [squeeze(mean(p1(:,2,:),1)),squeeze(mean(p2(:,2,:),1))];
x3 = squeeze(mean(bs(:,3,:),1));
y3 = [squeeze(mean(p1(:,3,:),1)),squeeze(mean(p2(:,3,:),1))];
x4 = squeeze(mean(bs(:,4,:),1));
y4 = [squeeze(mean(p1(:,4,:),1)),squeeze(mean(p2(:,4,:),1))];

boxplot([x1,mean(y1,2),x2,mean(y2,2),x3,mean(y3,2),x4,mean(y4,2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(x1,mean(y1,2)); 
[t12,t22,~,sts2] = ttest(x2,mean(y2,2)); 
[t13,t23,~,sts3] = ttest(x3,mean(y3,2)); 
[t14,t24,~,sts4] = ttest(x4,mean(y4,2)); 

title(sprintf('Con: BS vs P1-2, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% Panel D
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23      
        clear b1 b2 b3
        b1 = squeeze(mm.baseline(i,j,a_sub));
        b2 = squeeze(mm.condB.run1(i,j,a_sub));
        b3 = squeeze(mm.condB.run2(i,j,a_sub));
        [tb(1,j),tb(2,j),~,sts] = ttest(b1,mean([b2,b3],2));
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Con: BS vs P1-2'));
end


%% Figure 2
%%% panel A
figure;
x1 = squeeze(mean(BS(:,1,:),1));
y1 = [squeeze(mean(P3(:,1,:),1)),squeeze(mean(P4(:,1,:),1))];
x2 = squeeze(mean(BS(:,2,:),1));
y2 = [squeeze(mean(P3(:,2,:),1)),squeeze(mean(P4(:,2,:),1))];
x3 = squeeze(mean(BS(:,3,:),1));
y3 = [squeeze(mean(P3(:,3,:),1)),squeeze(mean(P4(:,3,:),1))];
x4 = squeeze(mean(BS(:,4,:),1));
y4 = [squeeze(mean(P3(:,4,:),1)),squeeze(mean(P4(:,4,:),1))];

boxplot([x1,mean(y1,2),x2,mean(y2,2),x3,mean(y3,2),x4,mean(y4,2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(x1,mean(y1,2)); 
[t12,t22,~,sts2] = ttest(x2,mean(y2,2)); 
[t13,t23,~,sts3] = ttest(x3,mean(y3,2)); 
[t14,t24,~,sts4] = ttest(x4,mean(y4,2)); 

title(sprintf('Pow: BS vs P3-4, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% Panel B 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mean(pow_baseline(j,s:e,a_sub),2));
        b2 = squeeze(mean(powB(3,j,s:e,a_sub),3));
        b3 = squeeze(mean(powB(4,j,s:e,a_sub),3));
        [tb(1,j),tb(2,j),~,sts] = ttest(b1,mean([b2,b3],2));
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Pow: BS vs P3-4'));
end

%%% Panel C
figure;
x1 = squeeze(mean(bs(:,1,:),1));
y1 = [squeeze(mean(p3(:,1,:),1)),squeeze(mean(p4(:,1,:),1))];
x2 = squeeze(mean(bs(:,2,:),1));
y2 = [squeeze(mean(p3(:,2,:),1)),squeeze(mean(p4(:,2,:),1))];
x3 = squeeze(mean(bs(:,3,:),1));
y3 = [squeeze(mean(p3(:,3,:),1)),squeeze(mean(p4(:,3,:),1))];
x4 = squeeze(mean(bs(:,4,:),1));
y4 = [squeeze(mean(p3(:,4,:),1)),squeeze(mean(p4(:,4,:),1))];

boxplot([x1,mean(y1,2),x2,mean(y2,2),x3,mean(y3,2),x4,mean(y4,2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(x1,mean(y1,2)); 
[t12,t22,~,sts2] = ttest(x2,mean(y2,2)); 
[t13,t23,~,sts3] = ttest(x3,mean(y3,2)); 
[t14,t24,~,sts4] = ttest(x4,mean(y4,2)); 

title(sprintf('Con: BS vs P3-4, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% Panel D
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23      
        clear b1 b2 b3
        b1 = squeeze(mm.baseline(i,j,a_sub));
        b2 = squeeze(mm.condB.run3(i,j,a_sub));
        b3 = squeeze(mm.condB.run4(i,j,a_sub));
        [tb(1,j),tb(2,j),~,sts] = ttest(b1,mean([b2,b3],2));
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Con: BS vs P3-4'));
end


%% Figure 3S

%%% panel A
figure;
x1 = [squeeze(mean(P1(:,1,:),1)),squeeze(mean(P2(:,1,:),1))];
y1 = [squeeze(mean(P3(:,1,:),1)),squeeze(mean(P4(:,1,:),1))];

x2 = [squeeze(mean(P1(:,2,:),1)),squeeze(mean(P2(:,2,:),1))];
y2 = [squeeze(mean(P3(:,2,:),1)),squeeze(mean(P4(:,2,:),1))];

x3 = [squeeze(mean(P1(:,3,:),1)),squeeze(mean(P2(:,3,:),1))];
y3 = [squeeze(mean(P3(:,3,:),1)),squeeze(mean(P4(:,3,:),1))];

x4 = [squeeze(mean(P1(:,4,:),1)),squeeze(mean(P2(:,4,:),1))];
y4 = [squeeze(mean(P3(:,4,:),1)),squeeze(mean(P4(:,4,:),1))];

boxplot([mean(x1,2),mean(y1,2),mean(x2,2),mean(y2,2),mean(x3,2),mean(y3,2),mean(x4,2),mean(y4,2)],...
    'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(mean(x1,2),mean(y1,2)); 
[t12,t22,~,sts2] = ttest(mean(x2,2),mean(y2,2)); 
[t13,t23,~,sts3] = ttest(mean(x3,2),mean(y3,2)); 
[t14,t24,~,sts4] = ttest(mean(x4,2),mean(y4,2)); 

title(sprintf('Pow: P1-2 vs P3-4, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% Panel B 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mean(powB(1,j,s:e,a_sub),3));
        b2 = squeeze(mean(powB(2,j,s:e,a_sub),3));
        b3 = squeeze(mean(powB(3,j,s:e,a_sub),3));
        b4 = squeeze(mean(powB(4,j,s:e,a_sub),3));
        [tb(1,j),tb(2,j),~,sts] = ttest(mean([b1,b2],2),mean([b3,b4],2));
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Pow: P1-2 vs P3-4'));
end

%%% Panel C
figure;
x1 = [squeeze(mean(p1(:,1,:),1)),squeeze(mean(p2(:,1,:),1))];
y1 = [squeeze(mean(p3(:,1,:),1)),squeeze(mean(p4(:,1,:),1))];

x2 = [squeeze(mean(p1(:,2,:),1)),squeeze(mean(p2(:,2,:),1))];
y2 = [squeeze(mean(p3(:,2,:),1)),squeeze(mean(p4(:,2,:),1))];

x3 = [squeeze(mean(p1(:,3,:),1)),squeeze(mean(p2(:,3,:),1))];
y3 = [squeeze(mean(p3(:,3,:),1)),squeeze(mean(p4(:,3,:),1))];

x4 = [squeeze(mean(p1(:,4,:),1)),squeeze(mean(p2(:,4,:),1))];
y4 = [squeeze(mean(p3(:,4,:),1)),squeeze(mean(p4(:,4,:),1))];

boxplot([mean(x1,2),mean(y1,2),mean(x2,2),mean(y2,2),mean(x3,2),mean(y3,2),mean(x4,2),mean(y4,2)],...
    'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(mean(x1,2),mean(y1,2)); 
[t12,t22,~,sts2] = ttest(mean(x2,2),mean(y2,2)); 
[t13,t23,~,sts3] = ttest(mean(x3,2),mean(y3,2)); 
[t14,t24,~,sts4] = ttest(mean(x4,2),mean(y4,2)); 

title(sprintf('Con: P1-2 vs P3-4,p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% Panel D
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23      
        clear b1 b2 b3
        b1 = squeeze(mm.condB.run1(i,j,a_sub));
        b2 = squeeze(mm.condB.run2(i,j,a_sub));        
        b3 = squeeze(mm.condB.run3(i,j,a_sub));
        b4 = squeeze(mm.condB.run4(i,j,a_sub));
        [tb(1,j),tb(2,j),~,sts] = ttest(mean([b1,b2],2),mean([b3,b4],2));
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Con: P1-2 vs P3-4'));
end


%% figure 3 Placebo vs Light 
for i = 1:4    
    s = f1(i);
    e = f2(i);      
    L1(:,i,1:n) = squeeze(mean(powA(1,:,s:e,a_sub),3)); % T1 placebo
    L2(:,i,1:n) = squeeze(mean(powA(2,:,s:e,a_sub),3)); % T2 placebo
    L3(:,i,1:n) = squeeze(mean(powA(3,:,s:e,a_sub),3)); % T3 placebo
    L4(:,i,1:n) = squeeze(mean(powA(4,:,s:e,a_sub),3)); % T4 placebo
    
    l1(:,i,1:n)= mm.condA.run1(i,:,a_sub);
    l2(:,i,1:n)= mm.condA.run2(i,:,a_sub);
    l3(:,i,1:n)= mm.condA.run3(i,:,a_sub);
    l4(:,i,1:n)= mm.condA.run4(i,:,a_sub);
end

%%% Panel A
figure;

%%% A1
x1 = squeeze(mean(P1(:,1,:),1));
y1 = squeeze(mean(L1(:,1,:),1));
x2 = squeeze(mean(P1(:,2,:),1));
y2 = squeeze(mean(L1(:,2,:),1));
x3 = squeeze(mean(P1(:,3,:),1));
y3 = squeeze(mean(L1(:,3,:),1));
x4 = squeeze(mean(P1(:,4,:),1));
y4 = squeeze(mean(L1(:,4,:),1));

subplot(2,2,1), boxplot([x1,y1,x2,y2,x3,y3,x4,y4],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(x1,y1); 
[t12,t22,~,sts2] = ttest(x2,y2); 
[t13,t23,~,sts3] = ttest(x3,y3); 
[t14,t24,~,sts4] = ttest(x4,y4); 

title(sprintf('Pow: P1 vs L1, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% A2
x1 = squeeze(mean(P2(:,1,:),1));
y1 = squeeze(mean(L2(:,1,:),1));
x2 = squeeze(mean(P2(:,2,:),1));
y2 = squeeze(mean(L2(:,2,:),1));
x3 = squeeze(mean(P2(:,3,:),1));
y3 = squeeze(mean(L2(:,3,:),1));
x4 = squeeze(mean(P2(:,4,:),1));
y4 = squeeze(mean(L2(:,4,:),1));

subplot(2,2,2), boxplot([x1,y1,x2,y2,x3,y3,x4,y4],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(x1,y1); 
[t12,t22,~,sts2] = ttest(x2,y2); 
[t13,t23,~,sts3] = ttest(x3,y3); 
[t14,t24,~,sts4] = ttest(x4,y4); 
title(sprintf('Pow: P2 vs L2, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% A3
x1 = squeeze(mean(P3(:,1,:),1));
y1 = squeeze(mean(L3(:,1,:),1));
x2 = squeeze(mean(P3(:,2,:),1));
y2 = squeeze(mean(L3(:,2,:),1));
x3 = squeeze(mean(P3(:,3,:),1));
y3 = squeeze(mean(L3(:,3,:),1));
x4 = squeeze(mean(P3(:,4,:),1));
y4 = squeeze(mean(L3(:,4,:),1));

subplot(2,2,3), boxplot([x1,y1,x2,y2,x3,y3,x4,y4],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(x1,y1); 
[t12,t22,~,sts2] = ttest(x2,y2); 
[t13,t23,~,sts3] = ttest(x3,y3); 
[t14,t24,~,sts4] = ttest(x4,y4); 
title(sprintf('Pow: P3 vs L3, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% A4
x1 = squeeze(mean(P4(:,1,:),1));
y1 = squeeze(mean(L4(:,1,:),1));
x2 = squeeze(mean(P4(:,2,:),1));
y2 = squeeze(mean(L4(:,2,:),1));
x3 = squeeze(mean(P4(:,3,:),1));
y3 = squeeze(mean(L4(:,3,:),1));
x4 = squeeze(mean(P4(:,4,:),1));
y4 = squeeze(mean(L4(:,4,:),1));

subplot(2,2,4), boxplot([x1,y1,x2,y2,x3,y3,x4,y4],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(x1,y1); 
[t12,t22,~,sts2] = ttest(x2,y2); 
[t13,t23,~,sts3] = ttest(x3,y3); 
[t14,t24,~,sts4] = ttest(x4,y4); 
title(sprintf('Pow: P4 vs L4, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));



%%% Panel B
figure;

%%% B1
x1 = squeeze(mean(p1(:,1,:),1));
y1 = squeeze(mean(l1(:,1,:),1));
x2 = squeeze(mean(p1(:,2,:),1));
y2 = squeeze(mean(l1(:,2,:),1));
x3 = squeeze(mean(p1(:,3,:),1));
y3 = squeeze(mean(l1(:,3,:),1));
x4 = squeeze(mean(p1(:,4,:),1));
y4 = squeeze(mean(l1(:,4,:),1));

subplot(2,2,1), boxplot([x1,y1,x2,y2,x3,y3,x4,y4],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(x1,y1); 
[t12,t22,~,sts2] = ttest(x2,y2); 
[t13,t23,~,sts3] = ttest(x3,y3); 
[t14,t24,~,sts4] = ttest(x4,y4); 

title(sprintf('Con: P1 vs L1, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% B2
x1 = squeeze(mean(p2(:,1,:),1));
y1 = squeeze(mean(l2(:,1,:),1));
x2 = squeeze(mean(p2(:,2,:),1));
y2 = squeeze(mean(l2(:,2,:),1));
x3 = squeeze(mean(p2(:,3,:),1));
y3 = squeeze(mean(l2(:,3,:),1));
x4 = squeeze(mean(p2(:,4,:),1));
y4 = squeeze(mean(l2(:,4,:),1));

subplot(2,2,2), boxplot([x1,y1,x2,y2,x3,y3,x4,y4],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(x1,y1); 
[t12,t22,~,sts2] = ttest(x2,y2); 
[t13,t23,~,sts3] = ttest(x3,y3); 
[t14,t24,~,sts4] = ttest(x4,y4); 
title(sprintf('Con: P2 vs L2, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% B3
x1 = squeeze(mean(p3(:,1,:),1));
y1 = squeeze(mean(l3(:,1,:),1));
x2 = squeeze(mean(p3(:,2,:),1));
y2 = squeeze(mean(l3(:,2,:),1));
x3 = squeeze(mean(p3(:,3,:),1));
y3 = squeeze(mean(l3(:,3,:),1));
x4 = squeeze(mean(p3(:,4,:),1));
y4 = squeeze(mean(l3(:,4,:),1));

subplot(2,2,3), boxplot([x1,y1,x2,y2,x3,y3,x4,y4],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(x1,y1); 
[t12,t22,~,sts2] = ttest(x2,y2); 
[t13,t23,~,sts3] = ttest(x3,y3); 
[t14,t24,~,sts4] = ttest(x4,y4); 
title(sprintf('Con: P3 vs L3, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% B4
x1 = squeeze(mean(p4(:,1,:),1));
y1 = squeeze(mean(l4(:,1,:),1));
x2 = squeeze(mean(p4(:,2,:),1));
y2 = squeeze(mean(l4(:,2,:),1));
x3 = squeeze(mean(p4(:,3,:),1));
y3 = squeeze(mean(l4(:,3,:),1));
x4 = squeeze(mean(p4(:,4,:),1));
y4 = squeeze(mean(l4(:,4,:),1));

subplot(2,2,4), boxplot([x1,y1,x2,y2,x3,y3,x4,y4],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(x1,y1); 
[t12,t22,~,sts2] = ttest(x2,y2); 
[t13,t23,~,sts3] = ttest(x3,y3); 
[t14,t24,~,sts4] = ttest(x4,y4); 
title(sprintf('Con: P4 vs L4, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));



%%% panel C
figure;

%%% C1
x1 = [squeeze(mean(P1(:,1,:),1)),squeeze(mean(P2(:,1,:),1))];
y1 = [squeeze(mean(L1(:,1,:),1)),squeeze(mean(L2(:,1,:),1))];

x2 = [squeeze(mean(P1(:,2,:),1)),squeeze(mean(P2(:,2,:),1))];
y2 = [squeeze(mean(L1(:,2,:),1)),squeeze(mean(L2(:,2,:),1))];

x3 = [squeeze(mean(P1(:,3,:),1)),squeeze(mean(P2(:,3,:),1))];
y3 = [squeeze(mean(L1(:,3,:),1)),squeeze(mean(L2(:,3,:),1))];

x4 = [squeeze(mean(P1(:,4,:),1)),squeeze(mean(P2(:,4,:),1))];
y4 = [squeeze(mean(L1(:,4,:),1)),squeeze(mean(L2(:,4,:),1))];

subplot(2,2,1), boxplot([mean(x1,2),mean(y1,2),mean(x2,2),mean(y2,2),mean(x3,2),mean(y3,2),mean(x4,2),mean(y4,2)],...
    'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(mean(x1,2),mean(y1,2)); 
[t12,t22,~,sts2] = ttest(mean(x2,2),mean(y2,2)); 
[t13,t23,~,sts3] = ttest(mean(x3,2),mean(y3,2)); 
[t14,t24,~,sts4] = ttest(mean(x4,2),mean(y4,2)); 

title(sprintf('Pow: P1-2 vs L1-L2, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% C2
x1 = [squeeze(mean(P3(:,1,:),1)),squeeze(mean(P4(:,1,:),1))];
y1 = [squeeze(mean(L3(:,1,:),1)),squeeze(mean(L4(:,1,:),1))];

x2 = [squeeze(mean(P3(:,2,:),1)),squeeze(mean(P4(:,2,:),1))];
y2 = [squeeze(mean(L3(:,2,:),1)),squeeze(mean(L4(:,2,:),1))];

x3 = [squeeze(mean(P3(:,3,:),1)),squeeze(mean(P4(:,3,:),1))];
y3 = [squeeze(mean(L3(:,3,:),1)),squeeze(mean(L4(:,3,:),1))];

x4 = [squeeze(mean(P3(:,4,:),1)),squeeze(mean(P4(:,4,:),1))];
y4 = [squeeze(mean(L3(:,4,:),1)),squeeze(mean(L4(:,4,:),1))];

subplot(2,2,2),boxplot([mean(x1,2),mean(y1,2),mean(x2,2),mean(y2,2),mean(x3,2),mean(y3,2),mean(x4,2),mean(y4,2)],...
    'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(mean(x1,2),mean(y1,2)); 
[t12,t22,~,sts2] = ttest(mean(x2,2),mean(y2,2)); 
[t13,t23,~,sts3] = ttest(mean(x3,2),mean(y3,2)); 
[t14,t24,~,sts4] = ttest(mean(x4,2),mean(y4,2)); 

title(sprintf('Pow: P3-4 vs L3-L4, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% C3
x1 = [squeeze(mean(p1(:,1,:),1)),squeeze(mean(p2(:,1,:),1))];
y1 = [squeeze(mean(l1(:,1,:),1)),squeeze(mean(l2(:,1,:),1))];

x2 = [squeeze(mean(p1(:,2,:),1)),squeeze(mean(p2(:,2,:),1))];
y2 = [squeeze(mean(l1(:,2,:),1)),squeeze(mean(l2(:,2,:),1))];

x3 = [squeeze(mean(p1(:,3,:),1)),squeeze(mean(p2(:,3,:),1))];
y3 = [squeeze(mean(l1(:,3,:),1)),squeeze(mean(l2(:,3,:),1))];

x4 = [squeeze(mean(p1(:,4,:),1)),squeeze(mean(p2(:,4,:),1))];
y4 = [squeeze(mean(l1(:,4,:),1)),squeeze(mean(l2(:,4,:),1))];

subplot(2,2,3), boxplot([mean(x1,2),mean(y1,2),mean(x2,2),mean(y2,2),mean(x3,2),mean(y3,2),mean(x4,2),mean(y4,2)],...
    'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(mean(x1,2),mean(y1,2)); 
[t12,t22,~,sts2] = ttest(mean(x2,2),mean(y2,2)); 
[t13,t23,~,sts3] = ttest(mean(x3,2),mean(y3,2)); 
[t14,t24,~,sts4] = ttest(mean(x4,2),mean(y4,2)); 

title(sprintf('Con: P1-2 vs L1-L2, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% C4
x1 = [squeeze(mean(p3(:,1,:),1)),squeeze(mean(p4(:,1,:),1))];
y1 = [squeeze(mean(l3(:,1,:),1)),squeeze(mean(l4(:,1,:),1))];

x2 = [squeeze(mean(p3(:,2,:),1)),squeeze(mean(p4(:,2,:),1))];
y2 = [squeeze(mean(l3(:,2,:),1)),squeeze(mean(l4(:,2,:),1))];

x3 = [squeeze(mean(p3(:,3,:),1)),squeeze(mean(p4(:,3,:),1))];
y3 = [squeeze(mean(l3(:,3,:),1)),squeeze(mean(l4(:,3,:),1))];

x4 = [squeeze(mean(p3(:,4,:),1)),squeeze(mean(p4(:,4,:),1))];
y4 = [squeeze(mean(l3(:,4,:),1)),squeeze(mean(l4(:,4,:),1))];

subplot(2,2,4),boxplot([mean(x1,2),mean(y1,2),mean(x2,2),mean(y2,2),mean(x3,2),mean(y3,2),mean(x4,2),mean(y4,2)],...
    'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(mean(x1,2),mean(y1,2)); 
[t12,t22,~,sts2] = ttest(mean(x2,2),mean(y2,2)); 
[t13,t23,~,sts3] = ttest(mean(x3,2),mean(y3,2)); 
[t14,t24,~,sts4] = ttest(mean(x4,2),mean(y4,2)); 

title(sprintf('Con: P3-4 vs L3-L4, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%%% Panles D
%%% D1
figure;
x1 = [squeeze(mean(P1(:,1,:),1)),squeeze(mean(P2(:,1,:),1)),squeeze(mean(P3(:,1,:),1)),squeeze(mean(P4(:,1,:),1))];
y1 = [squeeze(mean(L1(:,1,:),1)),squeeze(mean(L2(:,1,:),1)),squeeze(mean(L3(:,1,:),1)),squeeze(mean(L4(:,1,:),1))];

x2 = [squeeze(mean(P1(:,2,:),1)),squeeze(mean(P2(:,2,:),1)),squeeze(mean(P3(:,2,:),1)),squeeze(mean(P4(:,2,:),1))];
y2 = [squeeze(mean(L1(:,2,:),1)),squeeze(mean(L2(:,2,:),1)),squeeze(mean(L3(:,2,:),1)),squeeze(mean(L4(:,2,:),1))];

x3 = [squeeze(mean(P1(:,3,:),1)),squeeze(mean(P2(:,3,:),1)),squeeze(mean(P3(:,3,:),1)),squeeze(mean(P4(:,3,:),1))];
y3 = [squeeze(mean(L1(:,3,:),1)),squeeze(mean(L2(:,3,:),1)),squeeze(mean(L3(:,3,:),1)),squeeze(mean(L4(:,3,:),1))];

x4 = [squeeze(mean(P1(:,4,:),1)),squeeze(mean(P2(:,4,:),1)),squeeze(mean(P3(:,4,:),1)),squeeze(mean(P4(:,4,:),1))];
y4 = [squeeze(mean(L1(:,4,:),1)),squeeze(mean(L2(:,4,:),1)),squeeze(mean(L3(:,4,:),1)),squeeze(mean(L4(:,4,:),1))];

subplot(1,2,1),boxplot([mean(x1,2),mean(y1,2),mean(x2,2),mean(y2,2),mean(x3,2),mean(y3,2),mean(x4,2),mean(y4,2)],...
    'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(mean(x1,2),mean(y1,2)); 
[t12,t22,~,sts2] = ttest(mean(x2,2),mean(y2,2)); 
[t13,t23,~,sts3] = ttest(mean(x3,2),mean(y3,2)); 
[t14,t24,~,sts4] = ttest(mean(x4,2),mean(y4,2)); 

title(sprintf('Pow: P1-4 vs L1-L4, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% D2
x1 = [squeeze(mean(p1(:,1,:),1)),squeeze(mean(p2(:,1,:),1)),squeeze(mean(p3(:,1,:),1)),squeeze(mean(p4(:,1,:),1))];
y1 = [squeeze(mean(l1(:,1,:),1)),squeeze(mean(l2(:,1,:),1)),squeeze(mean(l3(:,1,:),1)),squeeze(mean(l4(:,1,:),1))];

x2 = [squeeze(mean(p1(:,2,:),1)),squeeze(mean(p2(:,2,:),1)),squeeze(mean(p3(:,2,:),1)),squeeze(mean(p4(:,2,:),1))];
y2 = [squeeze(mean(l1(:,2,:),1)),squeeze(mean(l2(:,2,:),1)),squeeze(mean(l3(:,2,:),1)),squeeze(mean(l4(:,2,:),1))];

x3 = [squeeze(mean(p1(:,3,:),1)),squeeze(mean(p2(:,3,:),1)),squeeze(mean(p3(:,3,:),1)),squeeze(mean(p4(:,3,:),1))];
y3 = [squeeze(mean(l1(:,3,:),1)),squeeze(mean(l2(:,3,:),1)),squeeze(mean(l3(:,3,:),1)),squeeze(mean(l4(:,3,:),1))];

x4 = [squeeze(mean(p1(:,4,:),1)),squeeze(mean(p2(:,4,:),1)),squeeze(mean(p3(:,4,:),1)),squeeze(mean(p4(:,4,:),1))];
y4 = [squeeze(mean(l1(:,4,:),1)),squeeze(mean(l2(:,4,:),1)),squeeze(mean(l3(:,4,:),1)),squeeze(mean(l4(:,4,:),1))];

subplot(1,2,2),boxplot([mean(x1,2),mean(y1,2),mean(x2,2),mean(y2,2),mean(x3,2),mean(y3,2),mean(x4,2),mean(y4,2)],...
    'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
[t11,t21,~,sts1] = ttest(mean(x1,2),mean(y1,2)); 
[t12,t22,~,sts2] = ttest(mean(x2,2),mean(y2,2)); 
[t13,t23,~,sts3] = ttest(mean(x3,2),mean(y3,2)); 
[t14,t24,~,sts4] = ttest(mean(x4,2),mean(y4,2)); 

title(sprintf('Con: P1-4 vs L1-L4, p1=%2.4f,p2=%2.4f,p3=%2.4f,p4=%2.4f',t21,t22,t23,t24));

%%% Panel E 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mean(powB(1,j,s:e,a_sub),3));
        b2 = squeeze(mean(powB(2,j,s:e,a_sub),3));
        b3 = squeeze(mean(powB(3,j,s:e,a_sub),3));
        b4 = squeeze(mean(powB(4,j,s:e,a_sub),3));
        
        a1 = squeeze(mean(powA(1,j,s:e,a_sub),3));
        a2 = squeeze(mean(powA(2,j,s:e,a_sub),3));
        a3 = squeeze(mean(powA(3,j,s:e,a_sub),3));
        a4 = squeeze(mean(powA(4,j,s:e,a_sub),3));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(b1,a1);
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Pow: P1 vs L1'));
end

%%% Panel F 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mean(powB(1,j,s:e,a_sub),3));
        b2 = squeeze(mean(powB(2,j,s:e,a_sub),3));
        b3 = squeeze(mean(powB(3,j,s:e,a_sub),3));
        b4 = squeeze(mean(powB(4,j,s:e,a_sub),3));
        
        a1 = squeeze(mean(powA(1,j,s:e,a_sub),3));
        a2 = squeeze(mean(powA(2,j,s:e,a_sub),3));
        a3 = squeeze(mean(powA(3,j,s:e,a_sub),3));
        a4 = squeeze(mean(powA(4,j,s:e,a_sub),3));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(b2,a2);
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Pow: P2 vs L2'));
end

%%% Panel G 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mean(powB(1,j,s:e,a_sub),3));
        b2 = squeeze(mean(powB(2,j,s:e,a_sub),3));
        b3 = squeeze(mean(powB(3,j,s:e,a_sub),3));
        b4 = squeeze(mean(powB(4,j,s:e,a_sub),3));
        
        a1 = squeeze(mean(powA(1,j,s:e,a_sub),3));
        a2 = squeeze(mean(powA(2,j,s:e,a_sub),3));
        a3 = squeeze(mean(powA(3,j,s:e,a_sub),3));
        a4 = squeeze(mean(powA(4,j,s:e,a_sub),3));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(b3,a3);
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Pow: P3 vs L3'));
end

%%% Panel H 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mean(powB(1,j,s:e,a_sub),3));
        b2 = squeeze(mean(powB(2,j,s:e,a_sub),3));
        b3 = squeeze(mean(powB(3,j,s:e,a_sub),3));
        b4 = squeeze(mean(powB(4,j,s:e,a_sub),3));
        
        a1 = squeeze(mean(powA(1,j,s:e,a_sub),3));
        a2 = squeeze(mean(powA(2,j,s:e,a_sub),3));
        a3 = squeeze(mean(powA(3,j,s:e,a_sub),3));
        a4 = squeeze(mean(powA(4,j,s:e,a_sub),3));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(b4,a4);
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Pow: P4 vs L4'));
end


%%% Panel i 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mm.condB.run1(i,j,a_sub));
        b2 = squeeze(mm.condB.run2(i,j,a_sub));        
        b3 = squeeze(mm.condB.run3(i,j,a_sub));
        b4 = squeeze(mm.condB.run4(i,j,a_sub));
        
        a1 = squeeze(mm.condA.run1(i,j,a_sub));
        a2 = squeeze(mm.condA.run2(i,j,a_sub));        
        a3 = squeeze(mm.condA.run3(i,j,a_sub));
        a4 = squeeze(mm.condA.run4(i,j,a_sub));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(b1,a1);
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Con: P1 vs L1'));
end


%%% Panel j 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mm.condB.run1(i,j,a_sub));
        b2 = squeeze(mm.condB.run2(i,j,a_sub));        
        b3 = squeeze(mm.condB.run3(i,j,a_sub));
        b4 = squeeze(mm.condB.run4(i,j,a_sub));
        
        a1 = squeeze(mm.condA.run1(i,j,a_sub));
        a2 = squeeze(mm.condA.run2(i,j,a_sub));        
        a3 = squeeze(mm.condA.run3(i,j,a_sub));
        a4 = squeeze(mm.condA.run4(i,j,a_sub));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(b2,a2);
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Con: P2 vs L2'));
end

%%% Panel k 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mm.condB.run1(i,j,a_sub));
        b2 = squeeze(mm.condB.run2(i,j,a_sub));        
        b3 = squeeze(mm.condB.run3(i,j,a_sub));
        b4 = squeeze(mm.condB.run4(i,j,a_sub));
        
        a1 = squeeze(mm.condA.run1(i,j,a_sub));
        a2 = squeeze(mm.condA.run2(i,j,a_sub));        
        a3 = squeeze(mm.condA.run3(i,j,a_sub));
        a4 = squeeze(mm.condA.run4(i,j,a_sub));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(b3,a3);
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Con: P3 vs L3'));
end

%%% Panel l 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mm.condB.run1(i,j,a_sub));
        b2 = squeeze(mm.condB.run2(i,j,a_sub));        
        b3 = squeeze(mm.condB.run3(i,j,a_sub));
        b4 = squeeze(mm.condB.run4(i,j,a_sub));
        
        a1 = squeeze(mm.condA.run1(i,j,a_sub));
        a2 = squeeze(mm.condA.run2(i,j,a_sub));        
        a3 = squeeze(mm.condA.run3(i,j,a_sub));
        a4 = squeeze(mm.condA.run4(i,j,a_sub));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(b4,a4);
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Con: P4 vs L4'));
end

%%% Panel m 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mean(powB(1,j,s:e,a_sub),3));
        b2 = squeeze(mean(powB(2,j,s:e,a_sub),3));
        b3 = squeeze(mean(powB(3,j,s:e,a_sub),3));
        b4 = squeeze(mean(powB(4,j,s:e,a_sub),3));
        
        a1 = squeeze(mean(powA(1,j,s:e,a_sub),3));
        a2 = squeeze(mean(powA(2,j,s:e,a_sub),3));
        a3 = squeeze(mean(powA(3,j,s:e,a_sub),3));
        a4 = squeeze(mean(powA(4,j,s:e,a_sub),3));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(mean([b1,b2],2),mean([a1,a2],2));
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Pow: P1-2 vs L1-2'));
end

%%% Panel n 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mean(powB(1,j,s:e,a_sub),3));
        b2 = squeeze(mean(powB(2,j,s:e,a_sub),3));
        b3 = squeeze(mean(powB(3,j,s:e,a_sub),3));
        b4 = squeeze(mean(powB(4,j,s:e,a_sub),3));
        
        a1 = squeeze(mean(powA(1,j,s:e,a_sub),3));
        a2 = squeeze(mean(powA(2,j,s:e,a_sub),3));
        a3 = squeeze(mean(powA(3,j,s:e,a_sub),3));
        a4 = squeeze(mean(powA(4,j,s:e,a_sub),3));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(mean([b3,b4],2),mean([a3,a4],2));
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Pow: P3-4 vs L3-4'));
end



%%% Panel o 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mean(powB(1,j,s:e,a_sub),3));
        b2 = squeeze(mean(powB(2,j,s:e,a_sub),3));
        b3 = squeeze(mean(powB(3,j,s:e,a_sub),3));
        b4 = squeeze(mean(powB(4,j,s:e,a_sub),3));
        
        a1 = squeeze(mean(powA(1,j,s:e,a_sub),3));
        a2 = squeeze(mean(powA(2,j,s:e,a_sub),3));
        a3 = squeeze(mean(powA(3,j,s:e,a_sub),3));
        a4 = squeeze(mean(powA(4,j,s:e,a_sub),3));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(mean([b1,b2,b3,b4],2),mean([a1,a2,a3,a4],2));
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Pow: P1-4 vs L1-4'));
end

%%% Panel p 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mm.condB.run1(i,j,a_sub));
        b2 = squeeze(mm.condB.run2(i,j,a_sub));        
        b3 = squeeze(mm.condB.run3(i,j,a_sub));
        b4 = squeeze(mm.condB.run4(i,j,a_sub));
        
        a1 = squeeze(mm.condA.run1(i,j,a_sub));
        a2 = squeeze(mm.condA.run2(i,j,a_sub));        
        a3 = squeeze(mm.condA.run3(i,j,a_sub));
        a4 = squeeze(mm.condA.run4(i,j,a_sub));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(mean([b1,b2],2),mean([a1,a2],2));
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Con: P1-2 vs L1-2'));
end

%%% Panel q 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mm.condB.run1(i,j,a_sub));
        b2 = squeeze(mm.condB.run2(i,j,a_sub));        
        b3 = squeeze(mm.condB.run3(i,j,a_sub));
        b4 = squeeze(mm.condB.run4(i,j,a_sub));
        
        a1 = squeeze(mm.condA.run1(i,j,a_sub));
        a2 = squeeze(mm.condA.run2(i,j,a_sub));        
        a3 = squeeze(mm.condA.run3(i,j,a_sub));
        a4 = squeeze(mm.condA.run4(i,j,a_sub));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(mean([b3,b4],2),mean([a3,a4],2));
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Con: P3-4 vs L3-4'));
end

%%% Panel q 
figure;
for i = 1:4
    s = f1(i);
    e = f2(i);  
    for j = 1:23             
        b1 = squeeze(mm.condB.run1(i,j,a_sub));
        b2 = squeeze(mm.condB.run2(i,j,a_sub));        
        b3 = squeeze(mm.condB.run3(i,j,a_sub));
        b4 = squeeze(mm.condB.run4(i,j,a_sub));
        
        a1 = squeeze(mm.condA.run1(i,j,a_sub));
        a2 = squeeze(mm.condA.run2(i,j,a_sub));        
        a3 = squeeze(mm.condA.run3(i,j,a_sub));
        a4 = squeeze(mm.condA.run4(i,j,a_sub));
        
        [tb(1,j),tb(2,j),~,sts] = ttest(mean([b1,b2,b3,b4],2),mean([a1,a2,a3,a4],2));
        tb(3,j) = sts.tstat;
    end
    subplot(1,4,i),topoplot(tb(3,:),chan,'style','map','electrodes','on');
    %colorbar
    colormap('jet')
    caxis([-3 3])
    title(sprintf('Con: P1-4 vs L1-4'));
end


%% extra1
for i = 1:4
    s = f1(i);
    e = f2(i);   
    B(1:n,1) = squeeze(mean(mean(pow_baseline(:,s:e,a_sub),2),1)); % baseline
    B(1:n,2) = squeeze(mean(mean(powB(1,:,s:e,a_sub),3),2));
    B(1:n,3) = squeeze(mean(mean(powB(2,:,s:e,a_sub),3),2));
    B(1:n,4) = squeeze(mean(mean(powB(3,:,s:e,a_sub),3),2));
    B(1:n,5) = squeeze(mean(mean(powB(4,:,s:e,a_sub),3),2));
   
    subplot(2,4,i),boxplot(B,'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
    [~,t1,~,sts] = ttest(B(:,1),B(:,2)); 
    [~,t2,~,sts] = ttest(B(:,1),B(:,3)); 
    [~,t3,~,sts] = ttest(B(:,1),B(:,4)); 
    [~,t4,~,sts] = ttest(B(:,1),B(:,5)); 
    [~,t5,~,sts] = ttest(B(:,2),B(:,3)); 
    [~,t6,~,sts] = ttest(B(:,2),B(:,4)); 
    [~,t7,~,sts] = ttest(B(:,2),B(:,5)); 
    [~,t8,~,sts] = ttest(B(:,3),B(:,4)); 
    [~,t9,~,sts] = ttest(B(:,3),B(:,5)); 
    [~,t10,~,sts] = ttest(B(:,4),B(:,5));
    title(sprintf('%2.2f,%2.2f,%2.2f,%2.2f,%2.2f,%2.2f,%2.2f,%2.2f,%2.2f,%2.2f',t1,t2,t3,t4,t5,t6,t7,t8,t9,t10));
%     subplot(5,4,i+4),boxplot([B(:,1),mean(B(:,2:3),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
%     subplot(5,4,i+8),boxplot([B(:,1),mean(B(:,4:5),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
    subplot(2,4,i+4),boxplot([B(:,1),mean(B(:,2:5),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
    [t1,t2,~,sts] = ttest(B(:,1),mean(B(:,2:5),2));  
    title(sprintf('Pow: BS vs P1-4 %2.2f',t2));
end    


%% extra2
for i = 1:4
    s = f1(i);
    e = f2(i);   
    B(:,1)= squeeze(mean(mm.baseline(i,:,a_sub),2));
    B(:,2)= squeeze(mean(mm.condB.run1(i,:,a_sub),2));
    B(:,3)= squeeze(mean(mm.condB.run2(i,:,a_sub),2));
    B(:,4)= squeeze(mean(mm.condB.run3(i,:,a_sub),2));
    B(:,5)= squeeze(mean(mm.condB.run4(i,:,a_sub),2));
   
    subplot(2,4,i),boxplot(B,'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
    [~,t1,~,sts] = ttest(B(:,1),B(:,2)); 
    [~,t2,~,sts] = ttest(B(:,1),B(:,3)); 
    [~,t3,~,sts] = ttest(B(:,1),B(:,4)); 
    [~,t4,~,sts] = ttest(B(:,1),B(:,5)); 
    [~,t5,~,sts] = ttest(B(:,2),B(:,3)); 
    [~,t6,~,sts] = ttest(B(:,2),B(:,4)); 
    [~,t7,~,sts] = ttest(B(:,2),B(:,5)); 
    [~,t8,~,sts] = ttest(B(:,3),B(:,4)); 
    [~,t9,~,sts] = ttest(B(:,3),B(:,5)); 
    [~,t10,~,sts] = ttest(B(:,4),B(:,5));
    title(sprintf('%2.2f,%2.2f,%2.2f,%2.2f,%2.2f,%2.2f,%2.2f,%2.2f,%2.2f,%2.2f',t1,t2,t3,t4,t5,t6,t7,t8,t9,t10));
%     subplot(5,4,i+4),boxplot([B(:,1),mean(B(:,2:3),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
%     subplot(5,4,i+8),boxplot([B(:,1),mean(B(:,4:5),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
    subplot(2,4,i+4),boxplot([B(:,1),mean(B(:,2:5),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
    [t1,t2,~,sts] = ttest(B(:,1),mean(B(:,2:5),2));  
    title(sprintf('Con: BS vs P1-4 %2.2f',t2));
end 



%% extra3 
figure; 
x1 = squeeze(mean(BS(:,1,:),1));
y1 = [squeeze(mean(P1(:,1,:),1)),squeeze(mean(P2(:,1,:),1))];
z1 = [squeeze(mean(P3(:,1,:),1)),squeeze(mean(P4(:,1,:),1))];


x2 = squeeze(mean(BS(:,2,:),1));
y2 = [squeeze(mean(P1(:,2,:),1)),squeeze(mean(P2(:,2,:),1))];
z2 = [squeeze(mean(P3(:,2,:),1)),squeeze(mean(P4(:,2,:),1))];


x3 = squeeze(mean(BS(:,3,:),1));
y3 = [squeeze(mean(P1(:,3,:),1)),squeeze(mean(P2(:,3,:),1))];
z3 = [squeeze(mean(P3(:,3,:),1)),squeeze(mean(P4(:,3,:),1))];

x4 = squeeze(mean(BS(:,4,:),1));
y4 = [squeeze(mean(P1(:,4,:),1)),squeeze(mean(P2(:,4,:),1))];
z4 = [squeeze(mean(P3(:,4,:),1)),squeeze(mean(P4(:,4,:),1))];

boxplot([x1,mean(y1,2),mean(z1,2),...
    x2,mean(y2,2),mean(z2,2),...
    x3,mean(y3,2),mean(z3,2),...
    x4,mean(y4,2),mean(z4,2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])


figure; 
x1 = squeeze(mean(bs(:,1,:),1));
y1 = [squeeze(mean(p1(:,1,:),1)),squeeze(mean(p2(:,1,:),1))];
z1 = [squeeze(mean(p3(:,1,:),1)),squeeze(mean(p4(:,1,:),1))];


x2 = squeeze(mean(bs(:,2,:),1));
y2 = [squeeze(mean(p1(:,2,:),1)),squeeze(mean(p2(:,2,:),1))];
z2 = [squeeze(mean(p3(:,2,:),1)),squeeze(mean(p4(:,2,:),1))];


x3 = squeeze(mean(bs(:,3,:),1));
y3 = [squeeze(mean(p1(:,3,:),1)),squeeze(mean(p2(:,3,:),1))];
z3 = [squeeze(mean(p3(:,3,:),1)),squeeze(mean(p4(:,3,:),1))];

x4 = squeeze(mean(bs(:,4,:),1));
y4 = [squeeze(mean(p1(:,4,:),1)),squeeze(mean(p2(:,4,:),1))];
z4 = [squeeze(mean(p3(:,4,:),1)),squeeze(mean(p4(:,4,:),1))];

boxplot([x1,mean(y1,2),mean(z1,2),...
    x2,mean(y2,2),mean(z2,2),...
    x3,mean(y3,2),mean(z3,2),...
    x4,mean(y4,2),mean(z4,2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])



%% extra3 alternate

figure; 
for i = 1:4
    s = f1(i);
    e = f2(i);   
    B(1:n,1) = squeeze(mean(mean(pow_baseline(:,s:e,a_sub),2),1)); % baseline
    B(1:n,2) = squeeze(mean(mean(powB(1,:,s:e,a_sub),3),2));
    B(1:n,3) = squeeze(mean(mean(powB(2,:,s:e,a_sub),3),2));
    B(1:n,4) = squeeze(mean(mean(powB(3,:,s:e,a_sub),3),2));
    B(1:n,5) = squeeze(mean(mean(powB(4,:,s:e,a_sub),3),2));
   
    subplot(2,4,i),boxplot([B(:,1),mean(B(:,2:3),2),mean(B(:,4:5),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
    [~,t1,~,sts] = ttest(B(:,1),mean(B(:,2:3),2)); 
    [~,t2,~,sts] = ttest(B(:,1),mean(B(:,4:5),2)); 
    [~,t3,~,sts] = ttest(mean(B(:,2:3),2),mean(B(:,4:5),2)); 
    title(sprintf('Pow: BS vs P1-2 vs P3-4, %2.2f,%2.2f,%2.2f',t1,t2,t3));
end 

for i = 1:4
    s = f1(i);
    e = f2(i);   
    B(:,1)= squeeze(mean(mm.baseline(i,:,a_sub),2));
    B(:,2)= squeeze(mean(mm.condB.run1(i,:,a_sub),2));
    B(:,3)= squeeze(mean(mm.condB.run2(i,:,a_sub),2));
    B(:,4)= squeeze(mean(mm.condB.run3(i,:,a_sub),2));
    B(:,5)= squeeze(mean(mm.condB.run4(i,:,a_sub),2));
    
    subplot(2,4,i+4),boxplot([B(:,1),mean(B(:,2:3),2),mean(B(:,4:5),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
    [~,t1,~,sts] = ttest(B(:,1),mean(B(:,2:3),2)); 
    [~,t2,~,sts] = ttest(B(:,1),mean(B(:,4:5),2)); 
    [~,t3,~,sts] = ttest(mean(B(:,2:3),2),mean(B(:,4:5),2)); 
    title(sprintf('Con: BS vs P1-2 vs P3-4, %2.2f,%2.2f,%2.2f',t1,t2,t3));
end


%% extra 4    
% **** NOTE LUIS
% The first figure replicates figure one in the original paper
figure; 
cc=0;
for i = 1:4
    s = f1(i);
    e = f2(i);   
    X(1:n,cc+1) = squeeze(mean(mean(pow_baseline(:,s:e,a_sub),2),1)); % baseline
    X(1:n,cc+2) = squeeze(mean(mean(powB(1,:,s:e,a_sub),3),2));
    X(1:n,cc+3) = squeeze(mean(mean(powB(2,:,s:e,a_sub),3),2));
    X(1:n,cc+4) = squeeze(mean(mean(powB(3,:,s:e,a_sub),3),2));
    X(1:n,cc+5) = squeeze(mean(mean(powB(4,:,s:e,a_sub),3),2));       
    cc = cc+5;
end   
    
boxplot(X,'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
title(sprintf('Pow: BS vs P1,2,3,4'));   

figure; 
cc=0;
for i = 1:4
    s = f1(i);
    e = f2(i);   
    X(1:n,cc+1) = squeeze(mean(mm.baseline(i,:,a_sub),2));
    X(1:n,cc+2) = squeeze(mean(mm.condB.run1(i,:,a_sub),2));
    X(1:n,cc+3) = squeeze(mean(mm.condB.run2(i,:,a_sub),2));
    X(1:n,cc+4) = squeeze(mean(mm.condB.run3(i,:,a_sub),2));
    X(1:n,cc+5) = squeeze(mean(mm.condB.run4(i,:,a_sub),2));
    cc = cc+5;
end   
    
boxplot(X,'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
title(sprintf('Con: BS vs P1,2,3,4'));    



%% extra 5 

figure; 
cc=0;
for i = 1:4
    s = f1(i);
    e = f2(i);   
    X(1:n,cc+1) = squeeze(mean(mean(pow_baseline(:,s:e,a_sub),2),1)); % baseline
    X(1:n,cc+2) = squeeze(mean(mean(powB(1,:,s:e,a_sub),3),2));
    X(1:n,cc+3) = squeeze(mean(mean(powB(2,:,s:e,a_sub),3),2));
    X(1:n,cc+4) = squeeze(mean(mean(powB(3,:,s:e,a_sub),3),2));
    X(1:n,cc+5) = squeeze(mean(mean(powB(4,:,s:e,a_sub),3),2));       
    cc = cc+5;
end   
    
boxplot([X(:,1),mean(X(:,2:5),2),X(:,6),mean(X(:,7:10),2),X(:,11),mean(X(:,12:15),2),X(:,16),mean(X(:,17:20),2)],...
    'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
title(sprintf('Pow: BS vs P1-4'));   


figure; 
cc=0;
for i = 1:4
    s = f1(i);
    e = f2(i);   
    X(1:n,cc+1) = squeeze(mean(mm.baseline(i,:,a_sub),2));
    X(1:n,cc+2) = squeeze(mean(mm.condB.run1(i,:,a_sub),2));
    X(1:n,cc+3) = squeeze(mean(mm.condB.run2(i,:,a_sub),2));
    X(1:n,cc+4) = squeeze(mean(mm.condB.run3(i,:,a_sub),2));
    X(1:n,cc+5) = squeeze(mean(mm.condB.run4(i,:,a_sub),2));
    cc = cc+5;
end     
    
boxplot([X(:,1),mean(X(:,2:5),2),X(:,6),mean(X(:,7:10),2),X(:,11),mean(X(:,12:15),2),X(:,16),mean(X(:,17:20),2)],...
    'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
title(sprintf('Con: BS vs P1-4'));   





%%
% %%  figure 2
% for i = 1:4
%     s = f1(i);
%     e = f2(i);  
%     
%     B(1:n,1) = squeeze(mean(mean(pow_baseline(:,s:e,a_sub),2),1)); % baseline
%     B(1:n,2) = squeeze(mean(mean(powB(1,:,s:e,a_sub),3),2));
%     B(1:n,3) = squeeze(mean(mean(powB(2,:,s:e,a_sub),3),2));
%     B(1:n,4) = squeeze(mean(mean(powB(3,:,s:e,a_sub),3),2));
%     B(1:n,5) = squeeze(mean(mean(powB(4,:,s:e,a_sub),3),2));
%   
%     bg(:,1)= squeeze(mean(mm.baseline(i,:,a_sub),2));
%     bg(:,2)= squeeze(mean(mm.condB.run1(i,:,a_sub),2));
%     bg(:,3)= squeeze(mean(mm.condB.run2(i,:,a_sub),2));
%     bg(:,4)= squeeze(mean(mm.condB.run3(i,:,a_sub),2));
%     bg(:,5)= squeeze(mean(mm.condB.run4(i,:,a_sub),2));
%     
%     subplot(4,4,i),boxplot([B(:,1),mean(B(:,4:5),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
%     [t1,t2(1,i),~,sts] = ttest(B(:,1),mean(B(:,4:5),2));      
%     for j = 1:23                  
%         b1 = squeeze(mean(pow_baseline(j,s:e,a_sub),2));
%         b2 = squeeze(mean(powB(3,j,s:e,a_sub),3));
%         b3 = squeeze(mean(powB(4,j,s:e,a_sub),3));
%         [tb(1,j),tb(2,j),~,sts] = ttest(b1,mean([b2,b3],2));
%         tb(3,j) = sts.tstat;
%     end
%     subplot(4,4,i+4),topoplot(tb(3,:),chan,'style','map','electrodes','on');
%     colorbar
%     colormap('parula')
%     caxis([-3 3])
%     
%     subplot(4,4,i+8),boxplot([bg(:,1),mean(bg(:,4:5),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .3 .3])
%     [t1,t2_(1,i),~,sts] = ttest(bg(:,1),mean(bg(:,4:5),2));     
%     for j = 1:23                  
%         b1 = squeeze(mm.baseline(i,j,a_sub));
%         b2 = squeeze(mm.condB.run3(i,j,a_sub));
%         b3 = squeeze(mm.condB.run4(i,j,a_sub));
%         [tb(1,j),tb(2,j),~,sts] = ttest(b1,mean([b2,b3],2));
%         tb(3,j) = sts.tstat;
%     end
%     subplot(4,4,i+12),topoplot(tb(3,:),chan,'style','map','electrodes','on');
%     colorbar
%     colormap('parula')
%     caxis([-3 3])
% end 




for i = 1:4
    s = f1(i);
    e = f2(i);   
  
    bg(:,1)= squeeze(mean(mm.baseline(i,:,a_sub),2));
    bg(:,2)= squeeze(mean(mm.condB.run1(i,:,a_sub),2));
    bg(:,3)= squeeze(mean(mm.condB.run2(i,:,a_sub),2));
    bg(:,4)= squeeze(mean(mm.condB.run3(i,:,a_sub),2));
    bg(:,5)= squeeze(mean(mm.condB.run4(i,:,a_sub),2));
    
    subplot(3,4,i),boxplot(bg,'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
    subplot(3,4,i+4),boxplot([B(:,1),mean(B(:,2:5),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
    subplot(3,4,i+8),boxplot([mean(B(:,2:3),2),mean(B(:,4:5),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.7 .5 .5])
    %[t1,t2(1,i),~,sts] = ttest(B(:,1),mean(B(:,3:5),2));   
end 

% %% second round of plotting added Dec 9, 2020
% figure;  
% for i = 1:4
%     s = f1(i);
%     e = f2(i); 
%     clear A
%     A(1:n,1) = squeeze(mean(mean(pow_baseline(:,s:e,a_sub),2),1)); % baseline
%     A(1:n,2) = squeeze(mean(mean(powA(1,:,s:e,a_sub),3),2));
%     A(1:n,3) = squeeze(mean(mean(powA(2,:,s:e,a_sub),3),2));
%     A(1:n,4) = squeeze(mean(mean(powA(3,:,s:e,a_sub),3),2));
%     A(1:n,5) = squeeze(mean(mean(powA(4,:,s:e,a_sub),3),2));
% 
%     B(1:n,1) = squeeze(mean(mean(pow_baseline(:,s:e,a_sub),2),1)); % baseline
%     B(1:n,2) = squeeze(mean(mean(powB(1,:,s:e,a_sub),3),2));
%     B(1:n,3) = squeeze(mean(mean(powB(2,:,s:e,a_sub),3),2));
%     B(1:n,4) = squeeze(mean(mean(powB(3,:,s:e,a_sub),3),2));
%     B(1:n,5) = squeeze(mean(mean(powB(4,:,s:e,a_sub),3),2));
%     subplot(3,4,i),boxplot([B(:,1),mean(B(:,3:5),2),mean(A(:,3:5),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors','b')
%     subplot(3,4,i+4),boxplot(B(:,2:5),'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors','b')
%     subplot(3,4,i+8),boxplot(A(:,2:5),'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors','b')
%     [t1,t2(1,i),~,sts] = ttest(B(:,1),mean(B(:,3:5),2));
%     [t1,t2(2,i),~,sts] = ttest(B(:,1),mean(A(:,3:5),2));
%     [t1,t2(3,i),~,sts] = ttest(mean(B(:,3:5),2),mean(A(:,3:5),2));
% 
% end
% 
% mm = strg;
% figure;
% for i = 2
%     ag(:,1)= squeeze(mean(mm.baseline(i,:,a_sub),2));
%     ag(:,2)= squeeze(mean(mm.condA.run1(i,:,a_sub),2));
%     ag(:,3)= squeeze(mean(mm.condA.run2(i,:,a_sub),2));
%     ag(:,4)= squeeze(mean(mm.condA.run3(i,:,a_sub),2));
%     ag(:,5)= squeeze(mean(mm.condA.run4(i,:,a_sub),2));
% 
%     bg(:,1)= squeeze(mean(mm.baseline(i,:,a_sub),2));
%     bg(:,2)= squeeze(mean(mm.condB.run1(i,:,a_sub),2));
%     bg(:,3)= squeeze(mean(mm.condB.run2(i,:,a_sub),2));
%     bg(:,4)= squeeze(mean(mm.condB.run3(i,:,a_sub),2));
%     bg(:,5)= squeeze(mean(mm.condB.run4(i,:,a_sub),2));
%     
%     subplot(3,4,i),boxplot([bg(:,1),mean(bg(:,2:5),2),mean(ag(:,2:5),2)],'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors','b')
%     subplot(3,4,i+4),boxplot(bg(:,2:5),'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors','b')
%     subplot(3,4,i+8),boxplot(ag(:,2:5),'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors','b')
%     [t1,t2(1,i),~,sts] = ttest(bg(:,1),mean(bg(:,2:5),2));
%     [t1,t2(2,i),~,sts] = ttest(bg(:,1),mean(ag(:,2:5),2));
%     [t1,t2(3,i),~,sts] = ttest(mean(bg(:,2:5),2),mean(ag(:,2:5),2));
% end
% 
% %% box plots and averages
% figure;  
% i = 3;
% s = f1(i);
% e = f2(i);       
% A(1:n,1) = squeeze(mean(mean(pow_baseline(:,s:e,a_sub),2),1)); % baseline
% A(1:n,2) = squeeze(mean(mean(powA(1,:,s:e,a_sub),3),2));
% A(1:n,3) = squeeze(mean(mean(powA(2,:,s:e,a_sub),3),2));
% A(1:n,4) = squeeze(mean(mean(powA(3,:,s:e,a_sub),3),2));
% A(1:n,5) = squeeze(mean(mean(powA(4,:,s:e,a_sub),3),2));
% subplot(3,1,1),boxplot(A(:,1:5),'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors','b')
% 
% B(1:n,1) = squeeze(mean(mean(pow_baseline(:,s:e,a_sub),2),1)); % baseline
% B(1:n,2) = squeeze(mean(mean(powB(1,:,s:e,a_sub),3),2));
% B(1:n,3) = squeeze(mean(mean(powB(2,:,s:e,a_sub),3),2));
% B(1:n,4) = squeeze(mean(mean(powB(3,:,s:e,a_sub),3),2));
% B(1:n,5) = squeeze(mean(mean(powB(4,:,s:e,a_sub),3),2));
% subplot(3,1,2),boxplot(B(:,1:5),'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[0.5 0.5 0.5])
%         
% 
% C = [];
% A_ = A-A(:,1);
% B_ = B-B(:,1);
% for i = 1:4
%     C = [C;A_(:,i+1)];
%     C = [C;B_(:,i+1)];
% end
% % g = [ones(10,1);2*ones(10,1);3*ones(10,1);4*ones(10,1);5*ones(10,1);6*ones(10,1);7*ones(10,1);8*ones(10,1)];
% % boxplot(C,g,'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.5 .5 .5])
% 
% 
% subplot(3,1,3), plot(1:5,mean(A_),'o-b')
% hold on
% plot(1:5,mean(B_),'o-','color',[0.5 0.5 0.5])
% xlim([0.5 5.5])
% 
% %% node-wise ttesting topoplots
% s = f1(i);
% e = f2(i);
% figure;
% t = zeros(5,5,23);
% t2 = ones(5,5,23);
% for j = 1:23    
%     A(:,1) = mean(pow_baseline(j,s:e,a_sub),2); % baseline
%     A(:,2) = mean(powA(1,j,s:e,a_sub),3);
%     A(:,3) = mean(powA(2,j,s:e,a_sub),3);
%     A(:,4) = mean(powA(3,j,s:e,a_sub),3);
%     A(:,5) = mean(powA(4,j,s:e,a_sub),3);
% 
%     B(:,1) = mean(pow_baseline(j,s:e,a_sub),2); % baseline
%     B(:,2) = mean(powB(1,j,s:e,a_sub),3);
%     B(:,3) = mean(powB(2,j,s:e,a_sub),3);
%     B(:,4) = mean(powB(3,j,s:e,a_sub),3);
%     B(:,5) = mean(powB(4,j,s:e,a_sub),3);
% 
%     for n1 = 1:4            
%         [t1a(n1,j),t2a(n1,j),~,sts] = ttest(A(:,1),A(:,n1+1));
%         ta(n1,j) = sts.tstat;
%     end
% 
%     for n1 = 1:4            
%         [t1b(n1,j),t2b(n1,j),~,sts] = ttest(B(:,1),B(:,n1+1));
%         tb(n1,j) = sts.tstat;
%     end
% 
% end
% figure;
% count = 1;
% for n1 = 1:4
%     subplot(1,4,count),topoplot(ta(n1,:),chan,'style','map','electrodes','on')
%     caxis([-3 3])
%     hold on
%     count = count+1;
% end   
% 
% figure;
% count = 1;
% for n1 = 1:4
%     subplot(1,4,count),topoplot(tb(n1,:),chan,'style','map','electrodes','on')
%     caxis([-3 3])
%     hold on
%     count = count+1;
% end   
% 
% figure; imagesc(1:10); colormap('jet')
% colorbar; caxis([-3 3])
% 
% 
% 
% %% plotting averages of network local features
% mm = strg;
% sub_a =[1:7,9:12];
% i = 3;
% figure;
% %%
% ag(:,1)= squeeze(mean(mm.baseline(i,:,sub_a),2));
% ag(:,2)= squeeze(mean(mm.condA.run1(i,:,sub_a),2));
% ag(:,3)= squeeze(mean(mm.condA.run2(i,:,sub_a),2));
% ag(:,4)= squeeze(mean(mm.condA.run3(i,:,sub_a),2));
% ag(:,5)= squeeze(mean(mm.condA.run4(i,:,sub_a),2));
% subplot(3,1,1),boxplot(ag(:,1:5),'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors','b')
% 
% bg(:,1)= squeeze(mean(mm.baseline(i,:,sub_a),2));
% bg(:,2)= squeeze(mean(mm.condB.run1(i,:,sub_a),2));
% bg(:,3)= squeeze(mean(mm.condB.run2(i,:,sub_a),2));
% bg(:,4)= squeeze(mean(mm.condB.run3(i,:,sub_a),2));
% bg(:,5)= squeeze(mean(mm.condB.run4(i,:,sub_a),2));
% subplot(3,1,2),boxplot(bg(:,1:5),'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[0.5 0.5 0.5])
% 
% a_ = ag-ag(:,1);
% b_ = bg-bg(:,1);
% subplot(3,1,3), plot(1:5,mean(a_),'o-b')
% hold on
% plot(1:5,mean(b_),'o-','color',[0.5 0.5 0.5])
% xlim([0.5 5.5])
% 
% ttest(ag(:,1),ag(:,2))
% ttest(ag(:,1),ag(:,3))
% ttest(ag(:,1),ag(:,4))
% ttest(ag(:,1),ag(:,5))
% 
% ttest(bg(:,1),bg(:,2))
% ttest(bg(:,1),bg(:,3))
% ttest(bg(:,1),bg(:,4))
% ttest(bg(:,1),bg(:,5))
% 
% ttest(ag(:,2),bg(:,2))
% ttest(ag(:,3),bg(:,3))
% ttest(ag(:,4),bg(:,4))
% ttest(ag(:,5),bg(:,5))
% C = [];
% for ii = 1:4
%     C = [C;ag(:,ii+1)];
%     C = [C;bg(:,ii+1)];
% end
% figure;
%  g = [ones(11,1);2*ones(11,1);3*ones(11,1);4*ones(11,1);5*ones(11,1);6*ones(11,1);7*ones(11,1);8*ones(11,1)];
%  boxplot(C,g,'PlotStyle','traditional','BoxStyle','filled','OutlierSize',3,'colors',[.5 .5 .5])
%  
% %% node-wise comparison, temporal and condition 
% clear t t2 t1 t1a t1b t2a t2b
% figure; 
% t = zeros(4,23);
% t2 = ones(4,23);
% for j = 1:23
%     aa(:,1)= mm.baseline(i,j,sub_a);
%     aa(:,2)= mm.condA.run1(i,j,sub_a);
%     aa(:,3)= mm.condA.run2(i,j,sub_a);
%     aa(:,4)= mm.condA.run3(i,j,sub_a);
%     aa(:,5)= mm.condA.run4(i,j,sub_a);
% 
%     bb(:,1)= mm.baseline(i,j,sub_a);
%     bb(:,2)= mm.condB.run1(i,j,sub_a);
%     bb(:,3)= mm.condB.run2(i,j,sub_a);
%     bb(:,4)= mm.condB.run3(i,j,sub_a);
%     bb(:,5)= mm.condB.run4(i,j,sub_a);     
% 
% 
%     for n1 = 1:4            
%         [t1,t2(n1,j),~,sts] = ttest(aa(:,n1+1),bb(:,n1+1));
%         t(n1,j) = sts.tstat;
%     end
%     
%     for n1 = 1:4            
%         [t1a(n1,j),t2a(n1,j),~,sts] = ttest(aa(:,1),aa(:,n1+1));
%         ta(n1,j) = sts.tstat;
%     end
% 
%     for n1 = 1:4            
%         [t1b(n1,j),t2b(n1,j),~,sts] = ttest(bb(:,1),bb(:,n1+1));
%         tb(n1,j) = sts.tstat;
%     end
% end
% 
% figure;
% count = 1;
% for n1 = 1:4
%     subplot(1,4,count),topoplot(ta(n1,:),chan,'style','map','electrodes','on');
%     caxis([-3 3])
%     hold on
%     count = count+1;
% end   
% hold off
% 
% figure;
% count = 1;
% for n1 = 1:4
%     subplot(1,4,count),topoplot(tb(n1,:),chan,'style','map','electrodes','on');
%     caxis([-3 3])
%     hold on
%     count = count+1;
% end   
% hold off
% 
% figure;
% for n1 = 1:4
%     subplot(1,4,n1),topoplot(t(n1,:),chan,'style','map','electrodes','on');
%     caxis([-3 3])
%     hold on           
% end   
% hold off    
% 

