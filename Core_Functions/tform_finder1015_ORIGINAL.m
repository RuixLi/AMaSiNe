function [matched_img, tform_1, tform_2, tform_3, ...
    matchedPoints_act_400,matchedPoints_ref_400,...
    matchedPoints_act_200, matchedPoints_ref_200, matchedPoints_act_100, matchedPoints_ref_100, ...
    matchedPoints_act_50, matchedPoints_ref_50]= ...
    tform_finder1015 ( img_act, img_ref, xy_pix_ref, BlockSz )
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

warning('off')

Hog_bin_num=9;

%%% Detect SURF Feature Points
points_ref_1 = detectSURFFeatures(img_ref,'MetricThreshold',5,'NumOctaves',1);
points_act_1 = detectSURFFeatures(img_act,'MetricThreshold',5,'NumOctaves',1);

%%% Describe Detected Feature Points (HOG descriptors)
[features_ref_1,valid_points_ref_1] = extractHOGFeatures(img_ref,points_ref_1,'CellSize',...
    round([250 250]/xy_pix_ref),'BlockSize', BlockSz);      % Cell size = 200x200 um;
[features_act_1,valid_points_act_1] = extractHOGFeatures(img_act,points_act_1,'CellSize',...
    round([250 250]/xy_pix_ref),'BlockSize', BlockSz);      % Cell size = 200x200 um;

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
    
    disp('not enough matching point pairs between the two images')
    
    matched_img = nan;
    tform_1 = nan;
    tform_2 = nan;
    tform_3 = nan;
    matchedPoints_act_200=nan;
    matchedPoints_ref_200=nan;
    matchedPoints_act_100=nan;
    matchedPoints_ref_100=nan;
    matchedPoints_act_50=nan;
    matchedPoints_ref_50=nan;
    matchedPoints_act_25=nan;
    matchedPoints_ref_25=nan;
    
    return
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% 2nd STAGE : PRECISE MATCHING  %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Detect SURF Feature Points %%%

points_act_2 = detectSURFFeatures(img_act_recovered_1,...
    'MetricThreshold',1,'NumOctaves',1);
%img_ref hasnt been changed, so no need to get its SURF features again

%%% Describe Detected Feature Points (HOG descriptors) %%%

[features_act_2,valid_points_act_2] = extractHOGFeatures(img_act_recovered_1,...
    points_act_2,'CellSize',round([250 250]/xy_pix_ref),'BlockSize',BlockSz);
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
    
    %     tform_2 = fitgeotrans( matchedPoints_act_2, matchedPoints_ref_2,'nonreflectivesimilarity');
    tform_2 = fitgeotrans( matchedPoints_act_2, matchedPoints_ref_2,'affine');
    outputView_2 = imref2d(size(img_ref));
    [img_act_recovered_2]  = imwarp(img_act_recovered_1,tform_2,'cubic','OutputView',outputView_2);
    
else % If not enough points are matched => Img pair not similar at all
    
    disp('not enough matching point pairs between the two images')
    
    matched_img = nan;
    tform_1 = nan;
    tform_2 = nan;
    tform_3 = nan;
       matchedPoints_act_200=nan;
    matchedPoints_ref_200=nan;
    matchedPoints_act_100=nan;
    matchedPoints_ref_100=nan;
    matchedPoints_act_50=nan;
    matchedPoints_ref_50=nan;
    matchedPoints_act_25=nan;
    matchedPoints_ref_25=nan;
    
    
    return
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 3rd STAGE : MATCHING WITH FIXED POINTS in IMG_ACT  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Set Fixed Points in img_act
% This is to assure even sampling of the points in the actual image


x_act_recovered2=1:round(100/xy_pix_ref):size(img_act_recovered_2,2);
y_act_recovered2=1:round(100/xy_pix_ref):size(img_act_recovered_2,1);

[x_act_recovered2,y_act_recovered2]=meshgrid(x_act_recovered2,y_act_recovered2);
x_act_recovered2=x_act_recovered2(:); y_act_recovered2=y_act_recovered2(:);

in_bnd_alpha = ref_boundarypad_pwl_1114( img_act_recovered_2, xy_pix_ref );

