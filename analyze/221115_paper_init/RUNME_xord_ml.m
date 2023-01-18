function  RUNME_xord_ml(df_long)
    % LIKELYHOODS 
    % IS ALMOST COMPLETE, BUTNEEDS
    % 
    % !!! TESTING PROCEDURE (only plots for now)
    % also plot clean up, documentation, input arguments, 
    
  
% --------------------------------------------------------         
    % SET YOUR SETTINGS/input arguments
    cogtask = 'GoNogo';
    bandname  = 'te';
    X = 'deg_w'; 
    maxlevel = 3;
    t=1;
    categwthn_condition = true;
    categwthn_subject = true;
    condition2anz = 'control';    

% --------------------------------------------------------     
% INITIATE DATA
    % Init variable names
    X_level  = sprintf('%s_level',X);
    X_level_ismx = sprintf('%s_dummy',X_level);
    desired_vars = [{X},experimentalvars()];

    % long to wide data frame
    df     = dflong2wide(df_long, cogtask, {'baseline', 'control','light'}, bandname, t,'keepchannels',true);
    df = df(:,desired_vars);
    S = subjects(cogtask)  ; % gets channels for topoplots      
    
    % categorize the IV
    df= categcolumn(df,X,maxlevel,"condition",categwthn_condition,"subject",categwthn_subject);
    df.(X_level) = findgroups(df.(X_level));
    df.(X_level_ismx) = df.(X_level) == maxlevel;    

    % assess one conditoin only for now
    rows2keep = (df.condition == "baseline" | df.condition ==condition2anz);
    df = df(rows2keep,:);
    df =dfrmcats(df);

    % SUBJECT IDS
    sbjid_list = unique(df.sbj);
    numsubj = numel(sbjid_list);


% --------------------------------------------------------     
    % FIGURE
    close all
    Fig_hist = figure('Visible','on');
    T = tiledlayout(2,4);
    T.Title.String = sprintf('[%s %s]  (%s, %s only)', bandname, upper(X), cogtask,  condition2anz);
    T.Title.Interpreter = "none";
    T.Title.FontWeight = "bold";
     
    Fig_topo = figure('Visible','on');
    T_topo = tiledlayout(2,3);
    T_topo.Title.String = sprintf('[%s %s]  (%s, %s only)', bandname, upper(X), cogtask,  condition2anz);
    T_topo.Title.Interpreter = "none";

   


% -------------------------------------------------------- 
% ANALYSIS AND PLOT    
    groups = {'baseline',condition2anz};
    imgclrs = {[1 1 .7],[0 0 0]; [1 1 .5],[.8 .3 0]};  
    xord_lev_names = {'LOW','HIGH'}; 
    xord_lev_values = [1 maxlevel];
    Xedges = [0.5:23.5];
    Yedges = [0.5:numsubj+.5];

    % data
    runtopoplot = @(chan_fs) topoplot(chan_fs,S.chan, 'electrodes','ptsnumbers','maplimits','maxmin');
       
    
    for lev_idx = 1:2
        xord_vel_val = xord_lev_values(lev_idx);
        xord_lev_name = xord_lev_names{lev_idx};
    
        df_bsl_xord = df(df.(X_level) == xord_vel_val & df.condition == 'baseline',:);
        df_ctr_xord = df(df.(X_level) == xord_vel_val & df.condition == 'control',:);        
        
        % Plot Total Frequency

        figure(Fig_hist);
        F_set = nan(numsubj,23,2);        
        nexttile(); hold on
        histogram(df_bsl_xord.chan,'Normalization','count','BinMethod','integers','FaceColor','k');
        histogram(df_ctr_xord.chan,'Normalization','count','BinMethod','integers');
        legend('Baseline',condition2anz,'FontSize',12);
        xlabel('Channel','FontSize',14);
        title(sprintf('# of times a channel had a\n %s level of %s',upper(xord_lev_name),gfn(X)),'FontSize',14);
        ylabel('Count','FontSize',14);
    
        % Frequency of for each subject
        
        for g_idx = 1:2
    
            % get data 
            grp_name = groups{g_idx};        
            df_xord = df(df.(X_level) == xord_vel_val & df.condition == grp_name,:);
            F = histcounts2(df_xord.chan,findgroups(df_xord.sbj),Xedges,Yedges);
            F = F';
 
            % Plot Joint Histogram
            figure(Fig_hist);
            imgclr_frnt = imgclrs{g_idx,1};
            imgclr_bck = imgclrs{g_idx,2};
            cmap = [repmat(imgclr_bck, [128,1]) ; repmat(imgclr_frnt, [128,1])];
            
            nexttile(); hold on;
            colormap(gca,cmap) ;
            imagesc(gca, F);
            axis tight
    
                % Fix up...
                cmap = [repmat(imgclr_bck, [128,1]) ; repmat(imgclr_frnt, [128,1])];
                colormap(gca,cmap) ;
        
                c = colorbar(gca);
                c.Label.FontSize = 16;
                c.Label.String = sprintf('Has a %s level of %s',upper(xord_lev_name), gfn(X));
                c.TickLabels = {'NO', 'YES'};
                c.FontSize = 16;
                c.Ticks = [0 1];
        
                xlabel('Channel','FontSize',14);
                ylabel('Subject','FontSize',14);            
                title_str = sprintf('For each subject\n %s levels of %s',upper(xord_lev_name),gfn(X));
                title(title_str,'FontSize',14);
                
                
            % TOPOPLOT
            figure(Fig_topo)
            nexttile(); hold on;
            runtopoplot(sum(F))

                % Fix up...
                set(gca,'Visible','on','Color',imgclr_bck,'XColor','none','YColor','none')  ; 
                title_str = sprintf('# of times a channel had %s levels of %s\nduring %s',upper(xord_lev_name), gfn(X),grp_name);
                title(title_str,'FontSize',14);   
                c = colorbar(gca);
                set(c.Label,'FontSize',16,'String', 'Count')
 
            % for computing changes in frequency
            F_set(:,:,g_idx) = F;
        end
            
            % PLOT HIST CHANGES
            figure(Fig_hist);
            nexttile;
            F_diff = F_set(:,:,2) - F_set(:,:,1)  ;
            imagesc(F_diff)
    
                % Fix HISTS
               title_str = sprintf('Change in %s\n (Control - Baseline)',gfn(X));
                title(title_str,'FontSize',14); 
                colormap(gca,'parula') ;
                c = colorbar;
                c.Label.FontSize = 16;
                c.Label.String = sprintf('diffence');
                [mn,mx] = bounds(F_diff,'all')   ;                    
                c.Ticks = [mn+.5,mx-.5];
                c.FontSize = 12;
                xlabel('channel','FontSize',14);
                ylabel('subject','FontSize',14);     
            
            % PLOT TOPO CHANGES
            figure(Fig_topo);
            nexttile()
            F_diff_mean = sum(F_set(:,:,2)) - sum(F_set(:,:,1)); 
            runtopoplot(F_diff_mean)

                % Fix up...
                % c = colorbar(gca);
                set(gca,'Visible','on','Color',[1 1 1],'XColor','none','YColor','none')   ;
                title_str = sprintf('Change in %s\n (Control - Baseline)',gfn(X));
                title(title_str,'FontSize',14);   
    end
    % TEST/MODEL (incomplete/building)
