%%

DFMASTER = dfgenerate();

%%
hyptest_sfn01(DFMASTER)

%%
[wpli,betw,pathl,eff,~,~,~, ~, clust] = getnetwork('PVT');

A = wpli.delta{1}(:,:,1)
%%
G = graph(A)

close all
plot(G)
figure(gcf)