in_bnd=inShape(in_bnd_alpha,x_act_recovered2,y_act_recovered2);

xy_act=[x_act_recovered2(in_bnd),y_act_recovered2(in_bnd)];


%%% Detect SURF Feature Points in img_ref (Low Threshold)
points_ref_3 = detectSURFFeatures(img_ref,'MetricThreshold',1,'NumOctaves',1);


%%% Describe Detected Feature Points (HOG descriptors)

[features_ref_3,valid_points_ref_3] = extractHOGFeatures(img_ref,points_ref_3,'CellSize',...
    round([250 250]/xy_pix_ref),'BlockSize',[6 6],'NumBins',Hog_bin_num,...
    'UseSignedOrientation',false);
[features_act_3,valid_points_act_3] = extractHOGFeatures(img_act_recovered_2,xy_act,'CellSize',...
    round([250 250]/xy_pix_ref),'BlockSize',[6 6],'NumBins',Hog_bin_num,...
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
    legit_pts_indx_3=find(dist_norm_3<(1000/xy_pix_ref));
    
    matchedPoints_ref_3=matchedPoints_ref_3(legit_pts_indx_3,:);
    matchedPoints_act_3=matchedPoints_act_3(legit_pts_indx_3,:);
    
end

if size(matchedPoints_act_3,1)>4
    
    tform_3 = fitgeotrans( matchedPoints_act_3, matchedPoints_ref_3,'affine');
    outputView_3 = imref2d(size(img_ref));
    [matched_img,~]  = imwarp(img_act_recovered_2,tform_3,'cubic','OutputView',outputView_3);
    
else
    
    
    disp('not enough matching point pairs between the two images')
    
    
    matched_img = nan;
    tform_1 = nan;
    tform_2 = nan;
    tform_3 = nan;
    matchedPoints_act_200=nan;
    matchedPoints_ref_200=nan;
    matchedPoints_act_100=nan;
    matchedPoints_ref_100=nan;
    matchedPoints_act_50=nan;
    matchedPoints_ref_50=nan;
    matchedPoints_act_25=nan;
    matchedPoints_ref_25=nan;
    
    
    return
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4-0th STAGE : Feature matching for non-linear trasformation - Resolution 200um  %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Set Fixed Points in img_act
% This is to assure even sampling of the points in the actual image
pt_int=400; % um %%%%%%%%%%%%%%
img_act_recovered_4_800=matched_img;
matched_bw=img_act_recovered_4_800;
matched_bw(matched_bw>0)=255;

x_act_recovered4=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_800,2);
y_act_recovered4=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_800,1);

[x_act_recovered4,y_act_recovered4]=meshgrid(x_act_recovered4,y_act_recovered4);
x_act_recovered4=x_act_recovered4(:); y_act_recovered4=y_act_recovered4(:);
in_bnd_alpha = ref_boundarypad_pwl_1114( img_act_recovered_4_800, xy_pix_ref );
in_bnd=inShape(in_bnd_alpha,x_act_recovered4,y_act_recovered4);
points_act_4=[x_act_recovered4(in_bnd),y_act_recovered4(in_bnd)];

%%%%%%%%%%%%%%%%%
img_ref_bw=img_ref;
level = graythresh(img_ref_bw);
img_ref_bw=imbinarize(img_ref_bw,0.5*level); 
img_ref_bw=imfill(img_ref_bw,'holes');

x_ref=1:round(pt_int/xy_pix_ref):size(img_ref,2);
y_ref=1:round(pt_int/xy_pix_ref):size(img_ref,1);

[x_ref,y_ref]=meshgrid(x_ref,y_ref);
x_ref=x_ref(:); y_ref=y_ref(:);
in_bnd_ref_alpha = ref_boundarypad_pwl_1114( img_ref, xy_pix_ref );
in_bnd_ref=inShape(in_bnd_ref_alpha,x_ref,y_ref);
points_ref_4=[x_ref(in_bnd_ref),y_ref(in_bnd_ref)];

%%% Describe Detected Feature Points (HOG descriptors)

[features_ref_4,valid_points_ref_4] = extractHOGFeatures(img_ref,points_ref_4,'CellSize',...
    round([250 250]/xy_pix_ref),'BlockSize',[6 6],'NumBins',Hog_bin_num,...
    'UseSignedOrientation',false);
