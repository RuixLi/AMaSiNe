load ANO.mat;
load Step5_ANO_info.mat;

ANO=padarray(ANO,round([3000 3000]/25));

unique_ROIs=unique(ANO);
unique_ROIs=setdiff(unique_ROIs,0);
unique_ROIs=intersect(unique_ROIs,region_ID_list(1).list);


ROI_shell_coord=nan(sum(sum(sum(logical(ANO)))),4);
fill_idx=1;


for ii=1:length(unique_ROIs)
    
    ii

    ANO_tf=ismember(ANO,unique_ROIs(ii));
    ANO_tf=ANO_tf-imerode(ANO_tf,strel('sphere',1));
    roi_vol_idx=find(ANO_tf);
    
    [roi_vol_x,roi_vol_y,roi_vol_z]=ind2sub(size(ANO),roi_vol_idx);
    
    roi_vol_xyz=...
        25*([roi_vol_y,-roi_vol_x,-roi_vol_z]-[348  -116  -214]);
    
    roi_vol_xyz=[roi_vol_xyz, unique_ROIs(ii)*ones(size(roi_vol_xyz,1),1)];
    
    ROI_shell_coord(fill_idx:fill_idx+size(roi_vol_xyz,1)-1,:)=roi_vol_xyz;
    
    fill_idx=fill_idx+size(roi_vol_xyz,1);
    

end

ROI_shell_coord_isnan=ROI_shell_coord(:,1);
ROI_shell_coord_isnan=find(~isnan(ROI_shell_coord_isnan));
ROI_shell_coord=ROI_shell_coord(ROI_shell_coord_isnan,:);

save('ROI_region_pixels','ROI_shell_coord','-v7.3')


