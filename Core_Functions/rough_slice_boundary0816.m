function [  rough_slice_BW  ] = rough_slice_boundary0816( I_contrast )
STEP_0_Parameters;

pad_size=0;
I_processing = imresize(I_contrast, (xy_pix/ref_atlas_vox_res));
% I_processing = imbinarize(I_processing,'adaptive','Sensitivity',0.05);
I_processing = padarray(I_processing,[pad_size pad_size]); 
% I_processing = uint8(I_processing*255);


imageSize = size(I_processing);
numRows = imageSize(1);
numCols = imageSize(2);

wavelengthMin = 4/sqrt(2);
wavelengthMax = hypot(numRows,numCols);
n = floor(log2(wavelengthMax/wavelengthMin));
wavelength = 2.^(0) * wavelengthMin;

deltaTheta = 15;
orientation = 0:deltaTheta:(180-deltaTheta);

g = gabor(wavelength,orientation);

gabormag = imgaborfilt(I_processing,g);

for i = 1:length(g)
    sigma = 0.5*g(i).Wavelength;
    K = 1;
    gabormag(:,:,i) = imgaussfilt(gabormag(:,:,i),K*sigma); 
end

X = 1:numCols;
Y = 1:numRows;
[X,Y] = meshgrid(X,Y);
featureSet = cat(3,gabormag,X);
featureSet = cat(3,featureSet,Y);

numPoints = numRows*numCols;
X = reshape(featureSet,numRows*numCols,[]);

X = bsxfun(@minus, X, mean(X));
X = bsxfun(@rdivide,X,std(X));

coeff = pca(X);
feature2DImage = reshape(X*coeff(:,1),numRows,numCols);

L = kmeans(X,2,'Replicates',5);

L = reshape(L,[numRows numCols]);

Aseg1 = zeros(size(I_processing),'like',I_processing);
Aseg2 = zeros(size(I_processing),'like',I_processing);
BW = L == 2;


Aseg1(BW) = I_processing(BW);
Aseg2(~BW) = I_processing(~BW);

if mean2(Aseg1)>mean2(Aseg2)
    rough_slice_BW=BW;
else
    rough_slice_BW=~BW;
end

% se = strel('disk', round(300/(0.625*50)));
% slice_BW = imdilate(slice_BW, se);
rough_slice_BW = imfill(rough_slice_BW, 'holes');
rough_slice_BW =rough_slice_BW(pad_size+1:size(rough_slice_BW ,1)-pad_size,...
    pad_size+1:size(rough_slice_BW ,2)-pad_size);
rough_slice_BW  = imresize(rough_slice_BW ,size(I_contrast),'nearest');

end

