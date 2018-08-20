# Exogenous Peer-to-peer solved with Consensus and Innovation

Steps to launch simulation:
 - Open MATLAB to the unzipped folder and add subfolders to the path
 - Open file ''Exo_P2P_main.m'';
 - Select the choosen options:
    - section ''Network fees'': to choose between free market, unique, distance or zone based network fees (uncomment the chosen one), also allow to select the range of network fee parameter ''u'';
    - section ''Optimization parameters'': to choose the different parameters such as alpha, beta, rho, delta, tau and stopping criterion;
 - Run simulation


Visualization of results:
 - Raw convergence results can be plot when section ''Plots'' of file ''Exo_P2P_CI_loop.m'' is uncommented
 - Light market analyses are available with file ''simulations_processing/market_processing.m''
 - Deeper analyses are available with file ''simulations_processing/network_fees_processing.m''
    - note that in such case the number of tests ''Fees{f}.N_tests'' indicated in file ''simulations_processing/load_fee_label.m'' must be lower or equal to the number of tests ''N_tests'' given for simulation in file ''Exo_P2P_main.m''

For any help contact: thomas.baroche@ens-rennes.fr