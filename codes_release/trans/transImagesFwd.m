% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function newImages = transImagesFwd(oldImages,T,rows,cols)
%newImages = transImagesFwd(oldImages)
%   images are all cell array.

m = length(oldImages);
if m~=length(T),error('size(oldImages,1) must equal to length(T)!');end;

if (m<100) || (matlabpool('size')==0)
    newImages = arrayfun(@(i)imtransform(oldImages{i},T(i),'XData',...
        [1 cols],'YData',[1 rows]),1:m,'UniformOutput',false);
    if (m>=100)
        warning('Please launch matlabpool to speed up your program!');
    end
else
    newImages = cell(m,1);
    parfor i = 1:m
        newImages{i} = imtransform(oldImages{i},T(i),'XData',...
            [1 cols],'YData',[1 rows]);
    end
end
for i = 1:m, if size(newImages{i},1)~=rows || size(newImages{i},2)~=cols, newImages{i} = imresize(newImages{i},[rows,cols]);end;end;

end

