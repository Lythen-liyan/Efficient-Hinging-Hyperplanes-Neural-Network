function [B, BB, stem_B, adjacency_matrix, id_var_bb, weights, lof, err]=weights_optimization(B, stem_B, id_var_bb, x, y, lambda, parameters)
%PRUNING TREES
%

%% parameters
%  complexity penalty
penalty = parameters.penalty;
% lasso parameters
gamma = parameters.gamma;
rho = parameters.rho;
precision = parameters.precision;
quiet = parameters.quiet;

%% generate the adjacency matrix A in the net,  where A(i, j) = 1 indicates that node i is connected to node j
num_nodes = size(stem_B,1);

% ---------------------------------check if stem_B_new has duplicated rows
tt = stem_B(stem_B(:, 1) > 0, :);
tmp = unique(tt, 'rows');
if size(tmp, 1) ~= size(tt, 1)
    disp('duplication occurs in the first place in prune_node.m')
    dbstop at 23
end
% ---------------------------------

num_connection = nnz(stem_B);
row_indices = zeros(num_connection, 1);
col_indices = zeros(num_connection, 1);
counter = 1;
for kk=1:num_nodes
    for jj = 1:2
        vkk=stem_B(kk,jj);
        if vkk > 0
            row_indices(counter) =  vkk;
            col_indices(counter) =  kk;
            counter = counter + 1;
        end
    end
end
adjacency_matrix = sparse(row_indices, col_indices, 1, num_nodes, num_nodes+1);
% ----------------------------check if any two columns in adjacency matrix is the same
tmp_index = find(sum(adjacency_matrix(:, 1:end-1)) > 0);
bb1 = adjacency_matrix(:, tmp_index)' ;
aa = unique(bb1, 'rows');
tmp = size(aa, 1);
if length(tmp_index) ~= tmp
    disp('Duplications in the adjacency matrix')
    dbstop at 49
end
% -----------------------------
%% compute the output values of each neuron, using the sample sata
node_values = cal_node_value(B, stem_B, x);

%% cpmpute the weights of each neuron to the output
lambda = lambda * sqrt(2*log10(num_nodes + 1));   % parameters determined by the number of neurons in the net
weights = lasso(node_values, y, lambda, rho, gamma, quiet); % weights are trained using lasso
weights_of_constant = weights(1);
weights_of_nodes = weights(2:end);

%% delete nodes that have no successors and have no contribute to the output
if sum(abs(weights_of_nodes)) > precision
    index_active_node = abs(weights_of_nodes) > precision;
    adjacency_matrix(index_active_node, num_nodes + 1) = 1;   % the last column
    % find useless neurons based on out-fan
    out_fan = sum(adjacency_matrix, 2);
    rem_index = find(out_fan > 0);  % indices of node to be remained
    
    num_node_remained = length(rem_index);
    while num_node_remained < num_nodes
        num_nodes = num_node_remained;
        % ----------------------------check if any two columns in adjacency matrix is the same
        tmp_index = find(sum(adjacency_matrix(:, 1:end-1)) > 0);
        tmp = size(unique(adjacency_matrix(:, tmp_index)', 'rows'), 1);
        if length(tmp_index) ~= tmp
            disp('Duplications in the adjacency matrix--2')
            dbstop at 77
        end
        % -----------------------------
        adjacency_matrix = adjacency_matrix(rem_index, [rem_index',end]);
        % update network
        if iscell(B)  % this concerns the whole B
            B=B(rem_index);
        else  % here concerns B_first
            rem_1=intersect(1:length(B), rem_index);
            B=B(rem_1,:);
        end
        id_var_bb = id_var_bb(rem_index);
        weights_of_nodes = weights_of_nodes(rem_index);
        stem_B = zeros(num_node_remained, 2);
        for nn = 1:num_node_remained
            tmp_id = find(adjacency_matrix(:,nn) > 0)';
            if ~isempty(tmp_id)
                if length(tmp_id) ~= 2
                    fprintf('Error when computing adjacency matrix: number of inputs is larger than 2\n')
                    quit()
                end
                stem_B(nn, :) = tmp_id;
            end
        end
        
        out_fan = sum(adjacency_matrix, 2);
        rem_index = find(out_fan > 0);  % indices of neurons to be remained
        num_node_remained=length(rem_index);
    end
    % ---------------------------------check if stem is computed properly
%     tmp_stem = adjacency_to_stem(adjacency_matrix(:, 1:end-1));
%     tt = sortrows(tmp_stem);
    ttt = sortrows(stem_B);
%     tttt = unique(tmp_stem, 'rows');
%     ttttt = tmp_stem(tmp_stem(:, 1) > 0, :);
%     if size(tttt, 1) ~= unique(ttttt)  % generate stem by program, where error arose
%         disp('1')
%     end
%     if size(tt, 1) ~= size(ttt, 1)   % generated stem by program is not consistent with that in iteration in size
%         disp('3')
%     end
%     if ~isequal(tt, ttt)   % generated stem by program is not consistent with that in iteration in content
%         disp('4')
%     end
    aa = stem_B(stem_B(:, 1) > 0, :);
    if size(unique(aa, 'rows'), 1) ~= size(aa, 1)
        disp('Duplications in stem--2')
        dbstop at 124
    end
    % ---------------------------------
    % calculate the output of each neuron
    node_values = cal_node_value(B, stem_B, x);
    weights = [weights_of_constant; weights_of_nodes];
    BB = node_values(:,2:end);
    
    hat_y = node_values * weights;
    err = norm(hat_y - y)^2 / norm(y - mean(y))^2;
    stds =  std(hat_y-y);
%     lof = err / ( 1 - ( num_nodes + 2 + penalty * (num_nodes+1) ) /
%     size(x, 1) )^2; ?did I write this?
% cm = trace(node_values*inv(node_values'*node_values)*node_values');
cm = num_nodes+1;%trace(BB*inv(BB'*BB)*BB')+1;%
    lof = err / ( 1 - ( cm + penalty * (num_nodes) ) / size(x, 1) )^2;%*norm(y - mean(y))^2
else % if all neurons contribute nothing to the output, then delete all nodes
    lof = 10;
    err = norm(y)^2 / norm(y - mean(y))^2;
    stds =  std(y);
    if weights_of_constant == 0
        BB=[];
    else
        BB = node_values(:, 2:end);
    end
end

