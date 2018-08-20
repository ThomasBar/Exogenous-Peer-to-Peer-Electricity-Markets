network_fees = [0:1:100];

gamma_base = zeros(n_agents,n_agents,N_tests);
gamma = zeros(n_agents);

dist_PT = distance_PT(testcase);

for test=n_tests_start:n_tests_stop
    for n= producers
        gamma_base(n,om{n},test-n_tests_start+1)= network_fees(test)/2 * dist_PT(n,om{n});
    end
    for n= consumers
        gamma_base(n,om{n},test-n_tests_start+1)= -network_fees(test)/2 * dist_PT(n,om{n});
    end
end


Fees.type = 'Distance Transmission Price - PTD';
Fees.unit = 'euro/MW';
Fees.tested = network_fees;
Fees.label = 'PTD';