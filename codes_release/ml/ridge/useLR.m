% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function y_hat = useLR(reg_model,X)
%y_hat = useLR(reg_model,X)
%   X: m * n
%   reg_model: (n+1)*ny
%   y: m * ny

m = size(X,1);
X = [X ones(m,1)];
y_hat = X * reg_model;


end

