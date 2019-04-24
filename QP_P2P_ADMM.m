function [P,Y,success,flagout,raw] = QP_P2P_ADMM(a_ag,b_ag,Pmin_ag,Pmax_ag,Conn,gamma,P0,varargin)
% Valid only for quadratic functions

%% Default options
% Penalty factor
opt.rho = 1;
% Solving method: 'quadprog' or 'direct' or 'direct2'
opt.method = 'quadprog';
% ADMM type: 'reduced' or 'classic'
opt.type = 'classic';
% Light 'direct2' method
opt.light = 'on';
% Maximum number of iteration
opt.maxit = 100;
% Maximum number of iteration of 'direct' method's nested loop
opt.maxitNest = 100;
% Stopping criterion: 'on' or 'off'
opt.stopcrit = 'off';
% Primal residual tolerance
opt.espPrimR = 1e-3;
% Dual residual tolerance
opt.espDualR = 1e-3;
% Local optimization tolerance
opt.espLoc = 1e-6;
% Bounded trades: 'on' or 'off'
opt.TradeBound = 'off';
% Boundaries relaxation parameter
opt.BoundParam = 0.05;
% Trade Boundaries relaxation parameter
opt.BoundParamT = 0.05;
% Boundaries relaxation in Quadratic programming: 'on' or 'off'
opt.QPrelax = 'off';
% Plot: 'raw_light', 'raw_full', 'res', 'all', 'none'
opt.Plot = '';

%% Chosen options
opt_in.blank = 0;
if isstruct(a_ag)
    if nargin>1
        varargin = b_ag;
    end
    error('Function call not ready yet')
end
if nargin>7 || varargin_on
    if isstruct(varargin{1})
        opt_in = varargin{1};
        opt_in.blank = 0;
    else
        if mod(length(varargin),2)~=0
            error('Wrong number of variable inputs!')
        else
            for i=1:(length(varargin)/2)
                if ~ischar(varargin{i}), error('One variable input name is not a string!'); end
                opt_in.(deblank(varargin{i})) = varargin{2*i};
            end
        end
    end

    if isfield(opt_in,'rho'),           opt.rho = opt_in.rho;                 end
    if isfield(opt_in,'method'),        opt.method = opt_in.method;           end
    if isfield(opt_in,'type'),          opt.type = opt_in.type;               end
    if isfield(opt_in,'light'),         opt.light = opt_in.light;             end
    if isfield(opt_in,'maxit'),         opt.maxit = opt_in.maxit;             end
    if isfield(opt_in,'maxitNest'),     opt.maxitNest = opt_in.maxitNest;     end
    if isfield(opt_in,'stopcrit'),      opt.stopcrit = opt_in.stopcrit;       end
    if isfield(opt_in,'espPrimR'),      opt.espPrimR = opt_in.espPrimR;       end
    if isfield(opt_in,'espDualR'),      opt.espDualR = opt_in.espDualR;       end
    if isfield(opt_in,'espLoc'),        opt.espLoc = opt_in.espLoc;           end
    if isfield(opt_in,'TradeBound'),    opt.TradeBound = opt_in.TradeBound;   end
    if isfield(opt_in,'BoundParam'),    opt.BoundParam = opt_in.BoundParam;   end
    if isfield(opt_in,'BoundParamT'),   opt.BoundParamT = opt_in.BoundParamT; end
    if isfield(opt_in,'QPrelax'),       opt.QPrelax = opt_in.QPrelax;         end
    if isfield(opt_in,'Plot'),          opt.Plot = opt_in.Plot;               end
end
% options str2num
if strcmp('reduced',opt.type),    opt.type = 1;         else    opt.type = 0;         end
if strcmp('on',opt.light),        opt.light = 1;        else    opt.light = 0;        end
if strcmp('on',opt.stopcrit),     opt.stopcrit = 1;     else    opt.stopcrit = 0;     end
if strcmp('on',opt.TradeBound),   opt.TradeBound = 1;   else    opt.TradeBound = 0;   end
if strcmp('on',opt.QPrelax),      opt.QPrelax = 1;      else    opt.QPrelax = 0;      end

if strcmp('direct',opt.method)
    opt.method = 1;
    warning('Method not validated yet')
elseif strcmp('direct2',opt.method)
    opt.method = 2;
    opt.maxitNest = 2;
%     warning('Method not validated yet')
else
    opt.method = 0;
end

