classdef subjects < handle
    % S = subjects(cogtestfolder) gives you detailed information about each subject
    % information includes their ID, the order and night of each run and each condition.
    % This is used to organize the raw data.

    %  See Properties below for output details

    properties
        cog_test            % Cognitive test data set name: PVT, or Math, ... (is case sensitive)
        path_data           % data base path of all cognitive tests
        path_data_cog_test  % data base path of desired cognitive test
        path_tool_eeglab    % path of eeglab module
        sbj_idS_str         % id number of subject, in string format
        sbj_idS_num         % id number of subject, in numeric format
        sbj_numel           % number of subjects including
        sbj                 % structure containing detailed information about each subject
        run_idx_cntl        % table showing subject ID, the order and night of each run under the control condition
        run_idx_light       % table showing subject ID, the order and night of each run under the light condition
        chan                % 'channel' structure used by eeglab module to run topoplots, etc
                 
    end

    methods
        function obj = subjects(cog_test_folder_name)
            obj.cog_test = (cog_test_folder_name);
            obj.getdata;
            
            obj.sbj_idS_str       = {'2952','2954','2956','2957','2958','2959','2961','2962', '2963','2967','2968','2969'};
            if strcmp(obj.cog_test, 'KDT')
                obj.sbj_idS_str    = {'2952','2954',       '2957','2958','2959','2961','2962', '2963','2967','2968','2969'};
            end

            obj.sbj_idS_num  = cellfun(@(x) str2double(x), obj.sbj_idS_str );
            obj.sbj_numel = numel(obj.sbj_idS_num);
            

            switch obj.cog_test
                case 'PVT'
                    cog_test_id = 'PVT';
                case 'KDT'
                    cog_test_id = 'KDT';
                case 'Math'
                    cog_test_id = 'Add';
                case 'GoNogo'
                    cog_test_id = 'Go';  
                otherwise
                    error('Cogntive test "%s" unkown. Remember its case sensitive', obj.cog_test )
            end


            for i = 1:obj.sbj_numel
                obj.sbj(i).id_str = obj.sbj_idS_str{i};
                obj.sbj(i).id_num = obj.sbj_idS_num(i);

                fname = sprintf('RCM%s_metrics_050322_%s_ASR5_nodyn.mat', obj.sbj_idS_str{i}, cog_test_id);
                obj.sbj(i).fname = fullfile(obj.path_data_cog_test, fname);

                obj.sbj(i).run_idx_cntl =  obj.run_idx_cntl (obj.sbj(i).id_num == obj.run_idx_cntl.sbj_id,:);
                obj.sbj(i).run_idx_light = obj.run_idx_light(obj.sbj(i).id_num == obj.run_idx_light.sbj_id,:);
            end

        end
    
        function obj = getdata(obj)
            % Get Data Path
            [~, hostname] =  system('hostname')  ;  
            hostname = strtrim(hostname);
            switch hostname
                case {'luis.ss.uci.edu','hnle'}
                    obj.path_data = fullfile('/home/luis/Insync/DEVCOM/prjSleepInertia/analyze', 'data');
                    obj.path_tool_eeglab  = fullfile('/home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze', 'eeglab2022.0');

                
                case  'DESKTOP-U2CJDUH'
                    obj.path_data = fullfile('G:\My Drive\DEVCOM\prjSleepInertia\analyze', 'data');
                    obj.path_tool_eeglab  = fullfile('C:\Users\Luis\Dropbox\DEVCOM\prjSleepinertia\analyze', 'eeglab2022.0');

                case  {'LuisMac', 'luismacair'}
                    obj.path_data = fullfile('/Users/luis/Library/CloudStorage/GoogleDrive-luisjexp@gmail.com/My Drive/DEVCOM/prjSleepInertia/analyze/', 'data');
                    obj.path_tool_eeglab  = fullfile('/Users/luis/Library/CloudStorage/GoogleDrive-luisjexp@gmail.com/My Drive/DEVCOM/prjSleepInertia/analyze/', 'eeglab2022.0');
                case 'your computer host name here'
                    % obj.path_data = enter the path of your data set here
                otherwise
                    error('LUIS: this is an unkown machine, cannot locate data set')

            end
            
            obj.path_data_cog_test = fullfile(obj.path_data , obj.cog_test);
            
            load(fullfile(obj.path_data, 'A_cond.mat'))  ;         
            load(fullfile(obj.path_data, 'B_cond.mat'))

            add_night_str = @(x) sprintf('night%d',  x);
            
            % to get the data from each run, first have to go into the data
            % set, find all the runs, and choose the runs that correspond
            % to the control and light conditions. it looks like the for
            % control conditions, the runs are 7:10, and for light, the runs
            % are 3:6. the get runs functions finds these runs. its overly
            % complex but its here because of the original code, just want
            % to make sure im using the same thing
            getruns = @(cond_mat) [cond_mat 4*(cond_mat(:,3)-1)+3 + [0 1 2 3]];
            var_names = {'sbj_id','night_no', 'condition_id', 'run1', 'run2', 'run3', 'run4'};
            
            run_cntl_tbl = array2table(getruns(B_cond), 'VariableNames',var_names);
            run_cntl_tbl.night_no = arrayfun(add_night_str, run_cntl_tbl.night_no, 'UniformOutput', false) ;
            obj.run_idx_cntl = run_cntl_tbl;
            
            run_light_tbl = array2table(getruns(A_cond), 'VariableNames',var_names);
            run_light_tbl.night_no = arrayfun(add_night_str, run_light_tbl.night_no, 'UniformOutput', false) ;
            obj.run_idx_light = run_light_tbl;
            
            
            if not( all(obj.run_idx_light{:,'sbj_id'} == obj.run_idx_cntl{:,'sbj_id'}) )...
                    || not(all(strcmp( obj.run_idx_light{:,'night_no'}, obj.run_idx_cntl{:,'night_no'} )))
                error('problem generating table')
            end

            c  = load(fullfile(obj.path_data, 'dchanlocs_rev.mat'))  ;         
            obj.chan = c.chan;

        end

        function sbj_psd = loadsbj(obj,id_num)
            sbj_idx = obj.sbj_idS_num == id_num;
            s = obj.sbj(sbj_idx); 
            d = load(s.fname);
            d = d.data;
        
            run_vars = {'run1', 'run2', 'run3', 'run4'};
            df = d.(s.run_idx_cntl.night_no{:}); % control and light conditions ran on the same night. both should work, this was checked


            bl_idx = 1;
            sbj_psd = make_psdstruct(df, bl_idx); % returns baseline data

            run_idx_light       = s.run_idx_light{:,run_vars};              
            sbj_psd.condA = make_psdstruct(df, run_idx_light);          

            run_idx_cntl = s.run_idx_cntl{:,run_vars};                      
            sbj_psd.condB = make_psdstruct(df, run_idx_cntl);


            function S = make_psdstruct(df, run_idx)
                psd = {df(run_idx).psd};
                num_runs = length(psd); % 4 runs if control or light, 1 run if baseline
                gpd_filled = cell(1,num_runs);
                for run = 1:num_runs
                    if isempty(psd{run})
                        gpd_filled{run}   = zeros(23, 251);
                    else
                        gpd_filled{run} = psd{run}.power;
                    end
    
                end

                if num_runs == 1
                    var_names = 'baseline';
                elseif num_runs == 4
                    var_names = run_vars;
                else 
                    error('there are more/less runs than expected')
                end

                S   = cell2struct(gpd_filled, var_names,2);
            end
        end

        function sbj_clust = loadsbjclust(obj,id_num)
            sbj_idx = obj.sbj_idS_num == id_num;
            s = obj.sbj(sbj_idx); 
            d = load(s.fname);
            d = d.data;
        
            run_vars = {'run1', 'run2', 'run3', 'run4'};
            df = d.(s.run_idx_cntl.night_no{:}); % control and light conditions ran on the same night. both should work, this was checked


            bl_idx = 1;
            sbj_clust = make_cluststruct(df, bl_idx); % returns baseline data

            run_idx_light       = s.run_idx_light{:,run_vars};              
            sbj_clust.condA = make_cluststruct(df, run_idx_light);          

            run_idx_cntl = s.run_idx_cntl{:,run_vars};                      
            sbj_clust.condB = make_cluststruct(df, run_idx_cntl);


            function S = make_cluststruct(df, run_idx)
                clust = {df.wpli};
                clust = clust(run_idx);

                num_runs = length(clust); % 4 runs if control or light, 1 run if baseline
                clust_filled = cell(1,num_runs);
                for run = 1:num_runs
                    if isempty(clust{run})
                        clust_filled{run}   = zeros(4,23);
                    else
                        clust_filled{run} = clust{run}.clusteringcoeff_wu;
                    end
    
                end

                if num_runs == 1
                    var_names = 'baseline';
                elseif num_runs == 4
                    var_names = run_vars;
                else 
                    error('there are more/less runs than expected')
                end

                S   = cell2struct(clust_filled, var_names,2);
            end            

        end
    end


end


    
     