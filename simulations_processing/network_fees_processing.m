clc;
clearvars ;
close all;
%% Post-process global option

% What type of network to study?
% choice between:
% 'free' - free market without unit fees
% 'uniq' - market with unique unit fee
% 'dist' - market with unit fees proportional to electrical distances
% 'zona' - market with unit fees by zones
% 'noda' - market with unit fees by nodes (ie zone=node)
type_fee = {'uniq','dist','zona'};
% type_fee = {'zona'};

% What type of plot?
% choice between:
% 'trades' - show on map the used trades (lines thickness representing the amount of power exchanged)
% 'exchan' - show on map the exchanges between zones and zones power balance
% 'effici' - show on graph the cost allocation efficiencies compared to classical pool market and economic dispatch
% 'lflows' - show on graph the change of line flows (dc power flow) compared to a reference (ie free market)
% 'anaMar' - anamorphosis of participants interactions
% 'anaNet' - anamorphosis of network usage
type_plot = 'lflows';

%% Unit fee type
Fees=load_fee_label(type_fee);
n_fee = length(type_fee);
%% Plot - Trades evolution on map
if strcmp(type_plot,'trades')
    % Plot options
    % 0 - Graph - Sum of all trades
    % 1 - Map
    type_display = 1;
    % 0 - No scaling (default)
    % 1 - Scaling (on lines thickness and axes limits)
    type_scale = 1;
    % 0 - Do not plot zoning areas
    % 1 - Plot zoning areas
    type_zoning = 1;
    % 0 - Do not plot agents' marker
    % 1 - Plot agents' marker
    type_agent = 1;
    % Power trades threshold 
    power_threshold = 10^-2;    % in MW
    
    if type_display
        for f=1:n_fee
            for test=Fees{f}.n_tests_start:Fees{f}.n_tests_stop
                first_intra = 1;
                first_extra = 1;
                legends=cell(2+2*type_agent,1);
                plots=[];%zeros(2+2*type_agent,1);
                results = load_results(Fees{f}.label,test);
                Pos = results.testcase.genpos;
                %     close all
                fig=figure(test*f);
                xlim([0.02 1.03])
                ylim([0 0.95])
                axis off
                hold on
                for n=results.consumers
                    P_net = sum(results.P(n,:));
                    for m=results.om{n}
                        trade_value = results.P(n,m);

                        if abs(trade_value)>power_threshold
                            % Edges color definition
    %                         if test==1
                                %Color_intra = [153, 182, 255]/255; % blue: intra-zone exchanges
                                Color_intra = [102, 255, 117]/255; % green: intra-zone exchanges
                                Color_extra = [254, 103, 105]/255; % red: extra-zone exchanges
    %                         end
                            if trade_value~=0
                                if results.testcase.bus(results.testcase.gen(n,1),7)==results.testcase.bus(results.testcase.gen(m,1),7)
                                    EdgeColor = Color_intra;
                                else
                                    EdgeColor = Color_extra;
                                end
                            end

                            if type_scale==1
                                if test==1
                                    Weight_ref = max(max(abs(results.P)));
                                end
                                LWidth = 2*abs(trade_value)/Weight_ref;
                            else
                                LWidth = 2*abs(trade_value)/100;%max(max(abs(results.P)));
                            end

                            h=plot(Pos([n m],2),Pos([n m],1),'Color',EdgeColor,'LineWidth',LWidth);
                            if first_extra && sum(EdgeColor==Color_extra)
                                %plots{2}=h;
                                plots(2)=h;
                                legends{2}='Extra-zone trades';
                                first_extra=0;
                            end
                            if first_intra && sum(EdgeColor==Color_intra)
                                %plots{1}=h;
                                plots(1)=h;
                                legends{1}='Intra-zone trades';
                                first_intra=0;
                            end
                            %set(h,'EdgeAlpha',0.5);
                        end
                    end
                end

                if type_agent
                    plots(3)=plot(Pos(results.producers,2),Pos(results.producers,1),'LineStyle','none','Marker','d','MarkerFaceColor',[0 114/255 189/255],'MarkerEdgeColor',[0 114/255 189/255]);
                    hold on
                    plots(4)=plot(Pos(results.consumers,2),Pos(results.consumers,1),'LineStyle','none','Marker','o','MarkerFaceColor',[74/255 189/255 238/255],'MarkerEdgeColor',[74/255 189/255 238/255]);
                    legends{3}='Producers';
                    legends{4}='Consumers';
                end

                if type_zoning
                    % zone 1
                    areapos = results.testcase.areapos{1};
                    plot(areapos(:,1),areapos(:,2),'LineStyle','--','Color',results.testcase.areacolor{1},'LineWidth',1.25)
                    text(0.1,0.8,'Zone 1','Color',results.testcase.areacolor{1},'FontWeight','bold')
                    % zone 2
                    areapos = results.testcase.areapos{2};
                    plot(areapos(:,1),areapos(:,2),'LineStyle','--','Color',results.testcase.areacolor{2},'LineWidth',1.25)
                    text(0.87,0.88,'Zone 2','Color',results.testcase.areacolor{2},'FontWeight','bold')
                    %     % zone 3
                    areapos = results.testcase.areapos{3};
                    plot(areapos(:,1),areapos(:,2),'LineStyle','--','Color',results.testcase.areacolor{3},'LineWidth',1.25)
                    text(0.35,0.25,'Zone 3','Color',results.testcase.areacolor{3},'FontWeight','bold')
                    %     % zone 4
                    areapos = results.testcase.areapos{4};
                    plot(areapos(:,1),areapos(:,2),'LineStyle','--','Color',results.testcase.areacolor{4},'LineWidth',1.25)
                    text(0.6,0.4,'Zone 4','Color',results.testcase.areacolor{4},'FontWeight','bold')
                end

                fig.Position(3:4) = [1.4 1.5].*fig.Position(3:4);%[626   626];
                fig.Position(2) = fig.Position(2) - fig.Position(4)/3;
    %             legend(plots,legends,'Location','North')
            end
        end
    else
        
        % Load pool price
        Pool_results = load('simulations/results_Free_1.mat');
        Pool_results = Pool_results.results;
        prices = zeros(Pool_results.n_agents,1);
        for n=1:Pool_results.n_agents
            prices(n)=mean(Pool_results.Y(n,Pool_results.om{n}));
        end
        Price_ref = mean(prices);
        
        % Evaluate global objectives
        Volumes = cell(n_fee,1);
        starts = zeros(n_fee,1);
        stops = zeros(n_fee,1);
        for f=1:n_fee
            Volumes{f} = zeros(Fees{f}.N_tests,1);
            
            % Set range of showed fees
            if Fees{f}.n_tests_start>1
                Fees{f}.show = [1 Fees{f}.n_tests_start:Fees{f}.n_tests_stop];
            else
                Fees{f}.show = Fees{f}.n_tests_start:Fees{f}.n_tests_stop;
            end
            starts(f) = Fees{f}.n_tests_start;
            stops(f) = Fees{f}.n_tests_stop;
            % Get flow rates and normalize them
            for test=Fees{f}.show
                results = load_results(Fees{f}.label,test);
                Volumes{f}(test) = sum(sum(abs(results.P)))/2;
            end
        end
        
        % Plot references
        fig=figure;
        hold on
        legends=cell(n_fee,1);
        hs=cell(n_fee,1);
        Colors = [55,126,184;228,26,28;152,78,163]/255;
        
        % Plot results
        maxs = zeros(n_fee,1);
        mins = zeros(n_fee,1);
        count=1;
        for f=1:n_fee
            xs = Fees{f}.n_tests_start:Fees{f}.n_tests_stop;
            xs = xs./Price_ref *100;
            hs{count}=plot(xs,Volumes{f},'Color',Colors(f,:),'LineWidth',1.1);
            maxs(f) = max(Volumes{f});
            mins(f) = min(Volumes{f});
            legends{count}=strcat('\it ',Fees{f}.legend2);
            count=count+1;
        end
        vline(10/Price_ref*100,'k--','17.5%')
        fig.Position(3:4) = [492   626/2];
        legend(legends,'FontName','Times New Roman','FontSize',10)
        xlabel('Unit fee (% of free market price)','FontName','Times New Roman','FontSize',11);
        ylabel('Total power traded (MW)','FontName','Times New Roman','FontSize',11);
        xlim([min(starts) max(stops)]./Price_ref *100)
        %ylim([min(mins)-5 max(maxs)+5])
        fig.Position(3:4) = [492   626/2];
    end
