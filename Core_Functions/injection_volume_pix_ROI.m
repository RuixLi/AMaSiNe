function [injection_site_ROI_pts] = injection_volume_pix_ROI( ANO,inj_ii )
%UNTITLED 이 함수의 요약 설명 위치
%   자세한 설명 위치

injection_site_ROI_pts=find(ANO==inj_ii);
[pts_x,pts_y,pts_z]=ind2sub(size(ANO),injection_site_ROI_pts);
injection_site_ROI_pts=[pts_y,pts_x,pts_z];

end

