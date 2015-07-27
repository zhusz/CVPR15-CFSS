% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function [serials,prob] = randSampleNoReplace(n,k,prob)

% serials: 1 * k output indexing serials
% n: scalar indicating total number of candidates (max of indexing)
% k: number to be sampled
% prob: n * 1 probability, no negative, infierier or NaN val allowed.
% it would be updated with some probs set to be 0.

% indexing begins from 1 like most of Matlab functions do.

assert(length(prob) == n);
assert(all(~isnan(prob)));
assert(all(~isinf(prob)));
assert(all(prob >= 0));
n_real = length(find(prob > 0));
assert(n_real >= k);

serials = zeros(1,k);
gen = rand(k,1);
for i = 1:k
    
    s = find(cumsum(prob / sum(prob)) > gen(i), 1, 'first');
    assert(length(s) == 1);
%     serials(i) = randsample(n,1,true,prob);

    prob(s) = 0;
    serials(i) = s;
end;

end
