function [nodes,ref_node,n_units,units_Pmin,units_Pmax,units_a,units_b,units_node,node_units,branch_conn,branch_B,branch_G,branch_max,bus_area] = read_mpc_case(case_fct,opf_type)

%% Charge test case charateristics
mpc = case_fct;

%% Adapt data according to opf_type
if opf_type=='DC'
    
    % Global data
        % number of buses
        [n_nodes size_mpc_bus] = size(mpc.bus);
        
        % set of buses
        nodes = 1:n_nodes;
        
        % buses area
        bus_area = mpc.bus(:,7);
        
        % reference bus
        ref_node = find(mpc.bus(:,2)==3);
        
        % generators (and flexible loads as negative power generators)
        generators = find(mpc.gen(:,2)~=0);
        n_gens = length(generators);
        
        % Power demand (non-flexible) on buses
        Pd = mpc.bus(:,3);
    
    % Generators data
        % gen power boundaries
        gen_Pmin = mpc.gen(generators,10);
        gen_Pmax = mpc.gen(generators,9);
        
        % gen quadratic coefficient
        if ismember(1,mpc.gencost(generators,1))
            error('Non-polynomial cost function')
        elseif ~ismember(3,mpc.gencost(generators,4))
            error('Non-quadratic cost function')
        else
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            % MATPOWER and PC-MBED (and NEMBED) algorithms do not consider the same
            % definition of quadratic function !
            % So a^{PC-MBED} = 2*a^{MATPOWER};
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            gen_a = 2*mpc.gencost(generators,5);
            gen_b = mpc.gencost(generators,6);
        end
        
        % gen's bus
        gen_node = cell(n_gens,1);
        for n=1:n_gens
            gen_node{n} = mpc.gen(generators(n),1);
        end 
    
    % Units data - grouping generators and power demand
        n_units = n_gens + n_nodes;
        
        units_Pmin = zeros(n_units,1);
        units_Pmax = zeros(n_units,1);
        units_a = zeros(n_units,1);
        units_b = zeros(n_units,1);
        
        % flexible units
        units_Pmin(1:n_gens) = gen_Pmin;
        units_Pmax(1:n_gens) = gen_Pmax;
        units_a(1:n_gens) = gen_a;
        units_b(1:n_gens) = gen_b;
        % non-flexible units (as fiwed power demand)
        units_Pmin((n_gens+1):end) = -Pd;
        units_Pmax((n_gens+1):end) = -Pd;
        
        % unit's bus
        units_node = cell(n_units,1);
        for i=1:n_gens
            % flexible units
            units_node{i} = gen_node{i};
        end
        for i=nodes
            % non-flexible units (as fixed power demand)
            units_node{i+n_gens} = i; 
        end
        
    % Nodes data        
        % units at node
        node_units = cell ( n_nodes ,1);
        for i=nodes
           node_units{i} = [];

           for n=1:n_units
              if units_node{n}==i
                  node_units{i} = [node_units{i}, n];
              end       
           end
        end
        
        
    % Branches data
        % number of branches
        n_branch = length(mpc.branch(:,1));
        
        % lines capacity (arbitrary since not specified in IEEE case)
        branch_max = zeros( n_nodes );
        for l=1:n_branch
            if mpc.branch(l,6)~=0
                branch_max(mpc.branch(l,1),mpc.branch(l,2)) = mpc.branch(l,6);
            else
                branch_max(mpc.branch(l,1),mpc.branch(l,2)) = 100000;
            end
        end
        branch_max = branch_max + branch_max';
        
        % branch's connections
        branch_conn = cell ( n_nodes ,1);
        for i=nodes
           branch_conn{i} = [];
           for j=nodes
              if branch_max(i,j)~=0
                  branch_conn{i} = [branch_conn{i}, j];
              end       
           end    
        end
        
        
        % branches conductance & suceptance
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % In Kargarian (2016) Toward distributed-decentralized DC optimal power flow implementation in future electric power systems
        % -- based on Wood et al (2014) Power Generation, Operation and Control --
        % and MATPOWER
        % do not have the same branch model !
        %
        % In MATPOWER branch shunt impedance corresponds to half of the one in Wood et al (2014)
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        bus_admitt = makeYbus(mpc);
        
        branch_G = zeros(n_nodes,n_nodes);
        branch_B = zeros(n_nodes,n_nodes);
        for i=nodes
            for j=nodes
                branch_G(i,j) = real(bus_admitt(i,j));
                branch_B(i,j) = imag(bus_admitt(i,j));
            end
        end
        
        branch_B = 2.* branch_B;
        branch_G = 2.* branch_G;
        
    
elseif opf_type=='AC'
    
    
    
    
    
    
end






    