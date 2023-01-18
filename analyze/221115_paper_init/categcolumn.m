function df_cat= categcolumn(df,columnname,numlevels,opts)
    arguments
        df 
        columnname
        numlevels {mustBeMember(numlevels,[2,3,4])}
        opts.condition = false
        opts.subject = false
    end

    % CATEGORIZE NETWORK PROPERTIES BY COMPARINING VALUES WITHIN A SUBJECT during a specific condition:

    if opts.condition == true && opts.subject == true
        % categorize a node by comparing its value to other nodes within
        % the same subjects during a specific condition: First get data
        % from each condition

        % first split by condition
        [df_bl, df_ctrl, df_light] = splitdfbycondition(df);
        
        % For each condition get data for each subject
        df_bl_sbj = splitdfbysubject(df_bl);
        df_ctrl_sbj = splitdfbysubject(df_ctrl);
        df_light_sbj =  splitdfbysubject(df_light);
        
        % Categorize the desired network property
        
        df_bl_cat           = cellfun(@(df_cond_sbj) [df_cond_sbj catnetworkprop(df_cond_sbj,columnname,numlevels)],df_bl_sbj,'UniformOutput',false);
        df_ctrl_cat           = cellfun(@(df_cond_sbj) [df_cond_sbj catnetworkprop(df_cond_sbj,columnname,numlevels)],df_ctrl_sbj,'UniformOutput',false);
        df_light_cat           = cellfun(@(df_cond_sbj) [df_cond_sbj catnetworkprop(df_cond_sbj,columnname,numlevels)],df_light_sbj,'UniformOutput',false);
        
        % Recreate table
        df_cat           = [cat(1,df_bl_cat{:}) ; cat(1,df_ctrl_cat{:}); cat(1,df_light_cat{:})];


    elseif opts.condition == true && opts.subject == false
        % categorize a node by comparing its value to other nodes during
        % the same condition, refardless of the subject

        % Just split by condition
        [df_bl, df_ctrl, df_light] = splitdfbycondition(df);
        
        % Categorize the desired network property
        df_bl      = [df_bl catnetworkprop(df_bl,columnname,numlevels)];
        df_ctrl    = [df_ctrl catnetworkprop(df_ctrl,columnname,numlevels)];
        df_light   = [df_light catnetworkprop(df_light,columnname,numlevels)];
        
        % Recreate table
        df_cat           = cat(1, df_bl,df_ctrl,df_light);
    elseif opts.condition == false && opts.subject == true
        % categorize a node by comparing its value to other nodes within
        % the same subject, during all conditions:
        
        % For each condition get data for each subject
        df_sbj = splitdfbysubject(df);

        % Categorize the desired network property
        df_cat           = cellfun(@(df_sbj) [df_sbj catnetworkprop(df_sbj,columnname,numlevels)],df_sbj,'UniformOutput',false);
        df_cat =  cat(1,df_cat{:});
    else
        
        df_cat = [df catnetworkprop(df,columnname,numlevels)];

    end

    % Make ordinal
    Y_cat_name = sprintf('%s_level',columnname); 
    catorder = cellstr(num2str(sort(unique(df_cat.(Y_cat_name)) )));   
    df_cat.(Y_cat_name) = ordinal(df_cat.(Y_cat_name),catorder);    

end



function Y_cat_df = catnetworkprop(df,ntwprop,numlevels)
    arguments
        df  
        ntwprop 
        numlevels {mustBeMember(numlevels,[2,3,4])}
    end
    % This function categorizes nodes into different levels by comparing
    % its its value (eg clustering coeff) with the values of all nodes in
    % the current data frame
    % 
    % NOTE: its important to know which variables are in this data frame.
    % for example, if the data frame has the nodes from all three
    % conditions, then the 'level' of a given node will be determined by
    % comparing its clustering coefficient to those in all conditions.
    % Whereas if the data frame only has data from the baseline condition,
    % the level of a given node is determined by comparing it only to those
    % in the baseline condition.
    
    Y = df.(ntwprop);
    Y_cat = zeros(size(Y,1),1);

    if numlevels == 2
            Y_1  = Y <= prctile(Y,50);
            Y_2  = Y > prctile(Y,50);

            Y_cat(Y_1)  = 1;
            Y_cat(Y_2)   = 2;

    elseif numlevels == 3
            Y_1  = Y <= prctile(Y,33);
            Y_2  = (Y> prctile(Y,33)) & (Y <= prctile(Y,66));
            Y_3  = Y > prctile(Y,66);

            Y_cat(Y_1)  = 1;
            Y_cat(Y_2)   = 2;
            Y_cat(Y_3)    = 3;
          

    elseif numlevels == 4
            Y_1  = Y <= prctile(Y,25) ;
            Y_2  = (Y> prctile(Y,25)) & (Y <= prctile(Y,50)) ;
            Y_3  = (Y> prctile(Y,50)) & (Y <= prctile(Y,75)) ;
            Y_4  = Y > prctile(Y,75);

            Y_cat(Y_1)  = 1;
            Y_cat(Y_2)   = 2;
            Y_cat(Y_3)    = 3;
            Y_cat(Y_4)    = 4;              
    end

    Y_cat_name = sprintf('%s_level',ntwprop);
    Y_cat_df= table(Y_cat,'VariableNames',  { Y_cat_name});  





end