% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function newPose = transPoseFwd(oldPose,T)
% newPose = transPoseFwd(oldPose,T)
% produce new pose according to oldPose and T
% size(oldPose) = [m,2n], each row must in the format of X1...Xn,Y1...Yn.
% T is a array containing n structures. Each one is the trans for one
% sample.
% newPose has the same size as oldPose.

m = size(oldPose,1);
if length(T)~=m,error('length(T) must be the same as size(oldPose,1)!');end;
n = size(oldPose,2);
if mod(n,2),error('size(pose,2) is odd!');end
n = n / 2;
ind_nan = find(isnan(oldPose));
oldPose(ind_nan) = 0;

% if (m<100) || (matlabpool('size')==0)
%     newPose = arrayfun(@(i)reshape(tformfwd(T(i),reshape(oldPose(i,:),n,2)),1,2*n),1:m,'UniformOutput',false);
%     newPose = cell2mat(newPose(:));
%     if m>=100
%         warning('Please launch matlabpool to speed up your program!');
%     end
% else
    newPose = zeros(size(oldPose));
    parfor i = 1:m
        newPose(i,:) = reshape(tformfwd(T(i),reshape(oldPose(i,:),n,2)),1,2*n);
    end
% end
newPose(ind_nan) = NaN;

end

