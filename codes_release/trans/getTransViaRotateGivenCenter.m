% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function T = getTransViaRotateGivenCenter(theta_vector,center,rotatorLength)
%T = getTransViaRotateGivenCenter(theta_vector,win_size)
%   T: m*1 t_concord
%   theta_vector: m*1 in degree! Make sure abs(theta)<180
%   center: 1*2 indicates the x-y coordinates of rotation center
%   rotatorLength: scalar, length of the ratator. Set this variable to
%       avoid numerical problems.

warning('This function might get non-affine tform');
assert(size(theta_vector,1)==1 || size(theta_vector,2)==1);
assert(size(center,1)==1 || size(theta_vector,2)==1);
assert(length(center)==2);
assert(length(rotatorLength)==1);
theta_vector = theta_vector(:);
assert(all(abs(theta_vector) < 180));

pose_src = zeros(length(theta_vector),4);
pose_src(:,[1 3]) = repmat(center(:)',length(theta_vector),1);
pose_src(:,2) = center(1) + rotatorLength * cosd(theta_vector);
pose_src(:,4) = center(2) + rotatorLength * sind(theta_vector);
pose_dst = [center(1) center(1)+rotatorLength center(2) center(2)];

T = getTransToSpecific(pose_src,pose_dst);

end