%% Init optimization
% Data verification
n_agents = length(a_ag);
if isempty(gamma),   gamma=zeros(n_agents);                  end
if isempty(P0),      P0=zeros(n_agents);                  end
if isempty(Conn),    Conn = logical(ones(n_agents)-eye(n_agents));    end
if length(b_ag)~=n_agents || all(size(Conn)~=[n_agents,n_agents]) || ...
        all(size(gamma)~=[n_agents,n_agents]) || all(size(P0)~=[n_agents,n_agents])
    error('Dimension error of input parameters')
end

% Local optimization variables
H = cell(n_agents,1);
% f = cell(n_agents,1);
n_om = zeros(n_agents,1);
for n=1:n_agents
    n_om(n) = sum(Conn(n,:));
    H{n} = a_ag(n)*ones(n_om(n)) + opt.rho*eye(n_om(n));
end

lb = cell(n_agents,1);
ub = cell(n_agents,1);
for n=1:n_agents
    lb{n} = -Inf(n_om(n),1);
    ub{n} = Inf(n_om(n),1);
end
if opt.TradeBound
    for n=1:n_agents
        lb{n} = Pmin_ag(n)*ones(n_om(n),1);
        ub{n} = Pmax_ag(n)*ones(n_om(n),1);
        if Pmin_ag(n)>0
            lb{n} = zeros(n_om(n),1);
        elseif Pmax_ag(n)<0
            ub{n} = zeros(n_om(n),1);
        end
    end
end


if opt.method
    Hi = cell(n_agents,1);
    for n=1:n_agents
        Hi{n} = (H{n})^(-1);
    end
else
    A = cell(n_agents,1);
    b = cell(n_agents,1);
    for n=1:n_agents
        A{n} = ones(2,n_om(n));
        A{n}(2,:) = -A{n}(2,:);
        b{n} = [Pmax_ag(n); -Pmin_ag(n)];
    end
    QPopt = optimoptions('quadprog','Display','off','OptimalityTolerance',opt.espLoc);
end

% Global variables
raw.n_agents    = n_agents;
raw.gamma       = gamma;
raw.Conn        = Conn;
raw.P           = zeros(n_agents,n_agents,opt.maxit);
raw.Y           = zeros(n_agents,n_agents,opt.maxit);
raw.Mup         = zeros(n_agents,opt.maxit);
raw.Mum         = zeros(n_agents,opt.maxit);
raw.Mupt        = zeros(n_agents,n_agents,opt.maxit);
raw.Mumt        = zeros(n_agents,n_agents,opt.maxit);
raw.PrimR       = zeros(opt.maxit,1);
raw.DualR       = zeros(opt.maxit,1);
raw.P(:,:,1)    = P0;

