% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function [images,T] = testingsetGeneration(img_root,nameList,bbox,...
    priorModel,priorsInfo,mean_simple_face,target_simple_face)
        
assert(~xor(nargout >= 3,exist('data','var')));
m = length(nameList);
assert(size(bbox,1)==m);
p = zeros(m,8);
p(:,1:4) = repmat(bbox(:,1),1,4) + ...
    repmat(mean_simple_face(:,1:4),m,1) .* repmat(bbox(:,2)-bbox(:,1),1,4);
p(:,5:8) = repmat(bbox(:,3),1,4) + ...
    repmat(mean_simple_face(:,5:8),m,1) .* repmat(bbox(:,4)-bbox(:,3),1,4);
Tb = getTransToSpecific(p,target_simple_face * priorsInfo.win_size);
ori_images = cell(m,1);
images = cell(m,1);
for i = 1:m
    img = imread([img_root nameList{i}]);
    img = im2uint8(img);
    if size(img,3)>1, img = rgb2gray(img);end;
    ori_images{i} = img;
    images{i} = imtransform(img,Tb(i),'XData',[1 priorsInfo.win_size],...
        'YData',[1,priorsInfo.win_size]);
end;

rotationCenter = priorsInfo.win_size * priorsInfo.rotationCenter;
extractWindow = priorsInfo.win_size * priorsInfo.extractWindow;
assert(extractWindow(4)-extractWindow(3) == extractWindow(2)-extractWindow(1));
extractCellSize = (extractWindow(4)-extractWindow(3)) / priorsInfo.extractCellNum;
predicted = zeros(m,2);
F = zeros(m,priorsInfo.extractCellNum*priorsInfo.extractCellNum*31);
for i = 1:m
    F(i,:) = reshape(...
        vl_hog(single(images{i}(extractWindow(3):extractWindow(4),extractWindow(1):extractWindow(2))),extractCellSize),...
        [1,priorsInfo.extractCellNum*priorsInfo.extractCellNum*31]);
end;
for i = 1:2
    predicted(:,i) = predict(priorModel.B{i},F);
end;

predicted_vote = mean(predicted,2);
ind = find(predicted(:,1) .* predicted(:,2) < 0);
predicted_vote(ind) = 0;
ind = find(predicted(:,1) > priorsInfo.predictedVoteThre & predicted(:,2) > priorsInfo.predictedVoteThre);
predicted_vote(ind) = max(predicted(ind,:),[],2);
ind = find(predicted(:,1) < -priorsInfo.predictedVoteThre & predicted(:,2) < -priorsInfo.predictedVoteThre);
predicted_vote(ind) = min(predicted(ind,:),[],2);

Tr = getTransViaRotateGivenCenter(-predicted_vote,rotationCenter,priorsInfo.rotatorLength);
T = getTransViaMerge(priorsInfo.win_size,Tb,Tr);
for i = 1:m
    images{i} = imtransform(ori_images{i},T(i),'XData',[1 priorsInfo.win_size],...
        'YData',[1 priorsInfo.win_size]);
end;
        
end

