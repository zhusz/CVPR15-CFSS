% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function [selectedFeat,ind] = selectFeatures(feat,sub,d)

ind = selectFeaturesIdx(size(feat,2),sub,d);
selectedFeat = feat(:,ind);

end

