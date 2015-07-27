% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function T = getTransPairRegardingNaN(pose1,pose2)
%T = getTransPair(pose1,pose2)
%   T: m*1 t_concord
%   pose1: m*2n
%   pose2: m*2n

n = size(pose1,2);
if mod(n,2),error('size(pose,2) is odd!');end
n = n / 2;
m = size(pose1,1);
assert(size(pose2,1)==m);
assert(size(pose2,2)==2*n);

T = cell(m,1);
parfor i = 1:m
    pose1I = pose1(i,:);
    pose2I = pose2(i,:);
    idx = intersect(find(~isnan(pose1I(1:n))),find(~isnan(pose2I(1:n))));
    T{i} = cp2tform(reshape(pose1I([idx idx+n]),length(idx),2),...
        reshape(pose2I([idx idx+n]),length(idx),2),...
        'nonreflective similarity');
end
T = cell2mat(T);

end

