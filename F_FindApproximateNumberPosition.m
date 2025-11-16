function [ I ] = F_FindApproximateNumberPosition( DataMatrix , number )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 [~, I]=min(abs( DataMatrix(:) - number ) ) ; 
end

