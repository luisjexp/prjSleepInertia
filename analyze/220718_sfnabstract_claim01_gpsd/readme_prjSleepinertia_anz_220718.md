% READ THIS

------------------------------
#ANALYSIS
----------
%% ---First for each cognitive test, analyze how power in the high
% frequency bands - alpha and beta - changes after awakening in the control
% conditions. we assess this for each test bout after awakening and compare
% with baseline.


%% ---Next compare how power changes for low vs high frequency bands.
% here, we define the power high frequency bands as the average power of
% the alpha and beta bands, and low frequencies are defined as the average
% of the delta and theta bands. the same analysis is conducted as the one
% above but instead using these definitions.

%% ---Third ask how many test bouts after awakening does power changes.
% do this for all cognitive tests and also for high frequency and low
% frequencies bands.

------------------------------
#CODE 
------------------------------
# Tests and Validations
none
# Updated Functions
none

# other
added comments and descriptions

------------------------------
# STILL TO DO
------------------------------
## Validations
- recreate figure 2 with new data frame
- recreate figure 3 with new data frame and topoplot functionality
- recreate SFN claims using new data frame


## Analysis
- New plots of new claims
- use clustered regression techniques as discussed with jodi
    - initial methods, for samples at 2 time points: Clustered robust standard error regression
        R package to use: huber white standard error regrsion package
    - More complex method, for more that 2 time points: longitudinal mixed models
- using wpli matrix, create a graph structure!!!!