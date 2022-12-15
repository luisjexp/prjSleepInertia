% Algorithm Description
% Creating a Watts-Strogatz graph has two basic steps:
% 
% Create a ring lattice with $N$ nodes of mean degree $2K$. Each node is connected to its $K$ nearest neighbors on either side.
% 
% For each edge in the graph, rewire the target node with probability $\beta$. The rewired edge cannot be a duplicate or self-loop.
% 
% After the first step the graph is a perfect ring lattice. So when $\beta = 0$, no edges are rewired and the model returns a ring lattice. In contrast, when $\beta = 1$, all of the edges are rewired and the ring lattice is transformed into a random graph.
% 
% The file WattsStrogatz.m implements this graph algorithm for undirected graphs. The input parameters are N, K, and beta according to the algorithm description above.
% W
% View the file WattsStrogatz.m.


% Copyright 2015 The MathWorks, Inc.

function h = WattsStrogatz(N,K,beta)
% H = WattsStrogatz(N,K,beta) returns a Watts-Strogatz model graph with N
% nodes, N*K edges, mean node degree 2*K, and rewiring probability beta.
%
% beta = 0 is a ring lattice, and beta = 1 is a random graph.

% Connect each node to its K next and previous neighbors. This constructs
% indices for a ring lattice.
s = repelem((1:N)',1,K);
t = s + repmat(1:K,N,1);
t = mod(t-1,N)+1;

% Rewire the target node of each edge with probability beta
for source=1:N    
    switchEdge = rand(K, 1) < beta;
    
    newTargets = rand(N, 1);
    newTargets(source) = 0;
    newTargets(s(t==source)) = 0;
    newTargets(t(source, ~switchEdge)) = 0;
    
    [~, ind] = sort(newTargets, 'descend');
    t(source, switchEdge) = ind(1:nnz(switchEdge));
end

h = graph(s,t);
end