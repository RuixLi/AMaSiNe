
function [img_similarity,img_act_recovered_3] = lwm_compensation0916(img_act, img_ref,downscaled_xy_pix,BlockSz)
% Try matching a pair of images--one from the atlas(img_ref), the other that you
% imaged(img_act)--and measure their similarity.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 1st STAGE : CRUDE MATCHING OF THE IMAGES %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



warning('off')


img_ref=padarray(img_ref,round([1500 1500]/downscaled_xy_pix));
img_act=padarray(img_act, round([1500 1500]/downscaled_xy_pix));

%%% Detect SURF Feature Points
points_ref_1 = detectSURFFeatures(img_ref,'MetricThreshold',150,'NumOctaves',3);
points_act_1 = detectSURFFeatures(img_act,'MetricThreshold',150,'NumOctaves',3);

%%% Describe Detected Feature Points (HOG descriptors)
[features_ref_1,valid_points_ref_1] = extractHOGFeatures(img_ref,points_ref_1,'CellSize',...
    round([250 250]/downscaled_xy_pix),'BlockSize', BlockSz);      % Cell size = 200x200 um;
[features_act_1,valid_points_act_1] = extractHOGFeatures(img_act,points_act_1,'CellSize',...
    round([250 250]/downscaled_xy_pix),'BlockSize', BlockSz);      % Cell size = 200x200 um;

%%% Match Similar Features (Low Max Ratio)
indexPairs_1 = matchFeatures(features_ref_1,features_act_1,...
    'Unique',true,'MatchThreshold',90,'MaxRatio',0.90,'Metric','SSD');

%%% Crop Out Unmatched Feature Points
matchedPoints_ref_1 = valid_points_ref_1(indexPairs_1(:,1),:);
matchedPoints_act_1 = valid_points_act_1(indexPairs_1(:,2),:);

%%% Transform img_act Based on the Matched Feature Points
if size(matchedPoints_act_1,1)>2
    
    tform_1 = fitgeotrans( matchedPoints_act_1.Location,  ...
        matchedPoints_ref_1.Location,'nonreflectivesimilarity');
    outputView_1 = imref2d(size(img_ref));
    [img_act_recovered_1, ~]  = imwarp(img_act,tform_1,'cubic','OutputView',outputView_1);
    
else % If not enough points are matched => Img pair not similar at all
    
    img_similarity=nan;
    c=1
    return
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% 2nd STAGE : PRECISE MATCHING  %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Detect SURF Feature Points %%%

points_act_2 = detectSURFFeatures(img_act_recovered_1,...
    'MetricThreshold',1,'NumOctaves',3);
%img_ref hasnt been changed, so no need to get its SURF features again

%%% Describe Detected Feature Points (HOG descriptors) %%%

[features_act_2,valid_points_act_2] = extractHOGFeatures(img_act_recovered_1,...
    points_act_2,'CellSize',round([250 250]/downscaled_xy_pix),'BlockSize',BlockSz);
%img_ref hasnt been changed, so no need to get its HOG descriptors again

%%% Match Similar Features (High Max Ratio => Returns more matched points)
indexPairs_2 = matchFeatures(features_ref_1,features_act_2,'Unique',true,...
    'MatchThreshold',90,'MaxRatio',0.95,'Metric','SSD');

%%% Crop Out Unmatched Feature Points
matchedPoints_ref_2 = valid_points_ref_1(indexPairs_2(:,1),:);
matchedPoints_act_2 = valid_points_act_2(indexPairs_2(:,2),:);

matchedPoints_ref_2=matchedPoints_ref_2.Location;
matchedPoints_act_2=matchedPoints_act_2.Location;

%%% Crop Out Incorrectly Matched Points (Criteria : zscore(distance)>2 )

if size(matchedPoints_ref_2,1)~=0
    relative_coordinates=matchedPoints_ref_2-matchedPoints_act_2;
    dist_matched_pts_2=hypot(relative_coordinates(:,1),relative_coordinates(:,2));
    dist_norm_2=zscore(dist_matched_pts_2);
    legit_pts_indx_2=find(dist_norm_2<2);
    
    matchedPoints_ref_2=matchedPoints_ref_2(legit_pts_indx_2,:);
    matchedPoints_act_2=matchedPoints_act_2(legit_pts_indx_2,:);
