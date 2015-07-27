% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function Pr = inferenceP(images,model,currentPose,level,probsInfo,tpt)

if ~exist('tpt','var')
    tpt = model{level}.tpt;
end;
n_pts = size(currentPose,2) / 2;
m = length(images);
mt = size(tpt,1);
assert(size(currentPose,1) == m);

% Validation over currentPose
feat_current = [];
featInfo.scale = probsInfo.pyramidScale;
for scale = 1:length(probsInfo.pyramidScale)
    feat_current = [feat_current ...
        extractSIFTs_toosimple(images,selectPoses(currentPose,probsInfo.semantic_id),scale,featInfo)];
end;
feat_current = feat_current / 255;

featLen = 128;
scoring_board = cell(length(probsInfo.semantic_id),1);
Pr = NaN * zeros(m,mt,length(probsInfo.semantic_id)+length(probsInfo.fix_id));
record_point = zeros(m,2*(length(probsInfo.semantic_id)+length(probsInfo.fix_id)));
record_mask = zeros(m,length(probsInfo.semantic_id)+length(probsInfo.fix_id));
for i = 1:length(probsInfo.semantic_id)
    ld_id = probsInfo.semantic_id(i);
    scoring_board{i} = zeros(m,mt);
    
    [~,~,confidence_current] = ...
        svmpredict(zeros(m,1),selectFeatures(feat_current,i + [0 1 2] * length(probsInfo.semantic_id),featLen),...
        model{level}.P.SVC{i},'-b 1 -q');
    confidence_current = confidence_current(:,1);
    
    ind = find(confidence_current >= probsInfo.acceptThre);
    % for only current
    dX = repmat(currentPose(ind,ld_id),[1,mt]) - repmat(tpt(:,ld_id)',[length(ind),1]);
    dY = repmat(currentPose(ind,ld_id+n_pts),[1,mt]) - repmat(tpt(:,ld_id+n_pts)',[length(ind),1]);
    scoring_board{i}(ind,:) = exp(-0.5 * probsInfo.gamma_current * (dX.^2 + dY.^2));
    record_point(ind,selectPosesIdx(2*(length(probsInfo.semantic_id)+length(probsInfo.fix_id)),i)) = ...
        selectPoses(currentPose(ind,:),ld_id);
    
    ind = find(confidence_current < probsInfo.acceptThre);
    % for considering resampling
    feat_search = [];
    for scale = 1:length(probsInfo.pyramidScale)
        feat_search = [feat_search ...
            extractSIFTs_toosimple(images(ind),repmat(model{level}.P.representativeLocation{i}(:)',...
            [length(ind) 1]),scale,featInfo)];
    end;
    feat_search = feat_search / 255;
    confidence_search = cell(1,size(model{level}.P.representativeLocation{i},1));
    parfor j = 1:size(model{level}.P.representativeLocation{i},1)
        [~,~,confidence_search{j}] = svmpredict(zeros(length(ind),1),...
            selectFeatures(feat_search,j + [0 1 2] * size(model{level}.P.representativeLocation{i},1),featLen),...
            model{level}.P.SVC{i},'-b 1 -q');
        confidence_search{j} = confidence_search{j}(:,1);
    end;
    confidence_search = cutThre(cell2mat(confidence_search));
    parfor j = 1:length(ind)
        confidence_search(j,:) = confidence_search(j,:) ./ sum(confidence_search(j,:));
    end; % Including NaN where no searching points hit more than half
    searched_point = confidence_search * model{level}.P.representativeLocation{i};
    dX = repmat(searched_point(:,1),[1,mt]) - repmat(tpt(:,ld_id)',[length(ind),1]);
    dY = repmat(searched_point(:,2),[1,mt]) - repmat(tpt(:,ld_id+n_pts)',[length(ind),1]);
    tmp = exp(-0.5 * probsInfo.gamma_current * (dX.^2 + dY.^2));
    tmp(isnan(tmp)) = 1;
    scoring_board{i}(ind,:) = tmp;
    record_point(ind,selectPosesIdx(2*(length(probsInfo.semantic_id)+length(probsInfo.fix_id)),i)) = ...
        searched_point;
    record_mask(ind,i) = 1;
    
    Pr(:,:,i) = scoring_board{i};
end;

for i = 1:length(probsInfo.fix_id)
    ld_id = probsInfo.fix_id(i);
    record_point(:,selectPosesIdx(2*(length(probsInfo.semantic_id)+length(probsInfo.fix_id)),i+length(probsInfo.semantic_id)))...
        = selectPoses(currentPose,ld_id);
    dX = repmat(currentPose(:,ld_id),[1,mt]) - repmat(tpt(:,ld_id)',[m,1]);
    dY = repmat(currentPose(:,ld_id+n_pts),[1,mt]) - repmat(tpt(:,ld_id+n_pts)',[m,1]);
    Pr(:,:,i+length(probsInfo.semantic_id)) = exp(-0.5 * probsInfo.gamma_current * (dX.^2 + dY.^2));
end;

record_Pr = Pr;
Pr = prod(Pr,3);

% Multiply the prior
prior = zeros(m,mt);
for i = 1:m
    d = repmat(currentPose(i,:),mt,1) - tpt;
    d_pca = usePCA(d,model{level}.P.pca_model);
    prior(i,:) = diag(d_pca * diag(1./model{level}.P.sigma) * d_pca')';
end;
prior = exp(-0.5 * probsInfo.gamma_prior(level) * prior);

Pr = Pr .* prior;

parfor i = 1:m
    Pr(i,:) = Pr(i,:) / sum(Pr(i,:));
end;

end


function y = cutThre(x,thre)

if ~exist('thre','var'), thre = 0.5; end;
y = x;
y(y < thre) = 0;

end

