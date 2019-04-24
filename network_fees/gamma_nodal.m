% network_fees = [0:4:40 45 50:10:100];
% 
% gamma_base = zeros(n_agents,n_agents,N_tests);
% gamma = zeros(n_agents);
% 
% dist_Zone = distance_Zone(testcase);   
% 
% for test=1:N_tests
%     for n= producers
%         gamma_base(n,om{n},test)= network_fees(test)/2 * dist_Zone(n,om{n});
%     end
%     for n= consumers
%         gamma_base(n,om{n},test)= -network_fees(test)/2 * dist_Zone(n,om{n});
%     end
% end


Fees.type = 'Nodal Transmission Price - NTD';
Fees.unit = 'euro/MW';
Fees.tested = network_fees;
Fees.label = 'NTP';