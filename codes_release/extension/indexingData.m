% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function varargout = indexingData(varargin)
%varargout = indexingData(ind,varargin)
%   every element in varargin will be extracted according to ind(index),
%   and the relative output will be sent to varargout.
%   PLEASE NOTE indexing only refer to the 1st dimension!

varargout = cell(1,nargin-1);
ind = varargin{1};
for i = 2:nargin
    k = varargin{i};
    if size(k,1) == 1
        k = k';
    end
    varargout{i-1} = k(ind,:);
end


end

