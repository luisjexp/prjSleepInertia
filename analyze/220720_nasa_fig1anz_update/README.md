WARNING WARNING WARNING WARNING WARNING WARNING 
WARNING WARNING WARNING WARNING WARNING WARNING 
WARNING WARNING WARNING WARNING WARNING WARNING 

there is a major issue with this analysis
although the code may be correct, i cannot seem to be able to replicate any of the results i posted on google drive
need to rerun this
this folder and the prevvious analysis as well are wrong


#####################
BELOW IS WHAT I WROTE BEFORE I REALIZED THE MISTAKE.....



# PROPERTIES
title nasa slides updated figure1 analaysis
comments non
date_initiated 220720
date_completed 220721
project_directory prjSleepinertia
readme_type analysis
___
# ANALYSIS
CREATED 3 FIGURES, similar to figure 1 in original paper
but this time, we will run the analysis for all cognitive tasks, including KDT, Math and GoNogo.
Used to update the nasa presentation slides on google
- [google drive link](https://docs.google.com/presentation/d/1joa-JIfZ72pIhrq-KHkTdFM1jyhXEkK0-0rrAqRHCis/edit?usp=sharing)
- This pdf in this folder [pdf here](prjSleepinert_comm_220720_nasa.pdf) It works!
this is different from the previous figure 1 analysis sub-project used to create sfn abstract, in the following ways
- much cleaner code, using new data frame
- prettier figures
- plenty of descriptions about conditions
- compacted data: both light and controls runs are shown for each band and task in one figure
- interpret-able: significant effects are marked,
- comparisons are only drawn between baseline and runs (never between runs)
# CHANGE LOG
# VALIDATIONS
dfgetsubset
- use dfgetsubset help for more information
  - i am not liking this function much. may delete soon
  - was only usefull for the 220720_nasa_clust_vs_task sub analysis
# TO DO
## ANALYSIS
Critical to do
- analyze path length, reduce focus on power talk to cassie and
- subject assignment to conditions, need to know how to describe
-  order of tasks, random?
Make New plots of new claims in sfn abstact (if indeed are true)
Use clustered regression techniques as discussed with jodi
-  initial methods, for samples at 2 time points:
  - Clustered robust standard error regression R package to use: huber white standard  regrsion package
- More complex method, for more that 2 time points:
  - longitudinal mixed models
  - New plots of new SFN claims
Other ideas
- using wpli matrix, create a graph structure!!!! \
- Assess visually using using matlabs graph structure and  wpli matrix\
## VALIDATIONS
- recreate figure 2 with new data frame
- recreate figure 3 with new data frame and topoplot functionality
## OTHER
---
end of read me
