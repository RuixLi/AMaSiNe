function [injection_site_ROI_pts] = injection_volume_pix_ROI( ANO,inj_ii )
%UNTITLED �� �Լ��� ��� ���� ��ġ
%   �ڼ��� ���� ��ġ

injection_site_ROI_pts=find(ANO==inj_ii);
[pts_x,pts_y,pts_z]=ind2sub(size(ANO),injection_site_ROI_pts);
injection_site_ROI_pts=[pts_y,pts_x,pts_z];

end

