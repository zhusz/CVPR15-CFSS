% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

if exist('config','var'), error('Please remove variable config mannally!'); end;

addpath(genpath('./codes_release'));
addpath(genpath('./external'));

config.stageTot = 3;
config.win_size = 250;

% From Pr to sub-region center
regsInfo.iterTot = [3 3 3];
regsInfo.samplingOffset = [NaN, 3750, 250];  % [NaN,1500,100];  % This hyper-param should be proportional to # training set
regsInfo.trainSampleTot = [10 10 10]; 
regsInfo.testSampleTot = [10 10 10]; 
regsInfo.aug_eyes_id = [61 73];  % [37 46]; Use the new index according to your new dataset. 1-based matlab.
regsInfo.win_size = config.win_size;
regsInfo.SIFTscale = [12 6 6 6];
regsInfo.mirror = [33:-1:1 47 46 45 44 43 51 50 49 48 38 37 36 35 34 42 41 40 39 ...
    52:55 60:-1:56 73 72 71 70 69 76 75 74 65 64 63 62 61 68 67 66 ...
    83:-1:77 88:-1:84 93:-1:89 96:-1:94 98 97];
% Use the new index according to your new dataset. 1-based matlab.
% regsInfo.mirror = [17:-1:1 27:-1:18 28:31 36:-1:32 ...
%     46 45 44 43 48 47 40 39 38 37 42 41 ...
%     55:-1:49 60:-1:56 65:-1:61 68:-1:66];
regsInfo.mirror = [regsInfo.mirror regsInfo.mirror+length(regsInfo.mirror)];
regsInfo.regressorInfo.trainMethod = @getLR_lcScale;
regsInfo.regressorInfo.lambda = [50*25 50*30 50*20 50*20];
regsInfo.regressorInfo.times = 20;

regsInfo.dominantIterTot = [100 100 100];

config.regs = regsInfo;

% From sub-region center to Pr

probsInfo.semantic_id = [34 39 51 47 61 65 69 73 77 83 79 80 81 86 17];
probsInfo.fix_id = [3 6 9 12 15 19 22 25 28 31];
% Readjust according to the new landmark protocol.
% probsInfo.semantic_id = [18 22 23 27 37 40 43 46 49 55 51 52 53 58 9];
% probsInfo.fix_id = [3:7 11:15];

probsInfo.sigmaCutoff = [0.25 0.25];

probsInfo.SVCradius = [20 10];
probsInfo.SVCthre = {[0.3 0.6],[0.3 0.6]};
probsInfo.probSamplings = [5 5];
probsInfo.pyramidScale = [6 12 18];
probsInfo.representativeNum1 = [12 12]; 
probsInfo.representativeNum2 = [8 8]; 

probsInfo.acceptThre = 0.9;
probsInfo.gamma_current = 1/50;
probsInfo.gamma_search = 1/50;
probsInfo.gamma_fix = 1/50;
probsInfo.gamma_prior = [1/50,1];

config.probs = probsInfo;

% Prior model
priorsInfo.augTimes = 10;
priorsInfo.maxRoll = 45;
priorsInfo.nose_id = 58; % readjusted 34;
priorsInfo.noseUpLength = 15;
priorsInfo.rotationCenter = [0.5 0.35]; %(x,y)
priorsInfo.win_size = config.win_size;
priorsInfo.rotatorLength = 15;
priorsInfo.extractWindow = [0.2 0.8 0.1 0.7]; %(xX,xD,yX,yD)
priorsInfo.extractCellNum = 3;
priorsInfo.BaggerNum = 100;

config.priors = priorsInfo;

clear regsInfo probsInfo priorsInfo;

%% Generate testConf
testConf.stageTot = config.stageTot;
testConf.win_size = config.win_size;
testConf.priors.win_size = config.win_size;
testConf.priors.rotationCenter = config.priors.rotationCenter;
testConf.priors.rotatorLength = config.priors.rotatorLength;
testConf.priors.extractWindow = config.priors.extractWindow;
testConf.priors.extractCellNum = config.priors.extractCellNum;
testConf.priors.predictedVoteThre = 10;
testConf.regs.samplingTot = [10 10 10];
testConf.regs.dominantIterTot = config.regs.dominantIterTot;
testConf.regs.SIFTscale = config.regs.SIFTscale;
testConf.regs.iterTot = config.regs.iterTot;
testConf.probs.probSamplings = config.probs.probSamplings;
testConf.probs.semantic_id = config.probs.semantic_id;
testConf.probs.fix_id = config.probs.fix_id;
testConf.probs.pyramidScale = config.probs.pyramidScale;
testConf.probs.acceptThre = config.probs.acceptThre;
testConf.probs.gamma_current = config.probs.gamma_current;
testConf.probs.gamma_search = config.probs.gamma_search;
testConf.probs.gamma_fix = config.probs.gamma_fix;
testConf.probs.gamma_prior = config.probs.gamma_prior;