end

%% Plot - Zone exchanges evolution on map
if strcmp(type_plot,'exchan')
    % Plot options
    % 0 - Graph
    % 1 - Map
    type_display = 0;
    
    if type_display
        for f=1:n_fee
            for test=Fees{f}.n_tests_start:Fees{f}.n_tests_stop
            results = load_results(Fees{f}.label,test);

            Pos = results.testcase.genpos;
            %     close all
            figure(50+test*f)
            xlim([0.02 1.03])
            ylim([0 0.95])
            axis off
            hold on

            plot(Pos(results.producers,2),Pos(results.producers,1),'LineStyle','none','Marker','d','MarkerFaceColor',[0 114/255 189/255],'MarkerEdgeColor',[0 114/255 189/255])
            hold on
            plot(Pos(results.consumers,2),Pos(results.consumers,1),'LineStyle','none','Marker','o','MarkerFaceColor',[74/255 189/255 238/255],'MarkerEdgeColor',[74/255 189/255 238/255])


            % Zone exchanges
            bus_area = results.testcase.bus(:,7);
            ag_bus = results.testcase.gen(:,1);
            n_zones = max(bus_area);
            P_exch = zeros(n_zones);
            for i=1:results.n_agents
                for j=1:results.n_agents
                    P_exch(bus_area(ag_bus(i)),bus_area(ag_bus(j))) = P_exch(bus_area(ag_bus(i)),bus_area(ag_bus(j))) + results.P(i,j);
                end
            end
            %P_exch
            P_net_zone = sum(P_exch,2);

            % zone 1
            areapos = results.testcase.areapos{1};
            plot(areapos(:,1),areapos(:,2),'LineStyle','--','Color',results.testcase.areacolor{1},'LineWidth',1.25)
            text(0.1,0.8,'Zone 1','Color',results.testcase.areacolor{1},'FontWeight','bold')
            texts =strcat('P_{1}^{ex}=',{' '},num2str(round(P_net_zone(1))),' MW');
            text(0.06,0.74,texts,'Color',results.testcase.areacolor{1},'FontWeight','bold')
            % zone 2
            areapos = results.testcase.areapos{2};
            plot(areapos(:,1),areapos(:,2),'LineStyle','--','Color',results.testcase.areacolor{2},'LineWidth',1.25)
            text(0.78,0.88,'Zone 2','Color',results.testcase.areacolor{2},'FontWeight','bold')
            texts =strcat('P_{2}^{ex}=',{' '},num2str(round(P_net_zone(2))),' MW');
            text(0.76,0.82,texts,'Color',results.testcase.areacolor{2},'FontWeight','bold')
            %     % zone 3
            areapos = results.testcase.areapos{3};
            plot(areapos(:,1),areapos(:,2),'LineStyle','--','Color',results.testcase.areacolor{3},'LineWidth',1.25)
            text(0.33,0.25,'Zone 3','Color',results.testcase.areacolor{3},'FontWeight','bold')
            texts =strcat('P_{3}^{ex}=',{' '},num2str(round(P_net_zone(3))),' MW');
            text(0.29,0.19,texts,'Color',results.testcase.areacolor{3},'FontWeight','bold')
            %     % zone 4
            areapos = results.testcase.areapos{4};
            plot(areapos(:,1),areapos(:,2),'LineStyle','--','Color',results.testcase.areacolor{4},'LineWidth',1.25)
            text(0.6,0.4,'Zone 4','Color',results.testcase.areacolor{4},'FontWeight','bold')
            texts =strcat('P_{4}^{ex}=',{' '},num2str(round(P_net_zone(4))),' MW');
            text(0.56,0.34,texts,'Color',results.testcase.areacolor{4},'FontWeight','bold')

            % Exchanges plots
            % 1-2
            plot([0.34 0.55],[0.8 0.8],'LineStyle','-','Color','k')
            texts = strcat('P_{12}^{ex}=',{' '},num2str(round(P_exch(1,2))),' MW');
            text(0.36,0.827,texts,'Color','k')
            % 1-3
            plot([0.25 0.25],[0.52 0.45],'LineStyle','-','Color','k')
            texts = strcat('P_{13}^{ex}=',{' '},num2str(round(P_exch(1,3))),' MW');
            text(0.07,0.485,texts,'Color','k')
            % 1-4
            plot([0.34 0.55],[0.6 0.58],'LineStyle','-','Color','k')
            texts = strcat('P_{14}^{ex}=',{' '},num2str(round(P_exch(1,4))),' MW');
            text(0.345,0.625,texts,'Color','k')
            % 2-3
            plot([0.55 0.4],[0.7 0.45],'LineStyle','-','Color','k')
            texts = strcat('P_{23}^{ex}=',{' '},num2str(round(P_exch(2,3))),' MW');
            text(0.435,0.485,texts,'Color','k')
            % 2-4
            plot([0.7 0.7],[0.66 0.605],'LineStyle','-','Color','k')
            texts = strcat('P_{24}^{ex}=',{' '},num2str(round(P_exch(2,4))),' MW');
            text(0.71,0.63,texts,'Color','k')
            % 3-4
            plot([0.5 0.55],[0.2 0.2],'LineStyle','-','Color','k')
            texts = strcat('P_{34}^{ex}=',{' '},num2str(round(P_exch(3,4))),' MW');
            text(0.508,0.23,texts,'Color','k')
            end
        end
    else
        Colors = [55,126,184;228,26,28;152,78,163]/255;
        f1=figure;
        hold on
        count=1;
        legends=cell(n_fee,1);
        for f=1:n_fee
            xs = Fees{f}.n_tests_start:Fees{f}.n_tests_stop;
            ys = zeros(length(xs),1);
            for test=xs
                results = load_results(Fees{f}.label,test);
                if f==1 && test==xs(1)
                    prices = zeros(results.n_agents,1);
                    for n=1:results.n_agents
                        prices(n)=mean(results.Y(n,results.om{n}));
                    end
                    Price_ref = mean(prices);
                end
                % Zone exchanges
                bus_area = results.testcase.bus(:,7);
                ag_bus = results.testcase.gen(:,1);
                n_zones = max(bus_area);
                P_exch = zeros(n_zones);
                for i=1:results.n_agents
                    for j=1:results.n_agents
                        P_exch(bus_area(ag_bus(i)),bus_area(ag_bus(j))) = P_exch(bus_area(ag_bus(i)),bus_area(ag_bus(j))) + results.P(i,j);
                    end
                end
                ys(test) = sum(sum(abs( triu(P_exch,1) )));
            end
            xs = xs./Price_ref *100;
            plot(xs,ys,'Color',Colors(f,:),'LineWidth',1.1)
            legends{count}=strcat('\it ',Fees{f}.legend2);
            count=count+1;
        end
        vline(10/Price_ref*100,'k--','17.5%')
        f1.Position(3:4) = [492   626/2];
        axis tight
        legend(legends,'FontName','Times New Roman','FontSize',10)
        xlabel('Unit fee (% of free market price)','FontName','Times New Roman','FontSize',11);
        ylabel('Absolute inter-zone exchanges (MW)','FontName','Times New Roman','FontSize',11);
    end
