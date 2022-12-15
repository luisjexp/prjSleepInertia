function [wpli,betw,pathl,eff,ecc,rad,strg,modul,clust] = extracting_wpli_light_copy_scratch(A_cond,B_cond, PVT_data_path)
% WARNING NOTE: for noe, the l light vs placeboo only computes wpli
% path length is computed ONLY first condition that you input as an argument 
% (eg condition A if its the first argument). ive only comfirmed this for
% path length, but proabably true for other properties


%% for light vs placebo
% i added number 62 to this data set, which they did not include in their
% paper (df = 10). It needs to be include so that the 'conditions' table
% match up. i cannot replicate results until i know which subject is
% missing. once i do i can drop the subject data as well has their
% corresponding row in the conditions table

subname = {'2952','2954','2956','2957','2958','2959','2961','2962',...
    '2963','2967','2968','2969'}; 
subid = [1:12];

chan = 23;

for i = 1:length(subid)
    i
    f = sprintf('RCM%s_metrics_050322_PVT_ASR5_nodyn.mat',subname{i});
    f_f =  strcat(PVT_data_path,f);

    load(f_f);
    night_no = A_cond(subid(i),2);
    
    % Baseline
    if ~isempty(data.(sprintf('night%d',night_no))(1).wpli)
        wpli.baseline(1:4,1:chan,1:chan,i) = data.(sprintf('night%d',night_no))(1).wpli.mat;  
        betw.baseline(1:4,1:chan,i) = data.(sprintf('night%d',night_no))(1).wpli.betweenness_centrality;
        pathl.baseline(1:4,i) = data.(sprintf('night%d',night_no))(1).wpli.path_length;
        eff.baseline(1:4,i)= data.(sprintf('night%d',night_no))(1).wpli.efficiency;
        ecc.baseline(1:4,1:chan,i)= data.(sprintf('night%d',night_no))(1).wpli.eccentricity;
        rad.baseline(1:4,i) = data.(sprintf('night%d',night_no))(1).wpli.radius;
        strg.baseline(1:4,1:chan,i) = data.(sprintf('night%d',night_no))(1).wpli.strength;
        modul.baseline(1:4,i) = data.(sprintf('night%d',night_no))(1).wpli.comms.Q(:,5); % for gamma ~ 1;
        %clust.baseline(1:4,1:9,i) = mean(data.(sprintf('night%d',night_no))(1).wpli.clusteringcoeff,3);
    else
        wpli.baseline(1:4,1:chan,1:chan,i)=zeros(4,chan,chan);
        betw.baseline(1:4,1:chan,i) =zeros(4,chan);
        pathl.baseline(1:4,i) = zeros(4,1);
        eff.baseline(1:4,i)= zeros(4,1);
        ecc.baseline(1:4,1:chan,i)= zeros(4,chan);
        rad.baseline(1:4,i) = zeros(4,1);
        strg.baseline(1:4,1:chan,i) = zeros(4,chan);
        modul.baseline(1:4,i) = zeros(4,1);
        %clust.baseline(1:4,1:9,i) = zeros(4,9);
    end
    
    % cond A 
    run = 4*(A_cond(subid(i),3)-1)+3;
    count = 1;
    for j = run:run+3
        if j > length(data.(sprintf('night%d',night_no)))
            wpli.condA.(sprintf('run%d',count))(1:4,1:chan,1:chan,i) = zeros(4,chan,chan);
            betw.condA.(sprintf('run%d',count))(1:4,1:chan,i) =zeros(4,chan);
            pathl.condA.(sprintf('run%d',count))(1:4,i) = zeros(4,1);
            eff.condA.(sprintf('run%d',count))(1:4,i)= zeros(4,1);
            ecc.condA.(sprintf('run%d',count))(1:4,1:chan,i)= zeros(4,chan);
            rad.condA.(sprintf('run%d',count))(1:4,i) = zeros(4,1);
            strg.condA.(sprintf('run%d',count))(1:4,1:chan,i) = zeros(4,chan);
            modul.condA.(sprintf('run%d',count))(1:4,i) = zeros(4,1);
            %clust.condA.(sprintf('run%d',count))(1:4,1:9,i) = zeros(4,9);
        else
            if ~isempty(data.(sprintf('night%d',night_no))(j).wpli)
                wpli.condA.(sprintf('run%d',count))(1:4,1:chan,1:chan,i) = data.(sprintf('night%d',night_no))(j).wpli.mat;
                betw.condA.(sprintf('run%d',count))(1:4,1:chan,i) = data.(sprintf('night%d',night_no))(j).wpli.betweenness_centrality;
                pathl.condA.(sprintf('run%d',count))(1:4,i) = data.(sprintf('night%d',night_no))(j).wpli.path_length;
                eff.condA.(sprintf('run%d',count))(1:4,i)= data.(sprintf('night%d',night_no))(j).wpli.efficiency;
                ecc.condA.(sprintf('run%d',count))(1:4,1:chan,i)= data.(sprintf('night%d',night_no))(j).wpli.eccentricity;
                rad.condA.(sprintf('run%d',count))(1:4,i) = data.(sprintf('night%d',night_no))(j).wpli.radius;
                strg.condA.(sprintf('run%d',count))(1:4,1:chan,i) = data.(sprintf('night%d',night_no))(j).wpli.strength;
                modul.condA.(sprintf('run%d',count))(1:4,i) = data.(sprintf('night%d',night_no))(j).wpli.comms.Q(:,5); % for gamma ~ 1;
                %clust.condA.(sprintf('run%d',count))(1:4,1:9,i) = mean(data.(sprintf('night%d',night_no))(j).wpli.clusteringcoeff,3);

            else 
                wpli.condA.(sprintf('run%d',count))(1:4,1:chan,1:chan,i) = zeros(4,chan,chan);
                betw.condA.(sprintf('run%d',count))(1:4,1:chan,i) =zeros(4,chan);
                pathl.condA.(sprintf('run%d',count))(1:4,i) = zeros(4,1);
                eff.condA.(sprintf('run%d',count))(1:4,i)= zeros(4,1);
                ecc.condA.(sprintf('run%d',count))(1:4,1:chan,i)= zeros(4,chan);
                rad.condA.(sprintf('run%d',count))(1:4,i) = zeros(4,1);
                strg.condA.(sprintf('run%d',count))(1:4,1:chan,i) = zeros(4,chan);
                modul.condA.(sprintf('run%d',count))(1:4,i) = zeros(4,1);
                %clust.condA.(sprintf('run%d',count))(1:4,1:9,i) = zeros(4,9);
            end
        end
        count = count+1;
    end
     
    % cond B 
    run = 4*(B_cond(subid(i),3)-1)+3;
    count = 1;
    for j = run:run+3
        if j > length(data.(sprintf('night%d',night_no)))
            wpli.condB.(sprintf('run%d',count))(1:4,1:chan,1:chan,i) = zeros(4,chan,chan);
            betw.condB.(sprintf('run%d',count))(1:4,1:chan,i) =zeros(4,chan);
            pathl.condB.(sprintf('run%d',count))(1:4,i) = zeros(4,1);
            eff.condB.(sprintf('run%d',count))(1:4,i)= zeros(4,1);
            ecc.condB.(sprintf('run%d',count))(1:4,1:chan,i)= zeros(4,chan);
            rad.condB.(sprintf('run%d',count))(1:4,i) = zeros(4,1);
            strg.condB.(sprintf('run%d',count))(1:4,1:chan,i) = zeros(4,chan);
            modul.condB.(sprintf('run%d',count))(1:4,i) = zeros(4,1);
            %clust.condB.(sprintf('run%d',count))(1:4,1:9,i) = zeros(4,9);
        else
            if ~isempty(data.(sprintf('night%d',night_no))(j).wpli)
                wpli.condB.(sprintf('run%d',count))(1:4,1:chan,1:chan,i) = data.(sprintf('night%d',night_no))(j).wpli.mat;
                betw.condB.(sprintf('run%d',count))(1:4,1:chan,i) = data.(sprintf('night%d',night_no))(j).wpli.betweenness_centrality;
                pathl.condB.(sprintf('run%d',count))(1:4,i) = data.(sprintf('night%d',night_no))(j).wpli.path_length;
                eff.condB.(sprintf('run%d',count))(1:4,i)= data.(sprintf('night%d',night_no))(j).wpli.efficiency;
                ecc.condB.(sprintf('run%d',count))(1:4,1:chan,i)= data.(sprintf('night%d',night_no))(j).wpli.eccentricity;
                rad.condB.(sprintf('run%d',count))(1:4,i) = data.(sprintf('night%d',night_no))(j).wpli.radius;
                strg.condB.(sprintf('run%d',count))(1:4,1:chan,i) = data.(sprintf('night%d',night_no))(j).wpli.strength;
                modul.condB.(sprintf('run%d',count))(1:4,i) = data.(sprintf('night%d',night_no))(j).wpli.comms.Q(:,5); % for gamma ~ 1;
                %clust.condB.(sprintf('run%d',count))(1:4,1:9,i) = mean(data.(sprintf('night%d',night_no))(j).wpli.clusteringcoeff,3);

            else 
                wpli.condB.(sprintf('run%d',count))(1:4,1:chan,1:chan,i) = zeros(4,chan,chan);
                betw.condB.(sprintf('run%d',count))(1:4,1:chan,i) =zeros(4,chan);
                pathl.condB.(sprintf('run%d',count))(1:4,i) = zeros(4,1);
                eff.condB.(sprintf('run%d',count))(1:4,i)= zeros(4,1);
                ecc.condB.(sprintf('run%d',count))(1:4,1:chan,i)= zeros(4,chan);
                rad.condB.(sprintf('run%d',count))(1:4,i) = zeros(4,1);
                strg.condB.(sprintf('run%d',count))(1:4,1:chan,i) = zeros(4,chan);
                modul.condB.(sprintf('run%d',count))(1:4,i) = zeros(4,1);
                %clust.condB.(sprintf('run%d',count))(1:4,1:9,i) = zeros(4,9);
            end
        end
        count = count+1;
    end
    
