clear;
DFMASTER = dfmaster();  

clearvars -except DFMASTER   

%-- GPSD ~ Task + condition bands and runs
fig1anz(DFMASTER, 'gpsd');

%-- CLUSTERING ~ Task + condition bands and runs
fig1anz(DFMASTER, 'clust');

%-- PATHLENGTH ~ Task + condition bands and runs
fig1anz(DFMASTER, 'pathl');


