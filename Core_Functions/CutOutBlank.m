function [ window_bnd ] = CutOutBlank(I)
% CUT OUT REGIONS OUTSIDE BOUNDARY TO SAVE COMPUTING RESOURCES %

logic_sum_x=logical(sum(I(:,:,1),1));
first_x=find(logic_sum_x,1,'first'); last_x=find(logic_sum_x,1,'last');

logic_sum_y=logical(sum(I(:,:,1),2));
first_y=find(logic_sum_y,1,'first'); last_y=find(logic_sum_y,1,'last');
window_bnd=[first_y,last_y,first_x,last_x];


% I_cutout=I(first_y:last_y, first_x:last_x,:);
end

