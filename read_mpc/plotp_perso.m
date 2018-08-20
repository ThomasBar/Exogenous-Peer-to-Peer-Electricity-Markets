function plotp_perso(testcase,branch_t,Power,Theta,Eta,k_last_CI,num_fig,non_flex,legend_p,subfull)
% 
% Inputs:
%   - testcase  : mpc structure
%   - branch_t  : Indicate the type branch flow (DC or AC)
%   - P_net     : Net power of all units (flexible and non flexible)
%   - T         : Voltage angles
%   - E         : Nodal prices
%   - k_last_CI : Last iteration
%   - num_fig   : Figure number base (not to overwrite other results)
%                 (default: 10)
%   - non_flex  : true  - plot non-flexible units
%                 false - do not plot non-flexible units (default) 
%   - legend_p  : true  - with Agents and Nodes legend
%                 false - without legends (default) 
%   - subfull   : 0 - only subplots (default)
%                 1 - only full plots
%                 2 - both
% 

% Default values
if nargin<7
    num_fig = 10;
end
if nargin<8
    non_flex = false;
end
if nargin<9
    legend_p = false;
end
if nargin<10
    subfull = 0;
end

% Network data
[nodes,ref_node,n_units,Pmin,Pmax,a,b,...
    units_node,node_units,branch_conn,branch_B,branch_G,branch_max,bus_area] = ...
    read_mpc_case(testcase,branch_t);
n_agents = sum(Pmin~=Pmax);         % Number of agents in the test case
producers = find(Pmax>0)';
consumers = find(Pmin<0)';
n_prod = length ( producers );
n_cons = length ( consumers );
agents =[ producers , consumers ];
n_agents = length ( agents );
n_nodes = length(nodes);

if non_flex
    n_agents = n_units;
end

% Plots
if subfull==0 || subfull==2
    figure(num_fig)
    subplot(2,2,1)
    legends = cell(n_agents,1);
    for n =1:n_agents
        plot(1:k_last_CI,Power(n,1:k_last_CI))
        hold on
        if Power(n,k_last_CI)>0
            legends{n} = strcat('producer',num2str(n));
        else
            legends{n} = strcat('consumer',num2str(n));
        end
    end
    
    if legend_p
        legend(legends)
    end
    % ylim([-600 600])
    title('Generations and Loads through iterations')
    xlabel('iterations')
    ylabel('Active power (MW)')


    subplot(2,2,3:4)
    legends = cell(n_nodes,1);
    for i =nodes
        plot(1:k_last_CI,Eta(i,1:k_last_CI))
        hold on
        legends{i} = strcat('Node',num2str(i));
    end
    
    if legend_p
        legend(legends)
    end
    title('Nodal prices through iterations')
    xlabel('iterations')
    ylabel('Nodal price (€/MW)')

    subplot(2,2,2)
    for i =nodes
        plot(1:k_last_CI,Theta(i,1:k_last_CI))
        hold on
        legends{i} = strcat('Node',num2str(i));
    end
    
    if legend_p
        legend(legends)
    end
    title('Voltage angles through iterations')
    xlabel('iterations')
    ylabel('Voltage angle (deg)')
end



if subfull==1 || subfull==2
    figure(num_fig+1)
    legends = cell(n_agents,1);
    for n =1:n_agents
        plot(1:k_last_CI,Power(n,1:k_last_CI))
        hold on
        if Power(n,k_last_CI)>0
            legends{n} = strcat('producer',num2str(n));
        else
            legends{n} = strcat('consumer',num2str(n));
        end
    end
    
    if legend_p
        legend(legends)
    end
    % ylim([-600 600])
    title('Generations and Loads through iterations')
    xlabel('iterations')
    ylabel('Active power (MW)')


    figure(num_fig+2)
    legends = cell(n_nodes,1);
    for i =nodes
        plot(1:k_last_CI,Eta(i,1:k_last_CI))
        hold on
        legends{i} = strcat('Node',num2str(i));
    end
    
    if legend_p
        legend(legends)
    end
    title('Nodal prices through iterations')
    xlabel('iterations')
    ylabel('Nodal price (€/MW)')

    figure(num_fig+3)
    for i =nodes
        plot(1:k_last_CI,Theta(i,1:k_last_CI))
        hold on
        legends{i} = strcat('Node',num2str(i));
    end
    
    if legend_p
        legend(legends)
    end
    title('Voltage angles through iterations')
    xlabel('iterations')
    ylabel('Voltage angle (deg)')
end

