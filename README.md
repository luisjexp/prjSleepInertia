# Project Sleep Inertia!!!
![Experimental Procedure](/readme_fig_experiment_procedure.png)


# 23 01 11 NASA MEET 2


!!! ! **TO DO ASAP**
Meeting with javia and kanika
cncept of homogeneity
- analysis: compare BL low vs bl high

task specifiticity : 
- PVT ~= KDT: argumanet to defend experimental results (as a control)

Subject variance analysis
- low vs high degrees

Send summary results to nasa

Look over dat set 


** HEY THE COUNT/FS TOPOPLOTS SHOULD NOT BE NORMALIZED

**OTHER TODO**

Frequency Band Analysis 
Are some nodes connected in some bands but not others?

Plotting Methods
GardnerAltmanPlot!!!!
Weighted graphs
using wpli matrix, create a graph structure!!!! 


Gava 2021 analysis  
- Correlations between WPLI matrices accross runs and conditions
- correlations between channels data set accross runs and conditions
- classification of conditions using classifier



# 22 11 12 NASA MEET 2 
analysis used to present to nasa peeps on january 12 
folder needs some cleaning: namely a clean description, and final run me scripts.


**Discussion notes from presenation**
Concept of homogeneity
- analysis: compare BL low vs bl high

task specifiticity : 
- PVT ~= KDT: argumanet to defend experimental results (as a control)

Subject variance analysis
- low vs high degrees

Send summary results to nasa

Look over dat set 



**New Things + functions**
**created a function **- _splitdfbycondition(df_wide)_ - that takes in the wide data frame (must contain data from all three conditions) and splits the data frame into 3 different onces, each with data from one condition only. typically this function is usd to compare/test variables accross conditions. very usefull and makes code simpler

New Stats: corrected for multiple comparisons and changed from using rank sum tests (assume independence) to sign rank (assume dependence)


**Realizations**
Remember!!! comparing control vs light is important, and gives plenty of insight even in cases where the intervention is no different from control

at sfn i had an interesting questions, that stirred my thoughts. what really is the implication of the analysis at different frequencies? I beleive it implies that there are 4 different networks, distinguished by their frequency at which they occilate (whether they influence eachother is not my concern here, thus i can consider them as being independent). thus i am analysing the connectivit of 4 different networks. 

**<u> show javi how i tossed some subjects from the analysis**</u> 


**Meeting with Joni for Proper Statistics/statistical tests**
How to compare differences of within group variances...??
- kolmorog sminog test distribution test

Interaction interpretation
- what is the meaning of the first 2 coefficients?
- simple not main effects!
  - slope of X for the reference group

Use clustered regression techniques as discussed with jodi
  - use mixed effects models
  - initial methods, for samples at 2 time points: Clustered robust standard error regression R package to use: huber white standard package 
  - More complex method, for more that 2 time points: longitudinal mixed models 



# 22 10 13 SFN Poster

Presented sfn poster which was an updated version of the TAB poster.

!!! ! **Completed**
Finished figure and analysis
- remove last figure/Replace with math results
- add eeg node graph example
  - add ntw prop examples to method
- reorganize into task comparison 
- show presleep as a bar with error bounds

Get New centrality measures
- rich club
- Sum of weighted edges
- binarization threshold analysis/minimization
  
<u>Various testing methods to compare network propers accross groups and time</u>

<u> meeting with kanija on oct 26th</u>
- use other measures of centrality
- desite randomness of slope analysis, we may be able to justify (eg fatigue effects at later time poiints)

<u> Created function to extrtact Raw WPLI for each subject,task, run, condition and band</u>
  created a function that extract thw raw WPLI matrix from the original structured data set and convert it into a table data frame. note that this table cannot be concatenated with the master data frame because each row contains the wpli matrix composed of 23 channels. However, it is usefull because for each row it has a corresponding task, band, and subject and run and condition. This makes it simple to create any desired property from the matrix. this is how i created a table where each row had the node's distances to the core function (see the other function i craeted for this).  
  
 <u> Created function that computes the distance's to core with varying 'gamme' thersholds, and degree with different binarization thresholds </u>
 This function creates a table with two new network properties 
