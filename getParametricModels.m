% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

clear;
load ./data/raw_300W_release.mat bbox data;
bbox = bbox(1:3148,:); % can only use training set
data = data(1:3148,:); % can only use training set
m = size(data,1);
n_pts = 68;
%% Get mean_simple_face
% according to the distribution of dataset
p = zeros(m,8);
p(:,1) = mean(data(:,37:42),2);
p(:,2) = mean(data(:,43:48),2);
p(:,5) = mean(data(:,n_pts+[37:42]),2);
p(:,6) = mean(data(:,n_pts+[43:48]),2);
p(:,[3 4 7 8]) = data(:,[49 55 49+n_pts 55+n_pts]);
a = zeros(m,8);
a(:,1:4) = (p(:,1:4)-repmat(bbox(:,1),1,4)) ./ repmat(bbox(:,2)-bbox(:,1),1,4);
a(:,5:8) = (p(:,5:8)-repmat(bbox(:,3),1,4)) ./ repmat(bbox(:,4)-bbox(:,3),1,4);
mean_simple_face = mean(a);
save ./model/mean_simple_face.mat mean_simple_face;
%% Get target_simple_face
% manually set
target_simple_face = [0.4 0.6 0.412 0.588 0.3 0.3 0.52 0.52];
save ./model/target_simple_face.mat target_simple_face;

