% Codes for CVPR-15 work `Face Alignment by Coarse-to-Fine Shape Searching'
% Any question please contact Shizhan Zhu: zhshzhutah2@gmail.com
% Released on July 25, 2015

function T = getTransShift(win_size,shift,m)
%T = getTransShift(win_size,shift,m)
%   return Ta with size m*1

centric = floor([win_size / 2, win_size / 2]);
side = centric + [100,0];
assert(max(side)<win_size);

centric = repmat(centric,m,1);
side = repmat(side,m,1);

move1_theta = rand(m,1)*360;
move1_r = shift * randn(m,1);
move1_shift = [move1_r.*cosd(move1_theta) move1_r.*sind(move1_theta)];

m_centric = centric + move1_shift;
move2_tao = shift * randn(m,1);
m_side = side + move1_shift;
m_side(:,2) = m_side(:,2) + move2_tao;

if (m<100) || (matlabpool('size')==0)
    T = arrayfun(@(i)cp2tform(...
        [centric(i,:);side(i,:)],...
        [m_centric(i,:);m_side(i,:)],...
        'nonreflective similarity'),1:m);
    if m>=100
        warning('Please launch matlabpool to speed up your program!');
    end
else
    T = cell(m,1);
    parfor i = 1:m
        T{i} = cp2tform([centric(i,:);side(i,:)],[m_centric(i,:);m_side(i,:)],'nonreflective similarity');
    end
    T = cell2mat(T);
end

end

