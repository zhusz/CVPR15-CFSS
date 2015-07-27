% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function featPCA = usePCA(featOriginal,pca_model)

featPCA = (featOriginal - repmat(pca_model.meanFeatOri,size(featOriginal,1),1))...
    * pca_model.coeff;

end

