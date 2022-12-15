% load data frames
gpsd    = getglobalpsd('PVT')
[wpli,~,pathl,~,~,~,~, ~] = getnetwork('PVT');
band_names = {'delta', 'theta', 'alpha', 'beta'};
%% TRY REPLICATING TESTS from FIGURE 1A, GLOBAL PSD, FROM MAIN AND SUPPLEMENTAL
% MAIN HAS CONTROL DATA, and SUPP HAS INTERVENTION.
% SET IW_CONDITION = LIGHT FOR COMPARING INTERVENTION RUNS WITH BASELINE
% SET IW_CONDITOIN = CONTROL FOR CONTROL COMPARISONS WITH BASELINE
% NOTES:
%   somewhat successful replication, with a few caveats
clearvars -except  band_names gpsd pathl wpli strg modul


iw_condition = 'control';
run_names = {'baseline', 'r1', 'r2', 'r3', 'r4'};
sbj = [1:7, 9:12]; % 8 needs to be skipped, must the reason why they only have 11 subjects

clf;


for i = 1:4

    iw_band = band_names{i};
    bl_idx  = strcmp(gpsd.condition, 'baseline');
    r1_idx = strcmp(gpsd.condition, iw_condition) & gpsd.run == 1;
    r2_idx = strcmp(gpsd.condition, iw_condition) & gpsd.run == 2;
    r3_idx = strcmp(gpsd.condition, iw_condition) & gpsd.run == 3;
    r4_idx = strcmp(gpsd.condition, iw_condition) & gpsd.run == 4;
        
    allcond_idx = bl_idx | r1_idx | r2_idx | r3_idx | r4_idx;
    df = cellfun(@(x) mean(x(:,sbj)),   gpsd.(iw_band)(allcond_idx)  ,   'UniformOutput',   false) ;
    df = cat(1, df{:});
    df = df';

    subplot(3,4,i);    
    [T, P, sp] = testpairs(df);
    boxplot(df)

    title(iw_band)
    set(gca, 'Xtick', 1:5, 'XTickLabel', run_names)  
    ylabel('Global PSD')
    
    subplot(3,4,4+i)
    imagesc(P); hold on
    set(gca, 'Xtick', 1:5, 'XTickLabel', run_names, 'Ytick', 1:5, 'YTickLabel', run_names)    
    r = sp(:,1);
    c = sp(:,2);
    rcl = sub2ind(size(P), r,c);
    str = cellfun(@(x) sprintf('%.03f',x), num2cell(P(rcl)),    'UniformOutput',    false);
    text(r',c',str(:), 'color', 'r')
    plot(r, c, 'r*', 'MarkerSize',10)
    title('P values')
    axis square
      
    axis square


end
figure(gcf)


