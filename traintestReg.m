% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function [regModel,currentPose] = traintestReg(images,targetPose,Pr,level,regsInfo)

% regModel: iterTot * 1 cell, cascaded regressors
% currentPose: m * (2*n_pts), estimated sub-region center
% images: m * 1 cell, procrusted images
% targetPose: m * (2*n_pts), target shape, also candidate shapes
% Pr: m * m, probability distribution over candidates
% level: scalar indicating current level
% regsInfo: configuration

% Steps:
% 1. Sampling both for train and test
% 2. Learn regressors (train part) to get regModel output
% 3. Test regressors (test part)
% 4. Dominant to get currentPose output

% Initial pose selection principle: 
% training according to the given Pr
% testing according to uniform distribution

% 1. Sampling both for train and test
m = length(images);
n_pts = size(targetPose,2) / 2;
regModel = cell(regsInfo.iterTot(level),1);

index_train = zeros(m,regsInfo.trainSampleTot(level));
index_test = zeros(m,regsInfo.testSampleTot(level));
currentPose_train = zeros(m,2*n_pts,regsInfo.trainSampleTot(level));
currentPose_test = zeros(m,2*n_pts,regsInfo.testSampleTot(level));
for i = 1:m
    if level > 1
        [~,tmp] = sort(Pr(i,:),'descend');
        index_train(i,:) = tmp(regsInfo.samplingOffset(level) + 1:...
            regsInfo.samplingOffset(level) + regsInfo.trainSampleTot(level));
        index_test(i,:) = tmp(regsInfo.samplingOffset(level) + regsInfo.trainSampleTot(level) + 1:...
            regsInfo.samplingOffset(level) + regsInfo.trainSampleTot(level) + regsInfo.testSampleTot(level));
    else
        [index_train(i,:),PrI_temp] = randSampleNoReplace(m,regsInfo.trainSampleTot(level),Pr(i,:));
        index_test(i,:) = randSampleNoReplace(m, regsInfo.testSampleTot(level), PrI_temp);
    end;
    for j = 1:regsInfo.trainSampleTot(level)
        currentPose_train(i,:,j) = targetPose(index_train(i,j),:);
    end;
    for j = 1:regsInfo.testSampleTot(level)
        currentPose_test(i,:,j) = targetPose(index_test(i,j),:);
    end;
end;

% 2. learn regressors to get regModel
% 2A. Augmentation
M = m * regsInfo.trainSampleTot(level);
im = cell(M,1);
tg = zeros(M,2*n_pts);
cu = zeros(M,2*n_pts);
for i = 1:regsInfo.trainSampleTot(level)
    Ta = getTransRandomCross(selectPoses(targetPose,regsInfo.aug_eyes_id));
    cu((i-1)*m+1:i*m,:) = transPoseFwd(currentPose_train(:,:,i),Ta);
    tg((i-1)*m+1:i*m,:) = transPoseFwd(targetPose,Ta);
    for j = 1:m
        im{(i-1)*m+j} = imtransform(images{j},Ta(j),...
            'XData',[1 regsInfo.win_size],'YData',[1 regsInfo.win_size]);
    end;
    if mod(i,2) == 0
        tg((i-1)*m+1:i*m,1:n_pts) = regsInfo.win_size + 1 - tg((i-1)*m+1:i*m,1:n_pts);
        tg((i-1)*m+1:i*m,:) = tg((i-1)*m+1:i*m,regsInfo.mirror);
        cu((i-1)*m+1:i*m,1:n_pts) = regsInfo.win_size + 1 - cu((i-1)*m+1:i*m,1:n_pts);
        cu((i-1)*m+1:i*m,:) = cu((i-1)*m+1:i*m,regsInfo.mirror);
        for j = (i-1)*m+1:i*m, im{j} = im{j}(:,end:-1:1); end;
    end;
end;

% 2B. Training iteration
featInfo.scale = regsInfo.SIFTscale;
for iter = 1:regsInfo.iterTot(level)
    featOri = extractSIFTs_toosimple(im,cu,iter,featInfo);
    [featReg,pca_model] = getPCA(featOri,[]);
    reg_model = trainLR_averagedHalfBagging(featReg,tg-cu,iter,regsInfo.regressorInfo);
    regModel{iter}.mu = pca_model.meanFeatOri;
    regModel{iter}.A = pca_model.coeff * reg_model(1:end-1,:);
    regModel{iter}.b = reg_model(end,:);
    cu = cu + (featOri - repmat(regModel{iter}.mu,M,1))*regModel{iter}.A ...
        + repmat(regModel{iter}.b,M,1);
    
    featOri_batch = extractSIFTs_toosimple_samples(images,currentPose_test,iter,featInfo);
    for j = 1:regsInfo.testSampleTot(level)
        currentPose_test(:,:,j) = currentPose_test(:,:,j) + ...
            (featOri_batch(:,:,j) - repmat(regModel{iter}.mu,m,1)) * regModel{iter}.A ...
            +repmat(regModel{iter}.b,m,1);
    end;
end;

currentPose = poseVoting(currentPose_test,regsInfo.dominantIterTot(level));

end
