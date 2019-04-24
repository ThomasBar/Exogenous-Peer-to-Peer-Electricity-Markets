function f=rotation(f,theta_rot,v_center)
% 
% 
% theta_rot: counter clock-wise in radiant
% v_in = [X_in;Y_in];
% v_out = [X_out;Y_out];

if nargin<3
    v_center = [0,0];
end

v_in = [f.XData',f.YData'];
ax = gca;
scale_x = ax.XLim;
scale_y = ax.YLim;

% create a matrix which will be used later in calculations
center = repmat(v_center, size(v_in,1),1);
% define a counter-clockwise rotation matrix
R = [cos(theta_rot) -sin(theta_rot); sin(theta_rot) cos(theta_rot)];
% do the rotation...
v_out = (R*(v_in - center)')' + center;

f.XData=v_out(:,1);
f.YData=v_out(:,2);

ax.XLim = scale_x;
ax.YLim = scale_y;