[features_act_4,valid_points_act_4] = extractHOGFeatures(img_act_recovered_4_800,points_act_4,'CellSize',...
    round([250 250]/xy_pix_ref),'BlockSize',[6 6],'NumBins',Hog_bin_num,...
    'UseSignedOrientation',false);

%%% Match Similar Features

indexPairs_4 = matchFeatures(features_ref_4,features_act_4,'Unique',true,...
    'MatchThreshold',100,'MaxRatio',1,'Metric','SSD');

%%% Crop Out Unmatched Feature Points


matchedPoints_ref_4 = valid_points_ref_4(indexPairs_4(:,1),:);
matchedPoints_ref_4 = matchedPoints_ref_4;

matchedPoints_act_4 = valid_points_act_4(indexPairs_4(:,2),:);
matchedPoints_act_4=matchedPoints_act_4;

%%% Crop Out Incorrectly Matched Points (Criteria : zscore(distance)>2 )

if size(matchedPoints_ref_4,1)~=0
    relative_coordinates_4=matchedPoints_ref_4-matchedPoints_act_4;
    dist_norm_4=hypot(relative_coordinates_4(:,1),relative_coordinates_4(:,2));
    legit_pts_indx_4=find(dist_norm_4<(sqrt(2)*pt_int/xy_pix_ref+realmin));
    % legit_pts_indx_4=find(dist_norm_4<(1000/xy_pix_ref)+realmin);
    
    matchedPoints_ref_4=matchedPoints_ref_4(legit_pts_indx_4,:);
    matchedPoints_act_4=matchedPoints_act_4(legit_pts_indx_4,:);
    
end

if size(matchedPoints_ref_4,1)<4

    disp('not enough matching point pairs between the two images')
    
    matched_img = nan;
    tform_1 = nan;
    tform_2 = nan;
    tform_3 = nan;
    matchedPoints_act_200=nan;
    matchedPoints_ref_200=nan;
    matchedPoints_act_100=nan;
    matchedPoints_ref_100=nan;
    matchedPoints_act_50=nan;
    matchedPoints_ref_50=nan;
    matchedPoints_act_25=nan;
    matchedPoints_ref_25=nan;
    
    
    return
    
end

%%% Set Boundary conditions to prevent unrealistic warping

x_bc_pts=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_800,2);
y_bc_pts=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_800,1);
[x_bc_pts,y_bc_pts]=meshgrid(x_bc_pts,y_bc_pts);
x_bc_pts=x_bc_pts(:); y_bc_pts=y_bc_pts(:);

in_bnd_act_alpha = in_bnd_alpha;
in_bnd_ref_alpha = ref_boundarypad_pwl_1114( img_ref, xy_pix_ref );

in_bnd_act=inShape(in_bnd_act_alpha,x_bc_pts,y_bc_pts);
in_bnd_ref=inShape(in_bnd_ref_alpha,x_bc_pts,y_bc_pts);

in_bnd_bc=~(in_bnd_act|in_bnd_ref);
x_bc_pts=x_bc_pts(in_bnd_bc); y_bc_pts=y_bc_pts(in_bnd_bc);

bc_pts=[x_bc_pts, y_bc_pts];
%%%%%%%

matchedPoints_ref_4=[matchedPoints_ref_4; bc_pts];
matchedPoints_act_4=[matchedPoints_act_4; bc_pts];

x_interp_grid=1:round(pt_int/xy_pix_ref):size(img_ref,2);
y_interp_grid=1:round(pt_int/xy_pix_ref):size(img_ref,1);
[x_interp_grid,y_interp_grid]=meshgrid(x_interp_grid,y_interp_grid);
x_interp_grid=x_interp_grid(:); y_interp_grid=y_interp_grid(:);


Vq_x = griddata(matchedPoints_ref_4(:,1),matchedPoints_ref_4(:,2),...
    matchedPoints_act_4(:,1),x_interp_grid,y_interp_grid,'natural');
Vq_y = griddata(matchedPoints_ref_4(:,1),matchedPoints_ref_4(:,2),...
    matchedPoints_act_4(:,2),x_interp_grid,y_interp_grid,'natural');

