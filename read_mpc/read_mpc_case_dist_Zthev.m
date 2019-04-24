function [dist_Zthev, paths] = read_mpc_case_dist_Zthev(case_fct,overused)
% Returns the shortest Zthev distances between every nodes (even those that
% are not directly connected)
% 
% dist_Zthev is a square matrix of a size equal to the number of agents
% (even gives the Zthev distances between producers and between consumers)
% 
% paths (optional) is a square cell array of the same size same dist_Zthev, 
% each cell contains the path followed to obtain the given shortest paths
% 
% 
% Uses dijkstra function by Joseph Kirk
% https://www.mathworks.com/matlabcentral/fileexchange/20025-dijkstra-s-minimum-cost-path-algorithm

if nargin<2
    nb_bus = size(case_fct.bus,1);
    overused = ones(nb_bus,nb_bus);
end

%% Get the Zthev distances between nodes
Zthev = read_mpc_case_Zthev(case_fct,overused);

%% Compute the shortest 
[dist_Zthev,paths] = dijkstra(Zthev>0,Zthev);


