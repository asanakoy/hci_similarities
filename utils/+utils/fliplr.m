function [y] = fliplr(x)
%FLIPLR Flip 2D or 3D matrix in left/right direction.
%   FLIPLR(X) returns X with row preserved and columns flipped
%   in the left/right direction.
%   
%   X = 1 2 3     becomes  3 2 1
%       4 5 6              6 5 4

matlab_version = version('-release');
if str2num(matlab_version(1:4)) < 2014
    y = x(:, end:-1:1, :);
else
    y = fliplr(x);
end

end
