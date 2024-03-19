function [ img_skeleton_pts ] = skeletonize1018( img_skeleton, xy_pix )
%UNTITLED2 이 함수의 요약 설명 위치
%   자세한 설명 위치

        img_skeleton= imgaussfilt(img_skeleton,50/xy_pix);
        img_skeleton=fibermetric(img_skeleton,round([150 300]/xy_pix));
        
        structure_thresh = multithresh(img_skeleton,7);
        img_skeleton = imquantize(img_skeleton,structure_thresh);
        img_skeleton(img_skeleton<3)=0;
        img_skeleton(img_skeleton>0)=1;
        img_skeleton = bwmorph(img_skeleton,'thin',inf);
        img_skeleton_pts=find(img_skeleton);
        [img_act_no_scale_structure_pts_x,img_act_no_scale_structure_pts_y]=...
            ind2sub(size(img_skeleton),img_skeleton_pts);
        img_skeleton_pts=...
            [img_act_no_scale_structure_pts_y,img_act_no_scale_structure_pts_x];

end

