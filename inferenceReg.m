% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function currentPose = inferenceReg(images,model,Pr,level,regsInfo)

m = length(images);
n_pts = size(model{level}.tpt,2) / 2;
tpt = model{max(1,level-1)}.tpt;
mt = size(tpt,1);

% 61. Sampling
index_inference = zeros(m,regsInfo.samplingTot(level));
currentPose_inference = zeros(m,2*n_pts,regsInfo.samplingTot(level));
for i = 1:m
    if level > 1
        [~,tmp] = sort(Pr(i,:),'descend');
        index_inference(i,:) = tmp(1:regsInfo.samplingTot(level));
    else
        index_inference(i,:) = randSampleNoReplace(mt, regsInfo.samplingTot(level), Pr(i,:));
    end;
    for j = 1:regsInfo.samplingTot(level)
        currentPose_inference(i,:,j) = tpt(index_inference(i,j),:);
    end;
end;

% 62. Inference Iteration
featInfo.scale = regsInfo.SIFTscale;
for iter = 1:regsInfo.iterTot(level)
    featOri_batch = extractSIFTs_toosimple_samples(images,currentPose_inference,iter,featInfo);
    for j = 1:regsInfo.samplingTot(level)
        currentPose_inference(:,:,j) = currentPose_inference(:,:,j) + ...
            (featOri_batch(:,:,j) - repmat(model{level}.reg{iter}.mu,m,1)) * model{level}.reg{iter}.A ...
             + repmat(model{level}.reg{iter}.b,m,1);
    end;
end;

currentPose = poseVoting(currentPose_inference,regsInfo.dominantIterTot(level));

end

