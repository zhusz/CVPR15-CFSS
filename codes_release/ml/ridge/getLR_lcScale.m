% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function reg_model = getLR_lcScale(X,y,lambda,scaling_index)
%reg_model = getLR_lcScale(X,y,lambda,scaling_index)
% X: m * n
% y: m * ny
% lambda: regularization scalar
% reg_model: (n+1)*ny
% each dimension in X(total n) will be scaled to near 1.

m = size(X,1);
n = size(X,2);

if nargin < 4, scaling_index = min(40,n); end;

d = std(X);
md = d(scaling_index);
d = (d+md)*d(1)/(d(1)+md);
X = X * diag(1./d);

X = [X ones(m,1)];
I = eye(n+1,n+1);
I(n+1,n+1) = 0;
reg_model = (X'*X + lambda*I)\(X'*y);

reg_model = diag(1./[d 1]) * reg_model;

end

