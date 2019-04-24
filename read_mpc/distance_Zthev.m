function distances = distance_Zthev(test_case,overused)
% Convert |Zthev| distances between nodes into distances between agents
% 
% Returns a matrix of dimension n_agent * n_agents
% 
mpc = test_case;
n_agents = size(mpc.gen,1);
if nargin==1
    overused=ones(39);
end

% Get distances
dist_Zthev = read_mpc_case_dist_Zthev(mpc,overused);

% Get node on which agents are connected
agents_node = mpc.gen(:,1);


% Select the corresponding nodes distance to obtain agents distance
distances = zeros(n_agents);

for n=1:n_agents
    for m=1:n_agents
        distances(n,m) = dist_Zthev(agents_node(n),agents_node(m));
    end
end