(1) a node's distance's to core with varying levels of the gamma thresholds  
(2) the degree of a node with varying binarization threhold levels
This is computed for each node, for each task, band, and run, condition and subject. 
Thus, the table  matches the format and columns of your other 'master' data frame. You should be able to concetinate this data table with the master data, and use the dfmastersplit function to create an analysis data frame.

!!! ! **REALIZATIONS**
<u> Plot conditional analysis for the path length and clustering</u>
this is tough because there is not enough data, the only option is to add all tasks or bands together, or split into two groups


<u>Comparing control vs light is important </u>
analyzing control vs light, since this is important as well and can still be convincing evidence that blue light exposre works


<u>On why to retain outliers</u>
> Retain outliers (https://www.scribbr.com/statistics/outliers/)
> Just like with missing values, the most conservative option is to keep outliers in your dataset. Keeping outliers is usually the better option when you’re not sure if they are errors.
> 
> With a large sample, outliers are expected and more likely to occur. But each outlier has less of an impact on your results when your sample is large enough. The central tendency and variability of your data won’t be as affected by a couple of extreme values when you have a large number of values.
> 
> If you have a small dataset, you may also want to retain as much data as possible to make sure you have enough statistical power. If your dataset ends up containing many outliers, you may need to use a statistical test that’s more robust to them. Non-parametric statistical tests perform better for these data.



!!! ! **Variance Analysis depreciated)** no need to consider this analysis any more, since i will not run this analysis (comment made on december 19th 2022, well after this question and analysis was created)


Note that these tests can already be used in code, just need interpretation for 
- each condition
- each band
- each time point
- each task
They essentially run the original figure 1 analysis but directly test how the intervention mediates the effect of waking


Question: find the support of distributions 

what is the maximum centrality that is possible? does this depend on weather the graph is connected or disconnected (which our case many of  our nodes have a value of 0 impying a disconnect graph) or does it depend on whethere its a weighted graph? right now im just assuming that the maximum is the total number of pairs . 