%     modelspec = [IV_level_ismx, '~ chan + condition'];        
%     df4mdl = table2dataset(df(:,{IV_level_ismx,'chan','condition'}));
%     mdl = fitglm(df4mdl,modelspec,'Distribution','binomial','CategoricalVars',{'chan','condition'});


%% -------------------------------------------------------- 
% SCRATCH ... 
%     L = F./repmat(sum(F),23,1);
%     imagesc(L');
%     
%     
%     dv_str = sprintf('P( Node | %s = 1...%d)',IV_level, numlevels);
%     ylabel(dv_str,'Interpreter','none')
%     title(sprintf('LIKELYHOOD: %s',dv_str),'Interpreter','none')
%     xlabel('channel')
%     ylabel(IV_level)
%     
%     ax_img.YTick  = 1:numlevels;
%     ax_img.YTickLabel  =cellstr(num2str([1:numlevels]'));
%     colorbar
%     set(gca, 'YDir','normal')
        
%             ax_jointp.YTick  = 1:numlevels;
%             ax_jointp.YTickLabel  =cellstr(num2str([1:numlevels]'));
%             
%             xlabel('channel')
%             ylabel(IV_level)
%             set(gca, 'YDir','normal')
%             view(2)
%             
% title('Joint Frequency Distribution: P(chan=i & K=j)','Interpreter','none')
%             colorbar
%             axis equal
%             figure(gcf)
%             F = [h.Values];
%             
%             % PLOT LIKELYHOOD;
%             ax_img = nexttile(3); 
%             
%             L = F./repmat(sum(F),23,1);
%             imagesc(L');
%             
%             
%             dv_str = sprintf('P( Node | %s = 1...%d)',IV_level, numlevels);
%             ylabel(dv_str,'Interpreter','none')
%             title(sprintf('LIKELYHOOD: %s',dv_str),'Interpreter','none')
%             xlabel('channel')
%             ylabel(IV_level)
%             
%             ax_img.YTick  = 1:numlevels;
%             ax_img.YTickLabel  =cellstr(num2str([1:numlevels]'));
%             colorbar
%             set(gca, 'YDir','normal')
    
    

% FACET
%     nexttile(4)
%     L = F./repmat(sum(F),23,1);
%     varnames = cellfun(@(x) sprintf('P(chan | %s = %d)',IV, x), num2cell(1:numlevels), 'UniformOutput',false);
%     rownames = cellfun(@(x) sprintf('channel %d',x), num2cell(1:23), 'UniformOutput',false);
%     
%     Lt =  array2table(L,VariableNames=varnames,RowNames=rownames);
%     ax_p = stackedplot(Lt,Lt.Properties.VariableNames(end:-1:1));
%     xlabel('channel')
%     
%     figure(gcf)    
end