clear all
load ANO.mat;

ANO=padarray(ANO,round([3000 3000]/25));

regions_unique=unique(ANO);
regions_unique=setdiff(regions_unique,0);

ano_json = fileread('annotation_label.json');
ano_decode = jsondecode(ano_json);
brain_region_label=ano_decode.msg.children(1);

room_idx=1;

generation(room_idx)=0;
region_ID{room_idx}=8;
region_name{room_idx}='Whole Brain';
region_color{room_idx}='BFDAE3';
room_idx=room_idx+1;

for aa=1:length(brain_region_label.children)
    
    
    if ismember(brain_region_label.children(aa).id,regions_unique) || ~isempty(brain_region_label.children(aa).children)
        generation(room_idx)=1;
        region_ID{room_idx}=brain_region_label.children(aa).id;
        region_name{room_idx}=brain_region_label.children(aa).name;
        region_color{room_idx}=brain_region_label.children(aa).color_hex_triplet;
        room_idx=room_idx+1;
    end
    
    for bb=1:length(brain_region_label.children(aa).children)
        
        if ismember(brain_region_label.children(aa).children(bb).id,regions_unique) || ~isempty(brain_region_label.children(aa).children(bb).children)
            generation(room_idx)=2;
            region_name{room_idx}=brain_region_label.children(aa).children(bb).name;
            region_ID{room_idx}=brain_region_label.children(aa).children(bb).id;
            region_color{room_idx}=brain_region_label.children(aa).children(bb).color_hex_triplet;
            room_idx=room_idx+1;
        end
        
        for cc=1:length(brain_region_label.children(aa).children(bb).children)
            
            if ismember(brain_region_label.children(aa).children(bb).children(cc).id,regions_unique) || ...
                    ~isempty(brain_region_label.children(aa).children(bb).children(cc).children)
                generation(room_idx)=3;
                region_name{room_idx}=brain_region_label.children(aa).children(bb).children(cc).name;
                region_ID{room_idx}=brain_region_label.children(aa).children(bb).children(cc).id;
                region_color{room_idx}=brain_region_label.children(aa).children(bb).children(cc).color_hex_triplet;
                room_idx=room_idx+1;
            end
            
            for dd=1:length(brain_region_label.children(aa).children(bb).children(cc).children)
                
                if ismember(brain_region_label.children(aa).children(bb).children(cc).children(dd).id,regions_unique) || ...
                        ~isempty(brain_region_label.children(aa).children(bb).children(cc).children(dd).children)
                    generation(room_idx)=4;
                    region_name{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).name;
                    region_ID{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).id;
                    region_color{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).color_hex_triplet;
                    room_idx=room_idx+1;
                end
                
                
                for ee=1:length(brain_region_label.children(aa).children(bb).children(cc).children(dd).children)
                    
                    if ismember(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).id,regions_unique) || ...
                            ~isempty(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children)
                        generation(room_idx)=5;
                        region_name{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).name;
                        region_ID{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).id;
                        region_color{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).color_hex_triplet;
                        room_idx=room_idx+1;
                    end
                    
                    for ff=1:length(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children)
                        
                        if ismember(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).id,regions_unique) || ...
                                ~isempty(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children)
                            generation(room_idx)=6;
                            region_name{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).name;
                            region_ID{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).id;
                            region_color{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).color_hex_triplet;
                            room_idx=room_idx+1;
                        end
                        
                        for gg=1:length(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children)
                            
                            if ismember(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).id,regions_unique) || ...
                                    ~isempty(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children)
                                generation(room_idx)=7;
                                region_name{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).name;
                                region_ID{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).id;
                                region_color{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).color_hex_triplet;
                                room_idx=room_idx+1;
                            end
                            
                            for hh=1:length(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children)
                                
                                if ismember(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).id,regions_unique) || ...
                                        ~isempty(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).children)
                                    generation(room_idx)=8;
                                    region_name{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).name;
                                    region_ID{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).id;
                                    region_color{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).color_hex_triplet;
                                    room_idx=room_idx+1;
                                end
                                for ii=1:length(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).children)
                                    
                                    if ismember(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).children(ii).id,regions_unique) || ...
                                            ~isempty(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).children(ii).children)
                                        generation(room_idx)=9;
                                        region_name{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).children(ii).name;
                                        region_ID{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).children(ii).id;
                                        region_color{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).children(ii).color_hex_triplet;
                                        room_idx=room_idx+1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

region_name=region_name';
generation= generation';
region_ID=region_ID';
region_color=region_color';

