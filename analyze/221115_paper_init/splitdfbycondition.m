function [df_bl, df_cntl, df_light] = splitdfbycondition(df_wide)
    arguments
        df_wide
    end

    if not(ismember({'baseline','control','light'},unique(df_wide.condition)))
        error('LUIS!!!: your data frame needs to contain data for all three conditions')
    end
    % Presleep
    df_bl   = df_wide(df_wide.condition == 'baseline',:);

    % Control
    df_cntl = df_wide(df_wide.condition == {'control'},:);

    % Light
    df_light    = df_wide(df_wide.condition == {'light'},:);   



end