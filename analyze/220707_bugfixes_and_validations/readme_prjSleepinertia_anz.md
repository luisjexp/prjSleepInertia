Started on July 7th
ended july 7th

# BIG BUG FIXES 

Mostly performed a sanity check and fixed analysis functions prone to errors
    - a new figure1 analysis function  (fig1analysis_update) will only accept subject identifiers,
    - avoiding the potential dangers of the original function.
    - note that fig2 analysis still does not have this update

Second I ran some tests on linear models using my new data frame: 
    - helped me realize and fix the dangers and errors produced by the figure1 analysis
    - moreover it highlighted the dangers of converting variable to categorical then running model (see below)
    - i also was able to replicate the original figure 1 analysys with a regression using categorinal variables
        (but note that the tests used were independent samples ubnlike the oringal analysis)
    - finally it helped me recall some important details obouf linear models

run the 'runthis.m' script for these tests
see the 'findings' section for more details on some of these update

# INITIAL IDEAS AND GOALS
First, sanity check, 
    - make sure youre data frame can replicate all of the results of the figure1 and figure 2 anallysi


Next, a linear model, 
    - find way to run regression with dependent samples (like the ttest analysis)
    - treating RUN as a categorical variable, 
        - means the that the model is not a time series model
    - if we let the regression the result should be similar, if not identical, to the ttest performed from figure 1 and 2 analysis
        - assuming we treat the baseline condition as the intercept 



# FINDINGS

If the run for the baseline condition is set to 0, then it imply that the other conditions (light and control) can potentially have a value of zero
    - thus this clearly wont yeild the same results as the ttest 
    - setting the run of the baseline to be nan will also not work bc the baseline rows will be dropped
    - solution is to make each condition totally independent from others. for instance, dummy code this way 
        baseline(:) = 0
        cntrolRun1(:) = 1 
        cntrolRun2(:) = 2
        ...
        lightRun1(:) = 5
        lightRun1(:) = 6
        ...
        this works, see your script


after recoding the dummy variables as stated above, i realized something about the regression coefficients that i forgot about
    - the coefficients ARE NOT ESTIMATES, they are TRUE VALUES 
        for example, B0 - B1*X1 = mean(X1)
    - i showed this only when treating X as a categorical but should be true for continous or other variable types

if we regress Y on a single run (eg run 1 vs run 3), while treating runs as categorical
    - then these ttest that identical to a INDEPENDENT ttest between reference condition and other condition
    - however, the regression tstat is not the same as the tstat produced with a dependent ttest, which is the test used in the original analysis

Say we have two IVs, both coding the same thing, 
    - for example, IV1 = {run1, run1, run1, ...}, IV2 = {1,1,1,...}
    - then regressing Y on both IVs is the same as regressing Y on IV1 only (or IV2 only).
    - this makes sense



# WARNING
do not convert table to categorical
this will screw up a regression when you only want to regress a subset of those categories
all of the catefories are included as IVs, event if you only select a few.
only convert to categorical JUST BEFORE you compute the model



