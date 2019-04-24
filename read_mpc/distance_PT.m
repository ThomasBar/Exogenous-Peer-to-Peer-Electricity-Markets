function distances = distance_PT(test_case,overused)
% Convert |Zthev| distances between nodes into distances between agents
% 
% Returns a matrix of dimension n_agent * n_agents
% 
mpc = test_case;
n_agents = size(mpc.gen,1);


if nargin<2
    nb_bus = size(mpc.bus,1);
    overused = ones(nb_bus,nb_bus);
end

% Get distances
dist_PT = read_mpc_case_dist_PT(mpc,overused);

% Get node on which agents are connected
agents_node = mpc.gen(:,1);


% Select the corresponding nodes distance to obtain agents distance
distances = zeros(n_agents);

for n=1:n_agents
    for m=1:n_agents
        distances(n,m) = dist_PT(agents_node(n),agents_node(m));
    end
end


