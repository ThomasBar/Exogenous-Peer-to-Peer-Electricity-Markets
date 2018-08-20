function dist_PT = read_mpc_case_dist_PT(test_case,overused)
% Returns the Power Transfer Distance (PT) for all possible trades.
% 
% dist_PT is a 2D matrix such that dist_PT(i,j) is the PT distance
% from node i to node j --
% since there is an absolute value dist_PT is symmetric.
% 

if nargin<2
    nb_bus = size(test_case.bus,1);
    overused = ones(nb_bus,nb_bus);
end

% Get all PTDFs
PTDFs = read_mpc_case_PTDFs(test_case,overused);

% Set absolutes
PTDFs = abs(PTDFs);

% Calculate al PT distances
nb_bus = size(PTDFs,1);
dist_PT = zeros(nb_bus);

for i=1:nb_bus
    for j=1:nb_bus
        dist_PT(i,j) = sum(PTDFs(i,j,:));
    end
end





