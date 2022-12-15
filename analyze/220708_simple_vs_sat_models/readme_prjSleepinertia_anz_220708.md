Started on July 8th
ended on july 8th

Notes
here i tested 2 similar notions
(1) the coefficients from a mult comparisons ttest are identical to those of a linear model
that compares a single group with a reference group. 
    I found this to be true, in all data sets i tested. 
    namely the mult com ttests from testing baseline with each run 
    the results hold tru for any cognitive test, network prop, condition, band, and subject selection
    this makes sense

(2) the coefficients from a mult comparisons ttest are NOT the same to those of a linear model
that compares a set of groups with a reference group. 
    I found this to be true, in all data sets i tested, like above
    the results hold tru for any cognitive test, network prop, condition, band, and subject selection
    this makes sense

Run and read the 'runthis' script for the analysis


UPDATES
- some comments and descriptions of functions

df4linmodel fcn
    - allows to specifiy list of cog tests, instead of forcing all tests to be added to data frame (takes a while)

