function distances = distance_Nodal_price(test_case,Nodal_price)
% Convert |Zthev| distances between nodes into distances between agents
% 
% Inputs: - Nodal_price: nodal prices of DC-NEMBED (with len_avg=150 it and
%                        t_offset_avg=9000 it)
% 
% Returns a matrix of dimension n_agent * n_agents
% 
mpc = test_case;
[nodes,ref_node,n_units,Pmin,Pmax,a,b,units_node] = read_mpc_case(mpc,'DC');
n_agents = size(mpc.gen,1);

% Select the corresponding nodes distance to obtain agents distance
distances = zeros(n_agents);

for n=1:n_agents
    for m=1:n_agents
        distances(n,m) = Nodal_price(units_node{n}) + Nodal_price(units_node{m});
        distances(m,n) = distances(n,m);
    end
end