matchedPoints_act_400=[Vq_x,Vq_y];   %%%%%
matchedPoints_ref_400=[x_interp_grid,y_interp_grid]; %%%%%

tform_noScale_400 = fitgeotrans(matchedPoints_act_400,...
    matchedPoints_ref_400,'pwl');

[img_act_recovered_4_400]  = imwarp(img_act_recovered_4_800,...
    tform_noScale_400,'cubic','OutputView',outputView_3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4-1st STAGE : Feature matching for non-linear trasformation - Resolution 200um  %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Set Fixed Points in img_act
% This is to assure even sampling of the points in the actual image
pt_int=200; % um %%%%%%%%%%%%%%
% img_act_recovered_4_400=matched_img;
matched_bw=img_act_recovered_4_400;
matched_bw(matched_bw>0)=255;

x_act_recovered4=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_400,2);
y_act_recovered4=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_400,1);

[x_act_recovered4,y_act_recovered4]=meshgrid(x_act_recovered4,y_act_recovered4);
x_act_recovered4=x_act_recovered4(:); y_act_recovered4=y_act_recovered4(:);
in_bnd_alpha = ref_boundarypad_pwl_1114( img_act_recovered_4_400, xy_pix_ref );
in_bnd=inShape(in_bnd_alpha,x_act_recovered4,y_act_recovered4);
points_act_4=[x_act_recovered4(in_bnd),y_act_recovered4(in_bnd)];

%%%%%%%%%%%%%%%%%
img_ref_bw=img_ref;
level = graythresh(img_ref_bw);
img_ref_bw=imbinarize(img_ref_bw,0.5*level); 
img_ref_bw=imfill(img_ref_bw,'holes');

x_ref=1:round(pt_int/xy_pix_ref):size(img_ref,2);
y_ref=1:round(pt_int/xy_pix_ref):size(img_ref,1);

[x_ref,y_ref]=meshgrid(x_ref,y_ref);
x_ref=x_ref(:); y_ref=y_ref(:);
in_bnd_ref_alpha = ref_boundarypad_pwl_1114( img_ref, xy_pix_ref );
in_bnd_ref=inShape(in_bnd_ref_alpha,x_ref,y_ref);
points_ref_4=[x_ref(in_bnd_ref),y_ref(in_bnd_ref)];

%%% Describe Detected Feature Points (HOG descriptors)

[features_ref_4,valid_points_ref_4] = extractHOGFeatures(img_ref,points_ref_4,'CellSize',...
    round([250 250]/xy_pix_ref),'BlockSize',[6 6],'NumBins',Hog_bin_num,...
    'UseSignedOrientation',false);
[features_act_4,valid_points_act_4] = extractHOGFeatures(img_act_recovered_4_400,points_act_4,'CellSize',...
    round([250 250]/xy_pix_ref),'BlockSize',[6 6],'NumBins',Hog_bin_num,...
    'UseSignedOrientation',false);

%%% Match Similar Features

indexPairs_4 = matchFeatures(features_ref_4,features_act_4,'Unique',true,...
    'MatchThreshold',100,'MaxRatio',1,'Metric','SSD');

%%% Crop Out Unmatched Feature Points


matchedPoints_ref_4 = valid_points_ref_4(indexPairs_4(:,1),:);
matchedPoints_ref_4 = matchedPoints_ref_4;

matchedPoints_act_4 = valid_points_act_4(indexPairs_4(:,2),:);
matchedPoints_act_4=matchedPoints_act_4;

%%% Crop Out Incorrectly Matched Points (Criteria : zscore(distance)>2 )

if size(matchedPoints_ref_4,1)~=0
    relative_coordinates_4=matchedPoints_ref_4-matchedPoints_act_4;
    dist_norm_4=hypot(relative_coordinates_4(:,1),relative_coordinates_4(:,2));
    legit_pts_indx_4=find(dist_norm_4<(sqrt(2)*pt_int/xy_pix_ref+realmin));
    % legit_pts_indx_4=find(dist_norm_4<(1000/xy_pix_ref)+realmin);
    
    matchedPoints_ref_4=matchedPoints_ref_4(legit_pts_indx_4,:);
    matchedPoints_act_4=matchedPoints_act_4(legit_pts_indx_4,:);
    
