% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function resultPose = poseVotingGivenWeight(resultPose_samples,weight)

% If weight default, it indicates an averaged voting.
% I really don't want to implement the trivial mid-val here...XD

M = size(resultPose_samples,1);
dim = size(resultPose_samples,2);
samplings = size(resultPose_samples,3);
resultPose = zeros(M,dim);
if nargin < 2
    weight = ones(M,samplings) / samplings;
else
    assert(size(weight,1) == M);
    assert(size(weight,2) == samplings);
end;

parfor k = 1:M
    candidate = reshape(resultPose_samples(k,:,:),dim,samplings);
    resultPose(k,:) = weight(k,:) * candidate';
end;

end