end

%%% Transform img_act Based on the Matched Feature Points
if size(matchedPoints_act_2,1)>2

    tform_2 = fitgeotrans( matchedPoints_act_2, matchedPoints_ref_2,'affine');
    outputView_2 = imref2d(size(img_ref));
    [img_act_recovered_2]  = imwarp(img_act_recovered_1,tform_2,'cubic','OutputView',outputView_2);
    
else % If not enough points are matched => Img pair not similar at all
    
    img_similarity=nan;
    b=1
    return
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 3rd STAGE : MATCHING WITH FIXED POINTS in IMG_ACT  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Set Fixed Points in img_act
% This is to assure even sampling of the points in the actual image

x_act_recovered2=1:round(200/downscaled_xy_pix):size(img_act_recovered_2,2);
y_act_recovered2=1:round(200/downscaled_xy_pix):size(img_act_recovered_2,1);


[x_act_recovered2,y_act_recovered2]=meshgrid(x_act_recovered2,y_act_recovered2);
x_act_recovered2=x_act_recovered2(:); y_act_recovered2=y_act_recovered2(:);

[img_act_bnd_coord] = ref_boundarypad_0809( img_act_recovered_2, downscaled_xy_pix );
in_bnd = inpolygon(x_act_recovered2,y_act_recovered2,...
    img_act_bnd_coord(:,2),img_act_bnd_coord(:,1));

xy_act=[x_act_recovered2(in_bnd),y_act_recovered2(in_bnd)];

% xy_act=[x_act_recovered2(in_bnd),y_act_recovered2(in_bnd);...
%     img_act_bnd_coord(:,2),img_act_bnd_coord(:,1)];


%%% Detect SURF Feature Points in img_ref (Low Threshold)
points_ref_3 = detectSURFFeatures(img_ref,'MetricThreshold',1,'NumOctaves',3);


[img_act_bnd_coord_ref] = ref_boundarypad_0809( img_ref, downscaled_xy_pix );

% points_ref_3 = [points_ref_3.Location; img_act_bnd_coord_ref(:,2), img_act_bnd_coord_ref(:,1)];


%%% Describe Detected Feature Points (HOG descriptors)


[features_ref_3,valid_points_ref_3] = extractHOGFeatures(img_ref,points_ref_3,'CellSize',...
    round([250 250]/downscaled_xy_pix),'BlockSize',BlockSz,'NumBins',12,...
    'UseSignedOrientation',false);
[features_act_3,valid_points_act_3] = extractHOGFeatures(img_act_recovered_2,xy_act,'CellSize',...
    round([250 250]/downscaled_xy_pix),'BlockSize',BlockSz,'NumBins',12,...
    'UseSignedOrientation',false);

%%% Match Similar Features

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % h = fspecial('gaussian',[13 13],5);
% % % 
% % %  n=9 ; x=h(:); % example
% % %  r=repmat(x,1,n)';
% % %  r=r(:)';
% % %  
% % % features_act_3=features_act_3.*r;
% % % features_ref_3=features_ref_3.*r;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

indexPairs_3 = matchFeatures(features_ref_3,features_act_3,'Unique',true,...
    'MatchThreshold',90,'MaxRatio',0.9,'Metric','SSD');

%%% Crop Out Unmatched Feature Points

matchedPoints_ref_3 = valid_points_ref_3(indexPairs_3(:,1),:);
matchedPoints_act_3 = valid_points_act_3(indexPairs_3(:,2),:);

matched_feat_ref_3=features_ref_3(indexPairs_3(:,1),:);
matched_feat_act_3=features_act_3(indexPairs_3(:,2),:);

matchedPoints_ref_3=matchedPoints_ref_3.Location;


%%% Crop Out Incorrectly Matched Points (Criteria : zscore(distance)>2 )

