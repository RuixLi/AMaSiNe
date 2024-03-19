function [ tform_trans ] = ...
    tform_finder_translation_1015 ( img_act, img_ref, xy_pix_ref, BlockSz )
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

warning('off')

% img_ref=padarray(img_ref,round([1500 1500]/xy_pix_ref));
% img_act=padarray(img_act, round([1500 1500]/xy_pix_ref));


%%% Set Fixed Points in img_act
% This is to assure even sampling of the points in the actual image

x_act_recovered2=1:round(300/xy_pix_ref):size(img_act,2);
y_act_recovered2=1:round(300/xy_pix_ref):size(img_act,1);

[x_act_recovered2,y_act_recovered2]=meshgrid(x_act_recovered2,y_act_recovered2);
x_act_recovered2=x_act_recovered2(:); y_act_recovered2=y_act_recovered2(:);

[img_act_bnd_coord] = ref_boundarypad_0809( img_act,xy_pix_ref );

in_bnd = inpolygon(x_act_recovered2,y_act_recovered2,...
    img_act_bnd_coord(:,2),img_act_bnd_coord(:,1));


xy_act=[x_act_recovered2(in_bnd),y_act_recovered2(in_bnd)];


%%% Detect SURF Feature Points in img_ref (Low Threshold)
points_ref_3 = detectSURFFeatures(img_ref,'MetricThreshold',1,'NumOctaves',1);


%%% Describe Detected Feature Points (HOG descriptors)

[features_ref_3,valid_points_ref_3] = extractHOGFeatures(img_ref,points_ref_3,'CellSize',...
    round([50 50]/xy_pix_ref),'BlockSize',[21 21],'NumBins',9,...
    'UseSignedOrientation',false);
[features_act_3,valid_points_act_3] = extractHOGFeatures(img_act,xy_act,'CellSize',...
    round([50 50]/xy_pix_ref),'BlockSize',[21 21],'NumBins',9,...
    'UseSignedOrientation',false);

%%% Match Similar Features

indexPairs_3 = matchFeatures(features_ref_3,features_act_3,'Unique',true,...
    'MatchThreshold',100,'MaxRatio',1,'Metric','SSD');

%%% Crop Out Unmatched Feature Points

matchedPoints_ref_3 = valid_points_ref_3(indexPairs_3(:,1),:);
matchedPoints_ref_3=matchedPoints_ref_3.Location;

matchedPoints_act_3 = valid_points_act_3(indexPairs_3(:,2),:);

%%% Crop Out Incorrectly Matched Points (Criteria : zscore(distance)>2 )

if size(matchedPoints_ref_3,1)~=0
    relative_coordinates_3=matchedPoints_ref_3-matchedPoints_act_3;
    dist_norm_3=hypot(relative_coordinates_3(:,1),relative_coordinates_3(:,2));
    legit_pts_indx_3=find(dist_norm_3<(500/xy_pix_ref));
    
    matchedPoints_ref_3=matchedPoints_ref_3(legit_pts_indx_3,:);
    matchedPoints_act_3=matchedPoints_act_3(legit_pts_indx_3,:);
    
end

if size(matchedPoints_act_3,1)>4
    
    tform_trans = fitgeotrans( matchedPoints_act_3, matchedPoints_ref_3,'nonreflectivesimilarity');
%     outputView_3 = imref2d(size(img_ref));
%     [matched_img]  = imwarp(img_act,tform_trans,'cubic','OutputView',outputView_3);
% %     [matched_img]  = imwarp(img_act,tform_trans,'cubic');
%     figure; imshowpair(matched_img,img_ref)
else
    
%     tform_trans = imregcorr(img_act,matched_img,'translation');
%      [matched_img2]  = imwarp(img_act,tform_trans,'cubic');
    
    disp('not enough matching point pairs between the two images')
    return
    
end


end

