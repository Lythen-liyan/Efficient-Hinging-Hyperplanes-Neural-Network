function [xsim, ysim]=sys_simulation_ehh_phi(u_id, y_id, u_v, y_v, B, stem_B, weights, u_interval, y_interval)

Lv = length(u_v);
u_v = reshape(u_v, Lv, 1);
% y_v = reshape(y_v, Lv, 1);
umin = u_interval(1);
umax = u_interval(2);
ymin = y_interval(1);
ymax = y_interval(2);
ysim = zeros(Lv, 1);
% ulag = 0;%2;

ns = max(max(u_id),max(y_id));
xsim = zeros(Lv, length(y_id)+length(u_id));
% ysim(1:ns)=y_v(1:ns);

for t = ns+1 : Lv
    reg1 = (ysim(t-y_id)-ymin)/(ymax-ymin);%(y_v(t-y_id)'-ymin)/(ymax - ymin);%
    %         reg2 = (u_v(t-1:-1:t-na)-umin)/(umax-umin);
    reg2 = (u_v(t-u_id)-umin)/(umax-umin);
    xsim( t, : ) = [ reg1', reg2'];
    ysim( t ) = cal_node_value( B, stem_B, xsim(t, :) )*weights;
end


