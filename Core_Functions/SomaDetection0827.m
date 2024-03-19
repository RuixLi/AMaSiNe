

function [ cell_pos ] = SomaDetection0827 (I_roi, xy_pix, soma_radius,EdgeThres)
% Soma Detector

warning('off')

fermi_mask= fermi_filter2(round(50/xy_pix),round(50/xy_pix),(soma_radius(1)/xy_pix),5);
fermi_mask= fermi_mask/sum(sum(fermi_mask));
I_roi=imfilter(I_roi,fermi_mask,'replicate');

h1 = fspecial('gaussian',[round(50/xy_pix),round(50/xy_pix)],(soma_radius(1)/xy_pix)/2.355);
h2 = fspecial('gaussian',[round(50/xy_pix),round(50/xy_pix)],3*(soma_radius(1)/xy_pix)/2.355);
h=h1-h2;

I_roi=imfilter(I_roi,h,'replicate');

% figure; imshow(I_roi)
% imcontrast

[cell_pos, ~]= imfindcircles(I_roi, round(soma_radius/xy_pix), 'Sensitivity', ...
    0.90, 'Method','TwoStage','EdgeThreshold',EdgeThres,'ObjectPolarity','bright');


% 
% [cell_pos, ~]= imfindcircles(I_roi, round(soma_radius/xy_pix), 'Sensitivity', ...
%     0.95, 'Method','TwoStage','EdgeThreshold',EdgeThres,'ObjectPolarity','bright');

end