ROI_ancestry=cell(length(region_name),1);
for iter=1:12
    for ii=1:length(region_name)
        ROI_ancestry{ii}=[ROI_ancestry{ii} ii];
        prev_regions_tempo=1:ii-1;
        parent_idx=max(find(generation(prev_regions_tempo)<generation(ii)));
        if ~isempty(parent_idx)
            region_ID{parent_idx} =[region_ID{parent_idx} region_ID{ii}];
            ROI_ancestry{parent_idx}=[parent_idx ROI_ancestry{ii} ROI_ancestry{parent_idx}];
        end
    end
end

for ii=1:length(region_ID)
    region_ID{ii}=unique(region_ID{ii});
    ROI_ancestry{ii}=unique(ROI_ancestry{ii});
end


%%%%%%%%%%%%%%%%%%%%%%% DRAW BOUNDARIES OF ROIs %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Whole Brain

h_progress = waitbar(0,'Computing ROI shell (alphashape)');

ANO_tf=logical(ANO);
ANO_tf=imfill(ANO_tf,'holes');

ANO_edge=ANO_tf-imerode(ANO_tf,true(3));

roi_vol_idx=find(ANO_edge);

[roi_vol_x,roi_vol_y,roi_vol_z]=ind2sub(size(ANO),roi_vol_idx);

roi_vol_xyz=...
    25*([roi_vol_y,-roi_vol_x,-roi_vol_z]-[348  -116  -214]);

shp = alphaShape(roi_vol_xyz,sqrt(3*100^2)+1); %% get alphashape shell of ROI

ROI_boundary(1).RL(1).shp=shp;

% figure; plot(shp,'EdgeColor','none','FaceAlpha',0.3); drawnow

 waitbar(1 / length(region_ID),h_progress,...
        strcat({'Computing ROI shell (alphashape) : '},{num2str(1)},...
    {' of '},{num2str( length(region_ID))},{' ROIs done'}))

for ii=2:length(region_ID) %%%% all the rest

    ANO_tf=ismember(ANO,region_ID{ii});
    
    ANO_edge=ANO_tf-imerode(ANO_tf,true(3));
    
    roi_vol_idx=find(ANO_edge);
    
    [roi_vol_x,roi_vol_y,roi_vol_z]=ind2sub(size(ANO),roi_vol_idx);
    
    roi_vol_xyz=...
        25*([roi_vol_y,-roi_vol_x,-roi_vol_z]-[348  -116  -214]);
    

    [tf,~]=ismember(0,roi_vol_xyz(:,1),'rows');
    
    if tf   %% if tf==1, right hemisphere ; else left hemisphere
        
        shp = alphaShape(roi_vol_xyz,sqrt(3*100^2)+1); %% get alphashape shell of ROI
        ROI_boundary(ii).RL(1).shp=shp;
        
    else
        
        roi_vol_xyz_RL=roi_vol_xyz(:,1);
        roi_vol_xyz_RL=roi_vol_xyz_RL>0;
        
        shp = alphaShape(roi_vol_xyz(roi_vol_xyz_RL,:),sqrt(3*100^2)+1); %% get alphashape shell of ROI
        ROI_boundary(ii).RL(1).shp=shp;
        
        shp = alphaShape(roi_vol_xyz(~roi_vol_xyz_RL,:),sqrt(3*100^2)+1); %% get alphashape shell of ROI
        ROI_boundary(ii).RL(2).shp=shp;
        
    end
    
%     figure; plot(shp,'EdgeColor','none','FaceAlpha',0.3); drawnow
  waitbar(ii / length(region_ID),h_progress,...
        strcat({'Computing ROI shell (alphashape) : '},{num2str(ii)},...
    {' of '},{num2str( length(region_ID))},{' ROIs done'}))

end

for ii=1:length(region_ID)
    region_name_list(ii).name=region_name{ii};
    region_ID_list(ii).list=region_ID{ii};
    ROI_ancestry_list(ii).list=ROI_ancestry{ii};
    eval_str=strcat('shp_',num2str(ii),'=ROI_boundary(ii);');
    eval(eval_str);
    
    save_title=strcat('shp_',num2str(ii));
    save(save_title,save_title,'-v7.3')
end



waitbar(ii / length(region_ID),...
    strcat({'Computing ROI shell (alphashape) : '},{'Done!'}))

close(h_progress);


save('Step5_ANO_info','region_ID_list','generation','region_name_list',...
    'ROI_ancestry_list','region_color','-v7.3')