if size(matchedPoints_ref_3,1)~=0
    relative_coordinates_3=matchedPoints_ref_3-matchedPoints_act_3;
    dist_matched_pts_3=hypot(relative_coordinates_3(:,1),relative_coordinates_3(:,2));
    dist_norm_3=zscore(dist_matched_pts_3);
    legit_pts_indx_3=find(dist_norm_3<2);
    
    matchedPoints_ref_3=matchedPoints_ref_3(legit_pts_indx_3,:);
    matchedPoints_act_3=matchedPoints_act_3(legit_pts_indx_3,:);
    
    matched_feat_ref_3=matched_feat_ref_3(legit_pts_indx_3,:);
    matched_feat_act_3=matched_feat_act_3(legit_pts_indx_3,:);
end



%%% Transform img_act Based on the Matched Feature Points
if size(matchedPoints_act_3,1)>6

%     tform_3 = fitgeotrans( matchedPoints_act_3, matchedPoints_ref_3,'lwm',size(matchedPoints_act_3,1));
    tform_3 = fitgeotrans( matchedPoints_act_3, matchedPoints_ref_3,'affine');
    outputView_3 = imref2d(size(img_ref));
    [img_act_recovered_3]  = imwarp(img_act_recovered_2,tform_3,'OutputView',outputView_3);
    
else % If not enough points are matched => Img pair not similar at all
    
    img_similarity=nan;
    d=1
    return
    
end


img_similarity=(sum((dot(matched_feat_ref_3,matched_feat_act_3,2))))/size(valid_points_ref_3,1);
figure; showMatchedFeatures(img_act_recovered_3, img_ref,matchedPoints_act_3, matchedPoints_ref_3,'montage')

figure; imshowpair(img_act_recovered_3,img_act_recovered_2);
if size(matched_feat_ref_3,1)<4
    a=1
    img_similarity=nan;
    
    return
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

points_act_recovered2 = detectSURFFeatures(img_act_recovered_2,'MetricThreshold',150,'NumOctaves',1);

%%% Describe Detected Feature Points (HOG descriptors)

[features_act_rec2,valid_points_act_rec2] = extractHOGFeatures(img_act_recovered_2,points_act_recovered2,'CellSize',...
    round([500 500]/downscaled_xy_pix),'BlockSize',BlockSz);      % Cell size = 200x200 um;

%%% Match Similar Features (Low Max Ratio)
indexPairs_check = matchFeatures(features_act_1,features_act_rec2,...
    'Unique',true,'MatchThreshold',30,'MaxRatio',0.85,'Metric','SSD');

%%% Crop Out Unmatched Feature Points
matchedPoints_act_check1 =  valid_points_act_1(indexPairs_check(:,1),:);
matchedPoints_act_rec2 = valid_points_act_rec2(indexPairs_check(:,2),:);

% scale_recovered=-100;
%%% Transform img_act Based on the Matched Feature Points
if size(matchedPoints_act_check1,1)>5
    
    tform_check = fitgeotrans( matchedPoints_act_rec2.Location, ...
        matchedPoints_act_check1.Location,'nonreflectivesimilarity');
    %    tform_1 = fitgeotrans( matchedPoints_act_1.Location,  ...
    %         matchedPoints_ref_1.Location,'affine');
    
    tformInv = invert(tform_check);
    Tinv = tformInv.T;
    ss = Tinv(2,1);
    sc = Tinv(1,1);
    scale_recovered = sqrt(ss*ss + sc*sc);
    
    if scale_recovered>1.30 || scale_recovered<0.70
        img_similarity=nan;
    end
else
    f=1
    img_similarity=nan;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure; showMatchedFeatures(img_act_recovered_3, img_ref,matchedPoints_act_3, matchedPoints_ref_3,'montage')
figure; imshowpair(img_act_recovered_3,img_ref,'montage')
% figure; imshowpair(img_act_recovered_3,img_ref)
% figure; imshow(img_act)
% figure; imshow(img_act_recovered_3,[])
% figure; imshow(img_ref)

% img_ref_fiber=fibermetric(img_ref,[2 4 ]);
% img_actrec_fiber=fibermetric(img_act_recovered_3,[2 4]);


% figure ; imshowpair(img_ref_fiber,img_actrec_fiber);

%  title(num2str(scale_recovered))
%  figure;
% disp(num2str(toc(start_t)))
end