end

if size(matchedPoints_ref_4,1)<4

    disp('not enough matching point pairs between the two images')
    
    matched_img = nan;
    tform_1 = nan;
    tform_2 = nan;
    tform_3 = nan;
    matchedPoints_act_200=nan;
    matchedPoints_ref_200=nan;
    matchedPoints_act_100=nan;
    matchedPoints_ref_100=nan;
    matchedPoints_act_50=nan;
    matchedPoints_ref_50=nan;
    matchedPoints_act_25=nan;
    matchedPoints_ref_25=nan;
    
    
    return
    
end

%%% Set Boundary conditions to prevent unrealistic warping

x_bc_pts=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_400,2);
y_bc_pts=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_400,1);
[x_bc_pts,y_bc_pts]=meshgrid(x_bc_pts,y_bc_pts);
x_bc_pts=x_bc_pts(:); y_bc_pts=y_bc_pts(:);

in_bnd_act_alpha = in_bnd_alpha;
in_bnd_ref_alpha = ref_boundarypad_pwl_1114( img_ref, xy_pix_ref );

in_bnd_act=inShape(in_bnd_act_alpha,x_bc_pts,y_bc_pts);
in_bnd_ref=inShape(in_bnd_ref_alpha,x_bc_pts,y_bc_pts);

in_bnd_bc=~(in_bnd_act|in_bnd_ref);
x_bc_pts=x_bc_pts(in_bnd_bc); y_bc_pts=y_bc_pts(in_bnd_bc);

bc_pts=[x_bc_pts, y_bc_pts];
%%%%%%%

matchedPoints_ref_4=[matchedPoints_ref_4; bc_pts];
matchedPoints_act_4=[matchedPoints_act_4; bc_pts];

x_interp_grid=1:round(pt_int/xy_pix_ref):size(img_ref,2);
y_interp_grid=1:round(pt_int/xy_pix_ref):size(img_ref,1);
[x_interp_grid,y_interp_grid]=meshgrid(x_interp_grid,y_interp_grid);
x_interp_grid=x_interp_grid(:); y_interp_grid=y_interp_grid(:);


Vq_x = griddata(matchedPoints_ref_4(:,1),matchedPoints_ref_4(:,2),...
    matchedPoints_act_4(:,1),x_interp_grid,y_interp_grid,'natural');
Vq_y = griddata(matchedPoints_ref_4(:,1),matchedPoints_ref_4(:,2),...
    matchedPoints_act_4(:,2),x_interp_grid,y_interp_grid,'natural');

matchedPoints_act_200=[Vq_x,Vq_y];   %%%%%
matchedPoints_ref_200=[x_interp_grid,y_interp_grid]; %%%%%

tform_noScale_200 = fitgeotrans(matchedPoints_act_200,...
    matchedPoints_ref_200,'pwl');

[img_act_recovered_4_200]  = imwarp(img_act_recovered_4_400,...
    tform_noScale_200,'cubic','OutputView',outputView_3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4-2nd STAGE : Feature matching for non-linear trasformation - Resolution 100um  %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Set Fixed Points in img_act
% This is to assure even sampling of the points in the actual image

pt_int=100; % um %%%%%%%%%%%%%%

matched_bw=img_act_recovered_4_200;
matched_bw(matched_bw>0)=255;

x_act_recovered4=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_200,2);
y_act_recovered4=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_200,1);

[x_act_recovered4,y_act_recovered4]=meshgrid(x_act_recovered4,y_act_recovered4);
x_act_recovered4=x_act_recovered4(:); y_act_recovered4=y_act_recovered4(:);
in_bnd_alpha = ref_boundarypad_pwl_1114( img_act_recovered_4_200, xy_pix_ref );
in_bnd=inShape(in_bnd_alpha,x_act_recovered4,y_act_recovered4);
points_act_4=[x_act_recovered4(in_bnd),y_act_recovered4(in_bnd)];

%%%%%%%%%%%%%%%%%
img_ref_bw=img_ref;
level = graythresh(img_ref_bw);
img_ref_bw=imbinarize(img_ref_bw,0.5*level); 
img_ref_bw=imfill(img_ref_bw,'holes');

