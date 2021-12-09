

function [error]=SNRerror(Nstarnet,Nsky,Nr,n,g,Nskyerr,Nstarneterr)
%%SNRerror
	% Author: Owen McWilliams

part=g*Nstarnet+n*g*Nsky+n*Nr^2;
partialNstarnet=(g/sqrt(part))-((g^2)*Nstarnet/(2*(part)^3/2));
partialNsky=-n*(g^2)*Nstarnet/(2*(part)^3/2);
error=sqrt((partialNstarnet^2)*(Nstarneterr^2)+(partialNsky^2)*(Nskyerr^2));


