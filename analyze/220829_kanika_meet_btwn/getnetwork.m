function [wpli_tble,btwn_tbl,pathl_tble,eff_tbl,ecc,rad,strg_tble, modul_tble, clust_w_tbl] = getnetwork(test_folder)
% my shortened version of original extracting_wpli function. 
% its an attempt to understand it and also convert the output to a table format
% note that this contains almost all of dependent variables 

S = subjects(test_folder);
load(fullfile(S.path_data, 'A_cond'))
load(fullfile(S.path_data, 'B_cond'))

sub_idx = 1:S.sbj_numel;
chan    = 23;

fprintf('\nGetting Network Props during %s: ', upper(test_folder))
for i = 1:length(sub_idx)
    fprintf('. ')
    s = S.sbj(i);
    load(s.fname);
    night_str =s.run_idx_light.night_no{1};
    
    % Baseline
    if ~isempty(data.(night_str)(1).wpli)
        wpli.baseline(1:4,1:chan,1:chan,i) = data.(night_str)(1).wpli.mat;  
        betw.baseline(1:4,1:chan,i) = data.(night_str)(1).wpli.betweenness_centrality;
        pathl.baseline(1:4,i) = data.(night_str)(1).wpli.path_length;
        eff.baseline(1:4,i)= data.(night_str)(1).wpli.efficiency;
        ecc.baseline(1:4,1:chan,i)= data.(night_str)(1).wpli.eccentricity;
        rad.baseline(1:4,i) = data.(night_str)(1).wpli.radius;
        strg.baseline(1:4,1:chan,i) = data.(night_str)(1).wpli.strength;
        modul.baseline(1:4,i) = data.(night_str)(1).wpli.comms.Q(:,5); % for gamma ~ 1;
        clust.baseline(1:4,1:9,i) = mean(data.(night_str)(1).wpli.clusteringcoeff,3);
    else
        wpli.baseline(1:4,1:chan,1:chan,i)=zeros(4,chan,chan);
        betw.baseline(1:4,1:chan,i) =zeros(4,chan);
        pathl.baseline(1:4,i) = zeros(4,1);
        eff.baseline(1:4,i)= zeros(4,1);
        ecc.baseline(1:4,1:chan,i)= zeros(4,chan);
        rad.baseline(1:4,i) = zeros(4,1);
        strg.baseline(1:4,1:chan,i) = zeros(4,chan);
        modul.baseline(1:4,i) = zeros(4,1);
        clust.baseline(1:4,1:9,i) = zeros(4,9);
    end
    
    % cond A 
    run_list_light = s.run_idx_light{:, {'run1', 'run2', 'run3', 'run4'}};
    count = 1;
    
    for r = run_list_light(:)'
        run_str = sprintf('run%d',count);
        if r > length(data.(night_str))
            wpli.condA.(run_str)(1:4,1:chan,1:chan,i) = zeros(4,chan,chan);
            betw.condA.(run_str)(1:4,1:chan,i) =zeros(4,chan);
            pathl.condA.(run_str)(1:4,i) = zeros(4,1);
            eff.condA.(run_str)(1:4,i)= zeros(4,1);
            ecc.condA.(run_str)(1:4,1:chan,i)= zeros(4,chan);
            rad.condA.(run_str)(1:4,i) = zeros(4,1);
            strg.condA.(run_str)(1:4,1:chan,i) = zeros(4,chan);
            modul.condA.(run_str)(1:4,i) = zeros(4,1);
            clust.condA.(run_str)(1:4,1:9,i) = zeros(4,9);
        else
            if ~isempty(data.(night_str)(r).wpli)
                wpli.condA.(run_str)(1:4,1:chan,1:chan,i) = data.(night_str)(r).wpli.mat;
                betw.condA.(run_str)(1:4,1:chan,i) = data.(night_str)(r).wpli.betweenness_centrality;
                pathl.condA.(run_str)(1:4,i) = data.(night_str)(r).wpli.path_length;
                eff.condA.(run_str)(1:4,i)= data.(night_str)(r).wpli.efficiency;
                ecc.condA.(run_str)(1:4,1:chan,i)= data.(night_str)(r).wpli.eccentricity;
                rad.condA.(run_str)(1:4,i) = data.(night_str)(r).wpli.radius;
                strg.condA.(run_str)(1:4,1:chan,i) = data.(night_str)(r).wpli.strength;
                modul.condA.(run_str)(1:4,i) = data.(night_str)(r).wpli.comms.Q(:,5); % for gamma ~ 1;
                clust.condA.(run_str)(1:4,1:9,i) = mean(data.(night_str)(r).wpli.clusteringcoeff,3);

            else 
                wpli.condA.(run_str)(1:4,1:chan,1:chan,i) = zeros(4,chan,chan);
                betw.condA.(run_str)(1:4,1:chan,i) =zeros(4,chan);
                pathl.condA.(run_str)(1:4,i) = zeros(4,1);
                eff.condA.(run_str)(1:4,i)= zeros(4,1);
                ecc.condA.(run_str)(1:4,1:chan,i)= zeros(4,chan);
                rad.condA.(run_str)(1:4,i) = zeros(4,1);
                strg.condA.(run_str)(1:4,1:chan,i) = zeros(4,chan);
                modul.condA.(run_str)(1:4,i) = zeros(4,1);
                clust.condA.(run_str)(1:4,1:9,i) = zeros(4,9);
            end
        end
        count = count+1;
    end
     
    % cond B 
    run_list_control = s.run_idx_cntl{:, {'run1', 'run2', 'run3', 'run4'}};
    count = 1;
    for r = run_list_control(:)'
        run_str = sprintf('run%d',count);
        
        if r > length(data.(night_str))
            wpli.condB.(run_str)(1:4,1:chan,1:chan,i)   = zeros(4,chan,chan);
            betw.condB.(run_str)(1:4,1:chan,i)          =zeros(4,chan);
            pathl.condB.(run_str)(1:4,i) = zeros(4,1);
            eff.condB.(run_str)(1:4,i)= zeros(4,1);
            ecc.condB.(run_str)(1:4,1:chan,i)= zeros(4,chan);
            rad.condB.(run_str)(1:4,i) = zeros(4,1);
            strg.condB.(run_str)(1:4,1:chan,i) = zeros(4,chan);
            modul.condB.(run_str)(1:4,i) = zeros(4,1);
            clust.condB.(run_str)(1:4,1:9,i) = zeros(4,9);
        else
            if ~isempty(data.(night_str)(r).wpli)
                wpli.condB.(run_str)(1:4,1:chan,1:chan,i) = data.(night_str)(r).wpli.mat;
                betw.condB.(run_str)(1:4,1:chan,i) = data.(night_str)(r).wpli.betweenness_centrality;
                pathl.condB.(run_str)(1:4,i) = data.(night_str)(r).wpli.path_length;
                eff.condB.(run_str)(1:4,i)= data.(night_str)(r).wpli.efficiency;
                ecc.condB.(run_str)(1:4,1:chan,i)= data.(night_str)(r).wpli.eccentricity;
                rad.condB.(run_str)(1:4,i) = data.(night_str)(r).wpli.radius;
                strg.condB.(run_str)(1:4,1:chan,i) = data.(night_str)(r).wpli.strength;
                modul.condB.(run_str)(1:4,i) = data.(night_str)(r).wpli.comms.Q(:,5); % for gamma ~ 1;
                clust.condB.(run_str)(1:4,1:9,i) = mean(data.(night_str)(r).wpli.clusteringcoeff,3);

            else 
                wpli.condB.(run_str)(1:4,1:chan,1:chan,i) = zeros(4,chan,chan);
                betw.condB.(run_str)(1:4,1:chan,i) =zeros(4,chan);
                pathl.condB.(run_str)(1:4,i) = zeros(4,1);
                eff.condB.(run_str)(1:4,i)= zeros(4,1);
                ecc.condB.(run_str)(1:4,1:chan,i)= zeros(4,chan);
                rad.condB.(run_str)(1:4,i) = zeros(4,1);
                strg.condB.(run_str)(1:4,1:chan,i) = zeros(4,chan);
                modul.condB.(run_str)(1:4,i) = zeros(4,1);
                clust.condB.(run_str)(1:4,1:9,i) = zeros(4,9);
            end
        end
        count = count+1;
    end
    
