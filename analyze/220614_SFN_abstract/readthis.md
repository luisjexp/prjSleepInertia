UPDATES AND DESCRIPTION

TASK COMPLETED
Analyzed TONS of data for SFN abstract submition. 

namely analyzed all possible combinations of
- Task Type/Cognitive Test Type: PVT, KDT, Math, GoNogo
- Network Properties: GPSD, PATHL, CLUSTER, BTWN, WPLI 
- Freq Bands: 4 bands
- analysis type: figure 1 analysis and figure 2 analysis

You can run the script to recreate all the figures. ideally run one line at a time.

ADDED FUNCTIONALITY
2 functions created. One runs the figure 1 analysis and the other runs the figure 2 analysis
    - Both functions can run analysis on any desired cognitive tests (last version only performed kdt analysis)
    - Both functions allow select whuch subjects to drop from analysis
    - Both functions now can automatically save and prints figures in .fig and .jpg formats


NOTES ON SUBJECTS AND DATA
there are some subjects that need to be dropped for some cognitive tests due to missing data
- for PVT data, drop subject 8
- for KDT Data, drop subject 7, there is no subject 12
- for Math data, drop subject 8, 5 and 10
- for GoNogo data, drop 5 ,7, and 8

when running the script, you will see that these subjects are dropped each time i run the analysis function
if you dont include this, the results will be scewed or, in the case of KDT, will cause an error because subject 12 has missing data file

I will eventually drop trim these subjects automatically un the Subjects Class to prevent hard coding and errors




OTHER NOTES
The entire set of analysis are saved in the see abstract png file on this folder
This analysis will continue to be updated and results posted on google drive for team to see.
furthermore

this took about 2 days to complete, 
with the help of javi and kanika who basically wrote the entire submitted abstract
althought some of my words are included as well
pretty happy about it









