function [ out_bnd_alpha ] = ref_boundarypad_0809_step5( img_ref, xy_pix_ref )
%UNTITLED3 이 함수의 요약 설명 위치
%   자세한 설명 위치

img_ref(img_ref~=0)=255;
img_ref=logical(img_ref);

BWdfill = imfill(img_ref, 'holes');


seD = strel('disk',round(75/xy_pix_ref));

img_ref_pad = imerode(BWdfill,seD);

BWdfill=BWdfill-img_ref_pad;

im_ref_bnd_pix=find(BWdfill);

[coord_x, coord_y]=ind2sub(size(img_ref),im_ref_bnd_pix);

out_bnd_alpha=alphaShape(coord_x,coord_y,sqrt(2)*xy_pix_ref+1);

end