end

%% running for clustering coefficient calculated on weighted matrices
wpli.subjects = subname;

for i = 1:length(subid)
    i
    f = sprintf('RCM%s_metrics_050322_PVT_ASR5_nodyn.mat',subname{i});
    f_f =  strcat(PVT_data_path,f);

    load(f_f);
    night_no = A_cond(subid(i),2);
    
    % Baseline
    if ~isempty(data.(sprintf('night%d',night_no))(1).wpli)
        clust.baseline(1:4,1:chan,i) = data.(sprintf('night%d',night_no))(1).wpli.clusteringcoeff_wu;
    else
        clust.baseline(1:4,1:chan,i) = zeros(4,chan);
    end
    
    % cond A 
    run = 4*(A_cond(subid(i),3)-1)+3;
    count = 1;
    for j = run:run+3
        if j > length(data.(sprintf('night%d',night_no)))
            clust.condA.(sprintf('run%d',count))(1:4,1:chan,i) = zeros(4,chan);
        else
            if ~isempty(data.(sprintf('night%d',night_no))(j).wpli)
                clust.condA.(sprintf('run%d',count))(1:4,1:chan,i) = data.(sprintf('night%d',night_no))(j).wpli.clusteringcoeff_wu;

            else 
                clust.condA.(sprintf('run%d',count))(1:4,1:chan,i) = zeros(4,chan);
            end
        end
        count = count+1;
    end
     
    % cond B 
    run = 4*(B_cond(subid(i),3)-1)+3;
    count = 1;
    for j = run:run+3
        if j > length(data.(sprintf('night%d',night_no)))
            clust.condB.(sprintf('run%d',count))(1:4,1:chan,i) = zeros(4,chan);
        else
            if ~isempty(data.(sprintf('night%d',night_no))(j).wpli)
                clust.condB.(sprintf('run%d',count))(1:4,1:chan,i) = data.(sprintf('night%d',night_no))(j).wpli.clusteringcoeff_wu;

            else 
                clust.condB.(sprintf('run%d',count))(1:4,1:chan,i) = zeros(4,chan);
            end
        end
        count = count+1;
    end
    
end