[see this site here] (https://faculty.nps.edu/rgera/MA4404/Winter2020/06-CentralitiesBetweenness.pdf). It states...
"Let G be a disconnected graph:
What is the minimum value of betweenness centrality a vertex can have in disconnected graphs? – an isolated vertex: 0 •
What is the maximum value of betweenness centrality a vertex can have in disconnected graphs 
center of a star with center: n^2 - (n -1)
let V(star) = {v0,v1,v2...vn-1} with center node at v
then there are n^2 pairs of nodes, from which we tak away n-1 shortest paths from vi to vi since v is not one on those paths
Or perhaps i can simulate it using a random walk as this post suggests???

But anoter post says something else
https://www.joshobrouwers.com/articles/between-you-me-network-analysis/
(n^2 - 3*n + 2)  /2
but this doesnt work for some data which have values greater than this



# 22 09 08 Submitted TAB Poster

This analysis folder contains the code used to generate the poster.
I still havent put all of the used code into a single runme file, still need to do this

**COMPLETED**
<u> Removed variables from data frame </u>
- cause bugs when averaging accross groups
- removing categorical version of bands, and replacing with an ordinal version.I chose the ordinal version of bands instead of cateogrical because it allows automatic sorting during plotting. furthermore, i wont ever run a model with bands as a predictor so this wont lead to an issue.
- removed run unique, because it is actually not a variable

<u> Meeting w kanika+javi </u>
plot all slope effects at time 1 for all tasks (and bands)


  
**REALIZATIONS**
I noticed that my replication analysis using the GPSD during the pv task had extreme low values, which were not plotted in the original paper. I then re-ran the exact same script she used to generate the plots (see new analaysis folder called [this folder](analyze/000000_original_code_modified2RunOnMyMachines/extracting_wpli_light.m)). She also had these same extremes. so it seems that she just decided to remove them from the plots (to make it look better, which im not really ok with). i have the choice of making my plots with the extreme values included. i have to make a decision, because fixing the plots on illustrator takes a long time, and they depend on the y range of values. Here is what i decided to do...
- show all extreme values.
- the box plots will appear nice, since most of the figures will be comparing the data from the same task, so there wont be any 'squishing'. this tends to be a problem when comparing data of two tasks, with y ranges that are very different. 

Removed buggy variables from data frame (see completed section) 

Note the sample size of all tests
- make sure to print out all of the data frames for each analysis to determine which variables were included in more, especially the categorical vars/those with few levels, to make sure you are not averaging accross the wrong variables 
___

# 22 08 29 Betweeness centrality Analysis and second meeting with kanika

Created the  figures and analysis for the second meeting with kanika.  same exact analysis as previous meeting on 22 08 22 but with betweeness centrality.

see the pdf and/or goodle drive slides for the figures, and the run me file for the analysis. this is what was done
- compare temporal evolution of metrics within frequency bands and tasks, i.e., reproduce figures 1 and S1 from the paper for the rest of the tasks. For this, compare all the time points within one frequency band and task (e.g., not just baseline and t1,t2, etc.)
- compare tasks for baseline and first time point only after waking up, within specific frequency bands.
- compare baseline, t1_control, and t1_light for each frequency band and task separately (reproduce figures 2 and S2 from the paper for the rest of the tasks).

at a later date i allowed you to run the analysis by removing the KD and/or Math task
did this to simplify figures for TAB presentation

note that the run me file has not been created into a readme

# 22 08 22 Analysis and meeting for kanika meeting 

analysis is complete, but readme needs to be built

**Meeting with kanika**
need to create readme from this, just convert to Lattex and run function
Analysis completed for meeting with kanika.
we just plotted these analysis, and she took a look. we also worked together to write down all of the significant effects. see the pdf in the analysis folder 

1. compare temporal evolution of metrics within frequency bands and tasks, i.e., reproduce figures 1 and S1 from the paper for the rest of the tasks. For this, compare all the time points within one frequency band and task (e.g., not just baseline and t1,t2, etc.)
2. compare tasks for baseline and first time point only after waking up, within specific frequency bands.
3. compare baseline, t1_control, and t1_light for each frequency band and task separately (reproduce figures 2 and S2 from the paper for the rest of the tasks).


**Realizations...**
realized that in my previous analysis (for nasa ) I must stop using my function that averages accross variables that uses the desired variables to average accross. there is an issue that arises when choosing variables that are the same versions of eachother (eg runs and run_unique, or bands and band_levels). long story short just use the original matlab function that has you choose the variables you want to group by (varfun(@mean), "inputvar", "y", groupingvars, ['asvas']). also make sure that all the variables that you want average accross are no longer present in the new data frame - ie make sure they are actually being ignored or "averaged accross".

note that the master data frame contains all network properties in one. if you dont pay attention this can lead to an error, for example, when averaging accross avriables. make sure you never averaging acrros the network property if there are more than one present in the data frame. TLDR, first get the data frame that has the desired network property, then run your analysis. check out this function here in the folder which is exactly what is done. grpAndCleanDf(DF, groupingvars, desired_ntwprop, opts)

# 22 08 16 Nested Analysis of clustering for first nasa presentation
this was the analysis used to present to the nasa people on friday august 19th, the very first presentation. 

all i did was run the analysis below with 3 different network properties and created the slides with them. you can recreate the figures by going through each section and changing the following variable to either 'clust', 'pathl', or 'gpsd....

The analysis is nicely structured because it analyzes variables in a 'nested' manner, first by comparing differences between conditions, averaging accross all other variables, then goes deeper and deeper averaging only accross tasks, then time, then bands, etc. however the slides were not organizes in this manner, since at the very end javi and kanika helped me reorganize the presentation to fit what cassie and erin may want to see.

Note that there is one slide that i did not create here. it was the slide where i assessed the lower and higher frequency bands for the math and pv task, and found differences in onset times and duration of clustering changes. That analysis was performed previously. 


**Next things to do immediately**

first
there were some issue with the analysis, or better stated, a subpar understanding of the analysis- namely the issue was that i didnt realize i was not averaging accross bands as i initially thought i was. the issue is in the building/cleaning dataframe function, which was able to average accross bands, but missed averaging accross the variable termed 'ordinal bands' or 'ordinal levels'. this prevented the bands from being averaged accross. the problem isnt that big visually, but it will impact the testing performed since it basically increased the number of samples within each comparison group. you can see the function below. so this was issue number one. 

second
another issue, one that i knew as i ran the analysis, is that i used independent samples ttests to compare accross tasks, which of course is an issue because some samples within each task had the same subjects (although they also had different subkects too). two solutions were discussed during the meeting - first is to use a fixed effects model and second is to show javi how i tossed some subjects from the analysis.

third
display the unique subjects/degrees of freedom for each test to emphasize the (in)dependence of the samples)

