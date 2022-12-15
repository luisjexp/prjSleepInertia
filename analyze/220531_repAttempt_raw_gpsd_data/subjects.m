classdef subjects < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        cog_test
        path_data
        path_data_cog_test
        sbj_idS_str
        sbj_idS_num
        sbj_numel
        sbj
        run_idx_cntl        
        run_idx_light
                 
    end

    methods
        function obj = subjects(cog_test)
            obj.cog_test = cog_test;
            obj.getdata;
            
            obj.sbj_idS_str       = {'2952','2954','2956','2957','2958','2959','2961','2962', '2963','2967','2968','2969'};
            if strcmpi(cog_test, 'KDT')
                obj.sbj_idS_str    = {'2952','2954',       '2957','2958','2959','2961','2962', '2963','2967','2968','2969'};
            end

            obj.sbj_idS_num  = cellfun(@(x) str2double(x), obj.sbj_idS_str );
            obj.sbj_numel = numel(obj.sbj_idS_num);
            

            for i = 1:obj.sbj_numel
                obj.sbj(i).id_str = obj.sbj_idS_str{i};
                obj.sbj(i).id_num = obj.sbj_idS_num(i);
                fname = sprintf('RCM%s_metrics_050322_%s_ASR5_nodyn.mat', obj.sbj_idS_str{i}, obj.cog_test);
                obj.sbj(i).fname = fullfile(obj.path_data_cog_test, fname);

                obj.sbj(i).run_idx_cntl =  obj.run_idx_cntl (obj.sbj(i).id_num == obj.run_idx_cntl.sbj_id,:);
                obj.sbj(i).run_idx_light = obj.run_idx_light(obj.sbj(i).id_num == obj.run_idx_light.sbj_id,:);
            end

        end
    

        function obj = getdata(obj)
            % Get Data Path
            [~, sys_name] =  system('hostname')  ;  
            sys_name = strtrim(sys_name);

            switch sys_name
                case 'DESKTOP-U2CJDUH'
                    obj.path_data = 'C:\Users\Luis\Dropbox\DEVCOM\projects\2205_sleepInertia\analyze\data\';
                case 'hnlh.ss.uci.edu' 
                    obj.path_data = '/home/luis/Dropbox/DEVCOM/projects/2205_sleepInertia/analyze/data/';
                otherwise 
                    error('this is an unknown computer')
            end 
            obj.path_data_cog_test = [obj.path_data, obj.cog_test];
            
            load([obj.path_data, 'A_cond'])  ;         
            load([obj.path_data, 'B_cond']);

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
    end


end


    
     