end

%% Plot - Line flow rates evolution
if strcmp(type_plot,'effici')
    % Plot references
    % 0 - None
    % 1 - Classical pool market
    % 2 - Classical economic dispatch
    % 3 - Both pool market and economic dispatch
    type_ref = 3;
    % Plot y-axis scale
    % 0 - Linear
    % 1 - Log (only for positive objectives)
    type_scale = 0;
    % Plot money scale
    % 1 - €
    % 2 - k€
    % 3 - M€
    % 4 - B€
    type_money = 2;
    % Plot full range
    % 0 - Only for feasible market outcomes
    % 1 - All market outcomes
    type_full = 0;
    
    
    Money_ref = {1,1e3,1e6,1e9};
    Money_txt = {'€','k€','M€','B€'};
    Colors = [55,126,184;228,26,28;152,78,163]/255;
    
    % Load pool results
    Pool_results = load('simulations/results_Free_1.mat');
    Pool_results = Pool_results.results;
    Pool_Pnet = sum(Pool_results.P,2);
    Pool_Obj = sum( 0.5*Pool_results.testcase.gencost(:,5).*(Pool_Pnet.^2) +  Pool_results.testcase.gencost(:,6).*Pool_Pnet +  Pool_results.testcase.gencost(:,7) )/Money_ref{type_money};
    
    % Load economic dispatch results
    ED_options = mpoption('model','DC','out.all',0);
    evalc('[ED_results, ED_success] = runopf(Pool_results.testcase,ED_options);');
    if ~ED_success, error('unsuccessful economic dispatch'); end
    ED_Obj = ED_results.f/Money_ref{type_money};
    
    % Evaluate initial electricity market price (before grid tariffs)
    prices = zeros(Pool_results.n_agents,1);
    for n=1:Pool_results.n_agents
        prices(n)=mean(Pool_results.Y(n,Pool_results.om{n}));
    end
    Price_ref = mean(prices);
    
    % Evaluate global objectives
    Obj = cell(n_fee,1);
    Flow_rates = cell(n_fee,1);
    starts = zeros(n_fee,1);
    stops = zeros(n_fee,1);
    for f=1:n_fee
        Obj{f} = zeros(Fees{f}.N_tests,1);
        Flow_rates{f} = zeros(Fees{f}.N_tests,1);
        
        % Set range of showed fees
        if Fees{f}.n_tests_start>1
            Fees{f}.show = [1 Fees{f}.n_tests_start:Fees{f}.n_tests_stop];
        else
            Fees{f}.show = Fees{f}.n_tests_start:Fees{f}.n_tests_stop;
        end
        starts(f) = Fees{f}.n_tests_start;
        stops(f) = Fees{f}.n_tests_stop;
        % Get flow rates and normalize them
        for test=Fees{f}.show
            results = load_results(Fees{f}.label,test);
            Pnet = sum(results.P,2);
            Obj{f}(test) = sum( 0.5*results.testcase.gencost(:,5).*(Pnet.^2) +  results.testcase.gencost(:,6).*Pnet +  results.testcase.gencost(:,7) )/Money_ref{type_money};
            Flow_rates{f}(test) = max(abs( results.PowerFlowDC ./ results.testcase.branch(:,6) )); 
        end
    end
    
    % Plot references
    fig=figure(501);
    hold on
    legends=cell(n_fee+2,1);
    hs=cell(n_fee+2,1);
    xs = min(starts):max(stops);
    xs = xs./Price_ref *100;
    if type_scale
        hs{1}=plot(xs,log10(Pool_Obj*ones(length(xs),1)),'Color','k','LineWidth',1.1);
        hs{2}=plot(xs,log10(ED_Obj*ones(length(xs),1)),'-.','Color','k','LineWidth',1.1);
    else
        hs{1}=plot(xs,-Pool_Obj*ones(length(xs),1),'Color','k','LineWidth',1.1);
        hs{2}=plot(xs,-ED_Obj*ones(length(xs),1),'-.','Color','k','LineWidth',1.1);
    end
    legends{1}='Free market';
    legends{2}='Endogenous P2P (1)';
    
    % Plot results
    maxs = zeros(n_fee,1);
    mins = zeros(n_fee,1);
    count=3;
    for f=1:n_fee
        xs = Fees{f}.n_tests_start:Fees{f}.n_tests_stop;
        xs = xs./Price_ref *100;
        if type_full
            ids = 1:length(xs);
        else
            ids = find(Flow_rates{f}<=1);
        end
        if type_scale
            hs{count}=plot(xs(ids),log10(Obj{f}(ids)),'Color',Colors(f,:),'LineWidth',1.1);
            maxs(f) = log10(max(Obj{f}(ids)));
            mins(f) = log10(min(Obj{f}(ids)));
        else
            hs{count}=plot(xs(ids),-Obj{f}(ids),'Color',Colors(f,:),'LineWidth',1.1);
            maxs(f) = max(-Obj{f}(ids));
            mins(f) = min(-Obj{f}(ids));
        end
        legends{count}=strcat('Feasible \it',Fees{f}.legend2);
        count=count+1;
    end
    
    vline(10/Price_ref*100,'k--','17.5%')
    legend(legends,'FontName','Times New Roman','FontSize',10)%,'Location','northwest')
    xlabel('Unit fee (% of free market price)','FontName','Times New Roman','FontSize',11);
