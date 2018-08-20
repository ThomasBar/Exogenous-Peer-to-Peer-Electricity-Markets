function distances = distance_Cart(test_case)
% Convert positions of agents into distances between agents
% 
% Returns a matrix of dimension n_agent * n_agents
% 
mpc = test_case;
Pos = read_mpc_case_pos(mpc);
n_agents = size(mpc.gen,1);
distances = zeros ( n_agents );
for i =1: n_agents
    for j =1: n_agents
        distances (i,j)= sqrt (( Pos(i ,1) -Pos(j ,1)) ^2 + ( Pos(i ,2) -Pos (j,2)) ^2);
    end
end
