%% Optimization loop
starttime = cputime;
stop = false;
for k =1:( max_it -1)
    for n =1: n_agents
        % y-update
        for m=om{n}
            Y(n,m,k +1)=Y(n,m,k) -beta(k)*(Y(n,m,k)-Y(m,n,k)) -alpha(k)*(P(n,m,k)-Z(n,m,k));
        end
        
        SumZ = sum(Z(n,om{n},k));
        
        % mu-updates
        Mup(n,k+1) = max(0, Mup(n,k)+rho(k)*(SumZ-Pmax(n)));
        Mum(n,k+1) = max(0, Mum(n,k)+rho(k)*(Pmin(n)-SumZ));

        % Calculus of the f factor
        fFactor = zeros ( n_agents ,1);
        for m=om{n}
            fFactor(m)=(abs(Z(n,m,k))+ delta1*power(k,- delta2));
        end
        SumfFactor = sum(fFactor);
        fFactor = fFactor/SumfFactor;

        % Calculus of Pi and Pi-tilde
        for m=om{n}
            % Pi-update
            PI= fFactor (m)*((Y(n,m,k+1) -b(n) -Mup(n,k+1) +Mum(n,k+1) -gamma(n,m))/a(n) - SumZ ) + Z(n,m,k);
            
            % Enforcement of the trade sign constraints
            if ismember (n, consumers ) && PI >0
                P(n,m,k+1) = 0;
            else
                if ismember (n, producers ) && PI <0
                    P(n,m,k+1) = 0;
                else
                    P(n,m,k+1) = PI;
                end
            end

        end
    end
    
    % Z-update
    Z(:,:,k+1) = (P(:,:,k+1)-P(:,:,k+1)')./2;

    % Calculus and test of the stopping criterion -- Different criteria possible
    if k >1
%         if sum(sum(abs(Y(:,:,k+1) -Y(:,:,k)))) < epsY && sum(sum(abs(Z(:,:,k+1) -Z(:,:,k)))) < epsZ
%         if max(max(abs(Y(:,:,k+1) -Y(:,:,k)))) < epsY && max(max(abs(Z(:,:,k+1) -Z(:,:,k)))) < epsZ
        if max(max(abs(Z(:,:,k+1) -Z(:,:,k)))) < epsZ
%         if max(max(abs(Y(:,:,k+1) -Y(:,:,k)))) < epsY && max(max(abs(Z(:,:,k+1) -P(:,:,k+1)))) < epsZ
%         if max(max(abs(Y(:,:,k+1) -Y(:,:,k)))) < epsY && sum(sum(Z(:,:,k+1))) < epsZ
%         if max(max(abs(Z(:,:,k+1) -P(:,:,k)))) < epsZ
%         if sum(sum(P(:,:,k+1))) < epsZ
%         if sum(sum(abs(Z(:,:,k+1) -P(:,:,k+1)))) < epsZ
            stop = true;
        end
    end
    
    if stop
        break;
    end
end
stoptime = cputime;

k_last_CI = k ;
comptime = stoptime - starttime ;

%% Plots - Raw results of convergence
% figure
% subplot(2,2,1)
% P_net = zeros(n_agents,k);
% for n= 1:n_agents
%     P_net(n,:) = reshape(sum(P(n,:,1:k),2),k,1);
%     plot(1:k,P_net(n,:))
%     hold on
% end
% title('Pnet')
% hold off
% subplot(2,2,3:4)
% for n= 1:n_agents
%     for m= 1:n_agents
%         plot(1:k,reshape(Y(n,m,1:k),k,1))
% %         plot(1:k,reshape(Y(n,m,1:k),k,1)+reshape(-Mup(n,1:k) +Mum(n,1:k) -gamma(n,m)*ones(1,k),k,1))
%         hold on
%     end
% end
% title('Y')
% hold off
% subplot(2,2,2)
% for n= 1:n_agents
%     plot(1:k,Mum(n,1:k))
%     hold on
%     plot(1:k,Mup(n,1:k))
% end
% title('Mu')
% hold off
% % savefig(strcat('simulations/results_',Fees.label,'_',num2str(test),'.fig'))

