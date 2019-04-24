% network_fees = [0:4:40 45 50:10:100];
network_fees = [0:1:100];

% N_tests=length(network_fees);

gamma_base = zeros(n_agents,n_agents,N_tests);
gamma = zeros(n_agents);

for test=n_tests_start:n_tests_stop
    for n= producers
        gamma_base(n,om{n},test-n_tests_start+1)= network_fees(test)/2 * ones(length(om{n}),1);
    end
    for n= consumers
        gamma_base(n,om{n},test-n_tests_start+1)= -network_fees(test)/2 * ones(length(om{n}),1);
    end
end


Fees.type = 'Unique Transmission Price';
Fees.unit = 'euro/MW';
Fees.tested = network_fees;
Fees.label = 'UTP';