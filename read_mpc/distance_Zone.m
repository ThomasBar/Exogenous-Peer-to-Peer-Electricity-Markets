function transportation_price = distance_Zone(test_case,area_price)
% Return the distance between each agents using Zone distance.
% 
% Works only for the case39b_31a test case.
% 
% Zone price = 0
% Zone price between connected zones = 1
% Zone price between indirectly connected zones = 2
% 

if nargin < 1
    mpc = case39b_31a;
else
    mpc = test_case;
end

n_agents = size(mpc.gen,1);

% Get agents zone
agents_node = mpc.gen(:,1); % node on which agents are connected
bus_area = mpc.bus(:,7);    % buses area


% Set zones distances
nb_area = max(bus_area);

%uniform zone price
if nargin < 2
    area_price = ones(nb_area,1);
end


% Get paths
overused = ones(size(mpc.branch,1));
[dist_Zthev, paths] = read_mpc_case_dist_Zthev(mpc,overused);
    
    
    

% Set agents distances
transportation_price = zeros(n_agents);

for n=1:n_agents
    for m=1:n_agents
        % Path zones
        path_zones = bus_area(paths{agents_node(n),agents_node(m)});

        % Single out crossed zones
        path_zones = sort(path_zones);
        zones = [path_zones(1)];
        for zo=2:length(path_zones)
            if path_zones(zo) > zones(end)
                zones = [zones, path_zones(zo)];
            end
        end
        
        transportation_price(n,m) = sum(area_price(zones));
    end
end






