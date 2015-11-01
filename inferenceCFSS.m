% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

clear;
load ./data/raw_300W_release.mat bbox nameList;
[bbox,nameList] = indexingData(3149:3837,bbox,nameList); % Testing
img_root = './imageSource/';
load ./model/mean_simple_face.mat mean_simple_face;
load ./model/target_simple_face.mat target_simple_face;
load ./model/CFSS_Model.mat priorModel testConf model;

m = length(nameList);
mt = size(model{1}.tpt,1);
T = cell(1,testConf.stageTot);
images = cell(m,1);

for level = 1:testConf.stageTot
    % 61. Re-trans
    if level == 1
        [images,T{level}] = testingsetGeneration(img_root,nameList,bbox,...
            priorModel,testConf.priors,mean_simple_face,target_simple_face);
        Pr = 1/mt * ones(m,mt);
    end;
    
    % 62. from Pr to sub-region center 
    currentPose = inferenceReg(images,model,Pr,level,testConf.regs); 
    
    if level >= testConf.stageTot, break; end;
    
    T{level+1} = getTransToSpecific(currentPose,priorModel.referenceShape);
    images = transImagesFwd(images,T{level+1},testConf.win_size,testConf.win_size);
    currentPose = transPoseFwd(currentPose,T{level+1});
    
    % 63. from sub-region center to Pr
    Pr = inferenceP(images,model,currentPose,level,testConf.probs);
end;

estimatedPose = currentPose;
for level = testConf.stageTot:-1:1
    estimatedPose = transPoseInv(estimatedPose,T{level});
end;

load ./data/raw_300W_release.mat data;
data = data(3149:end,:);
delta = abs(estimatedPose - data);
n = size(data,2) / 2;
er_abs = mean(sqrt(delta(:,1:n).^2 + delta(:,n+1:2*n).^2), 2);
eyes_dist = sqrt((mean(pose(:,[37:42]),2) - mean(pose(:,[43:48]),2)).^2 ...
    + (mean(pose(:,[105:110]),2) - mean(pose(:,[111:116]),2)).^2);
er = er_abs ./ eyes_dist;
