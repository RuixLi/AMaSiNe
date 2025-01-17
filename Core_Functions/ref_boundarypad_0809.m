function [ in_bnd_alpha] = ref_boundarypad_0809( img_ref, xy_pix_ref )
%UNTITLED3 이 함수의 요약 설명 위치
%   자세한 설명 위치

[~, threshold] = edge(img_ref, 'sobel');
fudgeFactor = .3;
BWs = edge(img_ref,'sobel', threshold * fudgeFactor);

se = strel('disk', round(250/xy_pix_ref)); %200


BWsdil = imdilate(BWs, se);


BWdfill = imfill(BWsdil, 'holes');


seD = strel('diamond',1);

img_ref_pad = imerode(BWdfill,seD);
img_ref_pad = imerode(img_ref_pad,seD);

im_ref_bnd_pix=find(img_ref_pad);

[coord_x, coord_y]=ind2sub(size(img_ref),im_ref_bnd_pix);

in_bnd_alpha=alphaShape(coord_y,coord_x,sqrt(2)*xy_pix_ref+1);

end

