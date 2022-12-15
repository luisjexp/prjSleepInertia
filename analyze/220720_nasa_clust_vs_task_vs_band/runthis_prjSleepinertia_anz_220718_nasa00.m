% WARNING IGNORE THIS FILE AND FOLDER IN GENERAL, SEE README

% ###################
% Run this to replicate results used to present in meeting with javi and
% kanika on july 20 2022 in prep for nasa presentation
% 
% Engagement in different tasks immediately after abrupt awakening uniquely
% impacts clustering in delta and beta bands
% 
% 
% Delta band clustering
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

clear;
DFMASTER = dfgenerate();  


hyptest_nasa00(DFMASTER, 'delta')
hyptest_nasa00(DFMASTER, 'beta')





