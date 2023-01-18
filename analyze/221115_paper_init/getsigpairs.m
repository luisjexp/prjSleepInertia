function sig_pairs = getsigpairs(test_results, level,opts)
    arguments
        test_results, level
        opts.testtype = 'ranksign'
        opts.bonfcorrect = 1;

    end
    
    % F(X): Make it easier to find group pairs that are significant from ttest


    % set the locations of bar ends
    if ischar(level)

        % For 'unconditional' plot 
        if strcmpi(level,'all')
            bl_xtick = .66;
            ctrl_xtick = 2;
            light_xtick = 3.33;
        end

    elseif isnumeric(level) 
        % For plot where Y is conditional on X
        bl_xtick = level-.33;
        ctrl_xtick = level;
        light_xtick = level+.33;
    end

    
    switch opts.testtype
        case {'ttest','t'}
            ctrl_p = test_results.control.ttest_p;
            light_p = test_results.light.ttest_p;
        case {'ranksum'}
            ctrl_p = test_results.control.ranktest_p;
            light_p = test_results.light.ranktest_p;  
        case {'signrank'}
            ctrl_p = test_results.control.signranktest_p;
            light_p = test_results.light.signranktest_p; 

        otherwise
            error('LUIS!!!!: unknown test type')
    end

    sig_pairs = {};    
    if ctrl_p<(.05/opts.bonfcorrect)
        sig_pairs = cat(2,sig_pairs,[bl_xtick ctrl_xtick]);
    end

    if light_p< (.05/opts.bonfcorrect)
        sig_pairs = cat(2,sig_pairs,[bl_xtick light_xtick]);
    end  


end
