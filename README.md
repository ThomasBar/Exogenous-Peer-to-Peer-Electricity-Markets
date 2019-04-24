# Exogenous Peer-to-peer solved with Consensus and Innovation

Steps to launch simulations:
 - Open MATLAB to the unzipped folder, add all folders and subfolders to the path
 - Open file ''Exo_main.m'';
 - Select the choosen options:
    - section ''Network fees'': to choose between free market, unique, distance or zone based network fees (uncomment the chosen one), also allow to select the range of unit fee parameter ''u'';
    - section ''Definition of optimization parameters'': to choose the different parameters such as rho, maximum number of iterations and whether stopping criteria are present;
 - Run simulations


Visualization of results:
 - Raw convergence results can be plot for each simulation in section ''Definition of optimization parameters'' by selecting the type of plot to be shown (5 options: 'raw_light', 'raw_full', 'res', 'all', 'none')
 - Light market analyses are available with file ''simulations_processing/market_processing.m''
 - Deeper analyses (ones presented in the paper) are available with file ''simulations_processing/network_fees_processing.m''
    - note that in such case the number of tests ''Fees{f}.N_tests'' indicated in file ''simulations_processing/load_fee_label.m'' must be lower or equal to the number of tests ''N_tests'' given for simulation in file ''Exo_main.m''

For any help contact: thomas.baroche@ens-rennes.fr