%% TRY REPLICATING PATH LENGTH TESTS from FIGURE 1B MAIN AND SUPPLEMENTARY
% success!!! (see notes on figure from 22 05 26
clearvars -except gpsd band_names pathl modul
clc
iw_condition = 'control';
run_names = {'baseline', 'r1', 'r2', 'r3', 'r4'};
sbj = [1:7, 9:12]; % 8 needs to be skipped, must the reason why they only have 11 subjects

clf;

for i = 1:4

    iw_band = band_names{i};
    bl_idx  = strcmp(pathl.condition, 'baseline');
    r1_idx = strcmp(pathl.condition, iw_condition) & pathl.run == 1;
    r2_idx = strcmp(pathl.condition, iw_condition) & pathl.run == 2;
    r3_idx = strcmp(pathl.condition, iw_condition) & pathl.run == 3;
    r4_idx = strcmp(pathl.condition, iw_condition) & pathl.run == 4;
        
        x = pathl.(iw_band)(bl_idx,sbj);
        y1 = pathl.(iw_band)(r1_idx,sbj);
        y2 = pathl.(iw_band)(r2_idx,sbj);
        y3 = pathl.(iw_band)(r3_idx,sbj);
        y4 = pathl.(iw_band)(r4_idx,sbj);
        df = [x; y1; y2; y3; y4]';
        subplot(3,4,i);    

    [T, P, sp] = testpairs(df);
    boxplot(df)
    title(iw_band)    

    set(gca, 'Xtick', 1:5, 'XTickLabel', run_names)  
    ylabel('Global PSD')
    
    subplot(3,4,8+i); 
    imagesc(P); hold on
    set(gca, 'Xtick', 1:5, 'XTickLabel', run_names, 'Ytick', 1:5, 'YTickLabel', run_names)    
    r = sp(:,1);
    c = sp(:,2);
    rcl = sub2ind(size(P), r,c);
    str = cellfun(@(x) sprintf('%.03f',x), num2cell(P(rcl)),    'UniformOutput',    false);
    text(r',c',str(:), 'color', 'r')
    plot(r, c, 'r*', 'MarkerSize',10)
    title('P values')
    axis square

end
figure(gcf)



%% TRY REPLICATING CLUSTERING TESTS from FIGURE 1C MAIN
%% ----- WARRING ERROR: cannot replicate because im not sure whch data set i
% should use. Its not module, the results are totally off. all other data
% structures have values that exceed the bounds graphs in the main papers
clearvars -except gpsd pathl band_names pathl modul 
clc
iw_condition = 'control';
run_names = {'baseline', 'r1', 'r2', 'r3', 'r4'};
sbj = [1:7, 9:12]; % 8 needs to be skipped, must the reason why they only have 11 subjects

clf;

for i = 1:4
    iw_band = band_names{i};
    bl_idx  = strcmp(modul.condition, 'baseline');
    r1_idx = strcmp(modul.condition, iw_condition) & modul.run == 1;
    r2_idx = strcmp(modul.condition, iw_condition) & modul.run == 2;
    r3_idx = strcmp(modul.condition, iw_condition) & modul.run == 3;
    r4_idx = strcmp(modul.condition, iw_condition) & modul.run == 4;
        
    allcond_idx = bl_idx | r1_idx | r2_idx | r3_idx | r4_idx;
    df = modul.(iw_band)(allcond_idx,sbj)';

    subplot(3,4,i);    

    [T, P, sp] = testpairs(df);
    boxplot(df)
    title(iw_band)    

    set(gca, 'Xtick', 1:5, 'XTickLabel', run_names)  
    ylabel('Global PSD')
    
    subplot(3,4,8+i); 
    imagesc(P); hold on
    set(gca, 'Xtick', 1:5, 'XTickLabel', run_names, 'Ytick', 1:5, 'YTickLabel', run_names)    
    r = sp(:,1);
    c = sp(:,2);
    rcl = sub2ind(size(P), r,c);
    str = cellfun(@(x) sprintf('%.03f',x), num2cell(P(rcl)),    'UniformOutput',    false);
    text(r',c',str(:), 'color', 'r')
    plot(r, c, 'r*', 'MarkerSize',10)
    title('P values')
    axis square

end
figure(gcf)




%% TRY REPLICATING CLUSTERING TESTS from FIGURE 2A MAIN
% comparing delta band path length between baseline, control and light
% conditions at t1

clearvars -except gpsd band_names pathl modul
clc; clf
sbj = [1:7, 9:12]; % 8 needs to be skipped, must the reason why they only have 11 subjects
iv_names_list = {'baseline', 'light_T_1', 'control_T_1'};
dv_names_list = {'path length', 'clustering', 'global psd'};
DV_ALL = {pathl, modul, gpsd};
for dv_idx = 1:3
    dv_name = dv_names_list{dv_idx};
    DV      = DV_ALL{dv_idx};
    
    bl_idx          = strcmp(DV.condition, 'baseline') ;
    light_r1_idx    = strcmp(DV.condition, 'light') & DV.run == 1;
    cntl_r1_idx     = strcmp(DV.condition, 'control') & DV.run == 1;
    all_cond_idx    = bl_idx | light_r1_idx | cntl_r1_idx  ;

    clear df
    switch dv_name
        case 'global psd'
            df = cellfun(@(x) mean(x(:,sbj)),   DV.('delta')(all_cond_idx)  ,   'UniformOutput',   false) ;
            df = cat(1, df{:});
            df = df';        
        case 'clustering'
            df = nan(3,3); % still need to figure this one out
        otherwise
            df = DV.('delta')(all_cond_idx, :)';     % i should change this so that this column turns into a cell so indexing is similar       
    end
    
    
    
    subplot(3,3,dv_idx);    
    [T, P, sp] = testpairs(df);
    boxplot(df); hold on
    plot(df', '-')
    title('delta') 
    set(gca, 'Xtick', 1:3, 'XTickLabel', iv_names_list)  
    ylabel(dv_name)
    
    subplot(3,3,3+dv_idx); 
    imagesc(P); hold on
    set(gca, 'Xtick', 1:3, 'XTickLabel', iv_names_list, 'Ytick', 1:3, 'YTickLabel', iv_names_list)    
    r = sp(:,1);
    c = sp(:,2);
    rcl = sub2ind(size(P), r,c);
    str = cellfun(@(x) sprintf('%.03f',x), num2cell(P(rcl)),    'UniformOutput',    false);
    text(r',c',str(:), 'color', 'r')
    plot(r, c, 'r*', 'MarkerSize',10)
    title('P values')
    axis square

end
figure(gcf)
