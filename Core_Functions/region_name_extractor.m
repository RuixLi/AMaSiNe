clear all

%%%%%%%%%%%%%%%%%%% Region Sorting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load ANO.mat

ANO=ANO_dil_col;
ANO=padarray(ANO,round([3000 3000]/25));

regions_unique=unique(ANO);
regions_unique=setdiff(regions_unique,0);

ano_json = fileread('annotation_label.json');
ano_decode = jsondecode(ano_json);
brain_region_label=ano_decode.msg.children(1);

room_idx=1;

generation(room_idx)=0;
region_ID{room_idx}=8;
region_name{room_idx}='Brain';
room_idx=room_idx+1;

for aa=1:length(brain_region_label.children)
    
    
    if ismember(brain_region_label.children(aa).id,regions_unique) || ~isempty(brain_region_label.children(aa).children)
        generation(room_idx)=1;
        region_ID{room_idx}=brain_region_label.children(aa).id;
        region_name{room_idx}=brain_region_label.children(aa).name;
        room_idx=room_idx+1;
    end
    
    for bb=1:length(brain_region_label.children(aa).children)
        
        if ismember(brain_region_label.children(aa).children(bb).id,regions_unique) || ~isempty(brain_region_label.children(aa).children(bb).children)
            generation(room_idx)=2;
            region_name{room_idx}=brain_region_label.children(aa).children(bb).name;
            region_ID{room_idx}=brain_region_label.children(aa).children(bb).id;
            room_idx=room_idx+1;
        end
        
        for cc=1:length(brain_region_label.children(aa).children(bb).children)
            
            if ismember(brain_region_label.children(aa).children(bb).children(cc).id,regions_unique) || ...
                    ~isempty(brain_region_label.children(aa).children(bb).children(cc).children)
                generation(room_idx)=3;
                region_name{room_idx}=brain_region_label.children(aa).children(bb).children(cc).name;
                region_ID{room_idx}=brain_region_label.children(aa).children(bb).children(cc).id;
                room_idx=room_idx+1;
            end
            
            for dd=1:length(brain_region_label.children(aa).children(bb).children(cc).children)
                
                if ismember(brain_region_label.children(aa).children(bb).children(cc).children(dd).id,regions_unique) || ...
                        ~isempty(brain_region_label.children(aa).children(bb).children(cc).children(dd).children)
                    generation(room_idx)=4;
                    region_name{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).name;
                    region_ID{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).id;
                    room_idx=room_idx+1;
                end
                
                
                for ee=1:length(brain_region_label.children(aa).children(bb).children(cc).children(dd).children)
                    
                    if ismember(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).id,regions_unique) || ...
                            ~isempty(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children)
                        generation(room_idx)=5;
                        region_name{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).name;
                        region_ID{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).id;
                        room_idx=room_idx+1;
                    end
                    
                    for ff=1:length(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children)
                        
                        if ismember(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).id,regions_unique) || ...
                                ~isempty(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children)
                            generation(room_idx)=6;
                            region_name{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).name;
                            region_ID{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).id;
                            room_idx=room_idx+1;
                        end
                        
                        for gg=1:length(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children)
                            
                            if ismember(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).id,regions_unique) || ...
                                    ~isempty(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children)
                                generation(room_idx)=7;
                                region_name{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).name;
                                region_ID{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).id;
                                room_idx=room_idx+1;
                            end
                            
                            for hh=1:length(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children)
                                
                                if ismember(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).id,regions_unique) || ...
                                        ~isempty(brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).children)
                                    generation(room_idx)=8;
                                    region_name{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).name;
                                    region_ID{room_idx}=brain_region_label.children(aa).children(bb).children(cc).children(dd).children(ee).children(ff).children(gg).children(hh).id;
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

region_name=region_name';
generation= generation';
region_ID=region_ID';

layer_tf_1=(contains(region_name,'layer'));
layer_tf_2=(contains(region_name,'Layer'));
layer_tf=(layer_tf_1 | layer_tf_2);

layer_tf_idx=find(layer_tf);
for ii=1:length(layer_tf_idx)
    prev_regions_tempo=1:layer_tf_idx(ii)-1;
    parent_idx=max(find(generation(prev_regions_tempo)<generation(layer_tf_idx(ii))));
    region_ID{parent_idx} =[region_ID{parent_idx}, region_ID{layer_tf_idx(ii)}];
    
end

region_name=region_name(~layer_tf);
generation= generation(~layer_tf);
region_ID=region_ID(~layer_tf);
ROI_ancestry=cell(length(region_name),1);
for iter=1:10
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

for ii=1:length(region_ID)

    ANO_tf=ismember(ANO,region_ID{ii});
    
    ANO_edge=ANO_tf-imerode(ANO_tf,true(3));

    roi_vol_idx=find(ANO_edge);

   [roi_vol_x,roi_vol_y,roi_vol_z]=ind2sub(size(ANO),roi_vol_idx);

    roi_vol_xyz=...
        25*([roi_vol_y,-roi_vol_x,-roi_vol_z]-[288+60, -56-60 -214]);
    
    shp = alphaShape(roi_vol_xyz(:,1),roi_vol_xyz(:,2),roi_vol_xyz(:,3),sqrt(3*25^2)+1)

    ROI_boudnary(ii).shp=shp;

end

for ii=1:length(region_ID)
    
    region_name_list(ii).name=region_name{ii};
    region_ID_list(ii).list=region_ID{ii};
    ROI_ancestry_list(ii).list=ROI_ancestry{ii};
    
end

matlab.io.saveVariablesToScript('test.m')

save('Step5_ANO','ROI_boudnary','region_ID_list','generation','region_name_list','ROI_ancestry_list','-v7.3')