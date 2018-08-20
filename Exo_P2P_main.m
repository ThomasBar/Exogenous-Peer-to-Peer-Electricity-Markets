clc;
clearvars ;
% close all;
%% Definition of the agents and their costs/benefits
testcase = case39b_31a;

[nodes,ref_node,n_units,units_Pmin,units_Pmax,units_a,units_b,units_node,node_units,branch_conn,branch_B,branch_G,branch_max,bus_area] = read_mpc_case(testcase,'DC');

n_agents = n_units - length(nodes);
Pmin = units_Pmin(1:n_agents);
Pmax = units_Pmax(1:n_agents);
a = units_a(1:n_agents);
b = units_b(1:n_agents);
consumers = (find(Pmin<0))';   % No prosumers present
producers = (find(Pmax>0))';   % No prosumers present

% Definition of the negocation neigbourhoods
om= cell( n_agents ,1);
for n= producers
    om{n}= consumers ;
end
for n= consumers
    om{n}= producers ;
end

%% Network fees
N_tests = 1;
n_tests_start = 1;
n_tests_stop = n_tests_start+N_tests-1;

% gamma_free          % Free market
% gamma_unique        % Unique Transmission Price (UTP)
% gamma_distance      % Distance Transmission Price (DTP)
gamma_zonal         % Uniform Zonal Transmission Price (ZTP)


%% Definition of optimization parameters

% Maximum number of iterations before forced stop
max_it =10000;

% Definition of the optimization parameters
delta1 =1;
delta2 =0.01;
epsY =0.00001;
epsZ =0.00001;

rho =0.005 ./ power (1: max_it ,0.01) ;
alpha =0.01 ./ power (1: max_it ,0) ;
beta =0.01 ./ power (1: max_it ,0) ;
%% Simulation

for test=n_tests_start:n_tests_stop
    % Definition of the power and price vectors
    P= zeros ( n_agents , n_agents , max_it );
    Z= zeros ( n_agents , n_agents , max_it );
    Y= zeros ( n_agents , n_agents , max_it );
    Mup= zeros ( n_agents , max_it );
    Mum= zeros ( n_agents , max_it );
    
    % Test case's gamma
    gamma = gamma_base(:,:,test-n_tests_start+1);
    
    % C+I optimization
    Exo_P2P_CI_loop
    
    % Save results
    results.Yall = Y;
    results.Zall = Z;
    results.Pall = P;
    results.Mumall = Mum;
    results.Mupall = Mup;
    results.Y = Y(:,:,k_last_CI);
    results.Z = Z(:,:,k_last_CI);
    results.P = P(:,:,k_last_CI);
    results.Mum = Mum(:,k_last_CI);
    results.Mup = Mup(:,k_last_CI);
    results.gamma = gamma;
    results.gamma_base = gamma_base;
    results.Fees = Fees;
    results.current_network_fee = test;
    results.current_network_fee_what = 'index number in tested Fees array';
    results.testcase = testcase;
    results.n_agents = n_agents;
    results.a = a;
    results.b = b;
    results.Pmin = Pmin;
    results.Pmax = Pmax;
    results.consumers = consumers;
    results.producers = producers;
    results.om = om;
    results.k = k_last_CI;
    results.comptime = comptime;
    results.comptime_unit = 's';
    results.rho = rho;
%     addpath('simulations/old');
%     save(strcat('simulations/old/results_',Fees.label,'_',num2str(test),'.mat'),'results')
%     rmpath('simulations/old');
    results=rmfield(results,{'Pall','Zall','Yall','Mumall','Mupall'});
    save(strcat('simulations/results_',Fees.label,'_',num2str(test),'.mat'),'results');

    % Show results
    disp(strcat('Results of test case',{' '},num2str(test)))
    disp(strcat('Time to compute',{' '},num2str(comptime),'s'))
    %Powers = results{test}.P
    %Prices = results{test}.Y
end

