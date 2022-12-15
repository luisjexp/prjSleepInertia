function testbetwVariance_temp(df, ntwprop)
    arguments
        df, ntwprop
    end
    
    % VARIANCE ASSESSMENTS 
    % The Levene, Brown-Forsythe, and O’Brien tests are used to test if
    % multiple data samples have equal variances, against the alternative that
    % at least two of the data samples do not have equal variances.

    %     The Levene, Brown-Forsythe, and O’Brien tests are less sensitive to
    %     departures from normality than Bartlett’s test, so they are useful
    %     alternatives if you suspect the samples come from nonnormal
    %     distributions.




    % The Ansari-Bradley test is a nonparametric alternative to the two-sample
    % F-test of equal variances. It does not require the assumption that x and
    % y come from normal distributions. The dispersion of a distribution is
    % generally measured by its variance or standard deviation, but the
    % Ansari-Bradley test can be used with samples from distributions that do
    % not have finite variances.
    
    % This test requires that the samples have equal medians. Under that
    % assumption, and if the distributions of the samples are continuous and
    % identical, the test is independent of the distributions. If the samples
    % do not have the same medians, the results can be misleading. In that
    % case, Ansari and Bradley recommend subtracting the median, but then the
    % distribution of the resulting test under the null hypothesis is no longer
    % independent of the common distribution of x and y. If you want to perform
    % the tests with medians subtracted, you should subtract the medians from x
    % and y before calling ansaribradley.

    Y_bl = df.(ntwprop)(df.condition == 'baseline');
    Y_cntl = df.(ntwprop)(df.condition == 'control');
    Y_light = df.(ntwprop)(df.condition == 'light');   

    lev_bl_cntl = vartestn(bl_vs_cntl.(ntwprop), double(bl_vs_cntl.condition), 'TestType', 'LeveneAbsolute','Display','on'); 
    lev_bl_light = vartestn(bl_vs_light.(ntwprop), double(bl_vs_light.condition), 'TestType', 'LeveneAbsolute','Display','on'); 

    
    lev_bl_cntl = vartestn([Y_bl Y_cntl], 'TestType', 'LeveneAbsolute','Display','on'); 
    lev_bl_light = vartestn([Y_bl Y_light], 'TestType', 'LeveneAbsolute','Display','on'); 


    [ans_blVsCntl, ~] = ansaribradley(Y_bl-median(Y_bl), Y_cntl-median(Y_cntl));
    [ans_blVsLight, ~] = ansaribradley(Y_bl-median(Y_bl), Y_light-median(Y_light))   ;

    % Display
        disp('------')
        disp('VARIANCE TESTS...')
        disp('Levene''s Test of differences in within group variance...')
        disp('- - Levene test--> baseline vs Control- - ')
        disp(lev_bl_cntl)
        disp('- - Levene test--> baseline vs Light- - ')
        disp(lev_bl_light)
        

        disp('Ansari test differences in means') 
        disp('- - ansari test--> baseline vs Control- - ')
        disp(ans_blVsCntl)
        disp('- - ansari test--> baseline vs Light- - ')
        disp(ans_blVsLight)
    
        disp(groupsummary(df, "condition",{"mean", "std", "median", "min","max", "range"}, ntwprop))
end