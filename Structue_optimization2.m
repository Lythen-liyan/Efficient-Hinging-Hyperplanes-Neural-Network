function [stem_B, adjacency_matrix, id_var_bb, lof, err]=Structue_optimization2(B_first, stem_B, adjacency_matrix, id_var_bb, weights, x,y,err0, parameters)
% functions for structural optimization

penalty = parameters.penalty;
err = err0;

num_nodes=size(stem_B,1);
cm = num_nodes + 1;
num1layer = size(B_first, 1);
lof = err / ( 1 - ( cm + penalty * (num_nodes) ) / size(x, 1) )^2;%*norm(y - mean(y))^2

% pos_row_id = find(stem_B(:,1)>0);  %positive row index, the rows for the first hidden layer are zero
% if isempty(pos_row_id)   % all the neurons are in the first hidden layer
%     num1layer = num_nodes;
% else
%     num1layer = num_nodes - length(pos_row_id);  % number of nodes in the first hidden layer
% end

for ii = num1layer+1:1:num_nodes
    node_values = cal_node_value(B_first, stem_B, x);
    change_node_id = find( adjacency_matrix(ii, 1:end-1) ~=0);
    to_com_id = setdiff(stem_B(change_node_id,:),ii);
    flag = 1;   % variable that controls the optimization in each column
    while flag
        flag = 0;
        ori_idx = stem_B(ii, :);
        
        candidate_combination = [repmat(ori_idx(1), ii-2, 1), setdiff((1:ii-1)', ori_idx(1))]; 
        candidate_combination = [candidate_combination; repmat(ori_idx(2), ii-2, 1), setdiff((1:ii-1)', ori_idx(2))];
        candidate_combination = sort(candidate_combination, 2);
        for kk = 1 : size(candidate_combination, 1)
            temp_combination = candidate_combination(kk, :);
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
            if ~isempty(intersect([temp_var1, temp_var2], cell2mat(id_var_bb(to_com_id))))
                continue
            end
            Adja_temp = adjacency_matrix;
            Adja_temp( :, ii )=0;
            Adja_temp(temp_id1, ii)=1;
            Adja_temp(temp_id2, ii)=1;
            stem_B_temp = stem_B;
            stem_B_temp(ii, :) = sort([temp_id1, temp_id2]);
            id_var_bb_temp = id_var_bb;
            id_var_bb_temp{ii} = sort([id_var_bb{temp_id1}, id_var_bb{temp_id2}]);
            node_value_temp = node_values;  %note the constant basis
            node_value_temp(:, ii+1) = min( node_values(:, temp_id1+1), node_values(:, temp_id2+1));
            
%             change_node_id = find( Adja_temp(ii, 1:end-1) ~=0);
            for kc = 1: length(change_node_id)
                id_kk = change_node_id(kc);
                i1 = stem_B_temp(id_kk, 1);
                i2 = stem_B_temp(id_kk, 2);
                node_value_temp(:, id_kk+1 ) = min( node_value_temp(:, i1+1), node_value_temp(:, i2+1));
                id_var_bb_temp{id_kk} = sort([id_var_bb_temp{i1}, id_var_bb_temp{i2}]);
            end
            hat_y_temp = node_value_temp * weights;
            err_temp = norm(hat_y_temp - y)^2 / norm(y - mean(y))^2;
            
            lof_temp = err_temp / ( 1 - ( cm + penalty * (num_nodes) ) / size(x, 1) )^2;%*norm(y - mean(y))^2
            
            if err_temp<err0
                adjacency_matrix = Adja_temp;
                stem_B = stem_B_temp;
                id_var_bb = id_var_bb_temp;
                err0=err;
                err = err_temp;
                lof = lof_temp;
                flag = 1;
                if size(unique(stem_B(num1layer+1:end,:),'rows'),1)<size(stem_B(num1layer+1:end,:),1)
                    dbstop at 74
                end
            end
        end
    end
end
