% READ THIS

------------------------------
#ANALYSIS
----------
Here i Visualized diffreences in network state between subject and within subjects
% here you can see how nodes vary within subjects 
% In he original anlaysis, we only assessed differences between
% subjects - that is between the 'graphs' of different subjects. In doing
% so we ignored the variablity of the nodes (the channels) within each
% graph. 

% For example, if you select to assess 'gpsd', you will now be visualizing the 'local' psd, aka the 'power' of EACH node. 
% thus you will no longer be looking at the 'global' power distribution,  which was originally used in the first analysis.

% Also note that path length is a global property of the network. that is no
% individual node has a path length. thus the analysis will not produce
% anything insightfull. good news is that my code is flexible enough to not
% crash and safe as well due to the 'averaging' method being used to
% extract the data


------------------------------
#CODE 
------------------------------
# Tests and Validations


# Updated Functions


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
- use clustered regression techniques as discussed with jodi
    - initial methods, for samples at 2 time points: Clustered robust standard error regression
        R package to use: huber white standard error regrsion package
    - More complex method, for more that 2 time points: longitudinal mixed models
- using wpli matrix, create a graph structure!!!!