function [B_first, weights, id_var_bb, stem_B, adjacency_matrix, lof, err, lambda_opt]=Ini_network(x, y, parameters)

% input
%       x          ---------------- the sample x used for the forward
%                   procedure, with size N x dim, part of the whole samples
%       y          ---------------- the sample y used for the forward
%                   procedure, with size N x 1, part of the whole samples

% output
%       BBf      --- the basis function evaluated at the points
%       Bf       --- the parameters of the basis function
%       coe      --- the coefficient matrix, dim x 1
%--forward growing of the network-----
%--random strategy---

% Parameter initilization
shares = parameters.shares;  % quantile number of each coordinate, the number of points interpolate in the interval
structure_parameter = parameters.structure;  % the parameters for structure definition
lambda = parameters.lambda;% the parameter for the Lasso regression 
num_neurons_added = parameters.num_nn;


start_time = tic;
%% the first layer
[B0, BB0, id_var_bb0, stem_B0, id_layer0] = ini_basis(x,shares);  % not containing the constant basis

B = B0;
BB = BB0';
num_neurons = size(BB, 2);
stem_B = stem_B0;
id_layer = id_layer0;
id_var_bb = id_var_bb0;
Adja = zeros(num_neurons+num_neurons_added, num_neurons+num_neurons_added);


%% forward process
for nn = 1: num_neurons_added
    candidate_combination = nchoosek(1: num_neurons, 2); % All candidate combinations
    length_candi = size(candidate_combination, 1);
    rand_candi = randperm( length_candi );
    candidate_combination = candidate_combination( rand_candi, : );
    for ii = 1 : length_candi
        temp_combination = sort(candidate_combination(ii, :));
        temp_id1 = temp_combination(1);
        temp_id2 = temp_combination(2);
        temp_var1 = id_var_bb{temp_id1};
        temp_var2 = id_var_bb{temp_id2};
        if ismember(temp_combination, stem_B, 'rows')
            continue
        end
        if ~isempty(intersect(temp_var1, temp_var2))
            continue
        end
        stem_B = [stem_B; temp_combination];
        num_neurons = num_neurons + 1;
        id_var_bb{num_neurons} = sort([temp_var1, temp_var2]);
        B{num_neurons}=[B{temp_id1};B{temp_id2}];
        BB(:,num_neurons)=min(BB(:,temp_id1), BB(:, temp_id2));
        Adja(temp_id1, num_neurons) = 1;
        Adja(temp_id2, num_neurons) = 1;
        break
    end
end
 
% ------------------check if stem has duplications
tmp = find(stem_B(:, 1));
tmp = stem_B(tmp, :);
tmp1 = unique(tmp, 'rows');
if size(tmp1, 1) ~= size(tmp, 1)
    TT
end
% ------------------------
    
%% Lasso regression

lof = 1e6;
B0=B;
stem_B0=stem_B;
% id_layer0=id_layer;
id_var_bb0=id_var_bb;

for k = 1:length(lambda)
    [Bk, BBk, stem_Bk, Adjak, id_var_bbk, coefk, lofk, errk] = weights_optimization(B0, stem_B0, id_var_bb0, x, y,lambda(k), parameters);
    % ------------------check if stem has duplications
    tmp = find(stem_Bk(:, 1));
    tmp = stem_Bk(tmp, :);
    tmp1 = unique(tmp, 'rows');
    if size(tmp1, 1) ~= size(tmp, 1)
        k
    end
    % ------------------------
    
    execute_prune = 'X';
    if lofk < lof
        B = Bk;
        BB = BBk;
        stem_B = stem_Bk;
        adjacency_matrix = Adjak;
%         id_layer = id_layerk;
        id_var_bb = id_var_bbk;
        weights = coefk;
        lof = lofk;
        execute_prune = 'ok';
        lambda_opt=lambda(k);
    end
    fprintf('lambda: %2.2f, error: %6.4f, lof: %6.4f,  prune? %s \n', lambda(k), errk, lofk, execute_prune);
end

%--the information of the first hidden layer-----
num_nodes=size(stem_B,1);
pos_row_id = find(stem_B(:,1)>0);  %positive row index, the rows for the first hidden layer are zero
if isempty(pos_row_id)   % all the neurons are in the first hidden layer
    num1layer = num_nodes;
else
    num1layer = num_nodes - length(pos_row_id);  % number of nodes in the first hidden layer
end
B_first = cell2mat(B(1:num1layer));  % basis function matrix in the first hidden layer

%% The output
node_values = cal_node_value(B_first,stem_B,x);
hat_y = node_values*weights;
err = norm(hat_y - y)^2/norm(y-mean(y))^2;
stds = std(hat_y - y);
time = toc(start_time);

fprintf('Final results: lambda: %2.2f, error: %6.4f, lof: %6.4f, std: %6.4f, ellapsed time: %f \n', lambda_opt, err, lof, stds, time);