x_ref=1:round(pt_int/xy_pix_ref):size(img_ref,2);
y_ref=1:round(pt_int/xy_pix_ref):size(img_ref,1);

[x_ref,y_ref]=meshgrid(x_ref,y_ref);
x_ref=x_ref(:); y_ref=y_ref(:);
in_bnd_ref_alpha = ref_boundarypad_pwl_1114( img_ref, xy_pix_ref );
in_bnd_ref=inShape(in_bnd_ref_alpha,x_ref,y_ref);
points_ref_4=[x_ref(in_bnd_ref),y_ref(in_bnd_ref)];

%%% Describe Detected Feature Points (HOG descriptors)

[features_ref_4,valid_points_ref_4] = extractHOGFeatures(img_ref,points_ref_4,'CellSize',...
    round([250 250]/xy_pix_ref),'BlockSize',[6 6],'NumBins',Hog_bin_num,...
    'UseSignedOrientation',false);
[features_act_4,valid_points_act_4] = extractHOGFeatures(img_act_recovered_4_200,points_act_4,'CellSize',...
    round([250 250]/xy_pix_ref),'BlockSize',[6 6],'NumBins',Hog_bin_num,...
    'UseSignedOrientation',false);

%%% Match Similar Features

indexPairs_4 = matchFeatures(features_ref_4,features_act_4,'Unique',true,...
    'MatchThreshold',100,'MaxRatio',1,'Metric','SSD');

%%% Crop Out Unmatched Feature Points


matchedPoints_ref_4 = valid_points_ref_4(indexPairs_4(:,1),:);
matchedPoints_ref_4 = matchedPoints_ref_4;

matchedPoints_act_4 = valid_points_act_4(indexPairs_4(:,2),:);
matchedPoints_act_4=matchedPoints_act_4;

%%% Crop Out Incorrectly Matched Points (Criteria : zscore(distance)>2 )

if size(matchedPoints_ref_4,1)~=0
    relative_coordinates_4=matchedPoints_ref_4-matchedPoints_act_4;
    dist_norm_4=hypot(relative_coordinates_4(:,1),relative_coordinates_4(:,2));
    legit_pts_indx_4=find(dist_norm_4<(sqrt(2)*pt_int/xy_pix_ref+realmin));
    % legit_pts_indx_4=find(dist_norm_4<(1000/xy_pix_ref)+realmin);
    
    matchedPoints_ref_4=matchedPoints_ref_4(legit_pts_indx_4,:);
    matchedPoints_act_4=matchedPoints_act_4(legit_pts_indx_4,:);
    
end

if size(matchedPoints_ref_4,1)<4

    disp('not enough matching point pairs between the two images')
    
    matched_img = nan;
    tform_1 = nan;
    tform_2 = nan;
    tform_3 = nan;
    matchedPoints_act_200=nan;
    matchedPoints_ref_200=nan;
    matchedPoints_act_100=nan;
    matchedPoints_ref_100=nan;
    matchedPoints_act_50=nan;
    matchedPoints_ref_50=nan;
    matchedPoints_act_25=nan;
    matchedPoints_ref_25=nan;
    
    
    return
    
end


%%% Set Boundary conditions to prevent unrealistic warping

x_bc_pts=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_200,2);
y_bc_pts=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_200,1);
[x_bc_pts,y_bc_pts]=meshgrid(x_bc_pts,y_bc_pts);
x_bc_pts=x_bc_pts(:); y_bc_pts=y_bc_pts(:);

in_bnd_act_alpha = in_bnd_alpha;
in_bnd_ref_alpha = ref_boundarypad_pwl_1114( img_ref, xy_pix_ref );

in_bnd_act=inShape(in_bnd_act_alpha,x_bc_pts,y_bc_pts);
in_bnd_ref=inShape(in_bnd_ref_alpha,x_bc_pts,y_bc_pts);

in_bnd_bc=~(in_bnd_act|in_bnd_ref);
x_bc_pts=x_bc_pts(in_bnd_bc); y_bc_pts=y_bc_pts(in_bnd_bc);

bc_pts=[x_bc_pts, y_bc_pts];
%%%%%%%

