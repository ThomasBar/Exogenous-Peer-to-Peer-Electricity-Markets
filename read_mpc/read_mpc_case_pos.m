function Positions = read_mpc_case_pos(case_fct)
% d_North   d_West

%% Charge test case charateristics
mpc = case_fct;

%% Read gen_pos
% d_North   d_West
Positions = mpc.genpos;


