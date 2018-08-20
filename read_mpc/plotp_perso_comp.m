function plotp_perso_comp(testcase,branch_t,Power,Theta,Eta,k_last_CI,num_fig,percent,res_tot,legend_p,non_flex)
% 
% Inputs:
%   - testcase  : mpc structure
%   - branch_t  : Indicate the type branch flow (DC or AC)
%   - P_net     : Net power of all units (flexible and non flexible)
%   - T         : Voltage angles
%   - E         : Nodal prices
%   - k_last_CI : Last iteration
%   - num_fig   : Figure number base (not to overwrite other results)
%                 (default: 100)
%   - percent   : 0 - absolute residuals (default)
%                 1 - relative residuals
%                 2 - both
%   - res_tot   : 0 - total residual (default)
%                 1 - partial residuals (per node and per agent)
%                 2 - both
%   - legend_p  : true  - with Agents and Nodes legend
%                 false - without legends (default) 
%   - non_flex  : true  - plot non-flexible units
%                 false - do not plot non-flexible units (default) 
% 

% Default values
if nargin<7
    num_fig = 100;
end
if nargin<8
    percent = 0;
end
if nargin<9
    res_tot = 0;
end
if nargin<10
    legend_p = false;
end
if nargin<11
    non_flex = false;
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
agents =[ consumers , producers ];
n_agents = length ( agents );
n_nodes = length(nodes);




% run power flow (DC or AC)
opf_result = testcase;
mpopt_case = mpoption('model', branch_t,'out.all',0);
[opf_result, success] = runopf(opf_result,mpopt_case);

if success
    %         printpf(results);
    if non_flex
        n_agents = n_units;
    end
    
    % optimal values
    Power_opt = zeros(n_agents,1);
    Power_opt(agents) = opf_result.gen(:,2);
    Price_opt = opf_result.bus(:,14);
    Theta_opt = opf_result.bus(:,9);

    
    
    % Plots -- total residuals
    if percent==0 || percent==2 
        % residuals
        Power_res = zeros(n_agents,k_last_CI);
        legends_ag = cell(n_agents,1);
        for n =1:n_agents
            Power_res(n,:) = abs(Power(n,1:k_last_CI) - Power_opt(n).*ones(1,k_last_CI));
            if Power(n,k_last_CI)>0
                legends_ag{n} = strcat('producer',num2str(n));
            else
                legends_ag{n} = strcat('consumer',num2str(n));
            end
        end
        Theta_res = zeros(n_nodes,k_last_CI);
        Price_res = zeros(n_nodes,k_last_CI);
        legends_bus = cell(n_nodes,1);
        for i =nodes
            Theta_res(i,:) = abs(Theta(i,1:k_last_CI) - Theta_opt(i).*ones(1,k_last_CI));
            Price_res(i,:) = abs(Eta(i,1:k_last_CI) - Price_opt(i).*ones(1,k_last_CI));
            legends_bus{i} = strcat('Node',num2str(i));
        end
        
        Power_res_tot = sum(Power_res,1);
        Theta_res_tot = sum(Theta_res,1);
        Price_res_tot = sum(Price_res,1);
        
        
        
        if res_tot==0 || res_tot==2
            figure(num_fig+5)
            plot(1:k_last_CI,Power_res_tot)
            hold on
            plot(1:k_last_CI,Theta_res_tot)
            hold on
%             plot(1:k_last_CI,Price_res_tot)
%             hold on
            legend('Active power residual','Voltage angle residual');%,'Price residual')
            title('Absolute residuals')
            xlabel('iterations')
            ylabel('Absolute residual')
        end
        
        if res_tot==1 || res_tot==2
            figure(num_fig+10)
                for n =1:n_agents
                    plot(1:k_last_CI,Power_res(n,:))
                    hold on
                end
                if legend_p
                    legend(legends)
                end
            title('Active power residuals')
            xlabel('iterations')
            ylabel('Absolute residual (MW)')

            figure(num_fig+11)
                for i =nodes
                    plot(1:k_last_CI,Theta_res(i,:))
                    hold on
                end
                if legend_p
                    legend(legends)
                end
            title('Voltage angle residuals')
            xlabel('iterations')
            ylabel('Absolute residual (deg)')


            figure(num_fig+12)
                for i =nodes
                    plot(1:k_last_CI,Price_res(i,:))
                    hold on
                end
                if legend_p
                    legend(legends)
                end
            title('Nodal price residuals')
            xlabel('iterations')
            ylabel('Absolute residual (€/MW)')
        end
    end
    
    
    
    
       
    % Plots -- total residuals
    if percent==1 || percent==2 
        % residuals
        Power_res = zeros(n_agents,k_last_CI);
        legends_ag = cell(n_agents,1);
        for n =1:n_agents
            Power_res(n,:) = 100.*abs((Power(n,1:k_last_CI) - Power_opt(n).*ones(1,k_last_CI))./(Power_opt(n).*ones(1,k_last_CI)));
            if Power(n,k_last_CI)>0
                legends_ag{n} = strcat('producer',num2str(n));
            else
                legends_ag{n} = strcat('consumer',num2str(n));
            end
        end
        Theta_res = zeros(n_nodes,k_last_CI);
        Price_res = zeros(n_nodes,k_last_CI);
        legends_bus = cell(n_nodes,1);
        for i =nodes
            if i~=ref_node
                Theta_res(i,:) = 100.*abs((Theta(i,1:k_last_CI) - Theta_opt(i).*ones(1,k_last_CI))./(Theta_opt(i).*ones(1,k_last_CI)));
            end
            Price_res(i,:) = 100.*abs((Eta(i,1:k_last_CI) - Price_opt(i).*ones(1,k_last_CI))./(Price_opt(i).*ones(1,k_last_CI)));
            legends_bus{i} = strcat('Node',num2str(i));
        end
        
        Power_res_tot = sum(Power_res,1);
        Theta_res_tot = sum(Theta_res,1);
        Price_res_tot = sum(Price_res,1);
        
        
        
        if res_tot==0 || res_tot==2
            figure(num_fig+6)
            plot(1:k_last_CI,Power_res_tot)
            hold on
            plot(1:k_last_CI,Theta_res_tot)
            hold on
%             plot(1:k_last_CI,Price_res_tot)
%             hold on
            legend('Active power residual','Voltage angle residual','Price residual')
            title('Relative residuals')
            xlabel('iterations')
            ylabel('Relative residual (%)')
        end
        
        if res_tot==1 || res_tot==2
            figure(num_fig+15)
                for n =1:n_agents
                    plot(1:k_last_CI,Power_res(n,:))
                    hold on
                end
                if legend_p
                    legend(legends)
                end
            title('Active power residuals')
            xlabel('iterations')
            ylabel('Relative residual (%)')

            figure(num_fig+16)
                for i =nodes
                    plot(1:k_last_CI,Theta_res(i,:))
                    hold on
                end
                if legend_p
                    legend(legends)
                end
            title('Voltage angle residuals')
            xlabel('iterations')
            ylabel('Relative residual (%)')


            figure(num_fig+17)
                for i =nodes
                    plot(1:k_last_CI,Price_res(i,:))
                    hold on
                end
                if legend_p
                    legend(legends)
                end
            title('Nodal price residuals')
            xlabel('iterations')
            ylabel('Relative residual (%)')
        end
    end
else
    error('pf pb');
end
