%     if type_full
        if type_scale
            ylabel(strcat('Global objective value (',Money_txt{type_money},', log_{10})'),'FontName','Times New Roman','FontSize',11);
        else
            ylabel(strcat('Total social welfare (',Money_txt{type_money},')'),'FontName','Times New Roman','FontSize',11);
        end
%     else
%         if type_scale
%             ylabel(strcat('Feasible global objective value (',Money_txt{type_money},', log_{10})'),'FontName','Times New Roman','FontSize',11);
%         else
%             ylabel(strcat('Feasible total social welfare (',Money_txt{type_money},')'),'FontName','Times New Roman','FontSize',11);
%         end
%     end
    xlim([min(starts) max(stops)]./Price_ref *100)
    %ylim([min(mins)-5 max(maxs)+5])
    ylim([-5 145])
    fig.Position(3:4) = [492   626/2];
end

%% Plot - Line flow rates evolution
if strcmp(type_plot,'lflows')
    % Plot options
    % 0 - Line flow rate compared to line capacity (Pline/Pcap)
    % 1 - Line flow rate normalized to free market (Pline/Pref)
    type_flow = 0;
    % 0 - Raw plot
    % 1 - Quantile (mean + filled quantile)
    % 2 - Quantile (mean + shadded quantile)
    % 3 - Means comparison between fees (independent of type_fee variable)
    % 4 - Total distance equivalent
    % 5 - Means comparison between fees + Collected money
    type_display = 5;
    
    % Evaluate normalized branch flows
    Flow_rates_ref = cell(n_fee,1);
    Flow_rates = cell(n_fee,1);
    Flow_rates_norm = cell(n_fee,1);
    N_branches = cell(n_fee,1);
    avg_max_ref = cell(n_fee,1);
    avg_min_ref = cell(n_fee,1);
    for f=1:n_fee
        results = load_results(Fees{f}.label,1);
        N_branches{f} = size(results.testcase.branch,1);
        Flow_rates_ref{f} = zeros(N_branches{f},1);
        Flow_rates{f} = zeros(N_branches{f},Fees{f}.N_tests);
        Flow_rates_norm{f} = zeros(N_branches{f},Fees{f}.N_tests);
        
        % Evaluate initial electricity market price (before grid tariffs)
        if f==1
            prices = zeros(results.n_agents,1);
            for n=1:results.n_agents
                prices(n)=mean(results.Y(n,results.om{n}));
            end
            Price_ref = mean(prices);
        end
        % Set range of showed fees
        if Fees{f}.n_tests_start>1
            Fees{f}.show = [1 Fees{f}.n_tests_start:Fees{f}.n_tests_stop];
        else
            Fees{f}.show = Fees{f}.n_tests_start:Fees{f}.n_tests_stop;
        end
        % Get flow rates and normalize them
        for test=Fees{f}.show
            results = load_results(Fees{f}.label,test);
            
            Flow_rates{f}(:,test) = results.PowerFlowDC;
            if test==1
                Flow_rates_ref{f}=Flow_rates{f}(:,test);
            end
            if type_flow==1
                %compared to free market (I/Iref = (I/Imax)/(Iref/Imax))
                Flow_rates_norm{f}(:,test) = abs(Flow_rates{f}(:,test)./Flow_rates_ref{f}); 
            else
                %compared to line capacity (I/Imax)
                Flow_rates_norm{f}(:,test) = abs(Flow_rates{f}(:,test)./results.testcase.branch(:,6)); 
            end
        end
        
        % Determine network use in limit cases (max and min consumption)
        if type_display==2 || type_display==3 || type_display==5
            [Flow_rates_max,Flow_rates_min,Line_occupation_max,Line_occupation_min] = extrema_network_usage(results.testcase);
            avg_max_ref{f} = mean(Line_occupation_max);
            avg_min_ref{f} = mean(Line_occupation_min);
        end
    end
    
    
    % Plot figure(s)
    if type_display==3 || type_display==5
        fig=figure(100+type_flow+10*type_display-1);
        hold on
        legends=cell(n_fee+4,1);
        hs=cell(n_fee+4,1);
        legends2=cell(n_fee,1);
        count=1;
    end
    for f=1:n_fee
        if type_display~=3 && type_display~=5
            fig=figure(100+type_flow+10*type_display+20*f);
            hold on
        end
        if type_display==0
            legends=cell(N_branches{f},1);
            for n=1:N_branches{f}
                plot(results.Fees.tested(Fees{f}.show),Flow_rates_norm{f}(n,:))
                legends{n}=strcat('branch ',num2str(n));
            end
            %legend(legends)
            xlabel(Fees{f}.label);
            ylabel('Line flow rate');
            hold off
        elseif type_display==1
            xs = results.Fees.tested(Fees{f}.show);
            plot(xs,mean(Flow_rates_norm{f},1))

            x_points_fill = [xs];
            y_points_fill = [min(Flow_rates_norm{f},[],1)];
            x_points_fill = [x_points_fill, xs(end:-1:1)];
            maxi = max(Flow_rates_norm{f},[],1);
            y_points_fill = [y_points_fill, maxi(end:-1:1)];
            fillhandle=fill(x_points_fill,y_points_fill,'b','LineStyle','none');
            hold on
            set(fillhandle,'EdgeColor','b','FaceAlpha',0.2,'EdgeAlpha',0.2); % set transparency
            xlabel(Fees{f}.label);
            ylabel('Line flow rate');
            hold off
        elseif type_display==2
            xs = Fees{f}.n_tests_start:Fees{f}.n_tests_stop;
            xs = xs./Price_ref *100;
            ys = sort(Flow_rates_norm{f},1)*100;
            
            legends = cell(3,1);
            hs = cell(3,1);
            x_points_fill = [xs(1)-1 xs(end)+1 xs(end)+1 xs(1)-1];
            y_points_fill = [100 100 max(ys(:,1))+1 max(ys(:,1))+1];
            hs{1}=fill(x_points_fill,y_points_fill,[220,220,220]/255);
            set(hs{1},'LineStyle','-','EdgeColor',[30,30,30]/250);
            legends{1}='Overload zone';
            xlim([xs(1) xs(end)])
            ylim([0 max(ys(:,1))])
            
            n_shade = size(ys,1);
            if mod(n_shade,2)
                n_shade=(n_shade-1)/2;
            else
                n_shade = n_shade/2;
            end
            shade_max = 0.3;
            shade_min = 0.07;
            shade_step = (shade_max-shade_min)/(n_shade-1);
            shade_fill = shade_min;

            for sh=1:n_shade
                x_points_fill = [xs];
                y_points_fill = [ys(sh,:)];
                x_points_fill = [x_points_fill, xs(end:-1:1)];
                y_points_fill = [y_points_fill, ys(end+1-sh,end:-1:1)];
                hs{3}=fill(x_points_fill,y_points_fill,'b','LineStyle','none');
                hold on
                set(hs{3},'EdgeColor','b','FaceAlpha',shade_fill,'EdgeAlpha',shade_fill); % set transparency
                shade_fill = shade_min + shade_step*(sh-1) - shade_fill;
            end
            
            hs{2}=plot(xs,mean(ys,1),'r','LineWidth',1.1);
            legends{2}='Average line rate';
            legends{3}='Line rates dispersion';
