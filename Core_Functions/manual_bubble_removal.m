function [ I_processing, BW ] = manual_bubble_removal(I_contrast)

figure; imshow(I_contrast)

title('Press SPACE to get a rough ROI')  % Press a key here.You can see the message 'Paused: Press any key' in        % the lower left corner of MATLAB window.


key = get(gcf,'CurrentKey');
while ~(strcmp (key , 'space'))
    key = get(gcf,'CurrentKey');
    pause
end


hold on;

h = imfreehand; BW = createMask(h);

I_processing=I_contrast.*uint8(BW);

close all


end

