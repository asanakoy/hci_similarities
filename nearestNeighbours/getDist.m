function [ dist, distFlipped ] = getDist( x, y, hogSize )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

delta = x - y;
dist = sum(delta .* delta);

x_flipped = reshape(fliplr(reshape(x, hogSize)), prod(hogSize), 1);
deltaFlipped = x_flipped - y;
distFlipped = sum(deltaFlipped .* deltaFlipped);

end

