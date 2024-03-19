clear all
load('ANO.mat')

brain_rasa=uint8(zeros(size(ANO,1),size(ANO,2)));

for ii=1:size(ANO,3)
    img_slice=ANO(:,:,ii);
    unique_rois=unique(img_slice);
    unique_rois=setdiff(unique_rois,0);
    tabula_rasa=false(size(img_slice));
    for roi_jj=1:length(unique_rois)
        img_tempo=img_slice;
        img_tempo(img_tempo~=unique_rois(roi_jj))=0;
        img_tempo(img_tempo==unique_rois(roi_jj))=255;
        img_tempo=edge(img_tempo,'Sobel');
        tabula_rasa(img_tempo)=true;
    end
    tabula_rasa=uint8(255*double(tabula_rasa));
    brain_rasa=cat(3,brain_rasa,tabula_rasa);
end

ANO_roi_edge=brain_rasa(:,:,2:end);
save('ANO_roi_edge','ANO_roi_edge','-v7.3');
