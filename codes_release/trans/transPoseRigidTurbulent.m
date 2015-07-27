% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function [newCurrentPose,testShift] = transPoseRigidTurbulent(themeA,win_size,turb_coeff,currentPose,targetPose,errorL,errorS,maxIter)
%   Please note 'turb_coeff' is defined as follows:
%     (errorL - errorS) * turb_coeff = (errorNew - errorS)
%   All error means L2 error.

errorNewTarget = errorS + (errorL-errorS)*turb_coeff;
testShift = 1;
upper = inf;
inffer = -inf;
step = 0.2;
m_sample = size(currentPose,1); % min(size(currentPose,1),1000);

for i = 1:maxIter
    ra = randperm(size(currentPose,1));
    ra = ra(1:m_sample);
    expOldCurrentPose = currentPose(ra,:);
    Tshift = getTransShift(win_size,testShift,m_sample);
    expNewCurrentPose = transPoseFwd(expOldCurrentPose,Tshift);
    errorNew = mean(calcErrors(expNewCurrentPose,targetPose(ra,:)) ./ calcEyesDist(themeA,targetPose(ra,:)));
    if errorNew < errorNewTarget
        if testShift > inffer
            inffer = testShift;
        end;
        if upper == inf
            testShift = testShift + step;
        else
            testShift = (upper+inffer)/2;
        end;
    else
        if testShift < upper
            upper = testShift;
        end;
        if inffer == -inf
            testShift = testShift - step;
        else
            testShift = (upper+inffer)/2;
        end;
    end;
%     testShift
end;
fprintf('The best testShift is %f.\n',testShift);
Tshift = getTransShift(win_size,testShift,size(currentPose,1));
newCurrentPose = transPoseFwd(currentPose,Tshift);

end