%             plot(xs,avg_max_ref{f}.*ones(length(xs),1),'k--')
%             plot(xs,avg_min_ref{f}.*ones(length(xs),1),'k--')
            legend([hs{1} hs{2} hs{3}],legends,'FontName','Times New Roman','FontSize',10)
            xlabel(strcat('\it',{' '},Fees{f}.legend2,'\rm Unit fee (% of free market price)'),'FontName','Times New Roman','FontSize',11);
            ylabel('Lines rate (% of line capacity)','FontName','Times New Roman','FontSize',11);
            hold off
            fig.Position(3:4) = [492   626/2];
        elseif type_display==3 || type_display==5
            if type_display==5
                ax1=subplot(2,1,1);
            end
            hold on
            xs = Fees{f}.n_tests_start:Fees{f}.n_tests_stop;
            xs = xs./Price_ref *100;
            ys = Flow_rates_norm{f}.*100;
            ys_flex = ys(1);
            if f==1
                Price_ref
                x_points_fill = [xs(1)-1 xs(end)+1 xs(end)+1 xs(1)-1];
                y_points_fill = [1 1 max(ys(:,1))+1 max(ys(:,1))+1].*100;
                hs{count}=fill(x_points_fill,y_points_fill,[220,220,220]/255);
                set(hs{count},'LineStyle','-','EdgeColor',[30,30,30]/250);
                legends{count}='Overload zone';
                count=count+1;
                
                y_points_fill = [avg_min_ref{f} avg_min_ref{f} avg_max_ref{f} avg_max_ref{f}].*100;
                hs{count}=fill(x_points_fill,y_points_fill,[188,233,148]/245);
                set(hs{count},'LineStyle','--','LineWidth',1,'EdgeColor',[49,102,0]/250);
                xlim([xs(1) xs(end)])
                ylim([0 max(ys(:,1))])
                legends{count}='Average range zone';
                count=count+1;
                
                hs{n_fee+3}=plot(xs,mean(ys,1),'Color','k','LineWidth',1.1);
                legends{n_fee+3}='Average';
                hs{n_fee+4}=plot(xs,max(ys),'-.','Color','k','LineWidth',1.1);
                legends{n_fee+4}='Maximum';
                
                Colors = [55,126,184;228,26,28;152,78,163]/255;
            end
            hs{count}=plot(xs,mean(ys,1),'Color',Colors(f,:),'LineWidth',1.1);
            legends{count}=strcat('\it ',Fees{f}.legend2);
            count=count+1;
            plot(xs,max(ys),'-.','Color',Colors(f,:),'LineWidth',1.1)
            %legends{count}=strcat('Maximum-',type_fee{f});
            %count=count+1;
        elseif type_display==4
            xs = results.Fees.tested(Fees{f}.show);

            results = load_results(Fees{f}.label,1);
            Zthev = read_mpc_case_Zthev(results.testcase);
            dist_branch = zeros(N_branches{f},1);
            for bus=1:N_branches{f}
                dist_branch(bus)=Zthev(results.testcase.branch(bus,1),results.testcase.branch(bus,2));
            end
            disteq = sum(Flow_rates{f} .* dist_branch,1);
            disteq_norm = disteq./disteq(1);
            plot(xs,disteq_norm)
            ylim([0 1])
            xlabel(Fees{f}.label);
            ylabel('Normalized distance equivalent (MW.Ohm)');
            hold off
        end
        vline(10/Price_ref*100,'k--','17.5%')
    end
    if type_display==3 || type_display==5
        % display options
        % 0 - single graph
        % 1 - seperate graph
        disp_op = 0;
        show_ex = 1;
        if type_display==5 && ~disp_op && show_ex
            ys = zeros(length(Fees{1}.show),1);
            for test=Fees{1}.n_tests_start:Fees{1}.n_tests_stop
                results = load_results(Fees{1}.label,test);
                ys(test-Fees{1}.n_tests_start+1) = sum(sum(results.P .* results.gamma))/1000;
            end
            [ys_max_money idx] = max(ys(1:40));
            xs_min = xs(idx);
            ys = Flow_rates_norm{1}.*100;
            ys = max(ys);
            ys_min = ys(idx);
            hss=plot(ax1,[xs_min xs_min],[0 ys_min],'k:');
            hss=plot(ax1,[0 xs_min],[ys_min ys_min],'k:');
        end
        
        hh = [];
        for f=1:(n_fee+4)
            hh = [hh hs{f}];
        end
        legend(hh,legends,'FontName','Times New Roman','FontSize',10)
        xl=xlabel('Unit fee (% of free market price)','FontName','Times New Roman','FontSize',11);
        ylabel('Lines rate (% of line capacity)','FontName','Times New Roman','FontSize',11);
        %hold off
    end
    if type_display==5
        fig.Position(2) = fig.Position(2) - fig.Position(4);
        fig.Position(3:4) = [492   626];
        ax2=subplot(2,1,2);
        hold on
        count = 1;
        for f=1:n_fee
            xs = Fees{f}.n_tests_start:Fees{f}.n_tests_stop;
            xs = xs./Price_ref *100;
            ys = zeros(length(Fees{f}.show),1);
            for test=Fees{f}.n_tests_start:Fees{f}.n_tests_stop
                results = load_results(Fees{f}.label,test);
                ys(test-Fees{f}.n_tests_start+1) = sum(sum(results.P .* results.gamma))/1000;
                if ~disp_op && show_ex
                    if xs(test)==xs_min && f==1
                        ys_min=ys(test-Fees{f}.n_tests_start+1);
                    end
                end
            end
            plot(xs,ys,'Color',Colors(f,:),'LineWidth',1.1)
            legends{count}=strcat('\it ',Fees{f}.legend2);
            count=count+1;
        end
        axis tight
        ax2.XLim = ax1.XLim;
        xlabel('Unit fee (% of free market price)','FontName','Times New Roman','FontSize',11);
        ylabel('Total collected fees \Gamma_{SO} (k€)','FontName','Times New Roman','FontSize',11);
        vline(10/Price_ref*100,'k--')
        
        
        if disp_op
            legend(legends,'Location','northwest','FontName','Times New Roman','FontSize',10)
        else
            ax2.XColor = 'none';
            ax2.YDir = 'reverse';
            uistack(ax1, 'top')
            xl.Position(2) = xl.Position(2)+10;
            ax1.Position(2) = ax2.Position(2)+ ax2.Position(4);
            annotation('arrow',[ax1.Position(1) ax1.Position(1)],[ax1.Position(2) ax1.Position(2)+ax1.Position(4)])
            annotation('arrow',[ax2.Position(1) ax2.Position(1)],[ax2.Position(2)+ax2.Position(4) ax2.Position(2)])
            hss=plot(ax2,[xs_min xs_min],[0 ys_min],'k:');
            hss=plot(ax2,[0 xs_min],[ys_min ys_min],'k:');
        end
    end
