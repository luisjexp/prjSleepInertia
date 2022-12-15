Started on July 5th


# Ideas and goals
for sfn abstract, we considered the idea that network properties on several variables.
basically wed like to characterize the 'state of the network' as a function of multiple factors.
Here is the idea writted in as a linear equation...

Network property ~ time + sleepInert + cogTest + frequency

where the Network Property ∈ {power, clustering, path length}

thus the goal here is to simple generate a data fram that allows for this modeling.



# UPDATES
created a data frame that contains a value for each possible combination of factors: 
- nework property X cogntive test X run  X Condition X frequency X subject Id

BUG FIXES
i changed the GPSD and NETWORK outputs to contain subject Identifiers 
    - i also made the data frame to have this info.
    - this is key to avoid errors since subjects have different index positions in different cognitive tests
    - for example, subject 4 in the KDT task is subject 3 in PVT task. 

there seems to be an issue in computing wpli
    - the dataframe i generate doesnt reproduce the analysis created by the figure1 function
    - this may be due to issues in averaging accross *pairs* of channels (its an adjaceny matrix i beleive)
    - need to check this, and also check eff variable, and other variables with an adjanceny structire
    - so i removed the analysis in the figure1 and figure two functions
    - and also the results for wpli from the main figures on the shared google doc (there were only a few)

# TO DO
although this can wait, id aslo like to add a variable that tells me the value at each channel.
currently all values are computed by averaging accross channels
this may take a while to do however 

