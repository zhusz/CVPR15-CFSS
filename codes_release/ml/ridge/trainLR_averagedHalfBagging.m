% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function reg_model = trainLR_averagedHalfBagging(X,y,iter,regressorInfo)

% train regressor using all the samples only once

assert(size(X,1) == size(y,1));
m = size(X,1);
REG = zeros(size(X,2)+1,size(y,2));

for i = 1:regressorInfo.times
    train_ind = randperm(m,ceil(m/2));
    REG = REG + (1/regressorInfo.times) * ...
        regressorInfo.trainMethod(X(train_ind,:),y(train_ind,:),regressorInfo.lambda(iter));
end;
reg_model = REG;

end
