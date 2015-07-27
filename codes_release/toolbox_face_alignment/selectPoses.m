% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function [selectedPose,ind] = selectPoses(pose,sub,d)

if nargin<3
    d = 2;
end;
ind = selectPosesIdx(size(pose,2),sub,d);
selectedPose = pose(:,ind);

end

