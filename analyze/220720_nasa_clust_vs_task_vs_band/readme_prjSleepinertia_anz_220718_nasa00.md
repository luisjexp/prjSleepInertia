2207 % WARNING IGNORE THIS FOLDER!!!


there is a major issue with this analysis
although the code may be correct, i cannot seem to be able to replicate any of the results i posted on google drive
need to rerun this


#####################
BELOW IS WHAT I WROTE BEFORE I REALIZED THE MISTAKE.....

----------
#ANALYSIS
----------
- Generated figures to present in meeting with javi and kaniki on july 20 2022 in prep for nasa presentation
- see present_prjSleepinertia_comm_220718_nasa00.pdf for slides

Generally found that Engagement in different tasks immediately after abrupt awakening uniquely impacts clustering in delta and beta bands 
- % Delta band clustering
%   PV task (original findings): significant reductions immediately after abrupt awakening 
%       observed only without blue light exposure
%       But with exposure, the reduction is eliminated
%   Math Task: significant increases  immediately after abrupt awakening
%       observed with and without blue light exposure
% 
% Beta Band Clustering
%   PV task (original findings): totally unaffected by waking 
%       observed with and without blue light exposure
%   Math Task: significant increases 
%   observed with and without blue light exposure

- exectute Run this to replicate results used to present in meeting 
- notice that only the first run was assessed for this analysis
------------------------------
#CODE 
------------------------------

# Tests and Validations
none

# Updated Functions
created hyptest_nasa00_getdf rows function
- it takes the large 'master data frame' produced by dfgenerate fcn 
- produces multuiple tables
    - raw table that is simply the table desired by the user, 
        - desired cognitive test (one type option only)
        - desired subjects
        - desired network prop (one option only)
        - desire band , multiple options available (see below)
            - desired frequency bands can be = {'alpha', 'beta', 'delta', 'theta', 'highfs' 'lowfs'}
                - 'lowfs' and 'highsf' produce tables that are averaged accross the d+th band, pr alph+bet band, respectively
        - desired runs, 'multipl options available (see below)
            - desired runs bands can be = {'1', '2', '3', '4', 'early' 'late', 'all'}
                - 'early', 'late', and 'all, produce tables that are averaged accross 
                    - the 1+2nd run, 3rd+4th run and all 4 runs, respectively            
        - desir either with or without channel by channel information 
        - currently this table is not an output but serves to create the other tables...
    - a group table where the values of the network property are grouped by
        - by cognitive test, subject, condition and, if desired, by channel 
        - thus, the desired frequency bands are collapsed
        - thus, the desired runs are also collapsed
    - an 'effects' table, where variables are created by subtracting values of different grroups
        - difference between BL and light
        - difference between BL and control
        - difference between light and control
    - a group table of the effects is also given, where each 'effect variable is averaged





# other


------------------------------
# STILL TO DO
------------------------------
## Validations
- recreate figure 2 with new data frame
- recreate figure 3 with new data frame and topoplot functionality
- recreate SFN claims using new data frame


## Analysis
- New plots of new claims in sfn abstract
- use clustered regression techniques as discussed with jodi
    - initial methods, for samples at 2 time points: Clustered robust standard error regression
        R package to use: huber white standard error regrsion package
    - More complex method, for more that 2 time points: longitudinal mixed models
- using wpli matrix, create a graph structure!!!!

## Other
- scrape readmes to generate master log
