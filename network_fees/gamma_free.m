N_tests = 1;
n_tests_start = 1;
n_tests_stop = n_tests_start+N_tests-1;

gamma_base = zeros(n_agents,n_agents,N_tests); % Free market

Fees.type = 'Free Market';
Fees.unit = '';
Fees.tested = [0];
Fees.label = 'Free';
