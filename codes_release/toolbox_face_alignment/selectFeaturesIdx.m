% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function ind = selectFeaturesIdx(len,sub,d)

assert(mod(len,d)==0);
sub = sub(:)';
ind = [];
for i = sub
    ind = [ind (i-1)*d+1:i*d];
end

end

