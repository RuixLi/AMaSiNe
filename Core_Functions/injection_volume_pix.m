function [injection_site_pts] = injection_volume_pix( img_ch_thumbnail )
%UNTITLED 이 함수의 요약 설명 위치
%   자세한 설명 위치
img_ch_thumbnail=imadjust(img_ch_thumbnail,stretchlim(img_ch_thumbnail,0),[0 1]);
img_thresh = graythresh( img_ch_thumbnail );
bw_bright=imbinarize(img_ch_thumbnail,img_thresh*5);

bw_grouped= double(bw_bright);
avg_filter = fspecial('average',[5 5]);
bw_grouped =imfilter(bw_grouped,avg_filter,'replicate');
bw_grouped(bw_grouped<0.5) =0;
bw_grouped(bw_grouped>=0.5) =1;
bw_grouped=logical(bw_grouped);

bw_injection_site=bw_grouped & bw_bright;

injection_site_pts=find(bw_injection_site);
[pts_x,pts_y]=ind2sub(size(bw_grouped),injection_site_pts);
injection_site_pts=[pts_y,pts_x];

end

