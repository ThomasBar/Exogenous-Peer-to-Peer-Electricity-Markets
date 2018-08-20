clc;
clearvars ;
close all;
%% Which network fee type?
type = 'free';


N_tests = 51;
n_tests_start = 1;
n_tests_stop = n_tests_start+N_tests-1;



if type=='free'
    Fees.type = 'Free Market';
    Fees.unit = '';
    Fees.label = 'Free';
    N_tests = 1;
    n_tests_start = 1;
    n_tests_stop = n_tests_start+N_tests-1;
elseif type=='uniq'
    Fees.type = 'Unique Transmission Price';
    Fees.unit = 'euro/MW';
    Fees.label = 'UTP';
elseif type=='dist'
    Fees.type = 'Distance Transmission Price - PTD';
    Fees.unit = 'euro/MW';
    Fees.label = 'PTD';
elseif type=='zona'
    Fees.type = 'Uniform Zonal Transmission Price - ZTD';
    Fees.unit = 'euro/MW/zone';
    Fees.label = 'ZTP';
elseif type=='noda'
    Fees.type = 'Nodal Transmission Price - NTD';
    Fees.unit = 'euro/MW';
    Fees.label = 'NTP';
    error('Network fee type not evailable yet!')
else
    error('Wrong network fee type!')
end

%% Market status
avg_price = zeros(N_tests,1);
objective = zeros(N_tests,1);
avg_network_fee = zeros(N_tests,1);
collected_fees = zeros(N_tests,1);
for test=n_tests_start:n_tests_stop
    load(strcat('simulations/results_',Fees.label,'_',num2str(test),'.mat'));
    
    P_nets = sum(results.P(:,:,results.k),2);
    ids = find(P_nets~=0)';
    
    prices = zeros(length(ids),1);
    objectives = zeros(length(ids),1); 
    for n=ids
        prices(n)=mean(results.Y(n,results.om{n},results.k));
    end
    avg_price(test) = mean(prices);
    
    net_fees = sum(results.gamma .* results.P(:,:,results.k),2);
    collected_fees(test) = mean(net_fees(ids));
    net_fees_prop = net_fees./P_nets;
    avg_network_fee(test) = mean(net_fees_prop(ids));
    
    objectives = 0.5*results.a.*P_nets.^2 + results.b.*P_nets + sum(results.gamma .* results.P(:,:,results.k),2);
    objective(test) = sum(objectives);
    
end

collected_fees_proportion_to_objective = abs(collected_fees./objective);

%% Values display
avg_price
% avg_network_fee
% objective
% collected_fees
% collected_fees_proportion_to_objective
