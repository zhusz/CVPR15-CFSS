% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function featOri_batch = extractSIFTs_toosimple_samples(images,currentPose_samples,iter,featInfo)

m = length(images);
assert(size(currentPose_samples,1) == m);
samplings = size(currentPose_samples,3);
pose = currentPose_samples(:,:,1);
for i = 2:samplings
    pose = mergePose(pose,currentPose_samples(:,:,i));
end;
featOri_total = extractSIFTs_toosimple(images,pose,iter,featInfo);
featOri_batch = reshape(featOri_total,[m,size(featOri_total,2) / samplings,samplings]);

end
