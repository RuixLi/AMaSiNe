clear all

brain_dil=0;  %% 150um dilation of outermost surface of the brain
%%%%%%%%%%%%%%%%%% Region Sorting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ANO, metaANO] = nrrdread('annotation.nrrd');
ANO=double(rot90(permute(ANO,[3 1 2]),3));

ANO_copy=ANO;
ANO_dummy=imerode(logical(ANO),strel('disk',1));
ANO_copy(ANO_dummy)=0;
ANO_tf=logical(ANO_copy);
ANO_idx=find(ANO_tf);
[i_ori,j_ori,k_ori]=ind2sub(size(ANO),ANO_idx);
ijk_ori=gpuArray([i_ori,j_ori,k_ori]);

ANO_dil=imdilate(logical(ANO),strel('sphere',round(brain_dil/25)));
ANO_dil(logical(ANO))=false;
ANO_dil_idx=find(ANO_dil);
[i_dil,j_dil,k_dil]=ind2sub(size(ANO),ANO_dil_idx);
ijk_dil=[i_dil,j_dil,k_dil];
ijk_dil=gpuArray(ijk_dil);

tic

ANO_dil_col=ANO;

for ii=1:length(ANO_dil_idx)

    dist_array=sqrt(sum(bsxfun(@minus, ijk_ori,ijk_dil(ii,:)).^ 2, 2));
    min_dist_idx=find(dist_array==min(dist_array));
    ANO_dil_col(ANO_dil_idx(ii))=ANO(ANO_idx(min_dist_idx(1)));
end

toc

ANO=ANO_dil_col;

save('ANO','ANO','-v7.3');
