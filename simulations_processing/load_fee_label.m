function Fees=load_fee_label(type_fee)

if ~iscell(type_fee)
    error('type_fee variable should be a cell vector')
end
n_fee = length(type_fee);
Fees = cell(n_fee,1);
Colors = 'rbgmcyk';
for f=1:n_fee
    if type_fee{f}=='free'
        Fees{f}.type = 'Free Market';
        Fees{f}.unit = '';
        Fees{f}.label = 'Free';
        Fees{f}.N_tests = 1;
        Fees{f}.n_tests_start = 1;
        Fees{f}.n_tests_stop = Fees{f}.n_tests_start+Fees{f}.N_tests-1;
        Fees{f}.color = Colors(f);
        Fees{f}.legend = 'Without network fee';
    elseif type_fee{f}=='uniq'
        Fees{f}.type = 'Unique Transmission Price';
        Fees{f}.unit = 'euro/MW';
        Fees{f}.label = 'UTP';
        Fees{f}.N_tests = 65; % 80 max
        Fees{f}.n_tests_start = 1;
        Fees{f}.n_tests_stop = Fees{f}.n_tests_start+Fees{f}.N_tests-1;
        Fees{f}.color = Colors(f);
        Fees{f}.legend = 'Unique network fee';
        Fees{f}.legend2 = 'u^{\rm uniq}';
    elseif type_fee{f}=='dist'
        Fees{f}.type = 'Distance Transmission Price - PTD';
        Fees{f}.unit = 'euro/MW';
        Fees{f}.label = 'PTD';
        Fees{f}.N_tests = 65; % 80 max
        Fees{f}.n_tests_start = 1;
        Fees{f}.n_tests_stop = Fees{f}.n_tests_start+Fees{f}.N_tests-1;
        Fees{f}.color = Colors(f);
        Fees{f}.legend = 'Electrical distance network fee';
        Fees{f}.legend2 = 'u^{\rm dist}';
    elseif type_fee{f}=='zona'
        Fees{f}.type = 'Uniform Zonal Transmission Price - ZTD';
        Fees{f}.unit = 'euro/MW/zone';
        Fees{f}.label = 'ZTP';
        Fees{f}.N_tests = 65; % 80 max
        Fees{f}.n_tests_start = 1;
        Fees{f}.n_tests_stop = Fees{f}.n_tests_start+Fees{f}.N_tests-1;
        Fees{f}.color = Colors(f);
        Fees{f}.legend = 'Uniform zonal network fee';
        Fees{f}.legend2 = 'u^{\rm zone}';
    elseif type_fee{f}=='noda'
        Fees{f}.type = 'Nodal Transmission Price - NTD';
        Fees{f}.unit = 'euro/MW';
        Fees{f}.label = 'NTP';
        Fees{f}.N_tests = 10;
        Fees{f}.n_tests_start = 1;
        Fees{f}.n_tests_stop = Fees{f}.n_tests_start+Fees{f}.N_tests-1;
        Fees{f}.color = Colors(f);
        Fees{f}.legend = 'Nodal network fee';
        Fees{f}.legend2 = 'u^\rm {node}';
        error('Network fee type not evailable yet!')
    else
        error('Wrong network fee type!')
    end
end