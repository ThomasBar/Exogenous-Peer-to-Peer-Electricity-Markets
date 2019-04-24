function Zthev_norm = read_mpc_case_Zthev(case_fct,overused)
% Returns the Zthev distances between each connected nodes
% Zthev_norm is a square matrix of the same size than Ybus and Zbus

%% Charge test case charateristics
mpc = case_fct;

%% Get Ybus
bus_admitt = makeYbus(mpc);

%% Calculate Zthev
n_bus = size(bus_admitt,1);

Zthev = zeros(n_bus);

if nargin==1
    overused=ones(n_bus);
end

for n=1:n_bus
    for m=n:n_bus
        if bus_admitt(n,m)~=0
            Zthev(n,m) = 1/bus_admitt(n,n) + 1/bus_admitt(m,m) - 1/bus_admitt(n,m) - 1/bus_admitt(m,n);
            Zthev(n,m) = overused(n,m)*Zthev(n,m);
            Zthev(m,n) = Zthev(n,m);
        end
    end
end

Zthev_norm = abs(Zthev);