matchedPoints_ref_4=[matchedPoints_ref_4; bc_pts];
matchedPoints_act_4=[matchedPoints_act_4; bc_pts];

x_interp_grid=1:round(pt_int/xy_pix_ref):size(img_ref,2);
y_interp_grid=1:round(pt_int/xy_pix_ref):size(img_ref,1);
[x_interp_grid,y_interp_grid]=meshgrid(x_interp_grid,y_interp_grid);
x_interp_grid=x_interp_grid(:); y_interp_grid=y_interp_grid(:);


Vq_x = griddata(matchedPoints_ref_4(:,1),matchedPoints_ref_4(:,2),...
    matchedPoints_act_4(:,1),x_interp_grid,y_interp_grid,'natural');
Vq_y = griddata(matchedPoints_ref_4(:,1),matchedPoints_ref_4(:,2),...
    matchedPoints_act_4(:,2),x_interp_grid,y_interp_grid,'natural'); %% changed from 'natural' -> 'linear' by WC

matchedPoints_act_100=[Vq_x,Vq_y];   %%%%%
matchedPoints_ref_100=[x_interp_grid,y_interp_grid]; %%%%%

tform_noScale_100 = fitgeotrans(matchedPoints_act_100,...
    matchedPoints_ref_100,'pwl');

[img_act_recovered_4_100]  = imwarp(img_act_recovered_4_200,...
    tform_noScale_100,'cubic','OutputView',outputView_3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4-3rd STAGE : Feature matching for non-linear trasformation - Resolution 50um  %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Set Fixed Points in img_act
% This is to assure even sampling of the points in the actual image

pt_int=50; % um %%%%%%%%%%%%%%

matched_bw=img_act_recovered_4_100;
matched_bw(matched_bw>0)=255;

x_act_recovered4=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_100,2);
y_act_recovered4=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_100,1);

[x_act_recovered4,y_act_recovered4]=meshgrid(x_act_recovered4,y_act_recovered4);
x_act_recovered4=x_act_recovered4(:); y_act_recovered4=y_act_recovered4(:);
in_bnd_alpha = ref_boundarypad_pwl_1114( img_act_recovered_4_100, xy_pix_ref );
in_bnd=inShape(in_bnd_alpha,x_act_recovered4,y_act_recovered4);
points_act_4=[x_act_recovered4(in_bnd),y_act_recovered4(in_bnd)];

%%%%%%%%%%%%%%%%%
img_ref_bw=img_ref;
level = graythresh(img_ref_bw);
img_ref_bw=imbinarize(img_ref_bw,0.5*level); 
img_ref_bw=imfill(img_ref_bw,'holes');

x_ref=1:round(pt_int/xy_pix_ref):size(img_ref,2);
y_ref=1:round(pt_int/xy_pix_ref):size(img_ref,1);

[x_ref,y_ref]=meshgrid(x_ref,y_ref);
x_ref=x_ref(:); y_ref=y_ref(:);
in_bnd_ref_alpha = ref_boundarypad_pwl_1114( img_ref, xy_pix_ref );
in_bnd_ref=inShape(in_bnd_ref_alpha,x_ref,y_ref);
points_ref_4=[x_ref(in_bnd_ref),y_ref(in_bnd_ref)];

%%% Describe Detected Feature Points (HOG descriptors)

[features_ref_4,valid_points_ref_4] = extractHOGFeatures(img_ref,points_ref_4,'CellSize',...
    round([250 250]/xy_pix_ref),'BlockSize',[6 6],'NumBins',Hog_bin_num,...
    'UseSignedOrientation',false);
[features_act_4,valid_points_act_4] = extractHOGFeatures(img_act_recovered_4_100,points_act_4,'CellSize',...
    round([250 250]/xy_pix_ref),'BlockSize',[6 6],'NumBins',Hog_bin_num,...
    'UseSignedOrientation',false);

%%% Match Similar Features

indexPairs_4 = matchFeatures(features_ref_4,features_act_4,'Unique',true,...
    'MatchThreshold',100,'MaxRatio',1,'Metric','SSD');

%%% Crop Out Unmatched Feature Points


