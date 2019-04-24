function PTDFs = read_mpc_case_PTDFs(test_case,overused)
% Returns the Power Transfer Distribution Factors (PTDF) of branches for a
% given single input bus and single output bus.
% 
% PTDFs is a 3D matrix such that PTDFs(n,m,j) is the PTDF of branch j for a
% flow from bus i to bus j -- with no power input/output from other buses.
% 

mpc = test_case;
nb_bus = size(mpc.bus,1);
nb_branch = size(mpc.branch,1);

PTDFs = zeros(nb_bus,nb_bus,nb_branch); % From_bus To_bus Branch_ptdf

for n=1:nb_bus
    factors = makePTDF(mpc,n);
    PTDFs(n,:,:)= factors';
end

for id_b=1:nb_branch
    PTDFs(mpc.branch(id_b,1),mpc.branch(id_b,2),id_b) = overused(mpc.branch(id_b,1),mpc.branch(id_b,2)) * PTDFs(mpc.branch(id_b,1),mpc.branch(id_b,2),id_b);
end

