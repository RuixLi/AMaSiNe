function [ BWoutline, BWfinal] = SliceBoundaryDetection (I_raw, xy_pix)
% Detection of the Brain Slice Bounday

%%% Basic Parameters
boundary_dilat_size=20;
Img_BWs=I_raw;
%%% Edge Detection %%%
% % % [~, threshold] = edge(I_raw, 'sobel');
% % % fudgeFactor = 0.7 ;
% % % 
% % % Img_BWs = edge(I_raw,'sobel', threshold * fudgeFactor);

%%% Image Dilation %%%
Img_BWs = bwareaopen(Img_BWs,9);  %% BLOB objects with its size less than 9 pixels are considered as noise
seD = strel('disk',round(boundary_dilat_size/(xy_pix)));
BWsdil = imdilate(Img_BWs, seD);

%%% Filling inside Large Boundaries %%%
BWnobord = imfill(BWsdil, 'holes');
BWnobord = imclearborder(BWnobord, 4);

%%% Boundary Smoothing %%%
seD = strel('diamond',10*round(boundary_dilat_size/(xy_pix)));
BWfinal = imopen(BWnobord,seD); 
% BWfinal = imopen(BWfinal,seD);

%%% Delete except the largest object %%%
L=bwlabel(BWfinal);
stats = regionprops(L,'Area','Centroid','PixelIdxList','Centroid');
areas = [stats.Area];
[maxArea largestBlobIndex] = max(areas);
Blob_idx=1:length(stats);
Blob_idx_delete=setdiff(Blob_idx,largestBlobIndex);


for ii=Blob_idx_delete
    BWfinal(stats(ii).PixelIdxList)=0;
end

%%% Visualise Object Boundary %%%
% BWfinal=imresize(BWfinal,size(I_general_shape));

BWoutline = bwperim(BWfinal,8);
seD_boundary = strel('disk',round(boundary_dilat_size/(2*xy_pix)));
BWoutline = imdilate(BWoutline,seD_boundary);

Segout = I_raw; 
Segout(BWoutline) = 255;
% 
% figure; imshow(Segout)%, title('outlined original image');
% figure; imshow(BWfinal);

end

