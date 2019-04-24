function [Flow_rates_max,Flow_rates_min,Line_occupation_max,Line_occupation_min,Power_sets_max,Power_sets_min] = extrema_network_usage(test_case)
% Return the extramal conditions of network usage.
% 
% This function solves a pool market for maximal and minimal power exchanges, so it
% is equivalent to a DC optimal power flow with no line constraints. Then
% gives the resulting power flows.
% 
% For example, if producers can provide all consumers at their maximal
% consumption, it does a pool market with flexible producers and fixed
% consumers (at their maximal consumption).
% 
% 
% Input: 
%       - test_case: MATPOWER test case structure with flexible loads (set
%       as negative generators).
% 
% Output:
%       - Flow_rates_max: network power flows for the maximum market power
%       exchanges.
%       - Flow_rates_min: network power flows for the minimum market power
%       exchanges.
%       - Line_occupation_max: network power flows for the maximum market
%       power exchanges relative to line capacities, so equivalent to an
%       use rate.
%       - Line_occupation_min: network power flows for the maximum market
%       power exchanges relative to line capacities, so equivalent to an
%       use rate.
%       - Power_sets_max: power sets of agents (in same order as input
%       test_case) for maximum power exchanges.
%       - Power_sets_min: power sets of agents (in same order as input
%       test_case) for minimum power exchanges.
% 

%% Construct testcase for network use limit estimation
pf_casedata_max = test_case;
pf_casedata_min = test_case;
mpopt_case = mpoption('model', 'DC','out.all',0);

% No line limitations - then dc-opf is equivalent to the pool market
N_branches = size(test_case,1);
pf_casedata_max.branch(:,6) = Inf*ones(N_branches,1);
pf_casedata_min.branch(:,6) = Inf*ones(N_branches,1);

% Minimum/maximum consumption/production
prod = find(pf_casedata_min.gen(:,9)>0);
cons = find(pf_casedata_min.gen(:,10)<0);
max_prod=sum(pf_casedata_min.gen(prod,9));
min_prod=sum(pf_casedata_min.gen(prod,10));
max_cons=-sum(pf_casedata_min.gen(cons,10));
min_cons=-sum(pf_casedata_min.gen(cons,9));

%% Compute power flows for maximum network use
if max_prod>max_cons
    disp('Producers can provide maximum consumption')
    % consumers set at their maximum consumtion
    % dc-opf with fixed consumers
    pf_casedata_max.bus(pf_casedata_max.gen(cons,1),3) = pf_casedata_max.bus(cons,3) - pf_casedata_max.gen(cons,10);
    pf_casedata_max.gen = pf_casedata_max.gen(prod,:);
    pf_casedata_max.gencost = pf_casedata_max.gencost(prod,:);
    [pf_casedata_max, success_max] = runopf(pf_casedata_max,mpopt_case);
    case_max = 0;
elseif max_prod<max_cons
    disp('Producers can not provide maximum consumption')
    % producers set at their maximum production
    % dc-opf with fixed producers
    pf_casedata_max.bus(pf_casedata_max.gen(prod,1),3) = pf_casedata_max.bus(prod,3) - pf_casedata_max.gen(prod,9);
    pf_casedata_max.gen = pf_casedata_max.gen(cons,:);
    pf_casedata_max.gencost = pf_casedata_max.gencost(cons,:);
    [pf_casedata_max, success_max] = runopf(pf_casedata_max,mpopt_case);
    case_max = 1;
else
    disp('Maximum production equals maximum consumption')
    % both producers/consumers set at their maximum production/consumption
    % only power flow analysis needed
    pf_casedata_max.gen(prod,2) = pf_casedata_max.gen(prod,9);
    pf_casedata_max.gen(cons,2) = pf_casedata_max.gen(cons,10);
    [pf_casedata_max, success_max] = runpf(pf_casedata_max,mpopt_case);
    case_max = -1;
end

%% Compute power flows for minimum network use
if min_prod>min_cons
    disp('Minimum consumption is lower than lowest production')
    % producers set at their minimum consumtion
    % dc-opf with fixed producers
    pf_casedata_min.bus(pf_casedata_min.gen(prod,1),3) = pf_casedata_max.bus(prod,3) - pf_casedata_min.gen(prod,10);
    pf_casedata_min.gen = pf_casedata_min.gen(cons,:);
    pf_casedata_min.gencost = pf_casedata_min.gencost(cons,:);
    [pf_casedata_min, success_min] = runopf(pf_casedata_min,mpopt_case);
    case_min = 0;
elseif min_prod<min_cons
    disp('Minimum consumption is higher than lowest production')
    % consumers set at their minimum consumtion
    % dc-opf with fixed consumers
    pf_casedata_min.bus(pf_casedata_min.gen(cons,1),3) = pf_casedata_max.bus(cons,3) - pf_casedata_min.gen(cons,9);
    pf_casedata_min.gen = pf_casedata_min.gen(prod,:);
    pf_casedata_min.gencost = pf_casedata_min.gencost(prod,:);
    [pf_casedata_min, success_min] = runopf(pf_casedata_min,mpopt_case);
    case_min = 1;
else
    disp('Minimum consumption equals minimum production')
    % both producers/consumers set at their minimum production/consumption
    % only power flow analysis needed
    pf_casedata_min.gen(prod,2) = pf_casedata_min.gen(prod,10);
    pf_casedata_min.gen(cons,2) = pf_casedata_min.gen(cons,9);
    [pf_casedata_min, success_min] = runpf(pf_casedata_min,mpopt_case);
    case_min = -1;
end

%% Extract results
if success_max && success_min
    %printpf(results);
    Flow_rates_max = pf_casedata_max.branch(:,14);
    Flow_rates_min = pf_casedata_min.branch(:,14);
    Line_occupation_max = abs(Flow_rates_max./test_case.branch(:,6));
    Line_occupation_min = abs(Flow_rates_min./test_case.branch(:,6));
    
    
    Power_sets_max = zeros(size(test_case.gen,1),1);
    Power_sets_min = Power_sets_max;
    if case_max==0
        Power_sets_max(prod) = pf_casedata_max.gen(:,2);
        Power_sets_max(cons) = test_case.gen(cons,10);
    elseif case_max==1
        Power_sets_max(cons) = pf_casedata_max.gen(:,2);
        Power_sets_max(prod) = test_case.gen(prod,9);
    else
        Power_sets_max = pf_casedata_max.gen(:,2);
    end
    if case_min==0
        Power_sets_min(cons) = pf_casedata_min.gen(:,2);
        Power_sets_min(prod) = test_case.gen(prod,10);
    elseif case_min==1
        Power_sets_min(prod) = pf_casedata_min.gen(:,2);
        Power_sets_min(cons) = test_case.gen(cons,9);
    else
        Power_sets_min = pf_casedata_min.gen(:,2);
    end
else
    error('Problem for one of the optimal power flow simulations');
end


