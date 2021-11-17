function [value]=SNR(Nstarnet,Nsky,Nr,n,g)
%%SNR
%   Author: Owen McWilliams

bottom=sqrt(g*Nstarnet+n*g*Nsky+n*Nr^2);
value = Nstarnet/bottom;
