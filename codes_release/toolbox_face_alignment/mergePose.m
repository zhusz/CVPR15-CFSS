% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function augmentedPose = mergePose(pose1,pose2)

m = size(pose1,1);
assert(size(pose2,1)==m);
assert(mod(size(pose1,2),2)==0);
assert(mod(size(pose2,2),2)==0);
n1 = size(pose1,2) / 2;
n2 = size(pose2,2) / 2;

augmentedPose = NaN * zeros(m,2*(n1+n2));
n = n1+n2;
augmentedPose(:,selectPosesIdx(2*n,1:n1)) = pose1;
augmentedPose(:,selectPosesIdx(2*n,n1+1:n)) = pose2;

end

