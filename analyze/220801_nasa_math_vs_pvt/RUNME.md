# The impact of Cognitive Tasks on Network Properties after abrupt awakening
# Summary


Interestingly the network appears to change in opposite ways accross multiple dimensions



   -  the frequency band that changes - upper or lower 
   -  the onset time of the change in the network - either network property is immediately effected or delayed 
   -  the duration of change in the network- either for a single test bout, or extended 



Notice that during the PV Task, the DELTA network is impacted immediately and temporaly after waking. Namely, clustering increases and path length decreases at time 1, but recovers quickly by time 2.




In contras during the Math Task, it is the BETA network that changes, and this change is not immediate and does not appear to recover. Namely, clustering increases and path length decreases during the seccond, third and fourth test bout.


# Get Data Set

```matlab:Code
clear;
DFM = dfmaster();  
```


```text:Output
##########
Getting GPSD during PVT Task. . . . . . . . . . . . 
	DONE

##########
Getting Network Props during PVT : . . . . . . . . . . . . 
	done
##########
Getting GPSD during KDT Task. . . . . . . . . . . 
	DONE

##########
Getting Network Props during KDT : . . . . . . . . . . . 
	done
##########
Getting GPSD during MATH Task. . . . . . . . . . . . 
	DONE

##########
Getting Network Props during MATH : . . . . . . . . . . . . 
	done
##########
Getting GPSD during GONOGO Task. . . . . . . . . . . . 
	DONE

##########
Getting Network Props during GONOGO : . . . . . . . . . . . . 
	done
```


```matlab:Code
clearvars -except DFM   
close all
```

# CLUSTERING and PATH LENGTH of LOW FREQUENCIES
## Low frequency components change only while engaging in PVT task. 

   -  Notice that during the PV Task, the DELTA network is impacted immediately and temporaly after waking.  
   -  Namely, clustering increases and path length decreases at time 1, but recovers quickly by time 2. 
   -  further more, the DELTA network remains unnaffected while engagin in the math task 


```matlab:Code
figanz_cogtestcmp(DFM, 'PVT', 'Math', 'clust', 'delta', 'control')
exportgraphics(gcf,'fig_clust_pvt_vs_math_beta_cntl.png','Resolution',100)
```


![/home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_0.png
](RUNME_images//home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_0.png
)


```matlab:Code
figanz_cogtestcmp(DFM, 'PVT', 'Math', 'pathl', 'delta', 'control')
exportgraphics(gcf,'fig_clust_pvt_vs_math_delta_cntl.png','Resolution',100)
```


![/home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_1.png
](RUNME_images//home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_1.png
)

# CLUSTERING and PATH LENGTH of HIGH FREQUENCIES
## High frequency networl components change only while engaging in Math task. 

   -  Notice that during the Math Task, it is the BETA network that changes 
   -  Namely, clustering increases and path length decreases  
   -  Note that unlike the lower frequency, this change is not immediate nor does it recover by the fourth test bout.  
   -  Further more, these effects are only visible while engaging in the MATH task 

### Compare the Low and hight fequency componenets

\hfill \break


```matlab:Code
figanz_cogtestcmp(DFM, 'PVT', 'Math', 'clust', 'beta', 'control')
exportgraphics(gcf,'fig_pathl_pvt_vs_math_beta_cntl.png','Resolution',100)
```


![/home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_2.png
](RUNME_images//home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_2.png
)


```matlab:Code

figanz_cogtestcmp(DFM, 'PVT', 'Math', 'pathl', 'beta', 'control')
exportgraphics(gcf,'fig_pathl_pvt_vs_math_beta_cntl.png','Resolution',100)
```


![/home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_3.png
](RUNME_images//home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_3.png
)

# Supplementary Figures: Original figure 1 analysis, but for all tasks. Ignore for now

```matlab:Code
fig1anz(DFM, 'gpsd')
exportgraphics(gcf,'fig_fig1Original_gpsd.png','Resolution',100)
```


![/home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_4.png
](RUNME_images//home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_4.png
)


```matlab:Code

fig1anz(DFM, 'clust')
exportgraphics(gcf,'fig_fig1Original_clust.png','Resolution',100)
```


![/home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_5.png
](RUNME_images//home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_5.png
)


```matlab:Code

fig1anz(DFM, 'pathl')
exportgraphics(gcf,'fig_fig1Original_pathl.png','Resolution',100)
```


![/home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_6.png
](RUNME_images//home/luis/Dropbox/DEVCOM/prjSleepinertia/analyze/220801_nasa_math_vs_pvt/RUNME_images/figure_6.png
)

