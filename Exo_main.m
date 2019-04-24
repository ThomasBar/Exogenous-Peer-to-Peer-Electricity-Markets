clc;
clearvars ;
close all;
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

% a(consumers) = -a(consumers);
% b(consumers) = -b(consumers);

% Definition of the negocation neigbourhoods
om= cell( n_agents ,1);
Conn = zeros(n_agents);
for n= producers
    om{n}= consumers ;
    Conn(n,consumers) = ones(1,length(consumers));
end
for n= consumers
    om{n}= producers ;
    Conn(n,producers) = ones(1,length(producers));
end
Conn = logical(Conn);
%% Network fees
N_tests = 1;
n_tests_start = 1;
n_tests_stop = n_tests_start+N_tests-1;

gamma_free          % Free market
% gamma_unique        % Unique Transmission Price (UTP)
% gamma_distance      % Distance Transmission Price (DTP)
% gamma_zonal         % Uniform Zonal Transmission Price (ZTP)
% % % % % gamma_nodal         % Nodal Transmission Price (NTP)

%% Definition of optimization parameters
ADMM_opt.rho = 1;
ADMM_opt.maxit = 2000;
ADMM_opt.method = 'quadprog';
ADMM_opt.stopcrit = 'on';
ADMM_opt.espPrimR = 1e-3;
ADMM_opt.espDualR = 1e-3;
ADMM_opt.TradeBound = 'on';
ADMM_opt.Plot = 'all';

%% Simulation
for test=n_tests_start:n_tests_stop
    disp(strcat('Test case',{' '},num2str(test)))
    
    % Test case's gamma
    gamma = gamma_base(:,:,test-n_tests_start+1);
    
    % Opti algo
    [P,Y,success,flagout,raw] = QP_P2P_ADMM(a,b,Pmin,Pmax,Conn,gamma,[],ADMM_opt);
    
    % Save results
    results.Yall = raw.Y;
    results.Pall = raw.P;
    results.Mumall = raw.Mum;
    results.Mupall = raw.Mup;
    results.Y = Y;
    results.P = P;
    results.Mum = raw.Mum(:,raw.last_it);
    results.Mup = raw.Mup(:,raw.last_it);
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
    results.Conn = Conn;
    results.k = raw.last_it;
    results.comptime = raw.comptime;
    results.comptime_unit = 's';
    results.rho_ADMM = ADMM_opt.rho;
    addpath('simulations/old');
    save(strcat('simulations/old/results_',Fees.label,'_',num2str(test),'.mat'),'results')
    rmpath('simulations/old');
    results=rmfield(results,{'Pall','Yall','Mumall','Mupall'});
    save(strcat('simulations/results_',Fees.label,'_',num2str(test),'.mat'),'results');

    % Show results
    disp(strcat('Stopped after',{' '},num2str(raw.last_it),...
        ' iterations computed in',{' '},num2str(raw.comptime),'s'))
    disp(strcat('Primal and Dual residual:',{' '},...
        num2str(raw.PrimR(raw.last_it)),' and',{' '},num2str(raw.DualR(raw.last_it))))
    
end