end

%% Plot - Anamorphosis of market interactions
if strcmp(type_plot,'anaMar')
    % Plot options
    % 0 - No ponderation of power exchanges (default)
    % 1 - Power exchanges are poundered by their PT distance
    % 2 - Power exchanges are poundered by their Zthev distance
    type_pond = 0;
    % 0 - Unique figure
    % 1 - Multiple figures
    % 2 - Animate (saved as avi)
    type_display = 1;
    % 0 - No scaling (default)
    % 1 - Scaling (on lines thickness and axes limits)
    type_scale = 1;
    
    if n_fee>1
        warning('anaMar post-process may takes a lot of memory for showing multiple fee tariffs')
        warning off
    end
    
    for f=1:n_fee
        Ps = cell(Fees{f}.N_tests,1);
        EdgeColors = cell(Fees{f}.N_tests,1);
        first=1;
        for test=Fees{f}.n_tests_start:Fees{f}.n_tests_stop
            results = load_results(Fees{f}.label,test);
            if type_pond==1
                PT = distance_PT(results.testcase);
                Pss=results.P .* PT;
            elseif type_pond==2
                Zthev = distance_Zthev(results.testcase);
                Pss=results.P .* Zthev;
            else
                Pss=results.P;
            end
            % Symetrisation of power exchanges
            Ps{test} = abs((Pss+Pss')/2);
            
            % Markers color definition
            if first
                NodeColors = zeros(results.n_agents,3);
                NodeShapes = cell(results.n_agents,1);
                areashape = {'o','s','*','^'};
                for n=1:results.n_agents
                    NodeColors(n,:) = results.testcase.areacolor{results.testcase.bus(results.testcase.gen(n,1),7)};
                    NodeShapes{n} = areashape{results.testcase.bus(results.testcase.gen(n,1),7)};
                end
                first=0;
            end
            % Edges color definition
            EdgeColors{test} = [];
            Color_intra = [40,40,40]/250; % grey: intra-zone exchanges
            Color_extra = [51, 153, 255]/255; % bleu: extra-zone exchanges
            if results.Pmax(1)>0
                ag_order=find(results.Pmax>0);
            else
                ag_order=find(results.Pmax<0);
            end
            for n=ag_order'
                for m=results.om{n}
                    if Ps{test}(n,m)~=0
                        if results.testcase.bus(results.testcase.gen(n,1),7)==results.testcase.bus(results.testcase.gen(m,1),7)
                            EdgeColors{test} = [EdgeColors{test}; Color_intra];
                        else
                            EdgeColors{test} = [EdgeColors{test}; Color_extra];
                        end
                    end
                end
            end
        end
        %     anamorphoses(Ps,'Display',type_display,'Scale',type_scale)
%         anamorphoses(Ps,'Display',type_display,'Scale',type_scale,...
%             'NodeColors',NodeColors,'EdgeColors',EdgeColors,'RotRefId',11,...
%             'RotRefAngle',-pi/4,'EdgeThreshold',10^-4)
        anamorphoses(Ps,'Display',type_display,'Scale',type_scale,...
            'NodeColors',NodeColors,'EdgeColors',EdgeColors,'RotRefId',11,...
            'RotRefAngle',-pi/4,'EdgeThreshold',10^-2,'FPS',2,'Filename',strcat('video',num2str(f)),...
            'Legend','on','Axis','off')
    end
end

%% Plot - Anamorphosis of network usage
if strcmp(type_plot,'anaNet')
    % Plot options
    % 0 - Show power flows on electrical network
    % 1 - Show PT anamorphosis of the electrical network
    % 2 - Show Zthev anamorphosis of the electrical network
    type_pond = 1;
    % 0 - Unique figure
    % 1 - Multiple figures
    % 2 - Animate (saved as avi)
    type_display = 0;
    % 0 - No scaling (default)
    % 1 - Scaling (on lines thickness and axes limits)
    type_scale = 0;
    
    if n_fee>1
        warning('anaNet post-process may takes a lot of memory for showing multiple fee tariffs')
        warning off
    end
    
    for f=1:n_fee
        Ps = cell(Fees{f}.N_tests,1);
        EdgeColors = cell(Fees{f}.N_tests,1);
        first=1;
        for test=Fees{f}.n_tests_start:Fees{f}.n_tests_stop
            results = load_results(Fees{f}.label,test);
            
            S.EndNodes = results.testcase.branch(:,1:2);
            if type_pond==1
                dist = read_mpc_case_dist_PT(results.testcase);
                dist_inv = inv_dist(dist);
            elseif type_pond==2
                dist = read_mpc_case_dist_Zthev(results.testcase);
                dist_inv = inv_dist(dist);
            else
                S.Weight = results.PowerFlowDC;
            end
            if type_pond==1 || type_pond==2
                S.Weight = zeros(size(S.EndNodes,1),1);
                for br=1:size(S.EndNodes,2)
                    S.Weight(br) = dist_inv(results.testcase.branch(br,1),results.testcase.branch(br,2));
                end
            end
            Ps{test} = struct2table(S);
            
            % Markers color definition
            if first
                NodeColors = zeros(size(results.testcase.bus,1),3);
                for bus=1:size(results.testcase.bus,1)
                    NodeColors(bus,:) = results.testcase.areacolor{results.testcase.bus(bus,7)};
                end
                first=0;
            end
            % Edges color definition
            EdgeColors{test} = zeros(size(results.testcase.branch,1),3);
            Color_intra = [40,40,40]/250; % grey: intra-zone exchanges
            Color_extra = [51, 153, 255]/255; % bleu: extra-zone exchanges
            for br=1:size(results.testcase.branch,1)
                if Ps{test}.Weight(bus)~=0
                    if results.testcase.bus(results.testcase.branch(br,1),7)==results.testcase.bus(results.testcase.branch(br,2),7)
                        EdgeColors{test}(br,:) = Color_intra;
                    else
                        EdgeColors{test}(br,:) = Color_extra;
                    end
                end
            end
        end
        
        % 0 - No scaling (default)
        % 1 - Scaling (on lines thickness and axes limits)
        type_scale = 0;
        %     anamorphoses(Ps,'Display',type_display,'Scale',type_scale)
        if type_pond==1 || type_pond==2
            anamorphoses(Ps{1},'Display',0,'Scale',0,...
                'NodeColors',NodeColors,'EdgeColors',EdgeColors,'Marker','s','RotRefId',11,...
                'RotRefAngle',-pi/4,'EdgeWidth','off','Axis','off')
        else
            anamorphoses(Ps,'Display',type_display,'Scale',type_scale,...
                'NodeColors',NodeColors,'EdgeColors',EdgeColors,'Marker','s','RotRefId',11,...
                'RotRefAngle',-pi/4,'EdgeThreshold',10^-4,'FPS',2,'Filename',strcat('video',num2str(f)),...
                'Axis','off')
        end
    end
end