matchedPoints_ref_4 = valid_points_ref_4(indexPairs_4(:,1),:);
matchedPoints_ref_4 = matchedPoints_ref_4;

matchedPoints_act_4 = valid_points_act_4(indexPairs_4(:,2),:);
matchedPoints_act_4=matchedPoints_act_4;

%%% Crop Out Incorrectly Matched Points (Criteria : zscore(distance)>2 )

if size(matchedPoints_ref_4,1)~=0
    relative_coordinates_4=matchedPoints_ref_4-matchedPoints_act_4;
    dist_norm_4=hypot(relative_coordinates_4(:,1),relative_coordinates_4(:,2));
    legit_pts_indx_4=find(dist_norm_4<(sqrt(2)*pt_int/xy_pix_ref+realmin));
    % legit_pts_indx_4=find(dist_norm_4<(1000/xy_pix_ref)+realmin);
    
    matchedPoints_ref_4=matchedPoints_ref_4(legit_pts_indx_4,:);
    matchedPoints_act_4=matchedPoints_act_4(legit_pts_indx_4,:);
    
end

if size(matchedPoints_ref_4,1)<4

    disp('not enough matching point pairs between the two images')
    
    matched_img = nan;
    tform_1 = nan;
    tform_2 = nan;
    tform_3 = nan;
    matchedPoints_act_200=nan;
    matchedPoints_ref_200=nan;
    matchedPoints_act_100=nan;
    matchedPoints_ref_100=nan;
    matchedPoints_act_50=nan;
    matchedPoints_ref_50=nan;
    matchedPoints_act_25=nan;
    matchedPoints_ref_25=nan;
    
    
    return
    
end

%%% Set Boundary conditions to prevent unrealistic warping

x_bc_pts=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_100,2);
y_bc_pts=1:round(pt_int/xy_pix_ref):size(img_act_recovered_4_100,1);
[x_bc_pts,y_bc_pts]=meshgrid(x_bc_pts,y_bc_pts);
x_bc_pts=x_bc_pts(:); y_bc_pts=y_bc_pts(:);

in_bnd_act_alpha = in_bnd_alpha;
in_bnd_ref_alpha = ref_boundarypad_pwl_1114( img_ref, xy_pix_ref );

in_bnd_act=inShape(in_bnd_act_alpha,x_bc_pts,y_bc_pts);
in_bnd_ref=inShape(in_bnd_ref_alpha,x_bc_pts,y_bc_pts);

in_bnd_bc=~(in_bnd_act|in_bnd_ref);
x_bc_pts=x_bc_pts(in_bnd_bc); y_bc_pts=y_bc_pts(in_bnd_bc);

bc_pts=[x_bc_pts, y_bc_pts];
%%%%%%%

matchedPoints_ref_4=[matchedPoints_ref_4; bc_pts];
matchedPoints_act_4=[matchedPoints_act_4; bc_pts];

x_interp_grid=1:round(pt_int/xy_pix_ref):size(img_ref,2);
y_interp_grid=1:round(pt_int/xy_pix_ref):size(img_ref,1);
[x_interp_grid,y_interp_grid]=meshgrid(x_interp_grid,y_interp_grid);
x_interp_grid=x_interp_grid(:); y_interp_grid=y_interp_grid(:);


Vq_x = griddata(matchedPoints_ref_4(:,1),matchedPoints_ref_4(:,2),...
    matchedPoints_act_4(:,1),x_interp_grid,y_interp_grid,'natural');
Vq_y = griddata(matchedPoints_ref_4(:,1),matchedPoints_ref_4(:,2),...
    matchedPoints_act_4(:,2),x_interp_grid,y_interp_grid,'natural');

matchedPoints_act_50=[Vq_x,Vq_y];   %%%%%
matchedPoints_ref_50=[x_interp_grid,y_interp_grid]; %%%%%

tform_noScale_50 = fitgeotrans(matchedPoints_act_50,...
    matchedPoints_ref_50,'pwl');

[img_act_recovered_4_50]  = imwarp(img_act_recovered_4_100,...
    tform_noScale_50,'cubic','OutputView',outputView_3);


matched_img=img_act_recovered_4_50;

% % figure; imshowpair(img_act_recovered_4_25,img_ref,'montage')
end

