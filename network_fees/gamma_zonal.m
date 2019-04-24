% network_fees = [0:4:40 45 50:10:100];
network_fees = [0:1:100];

% N_tests=length(network_fees);

gamma_base = zeros(n_agents,n_agents,N_tests);
gamma = zeros(n_agents);

dist_Zone = distance_Zone(testcase);   

for test=n_tests_start:n_tests_stop
    for n= producers
        gamma_base(n,om{n},test-n_tests_start+1)= network_fees(test)/2 * dist_Zone(n,om{n});
    end
    for n= consumers
        gamma_base(n,om{n},test-n_tests_start+1)= -network_fees(test)/2 * dist_Zone(n,om{n});
    end
end


Fees.type = 'Uniform Zonal Transmission Price - ZTD';
Fees.unit = 'euro/MW/zone';
Fees.tested = network_fees;
Fees.label = 'ZTP';