end
%% running for clustering coefficient calculated on weighted matrices
init_runs = nan(4,23,S.sbj_numel);
run_struct = struct('run1',init_runs, 'run2', init_runs, 'run3',init_runs, 'run4', init_runs);
clust_w = struct('baseline', init_runs, 'condA', run_struct, 'condB', run_struct);

for i = 1:(S.sbj_numel)
    sbj_name_num = S.sbj_idS_num(i);

    sbj_clust = S.loadsbjclust(sbj_name_num);
    for run_idx =1:4
        rstr =sprintf('run%d',run_idx);
        clust_w.baseline(1:4,1:23,i) = sbj_clust.baseline;
        clust_w.condA.(rstr)(1:4,1:23,i) = sbj_clust.condA.(rstr);
        clust_w.condB.(rstr)(1:4,1:23,i) = sbj_clust.condB.(rstr);
    end

end


%% LUIS MAIN CODE: CONVERT SOME STRUCTURES TO TABLE
wpli_tble = create_tbl(wpli,S); 
pathl_tble = create_tbl(pathl,S); 
modul_tble = create_tbl(modul,S);
strg_tble = create_tbl(strg,S);
clust_w_tbl = create_tbl(clust_w,S);
btwn_tbl = create_tbl(betw,S);
eff_tbl = create_tbl(eff,S);

fprintf('-done\n')

end


% Convert Structure to table
function  [tble] = create_tbl(netstruct, S) 
    var_names = {'condition', 'run' 'raw_df', 'delta', 'theta', 'alpha', 'beta'};
    cat_table = @(netmat, condition_name, run) {condition_name, run, netmat, squeeze(netmat(1,:,:,:)), squeeze(netmat(2,:,:,:)), squeeze(netmat(3,:,:,:)), squeeze(netmat(4,:,:,:))};
    
    bl_tbl     = cell2table(cat_table(netstruct.baseline,'baseline',0));
    [cntl_tbl, light_tbl] = deal(table);
    for r = 1:4
        rstr = sprintf('run%d', r);
        cntl_tbl = [cntl_tbl; cat_table(netstruct.condB.(rstr),'control',r)];
        light_tbl = [light_tbl; cat_table(netstruct.condA.(rstr),'light',r)];
    
    end
    
    tble = [bl_tbl;cntl_tbl; light_tbl];
    tble.Properties.VariableNames = var_names;
    tble.sbjid = repmat(S.sbj_idS_num, height(tble),1);
    tble.rununique = (0:8)';
end





