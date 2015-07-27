% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function feat = extractSIFT_toosimple( img, pt , scale)

if nargin < 3
    error('you didn''t set the SIFTscale!!!');
end

if( size(pt,1)==1 )
    n_pts = size(pt,2)/2;
    pt = reshape(pt ,n_pts, 2);
else
    n_pts = size( pt,1);
end

fc = [ pt' ; ones(1,n_pts)*scale/6 ; zeros(1,n_pts)];

[f,descriptor] = vl_sift_toosimple(img,'frames',fc);

f = f(1:2,:);
fc = fc(1:2,:);
diff = [ones(2,1), f(:,2:end)-f(:,1:end-1)];

bo = sum(abs(diff)) > 0.1 ;

f = f(:,bo);
descriptor = descriptor(:,bo);

[IDX, ~] = knnsearch(f',fc','k',1);

feat = descriptor(:, IDX );