% Author: Owen McWilliams

[flx,err,Nsky,Nstarnet,n,Nskyerr,Nstarneterr]=aperE(rfixedimg,585,750,semim,semiM,140,200,180,250,g);
SignaltoNoiseError=SNRerror(Nstarnet,Nsky,Nr,n,g,Nskyerr,Nstarneterr);