% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function [images,targetPose,priorModel,T] = trainingsetGeneration(img_root,nameList,bbox,data,priorsInfo,...
    mean_simple_face,target_simple_face)

% Loading original images
m = length(nameList);
assert(size(bbox,1)==m && size(data,1)==m);
p = zeros(m,8);
p(:,1:4) = repmat(bbox(:,1),1,4) + ...
    repmat(mean_simple_face(:,1:4),m,1) .* repmat(bbox(:,2)-bbox(:,1),1,4);
p(:,5:8) = repmat(bbox(:,3),1,4) + ...
    repmat(mean_simple_face(:,5:8),m,1) .* repmat(bbox(:,4)-bbox(:,3),1,4);
Tb = getTransToSpecific(p,target_simple_face*priorsInfo.win_size);
ori_images = cell(m,1);
for i = 1:m
    img = imread([img_root nameList{i}]);
    img = im2uint8(img);
    if size(img,3)>1, img = rgb2gray(img);end;
    ori_images{i} = img;
end;
targetPose = transPoseFwd(data,Tb);
referenceShape = mean(targetPose);

% Label angle estimation according to targetPose
Te = getTransPair(repmat(referenceShape,m,1),targetPose);
nosePose = selectPoses(targetPose,priorsInfo.nose_id);
noseUpPose = nosePose;
noseUpPose(:,2) = noseUpPose(:,2) + priorsInfo.noseUpLength;
noses = mergePose(nosePose,noseUpPose);
new_noses = transPoseFwd(noses,Te);
angle = atand((new_noses(:,2) - new_noses(:,1)) ./ (new_noses(:,4) - new_noses(:,3)));

% Dataset partition
ra = randperm(m);
set_id = zeros(m,1);
set_id(ra(1:ceil(m/2))) = 1;
set_id(ra(1+ceil(m/2):m)) = 2;

% Training 
B = cell(2,1);
rotationCenter = priorsInfo.win_size * priorsInfo.rotationCenter;
extractWindow = priorsInfo.win_size * priorsInfo.extractWindow;
assert(extractWindow(4)-extractWindow(3) == extractWindow(2)-extractWindow(1));
extractCellSize = (extractWindow(4)-extractWindow(3)) / priorsInfo.extractCellNum;
for s = 1:2
    ind_train = find(set_id == s);
    angle_train = angle(ind_train);
    images_train = ori_images(ind_train);
    Tb_train = Tb(ind_train);
    
    mp = length(ind_train);
    MP = mp * priorsInfo.augTimes;
    im = cell(MP,1);
    label = priorsInfo.maxRoll * (2*rand(MP,1)-1);
    for i = 1:priorsInfo.augTimes
        Tr_train = getTransViaRotateGivenCenter(label((i-1)*mp+1:i*mp)-angle_train,...
            rotationCenter,priorsInfo.rotatorLength);
        Tbr_train = getTransViaMerge(priorsInfo.win_size,Tb_train,Tr_train);
        im((i-1)*mp+1:i*mp) = transImagesFwd(images_train,Tbr_train,priorsInfo.win_size,priorsInfo.win_size);
    end;
    F = zeros(MP,priorsInfo.extractCellNum*priorsInfo.extractCellNum*31);
    for i = 1:MP
        F(i,:) = reshape(...
            vl_hog(single(im{i}(extractWindow(3):extractWindow(4),extractWindow(1):extractWindow(2))),extractCellSize),...
            [1,priorsInfo.extractCellNum*priorsInfo.extractCellNum*31]);
    end;
    B{s} = TreeBagger(priorsInfo.BaggerNum,F,label,'Method','regression');
end;

images = transImagesFwd(ori_images,Tb,priorsInfo.win_size,priorsInfo.win_size);
% Testing
% predicted = zeros(m,1);
% F = zeros(m,priorsInfo.extractCellNum*priorsInfo.extractCellNum*31);
% for i = 1:m
%     F(i,:) = reshape(...
%         vl_hog(single(images{i}(extractWindow(3):extractWindow(4),extractWindow(1):extractWindow(2))),extractCellSize),...
%         [1,priorsInfo.extractCellNum*priorsInfo.extractCellNum*31]);
% end;
% for s = 1:2
%     ind_test = find(set_id == s);
%     predicted(ind_test) = predict(B{3-s},F(ind_test,:));
% end;
% 
% save now0D; error here;

priorModel.referenceShape = referenceShape;
priorModel.B = B;
T = Tb;

end

