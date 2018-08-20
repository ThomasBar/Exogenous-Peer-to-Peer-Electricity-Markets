function printpf_perso(testcase,branch_t,Power,Theta,Eta)
% 
% 
% Inputs:
%   - testcase  : mpc structure
%   - branch_t  : Indicate the type branch flow (DC or AC)
%   - Power     : Final net power of all units (flexible and non flexible)
%   - Theta     : Final voltage angles
%   - Eta       : Final nodal prices
% 

%% Network data
[nodes,ref_node,n_units,Pmin,Pmax,a,b,...
    units_node,node_units,branch_conn,branch_B,branch_G,branch_max,bus_area] = ...
    read_mpc_case(testcase,branch_t);

n_nodes = length(nodes);
n_branch = size(branch_max,1);

%% Text output
fd = 1; % Output fprintf (1 -> screen)


%% Bus data
    fprintf(fd, '\n================================================================================');
    fprintf(fd, '\n|     Bus Data                                                                 |');
    fprintf(fd, '\n================================================================================');
    fprintf(fd, '\n Bus      Voltage          Generation             Load        ');
    fprintf(fd, '  Lambda(€/MW)');
    fprintf(fd, '\n  #   Mag(pu) Ang(deg)   P (MW)   Q (MVAr)   P (MW)   Q (MVAr)');
    fprintf(fd, '     P        Q   ')
    fprintf(fd, '\n----- ------- --------  --------  --------  --------  --------');
    fprintf(fd, '  -------  -------')


tot_gen = 0;
tot_load = 0;

for i =nodes
   fprintf(fd, '\n%5d%7.3f%9.3f', [i 1.000 Theta(i)]);
   
   if i == ref_node
       fprintf(fd, '*');
   else
       fprintf(fd, ' ');
   end
   
   
   gen_value = 0;
   load_value = 0;
   for n=node_units{i}
        if a(n)~= 0
           gen_value = gen_value + Power(n);
        else
            load_value = load_value + Power(n);
        end
   end
   load_value = abs(load_value);
   
   if gen_value ~= 0    
       fprintf(fd, '%10.2f%10.2f', [gen_value , 0]);
       tot_gen = tot_gen + gen_value;
   else
       fprintf(fd, '      -         -   ');
   end
   
   if load_value ~= 0       
       fprintf(fd, '%9.2f%10.2f ', [load_value , 0]);
       tot_load = tot_load + load_value;
   else
       fprintf(fd, '      -         -   ');
   end
   
   fprintf(fd, '%9.3f', Eta(i));
   fprintf(fd, '     -');
end
   
   fprintf(fd, '\n                        --------  --------  --------  --------');
   fprintf(fd, '\n               Total: %9.2f %9.2f %9.2f %9.2f', [ tot_gen , 0, tot_load, 0]);

fprintf(fd,'\n');



%% Branch data
    fprintf(fd, '\n================================================================================');
    fprintf(fd, '\n|     Branch Data                                                              |');
    fprintf(fd, '\n================================================================================');
    fprintf(fd, '\nBrnch   From   To    From Bus Injection   To Bus Injection     Loss (I^2 * Z)  ');
    fprintf(fd, '\n  #     Bus    Bus    P (MW)   Q (MVAr)   P (MW)   Q (MVAr)   P (MW)   Q (MVAr)');
    fprintf(fd, '\n-----  -----  -----  --------  --------  --------  --------  --------  --------');
    

inc = 1;
PF = zeros( n_nodes ); 
for i =nodes
   for j=branch_conn{i}
       if j>i
           if branch_t=='DC'
               PF(i,j) = (Theta(i)-Theta(j))*branch_B(i,j);
               PF(j,i) = (Theta(j)-Theta(i))*branch_B(j,i);
           end
           
           fprintf(fd, '\n%4d%7d%7d%10.2f%10.2f%10.2f%10.2f%10.3f%10.2f',...
               [inc, i, j, PF(i,j), 0, PF(j,i), 0, 0, 0]);
           
           inc = inc +1;
       end
   end
end

    fprintf(fd, '\n                                                             --------  --------');
    fprintf(fd, '\n                                                    Total:%10.3f%10.2f',[0,0]);
    fprintf(fd, '\n');



%% generators P constraints
gen_const = [];
for n=1:n_units
    if a(n)~= 0
        if Power(n)<=Pmin(n)|| Pmax(n)<=Power(n)
            gen_const = [gen_const, n];
        end
    end
end

if length(gen_const)>0
    fprintf(fd, '\n================================================================================');
    fprintf(fd, '\n|     Generation Constraints                                                   |');
    fprintf(fd, '\n================================================================================');
    fprintf(fd, '\n Gen   Bus                  Active Power Limits');
    fprintf(fd, '\n  #     #     Pmin mu     Pmin       Pg       Pmax    Pmax mu');
    fprintf(fd, '\n----  -----   -------   --------  --------  --------  -------');
    
    for n=gen_const
        fprintf(fd, '\n%4d%6d ', [n, units_node{n}]);
        fprintf(fd, '      -   ');
        fprintf(fd, '%10.2f%10.2f%10.2f', [Pmin(n), Power(n), Pmax(n)]);
        fprintf(fd, '      -   ');
    end   
    fprintf(fd, '\n');
end


%% line flow constraints
branch_const_num = [];
branch_const_from = [];
branch_const_to = [];
inc = 1;
for i =nodes
   for j=branch_conn{i}
       if j>i
            if abs(PF(i,j)) >= branch_max(i,j)
                branch_const_num = [branch_const_num, inc];
                branch_const_from = [branch_const_from, i];
                branch_const_to = [branch_const_to, j];
            end
            inc = inc +1;
       end
   end
end


if length(branch_const_num)>0
    
    fprintf(fd, '\n================================================================================');
    fprintf(fd, '\n|     Branch Flow Constraints                                                  |');
    fprintf(fd, '\n================================================================================');
    fprintf(fd, '\nBrnch   From     "From" End        Limit       "To" End        To');
    str = '\n  #     Bus    Pf  mu     Pf      |Pmax|      Pt      Pt  mu   Bus';
    fprintf(fd, str);
    fprintf(fd, '\n-----  -----  -------  --------  --------  --------  -------  -----');
    
    for inc=1:length(branch_const_num)
        num = branch_const_num(inc);
        i = branch_const_from(inc);
        j = branch_const_to(inc);
        
        fprintf(fd, '\n%4d%7d', [num,i]);
        fprintf(fd, '      -   ');
        fprintf(fd, '%9.2f%10.2f%10.2f',[-branch_max(i,j), -PF(i,j), branch_max(i,j)]);
        fprintf(fd, '      -   ');
        fprintf(fd, '%6d', j);
    end
    fprintf(fd, '\n');
end


