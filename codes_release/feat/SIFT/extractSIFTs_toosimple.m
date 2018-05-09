% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function feat = extractSIFTs_toosimple( images , currentPose, iter, featInfo)

if nargin < 4 || isempty( featInfo )
    error('you didn''t set SIFT param!!!');
end
scale = featInfo.scale(iter);
n = length( images );
n_pts = size( currentPose,2)/2;
feat = zeros(n,128*n_pts);

if isempty(currentPose), return; end;

% if (length(images)<100) || (matlabpool('size')==0)
%     for i = 1:length(images)
%         pts = reshape(currentPose(i,:),n_pts,2);
%         descriptor = extractSIFT_toosimple( single( images{i} ), pts ,scale);
%         feat(i,:) = descriptor(:)';
%     end
%     if length(images)>=500
%         warning('Please launch matlabpool to speed up your program!');
%     end
% else
    parfor i = 1:length(images)
%         descriptor = extractSIFT( single( images{i} ), reshape(currentPose(i,:),n_pts,2) ,scale);
%         feat(i,:) = descriptor(:)';
        feat(i,:) = reshape(extractSIFT_toosimple( single( images{i} ), reshape(currentPose(i,:),n_pts,2) ,scale),...
            1,128*n_pts)';
    end
% end
