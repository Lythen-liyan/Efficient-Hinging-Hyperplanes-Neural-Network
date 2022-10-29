 clear
close all
%% generate the train data and test data

%% you should change this address to put your own data here.
load('C:/Users/hm383/Desktop/EHH/EHH/data/bouc-wen2.mat');


na=10;%1;
nb=15;
dbstop if error

u_interval = [min(u), max(u)];
y_interval = [min(y), max(y)];
uval_multisine = uval_multisine';
yval_multisine = yval_multisine';
uval_sinesweep = uval_sinesweep';
yval_sinesweep = yval_sinesweep';

% ulag = 1;
u_id = 0:14;%[1 3 2 6];
y_id = 1:15;%[1 2 5 4 6 3 9 11 10 12 7];
u = reshape(u,8192,5);
y = reshape(y,8192,5);
% [phi, yphi]=arrange_uy(u(:,5), y(:,5), na, nb, u_interval, y_interval,ulag);
u_use = u(:, 4);
y_use = y(:, 4);
[phi, yphi] = arrange_phi(u_use(:),y_use(:),u_id, y_id, u_interval, y_interval);

dim = size(phi,2);
Ntrain=length(yphi);

Ntest1=length(yval_multisine);
Ntest2=length(yval_sinesweep);
x_train=phi;
y_train=yphi;
   




%% Parameter Initialiation
config_file = 'config.ini';
parameters = init_par(config_file);
penalty = parameters.penalty;  % complexity penalty
num_train = parameters.num_train;  % number of training
percent = parameters.percent; % percentage of training data
parameters.lambda=[1e-7,1e-6,1e-5,1e-4];%; should be tuned for specific problem?
epsilon = 1e-3;
%%--EHH network optimization--
%--ten times optimization--
Err_sim1_EHH_0 = zeros( 10, 1);
Err_sim2_EHH_0 = Err_sim1_EHH_0;
Err_sim1_EHH = Err_sim1_EHH_0;
Err_sim2_EHH = Err_sim1_EHH_0;
Num_nn = Err_sim1_EHH_0;
train_times = zeros( 10, 1);
Duration = zeros( 10, 1);
M0 = zeros(10, 2);

for counts = 1 : 10
    
    t1 = clock;
    
    
    [B_first, weights, id_var_bb, stem_B, adja, lof0, err0, lambda_opt] = Ini_network(x_train, y_train, parameters);
    num_m0 = [size(B_first, 1), size(stem_B, 1)-size(B_first, 1)];
    
    flag = 1;
    [err0, lof0]
    
    [~,ysim1] = sys_simulation_ehh_phi(u_id, y_id, uval_multisine, yval_multisine, B_first, stem_B, weights, u_interval, y_interval);
    [~,ysim2] = sys_simulation_ehh_phi(u_id, y_id, uval_sinesweep, yval_sinesweep, B_first, stem_B, weights, u_interval, y_interval);
    err_sim01 = sqrt(norm(ysim1(16:end)-yval_multisine(16:end))^2/(Ntest1-15))
    err_sim02 = sqrt(norm(ysim2(16:end)-yval_sinesweep(16:end))^2/(Ntest2-15))
    
    Err_sim1_EHH_0( counts ) = err_sim01;
    Err_sim2_EHH_0( counts ) = err_sim02;
    
    k_train = 0;
    while flag
        k_train = k_train + 1;
        [stem_B, adja, id_var_bb, lof, err]=Structue_optimization2(B_first, stem_B, adja, id_var_bb, weights, x_train,y_train,err0, parameters);
        %         [~, yahh] = sys_simulation_ehh(na, nb, u_v, B_first, stem_B, weights, u_interval, y_interval,ulag);
        %         sqrt(norm( yahh - y_test )^2 / Ntest)%norm( y_test - mean( y_test ) )^2;%sqrt(/Ntest);%
        [ err, lof]
        [B_first, BB, stem_B, adja, id_var_bb, weights, lof, err]=weights_optimization(B_first, stem_B, id_var_bb, x_train, y_train, lambda_opt, parameters);
        %         [~, yahh] = sys_simulation_ehh(na, nb, u_v, B_first, stem_B, weights, u_interval, y_interval,ulag);
        %         sqrt(norm( yahh - y_test )^2 / Ntest)%norm( y_test - mean( y_test ) )^2;%sqrt(/Ntest);%
        [ err, lof ]
        if lof<(1-epsilon)*lof0
            flag = 1;
            lof0 = lof;
            err0 = err;
        else
            flag = 0;
        end
    end
    
    t2 = clock;
    
    % [~,ysim1] = sys_simulation_ehh(na, nb, uval_multisine, B_first, stem_B, weights, u_interval, y_interval,ulag);
    [~,ysim1] = sys_simulation_ehh_phi(u_id, y_id, uval_multisine, yval_multisine, B_first, stem_B, weights, u_interval, y_interval);
    % [~,ysim2] = sys_simulation_ehh(na, nb, uval_sinesweep, B_first, stem_B, weights, u_interval, y_interval,ulag);
    [~,ysim2] = sys_simulation_ehh_phi(u_id, y_id, uval_sinesweep, yval_sinesweep, B_first, stem_B, weights, u_interval, y_interval);
    err_sim1 = sqrt(norm(ysim1(16:end)-yval_multisine(16:end))^2/(Ntest1-15))
    err_sim2 = sqrt(norm(ysim2(16:end)-yval_sinesweep(16:end))^2/(Ntest2-15))
    
    if err_sim2<2.1*10^(-5)
        dbstop at 109
    end
    
    M0(counts, :)=num_m0;
    B1{ counts } = B_first;
    Err_sim1_EHH( counts ) = err_sim1;
    Err_sim2_EHH( counts ) = err_sim2;
    train_times( counts ) = k_train;
    Duration( counts ) = etime(t2, t1);
    Num_nn( counts ) = length(weights)-1;
    ADJA{counts} = adja;
    WEIGHT{counts} = weights;
    
end


figure
plot(yval_multisine(7001:end),':','linewidth',1.5)
hold on
plot(ysim1(7001:end),'linewidth',1.5)
xlabel('Times Instant','fontsize',14)
ylabel('The outputs','fontsize',14)
legend('System output', 'Simulated output')

figure
plot(yval_sinesweep,':','linewidth',1.5)%(7001:end)
hold on
plot(ysim2,'linewidth',1.5)
xlabel('Times Instant','fontsize',14)
ylabel('The outputs','fontsize',14)
legend('System output', 'Simulated output')

