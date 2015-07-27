% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function [resultPose,weight] = poseVoting(resultPose_samples,voteIterTot)
% resultPose_samples : M * dim * samplings
% voteIterTot : scalar
%
% resultPose : M * dim
% weight : M * samplings

if ~exist('voteIterTot','var')
    voteIterTot = 100;
end;
M = size(resultPose_samples,1);
dim = size(resultPose_samples,2);
samplings = size(resultPose_samples,3);
% assert(dim <= 3);
resultPose = zeros(M,dim);
weight = zeros(M,samplings);
parfor k = 1:M
    candidate = reshape(resultPose_samples(k,:,:),dim,samplings);
    d = dist(candidate);
    d = d / mean(d(:));
    ed = exp(-d.^2);
    for i = 1:size(ed,1), ed(i,i) = 0;end;
    w = zeros(samplings,voteIterTot);
    w(:,1) = 1 / samplings;
    for i = 1:voteIterTot-1
        for j = 1:samplings, w(:,i+1) = w(:,i+1) + ed(:,j).*w(j,i);end;
        w(:,i+1) = w(:,i+1) / sum(w(:,i+1));
    end;
    weight(k,:) = w(:,voteIterTot)';
    resultPose(k,:) = w(:,voteIterTot)' * candidate';
end;

end
