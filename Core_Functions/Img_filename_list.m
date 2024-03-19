function [ img_name ] = Img_filename_list(img_format)
%%% Sorts the Image File Names in Order

STEP_0_Parameters;

name_format=strcat('**/*.',img_format);
list_of_imgs=dir(name_format);

img_names_raw= {list_of_imgs.name}';

img_info_no=regexp(img_names_raw,'\d+','match');

img_info_no=cell2table(img_info_no);
img_info_no=table2array(img_info_no);
img_info_no=str2double(img_info_no);

sort_order=[slide_digit scene_digit channel_digit];
if sum(isnan(sort_order))==0
    img_info_no=img_info_no(:,sort_order);
    img_info_no=[img_info_no transpose(1:size(img_info_no,1))];
    img_info_no=sortrows(img_info_no,1); % based on slide #
else
    
    nan_idx=find(isnan(sort_order));
    sort_order(nan_idx)=1;
    img_info_no=img_info_no(:,sort_order);
    
    img_info_no=[img_info_no transpose(1:size(img_info_no,1))];
    img_info_no=sortrows(img_info_no,1); % based on slide #
    
    img_info_no(:,nan_idx)=1;
       
end



for ii=1:size(img_info_no,1)
    img_idx=find(img_info_no(:,4)==ii);
    for channel_check = 1:length(Name_Channels)
        if img_info_no(img_idx,3)==channel_check
            img_name{(img_idx+(length(Name_Channels)-channel_check))/length(Name_Channels),channel_check}=char(img_names_raw(ii));
        end
    end
end




end

