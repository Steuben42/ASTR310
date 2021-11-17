% Author: Owen McWilliams

arr=[]; 
plotarr=zeros(30,76);
img=rfits('NGC-672-g-master.fit');
rfixedimg=imrotate(img.data,-11);
g=0.3846;
Nr=15;

%Iterating through different target aperture sizes
for semiM = 75:150
    for semim = 1:30
        [flx,err,Nsky,Nstarnet,n]=aperE(rfixedimg,590,750,semim,semiM,75,160,100,200,g);
        SignalToNoise=SNR(Nstarnet,Nsky,Nr,n,g);
        A=[SignalToNoise,semiM,semim];
        arr = cat(1,arr,A);
        plotarr(semim,semiM-74)=SignalToNoise;
    end
end

[M,I] = max(arr);
%Maximum point: SNR, Semimajor axis, Semiminor axis
maxpoint = arr(I(1),:,:)

%Plotting the SNR versus semimajor and semiminor axes
[X,Y] = meshgrid(75:1:150,1:30);
surf(X,Y,plotarr);
hold on;
[~,i] = max(plotarr(:));
h = scatter3(X(i),Y(i),plotarr(i),'filled');
h.SizeData = 150;
hold off;
