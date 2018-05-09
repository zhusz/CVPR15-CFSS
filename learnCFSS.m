% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

clearvars -except config testConf;
if ~exist('config','var'), error('Please run addAll.m first!'); end;
load ./data/raw.mat bbox data nameList;
[bbox,data,nameList] = indexingData([1:7500],bbox,data,nameList); % Training
img_root = './imageSource/';
load ./model/mean_simple_face.mat mean_simple_face;
load ./model/target_simple_face.mat target_simple_face;

m = size(data,1);
T = cell(1,config.stageTot);
images = cell(m,1);

model= cell(config.stageTot,1);
for level = 1:config.stageTot
    % 1. Re-trans
    if level == 1
        [images,targetPose,priorModel,T{level}] = trainingsetGeneration(img_root,nameList,bbox,data,config.priors,...
            mean_simple_face,target_simple_face);
        Pr = (1-diag(ones(m,1))) ./ (m-1);
        model{level}.tpt = targetPose;
    end;
    
    % 2. from Pr to sub-region center
    [model{level}.reg,currentPose] = traintestReg(images,targetPose,Pr,level,config.regs);
    
    if level >= config.stageTot, break; end;
    
    T{level+1} = getTransToSpecific(currentPose,priorModel.referenceShape);
    images = transImagesFwd(images,T{level+1},config.win_size,config.win_size);
    targetPose = transPoseFwd(targetPose,T{level+1});
    currentPose = transPoseFwd(currentPose,T{level+1});
    model{level+1}.tpt = targetPose;
    
    % 3. Train-test Pr (not for last stage)
    [model{level}.P,Pr] = traintestP(images,targetPose,currentPose,level,config.probs);
end;

save ./model/CFSS_Model.mat model priorModel testConf;
