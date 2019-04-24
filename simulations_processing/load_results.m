function results=load_results(label,test)
% Load simulation results and verify results file size if necessary
%% Load test case
results = load(strcat('simulations/results_',label,'_',num2str(test),'.mat'));
results = results.results;
%% If results structure size not already reduced
reduced=0;
if length(size(results.P))==3
    results.Pall = results.P;
    results.P = results.Pall(:,:,results.k);
    reduced=1;
end
if length(size(results.P))~=2
    error('Problem of data input: P')
end
if length(size(results.P))==3
    results.Pall = results.P;
    results.P = results.Pall(:,:,results.k);
    reduced=1;
end
if length(size(results.P))~=2
    error('Problem of data input: Z')
end
if length(size(results.Y))==3
    results.Yall = results.Y;
    results.Y = results.Yall(:,:,results.k);
    reduced=1;
end
if length(size(results.Y))~=2
    error('Problem of data input: Y')
end
if size(results.Mum,2)~=1
    results.Mumall = results.Mum;
    results.Mum = results.Mumall(:,results.k);
    reduced=1;
end
if size(results.Mum,2)~=1
    error('Problem of data input: Mum')
end
if size(results.Mup,2)~=1
    results.Mupall = results.Mup;
    results.Mup = results.Mupall(:,results.k);
    reduced=1;
end
if size(results.Mup,2)~=1
    error('Problem of data input: Mup')
end
if reduced
    addpath('simulations/old');
    save(strcat('simulations/old/results_',label,'_',num2str(test),'.mat'),'results');
    rmpath('simulations/old');
    results=rmfield(results,{'Pall','Zall','Yall','Mumall','Mupall'});
    save(strcat('simulations/results_',label,'_',num2str(test),'.mat'),'results');
    disp(strcat('Structure of test=',num2str(test),' has been reduced'));
end

%% Run power flow if not already done in the passed
if ~isfield(results,'PowerFlowDC')
    pf_casedata = results.testcase;
    pf_casedata.gen(:,2) = sum(results.P,2);
    mpopt_case = mpoption('model', 'DC','out.all',0);
    [pf_casedata, success] = runpf(pf_casedata,mpopt_case);
    if success
        %printpf(results);
        results.PowerFlowDC = pf_casedata.branch(:,14);
        save(strcat('simulations/results_',label,'_',num2str(test),'.mat'),'results');
    else
        error('pf pb');
    end
end