fourth
ask kanika about removing the KD task

fifth
ask kanika about what variables to 'average accross'

sixth
as always, there are more things to do that are in the backburner, see the very last section of this folder

# 22 08 15 220815_nasa_math_vs_pvt_cntlVsLight
need to copy paste readme from main analysis folder

# 22 08 04 experiment timecourse
need to copy paste readme from main analysis folder

# 28 08 01 Analsysis - Nasa_math_vs_PVT

Interestingly the network appears to change in opposite ways accross multiple dimensions
   -  the frequency band that changes - upper or lower 
   -  the onset time of the change in the network - either network property is immediately effected or delayed 
   -  the duration of change in the network- either for a single test bout, or extended 

Notice that during the PV Task, the DELTA network is impacted immediately and temporaly after waking. Namely, clustering increases and path length decreases at time 1, but recovers quickly by time 2.

In contras during the Math Task, it is the BETA network that changes, and this change is not immediate and does not appear to recover. Namely, clustering increases and path length decreases during the seccond, third and fourth test bout.



# 22 07 30 Analysis - Validation and figure 1 analysis cleanup
Here i validated and cleaned up figure 1 analysis for the nase a presentation according to what javi and kanika suggested. 
Note that I need to regenerate the google slides for the nasa presentation again.


i wasnt able to replicate the google drive slides i showed kanika and javi for nasa presentation, generated from the prevoious 2 analyses in the folder called 
- prjSleepinertia\analyze\220720_nasa_clust_vs_task_vs_band
- and - prjSleepinertia\analyze\220720_nasa_fig1anz_update
- both analysis are basically the same and both used to create the slides

[See the google slides generated from these analysis here ](PRESENTME.PNG).
- Note the discrepency between slide 4 and 8+9, clustering analysis. 
- The interpretation is wrong, there are no significant effects in ckustering during MATH task ]
- one issue, is that i used the common subjects in both the math and pvt task when generating the the bar graphs in slides 8+9, where as in slide 4, the PVT task had different subjects vs the MATH task. 
- Nevertheless, even if i consider this i cannot replicate the results. 

# 22 07 20 fig1anz_update

WARNING WARNING WARNING WARNING WARNING WARNING 
WARNING WARNING WARNING WARNING WARNING WARNING 
WARNING WARNING WARNING WARNING WARNING WARNING 

there is a major issue with this analysis
although the code may be correct, i cannot seem to be able to replicate any of the results i posted on google drive
need to rerun this
this folder and the prevvious analysis as well are wrong
To see the issue, 
- check out the one of the anaylsis [README here](..\220720_nasa_fig1anz_update\README.MD).
- Or run the the [RUNME.m](..\220720_nasa_fig1anz_update\RUNME.m) script, and note that you cannot replicate the results.


---

## What this readme is about/contains**
This is a 'MASTER' readme. It is basically a compilations of the readme's that are created for each analysis folder (i basically just  of copy/paste some parts of each read me). Sometimes it contains information about meetings or discussions ive had.

typically each the readme's contains the following...
-  the analysis that was performed
-  describing highly critical knowledge and realizations of what ive been doing/errors
-  updates to the code
-  how to run the analysis (typically in a file named 'RUNME')
- a to do list

i want to one day write some code to scrape all of my readmes to generate this master readme, so that if i update that read me, it will update this change log with new to-dos, ideas and realizations. 