%% Optimization loop
flagout = 0;
cont = 1;
k = 1;
raw.comptime = cputime;
while k < (opt.maxit-1) && cont
    % Power trades update
    if opt.method == 2 && opt.light
        for n=1:n_agents
            if opt.type
                f = (b_ag(n)+raw.Mup(n,k)-raw.Mum(n,k))*ones(n_om(n),1) ...
                    + ( gamma(n,Conn(n,:)) - opt.rho*raw.Y(n,Conn(n,:),k) ...
                    - opt.rho/2 * (raw.P(n,Conn(n,:),k)-raw.P(Conn(n,:),n,k)') ...
                    +raw.Mupt(n,Conn(n,:),k)-raw.Mumt(n,Conn(n,:),k) )';
            else
                f = (b_ag(n)+raw.Mup(n,k)-raw.Mum(n,k))*ones(n_om(n),1) ...
                    + ( gamma(n,Conn(n,:)) - raw.Y(n,Conn(n,:),k) ...
                    - opt.rho/2 * (raw.P(n,Conn(n,:),k)-raw.P(Conn(n,:),n,k)') ...
                    +raw.Mupt(n,Conn(n,:),k)-raw.Mumt(n,Conn(n,:),k) )';
            end
            raw.P(n,Conn(n,:),k+1) = -Hi{n}*f;
            raw.Mup(n,k) = max(raw.Mup(n,k) + opt.BoundParam*(sum(raw.P(n,Conn(n,:),k+1))-Pmax_ag(n)), 0);
            raw.Mum(n,k) = max(raw.Mum(n,k) + opt.BoundParam*(Pmin_ag(n)-sum(raw.P(n,Conn(n,:),k+1))), 0);
            if opt.TradeBound
                raw.Mupt(n,Conn(n,:),k+1) = max(raw.Mupt(n,Conn(n,:),k) + opt.BoundParamT*(raw.P(n,Conn(n,:),k+1)-ub{n}'), 0);
                raw.Mumt(n,Conn(n,:),k+1) = max(raw.Mumt(n,Conn(n,:),k) + opt.BoundParamT*(lb{n}'-raw.P(n,Conn(n,:),k+1)), 0);
            end
        end
    elseif opt.method
        Ps = raw.P(:,:,k);
        Pso = Ps;
        Mups = raw.Mup(:,k);
        Mums = raw.Mum(:,k);
        Mupts = raw.Mupt(:,:,k);
        Mumts = raw.Mumt(:,:,k);
        ks = 1;
        conts = 1;
        while ks < opt.maxitNest && conts
            for n=1:n_agents
                if opt.type
                    f = (b_ag(n)+Mups(n)-Mums(n))*ones(n_om(n),1) ...
                        + ( gamma(n,Conn(n,:)) - opt.rho*raw.Y(n,Conn(n,:),k) ...
                        - opt.rho/2 * (Ps(n,Conn(n,:))-Ps(Conn(n,:),n)') ...
                        +Mupts(n,Conn(n,:))-Mumts(n,Conn(n,:)) )';
                else
                    f = (b_ag(n)+Mups(n)-Mums(n))*ones(n_om(n),1) ...
                        + ( gamma(n,Conn(n,:)) - raw.Y(n,Conn(n,:),k) ...
                        - opt.rho/2 * (Ps(n,Conn(n,:))-Ps(Conn(n,:),n)') ...
                        +Mupts(n,Conn(n,:))-Mumts(n,Conn(n,:)) )';
                end
                Ps(n,Conn(n,:)) = -Hi{n}*f;
                Mups(n) = max(Mups(n) + opt.BoundParam*(sum(Ps(n,Conn(n,:)))-Pmax_ag(n)), 0);
                Mums(n) = max(Mums(n) + opt.BoundParam*(Pmin_ag(n)-sum(Ps(n,Conn(n,:)))), 0);
                if opt.TradeBound
                    Mupts(n,Conn(n,:)) = max(Mupts(n,Conn(n,:)) + opt.BoundParamT*(Ps(n,Conn(n,:))-ub{n}'), 0);
                    Mumts(n,Conn(n,:)) = max(Mumts(n,Conn(n,:)) + opt.BoundParamT*(lb{n}'-Ps(n,Conn(n,:))), 0);
                end
            end
            if norm(Ps-Pso) < opt.espLoc*n_agents
                conts = 0;
            end
            Pso = Ps;
            ks = ks + 1;
        end
        raw.P(:,:,k+1) = Ps;
        raw.Mup(:,k+1) = Mups;
        raw.Mum(:,k+1) = Mums;
        raw.Mupt(:,:,k+1) = Mupts;
        raw.Mumt(:,:,k+1) = Mumts;
    else
        for n=1:n_agents
            if opt.type
                f = (b_ag(n)+raw.Mup(n,k)-raw.Mum(n,k))*ones(n_om(n),1) ...
                    + ( gamma(n,Conn(n,:)) - opt.rho*raw.Y(n,Conn(n,:),k) - opt.rho/2 * (raw.P(n,Conn(n,:),k)-raw.P(Conn(n,:),n,k)') )';
            else
                f = (b_ag(n)+raw.Mup(n,k)-raw.Mum(n,k))*ones(n_om(n),1) ...
                    + ( gamma(n,Conn(n,:)) - raw.Y(n,Conn(n,:),k) - opt.rho/2 * (raw.P(n,Conn(n,:),k)-raw.P(Conn(n,:),n,k)') )';
            end
            [x,fval,exitflag] = quadprog(H{n},f,A{n},b{n},[],[],lb{n},ub{n},raw.P(n,Conn(n,:),k)',QPopt);
            if exitflag<1, error(strcat('Quadprog exitflag error:',num2str(exitflag))); end
            if exitflag~=1, warning(strcat('Quadprog exitflag warning:',num2str(exitflag))); end
            raw.P(n,Conn(n,:),k+1) = x';
            if opt.QPrelax
                raw.Mup(n,k+1) = max(0, raw.Mup(n,k+1) + opt.BoundParam*(sum(x)-Pmax_ag(n)));
                raw.Mum(n,k+1) = max(0, raw.Mum(n,k+1) + opt.BoundParam*(Pmin_ag(n)-sum(x)));
            end
        end
    end
    
    % Prices update
    if opt.type
        raw.Y(:,:,k+1) = raw.Y(:,:,k) - (raw.P(:,:,k+1)+raw.P(:,:,k+1)')/2;
    else
        raw.Y(:,:,k+1) = raw.Y(:,:,k) - opt.rho*(raw.P(:,:,k+1)+raw.P(:,:,k+1)')/2;
    end
    
    
    raw.PrimR(k+1) = norm(raw.P(:,:,k+1)+raw.P(:,:,k+1)')/2;
    raw.DualR(k+1) = norm(raw.P(:,:,k+1)-raw.P(:,:,k));
    if opt.stopcrit
        if raw.PrimR(k+1)<opt.espPrimR && raw.DualR(k+1)<opt.espDualR
            flagout = 1;
            cont = 0;
        end
    end
    k = k + 1; 
end
raw.comptime = cputime-raw.comptime;
raw.last_it = k;
P = raw.P(:,:,k);
Y = raw.Y(:,:,k);
raw.opt = opt;

%% Social Welfare
raw.SW = zeros(opt.maxit,1);
for k=1:raw.last_it
    for n=1:n_agents
        raw.SW(k) = raw.SW(k) + 0.5*a_ag(n)*sum(raw.P(n,:,k),2)+b_ag(n)*sum(raw.P(n,:,k),2)+sum(raw.P(n,:,k).*gamma(n,:),2);
    end
end

%% Flag output
if flagout>=0
    success = 1;
else
    success = 0;
end

raw.succes = success;
raw.flagout = flagout;

%% Plot
% Plot option - Type of plot: 'raw_light', 'raw_full', 'res', 'all', 'none'
if ~strcmp('none',opt.Plot)
    disp(strcat('Stopped after',{' '},num2str(raw.last_it),...
        ' iterations computed in',{' '},num2str(raw.comptime),'s'))
    disp(strcat('Final Primal and Dual residuals:',{' '},...
        num2str(raw.PrimR(raw.last_it)),' and',{' '},num2str(raw.DualR(raw.last_it))))
    disp(strcat('Final Social Welfare is',{' '},num2str(raw.SW(raw.last_it))))
    
    if strcmp('raw_light',opt.Plot)
        figure
        subplot(1,2,1)
        hold on
        for n=1:n_agents
            plot(1:raw.last_it,reshape(sum(raw.P(n,:,1:raw.last_it),2),raw.last_it,1))
        end
        xlabel('iteration')
        ylabel('Total power traded')
        subplot(1,2,2)
        hold on
        for n=1:n_agents
            for m=find(Conn(n,:))
                plot(1:raw.last_it,reshape(raw.Y(n,m,1:raw.last_it),raw.last_it,1))
            end
        end
        xlabel('iteration')
        ylabel('Trading prices')  
    elseif strcmp('raw_full',opt.Plot) || strcmp('all',opt.Plot)
        figure
        subplot(2,2,1)
        hold on
        for n=1:n_agents
            plot(1:raw.last_it,reshape(sum(raw.P(n,:,1:raw.last_it),2),raw.last_it,1))
        end
        xlabel('iteration')
        ylabel('Total power traded')
        subplot(2,2,2)
        hold on
        for n=1:n_agents
            for m=find(Conn(n,:))
                plot(1:raw.last_it,reshape(raw.Y(n,m,1:raw.last_it),raw.last_it,1))
            end
        end
        xlabel('iteration')
        ylabel('Trading prices')  
        subplot(2,2,3)
        hold on
        for n=1:n_agents
            for m=find(Conn(n,:))
                plot(1:raw.last_it,reshape(raw.P(n,m,1:raw.last_it),raw.last_it,1))
            end
        end
        xlabel('iteration')
        ylabel('Power trades')
        subplot(2,2,4)
        hold on
        for n=1:n_agents
            plot(1:raw.last_it,reshape(raw.Mup(n,1:raw.last_it),raw.last_it,1))
            plot(1:raw.last_it,reshape(raw.Mum(n,1:raw.last_it),raw.last_it,1))
            for m=find(Conn(n,:))
                plot(1:raw.last_it,reshape(raw.Mupt(n,m,1:raw.last_it),raw.last_it,1))
                plot(1:raw.last_it,reshape(raw.Mumt(n,m,1:raw.last_it),raw.last_it,1))
            end
        end
        xlabel('iteration')
        ylabel('Relaxation dual variables')
    end
    if strcmp('res',opt.Plot) || strcmp('all',opt.Plot)
        figure
        subplot(1,2,1)
        plot(1:raw.last_it,log10(raw.PrimR(1:raw.last_it)))
        xlabel('iteration')
        ylabel('Primal residual (log scale)')
        subplot(1,2,2)
        plot(1:raw.last_it,log10(raw.DualR(1:raw.last_it)))
        xlabel('iteration')
        ylabel('Dual residual (log scale)')
    end
end