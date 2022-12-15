% this is a sanity check for ensuring that your updated figure 1 analysis works and
% replicates the original analysis

% the function will first the analysis using the original figure1 function. This
% requires you to specify the SUBJECT INDECES THAT WILL BE REMOVED


% Next it will run the analysis using the updated, safer bersion of the figure1 function. This
% requires you to specify the SUBJECT INDENTIFIERS THAT WILL KEPT

% see the command window output to see if the validation worked
% it seems like it does, for all possible combinations of variables...
% try any that you like.

clear; clc;
cogtest     = 'KDT';
ntwpropname = {'GPSD'}; 
conditionname = 'light';
bandName = 'alpha'; 
ttesttype = 'paired';

fig1analysis_update_validation(ntwpropname, cogtest, conditionname,bandName, ttesttype)