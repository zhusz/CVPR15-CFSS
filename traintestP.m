% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function [PModel,Pr] = traintestP(images,targetPose,currentPose,level,probsInfo)

n_pts = size(targetPose,2) / 2;
m = length(images);
assert(size(targetPose,1) == m && size(currentPose,1) == m);

% A. Prior Prob Learning
d = currentPose - targetPose;
[d_pca,pca_model] = getPCA(d,ceil(n_pts * probsInfo.sigmaCutoff(level)));
PModel.sigma = diag(cov(d_pca));
PModel.pca_model = pca_model;

% B. Features Prob Learning

% 1. Sampling for training and testing
s = probsInfo.probSamplings(level);
ld = cell(length(probsInfo.semantic_id),1);
for i = 1:length(probsInfo.semantic_id)
    ld{i} = zeros(m,s,2);
    r_seed = rand(m,s);
    theta_seed = rand(m,s);

    r = r_seed * probsInfo.SVCradius(level);
    theta = theta_seed * pi * 2;
    dx = r .* cos(theta);
    dy = r .* sin(theta);
    ld{i}(:,:,1) = repmat(targetPose(:,probsInfo.semantic_id(i)),1,s) + dx;
    ld{i}(:,:,2) = repmat(targetPose(:,n_pts + probsInfo.semantic_id(i)),1,s) + dy;    
end;

% 2. Centralized feature extraction
feat_all = cell(length(probsInfo.pyramidScale),1);
feat_info.scale = probsInfo.pyramidScale;
for pyramid = 1:length(probsInfo.pyramidScale)
    pose = zeros(m,length(probsInfo.semantic_id)*2,s+1);
    for i = 1:length(probsInfo.semantic_id)
        for j = 1:s
            pose(:,i,j) = ld{i}(:,j,1); % x
            pose(:,i+length(probsInfo.semantic_id),j) = ld{i}(:,j,2); % y
        end;
        pose(:,i,s+1) = currentPose(:,probsInfo.semantic_id(i)); % x
        pose(:,i+length(probsInfo.semantic_id),s+1) = currentPose(:,probsInfo.semantic_id(i)+n_pts); % y
    end;
    feat_all{pyramid} = extractSIFTs_toosimple_samples(images,pose,pyramid,feat_info);
end;

featLen = 128;
% Unroll them into training and test set
F_train = cell(length(probsInfo.semantic_id),1);
L_train = cell(length(probsInfo.semantic_id),1);
F_current = cell(length(probsInfo.semantic_id),1);
for i = 1:length(probsInfo.semantic_id)
    F_train{i} = zeros(m*s,featLen*length(probsInfo.pyramidScale));
    L_train{i} = zeros(m*s,2);
    for j = 1:s
        for k = 1:length(probsInfo.pyramidScale)
            F_train{i}(j:s:end,(k-1)*featLen+1:k*featLen) = ...
                selectFeatures(feat_all{k}(:,:,j),i,featLen) / 255;
        end;
        L_train{i}(j:s:end,1) = targetPose(:,probsInfo.semantic_id(i)) - pose(:,i,j);
        L_train{i}(j:s:end,2) = targetPose(:,probsInfo.semantic_id(i)+n_pts) - pose(:,i+length(probsInfo.semantic_id),j);
    end;
    F_current{i} = zeros(m,featLen*length(probsInfo.pyramidScale));
    for k = 1:length(probsInfo.pyramidScale)
        F_current{i}(:,(k-1)*featLen+1:k*featLen) = ...
            selectFeatures(feat_all{k}(:,:,s+1),i,featLen) / 255;
    end;
end;
clear feat_all;

% 3. Train SVM classifiers for each landmark (using the first s
% samples)
svc_ = cell(length(probsInfo.semantic_id),1);
parfor i = 1:length(probsInfo.semantic_id)
    e = sqrt(L_train{i}(:,1).^2 + L_train{i}(:,2).^2);
    ind_pos = find(e < probsInfo.SVCthre{level}(1) * probsInfo.SVCradius(level));
    ind_neg = find(e > probsInfo.SVCthre{level}(2) * probsInfo.SVCradius(level));
    ind_pos = ind_pos(:)';
    ind_neg = ind_neg(:)';
    HL = min(length(ind_pos),length(ind_neg));
    assert(HL > 8 * length(probsInfo.pyramidScale) * featLen);
    ind = [ind_pos(randperm(length(ind_pos),HL)),ind_neg(randperm(length(ind_neg),HL))];
    svc_{i} = svmtrain([ones(HL,1);-ones(HL,1)],F_train{i}(ind,:),'-c 1 -g 0.07 -b 1 -q');
end;
PModel.SVC = svc_;

% 4. tpt analysis
PModel.representativeLocation = cell(length(probsInfo.semantic_id),1);
for i = 1:length(probsInfo.semantic_id)
    location = selectPoses(targetPose,probsInfo.semantic_id(i));
    picked_id = analyse_tpt(location,probsInfo.representativeNum1(level),probsInfo.representativeNum2(level));
    for j = 1:probsInfo.representativeNum1(level)+probsInfo.representativeNum2(level)
        PModel.representativeLocation{i}(j,:) = location(picked_id(j),:);
    end;
end;

% Learning finished, now beginning testing on training
% C. Testing on training
sudoModel{level}.P = PModel;
Pr = inferenceP(images,sudoModel,currentPose,level,probsInfo,targetPose);
for i = 1:m, Pr(i,i) = 0; Pr(i,:) = Pr(i,:) ./ sum(Pr(i,:)); end;

end





