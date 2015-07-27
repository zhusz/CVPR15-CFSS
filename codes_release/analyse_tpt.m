% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function [picked_id,assign] = analyse_tpt(location,representativeNum1,representativeNum2)

assert(size(location,2) == 2); % only for this site
assert(length(representativeNum1) == 1);
assert(length(representativeNum2) == 1);

% Step A: For all locations.
pA = analyse_tpt_base(location,representativeNum1);
capital_id = find(representativeNum1 == knnsearch(location(pA,:),location,'k',1));

% Step B: For capital locations in Step A.
pB = analyse_tpt_base(location(capital_id,:),representativeNum2+1);
pB = capital_id(pB);

% Merge and get assign
picked_id = [pA(1:end-1);pB];
assign = knnsearch(location(picked_id,:),location,'k',1);

% We want the original index!!! So commont the following line!!!
% assign = picked_id(assign);

end

function picked_id = analyse_tpt_base(location,representativeNum)

picked_id = NaN * zeros(representativeNum,1);
% Step A: Find the point closest to the mass center as the first point
cent = mean(location);
picked_id(1) = knnsearch(location,cent,'k',1);

% Step B: Each time find a point whose minimun distance to existing chosen
% points is maximized.
for i = 2:representativeNum
    [~,d] = knnsearch(location(picked_id(1:i-1),:),location,'k',1);
    [~,picked_id(i)] = max(d);
end;

picked_id = picked_id([2:end 1]); % From edger to center

% % Step C: For all m samples, find the closest chosen point to itself.
% assign = knnsearch(location(picked_id,:),location,'k',1);
% assign = picked_id(assign);

end

