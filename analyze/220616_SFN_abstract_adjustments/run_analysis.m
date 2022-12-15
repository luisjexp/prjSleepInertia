
% these are all the possible DVs
all_dv_names = {'gpsd', 'pathl', 'clust', 'betw', 'wpli'};

% Show you can replicate original pvt analysis, be sure to remove subject 8, do not save figures
% quickly show this, run all possible analysis at the same time
fig1analysis('PVT', {'gpsd', 'pathl', 'clust'}, 8, false) 
fig2analysis('PVT', {'gpsd', 'pathl', 'clust'},8, false) ;

% Run new pvt analysis, remove subject 8, do not save figures
% run one variable at a time
fig1analysis('PVT', {'betw'}, 8, false) 
fig1analysis('PVT', {'wpli'}, 8, false) 

fig2analysis('PVT', {'betw'},8, false) ; 
fig2analysis('PVT', {'wpli'},8, false) ; 



% Run new analysis using KDT, remove subject 7, sbj 12 has no data, also do not save figures
% run anlasyis one variable at a time
fig1analysis('KDT', {'gpsd'}, [7 12], false) 
fig1analysis('KDT', {'pathl'}, [7 12], false) 
fig1analysis('KDT', {'clust'}, [7 12], false) 
fig1analysis('KDT', {'betw'}, [7 12], false) 
fig1analysis('KDT', {'wpli'}, [7 12], false) 

fig2analysis('KDT', {'gpsd'},[7 12], false) ; 
fig2analysis('KDT', {'pathl'},[7 12], false) ; 
fig2analysis('KDT', {'clust'},[7 12], false) ; 
fig2analysis('KDT', {'betw'},[7 12], false) ; 
fig2analysis('KDT', {'wpli'},[7 12], false) ; 


% Run new analysis using  MATH | remove subject 5, 8, and 10 | and do not save figures
fig1analysis('Math', {'gpsd'}, [8 5 10], false) 
fig1analysis('Math', {'pathl'}, [8 5 10], false) 
fig1analysis('Math', {'clust'}, [8 5 10], false) 
fig1analysis('Math', {'betw'}, [8 5 10], false) 
fig1analysis('Math', {'wpli'}, [8 5 10], false) 


fig2analysis('Math', {'gpsd'}, [8 5 10], false) 
fig2analysis('Math', {'pathl'}, [8 5 10], false) 
fig2analysis('Math', {'clust'}, [8 5 10], false) 
fig2analysis('Math', {'betw'}, [8 5 10], false) 
fig2analysis('Math', {'wpli'}, [8 5 10], false) 




% Run GONO analysis remove subject 5, 7, and 8, and do not save figures
fig1analysis('GoNogo', {'gpsd'}, [5 7 8], false) 
fig1analysis('GoNogo', {'pathl'}, [5 7 8], false) 
fig1analysis('GoNogo', {'clust'}, [5 7 8], false) 
fig1analysis('GoNogo', {'betw'}, [5 7 8], false) 
fig1analysis('GoNogo', {'wpli'}, [5 7 8], false) 

fig2analysis('GoNogo', {'gpsd'}, [5 7 8], false) 
fig2analysis('GoNogo', {'pathl'}, [5 7 8], false) 
fig2analysis('GoNogo', {'clust'}, [5 7 8], false) 
fig2analysis('GoNogo', {'betw'}, [5 7 8], false) 
fig2analysis('GoNogo', {'wpli'}, [5 7 8], false) 

