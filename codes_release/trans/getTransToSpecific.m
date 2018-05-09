% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function T = getTransToSpecific(pose,specific)
%T = getTransToSpecific(pose,specific)
%   T: m*1 t_concord
%   pose: m*2n
%   specific: 1*2n

n = size(pose,2);
if mod(n,2),error('size(pose,2) is odd!');end
n = n / 2;
m = size(pose,1);
assert(size(specific,1)==1);
assert(size(specific,2)==2*n);

specific = reshape(specific,n,2);
% if (m<100) || (matlabpool('size')==0)
%     T = arrayfun(@(i)cp2tform(reshape(pose(i,:),n,2),specific,'nonreflective similarity'),1:m);
%     if m>=100
%         warning('Please launch matlabpool to speed up your program!');
%     end
% else
    T = cell(m,1);
    parfor i = 1:m
        T{i} = cp2tform(reshape(pose(i,:),n,2),specific,'nonreflective similarity');
    end
    T = cell2mat(T);
% end


end

