%% Header
% Author: Steven Shockley
% 25 Oct 2021; Last Revision: 15 Nov 2021

%% Globals
clear
addpath('./functions/');

% User inputs
sets = input('Number of sets: ');
filters = {input('Filter 1: ','s'), input('Filter 2: ','s')};

% File loading
fits = cell(6,sets);
for i=1:sets
    fits{1,i} = loadfits(strcat('./data/set_0',string(i),'/calibration/'),'-bi');
    fits{2,i} = loadfits(strcat('./data/set_0',string(i),'/calibration/'),'-d');
    fits{3,i} = loadfits(strcat('./data/set_0',string(i),'/calibration/'),strcat('-',filters{1}));
    fits{4,i} = loadfits(strcat('./data/set_0',string(i),'/calibration/'),strcat('-',filters{2}));
    fits{5,i} = loadfits(strcat('./data/set_0',string(i),'/science/'),strcat('-',filters{1}));
    fits{6,i} = loadfits(strcat('./data/set_0',string(i),'/science/'),strcat('-',filters{2}));
end

%% Script

% Bias median
for i=1:sets
    imc = cell(1,size(fits{1,i},2));
    for k=1:size(fits{1,i},2)
        imc{k} = fits{1,i}{k}.data;
    end
    fits{1,i} = immedian(imc);
    wfits(fits{1,i},strcat('./data/set_0',string(i),'/masters/calibration-',string(i),'-bi-master.fit'));
end

% Dark biasing, median
darkexp = cell(1,sets);
for i=1:sets
    imc = cell(1,size(fits{2,i},2));
    darkexp{i} = fits{2,i}{1}.exposure;
    for k=1:size(fits{2,i},2)
        imc{k} = fits{2,i}{k}.data - fits{1,i};
    end
    fits{2,i} = immedian(imc);
    wfits(fits{2,i},strcat('./data/set_0',string(i),'/masters/calibration-',string(i),'-d-master.fit'));
end

% Flats dark (adjusting for exposure) and biasing, median, normalization
flatexp = cell(2,sets);
for i=1:sets
    imc1 = cell(1,size(fits{3,i},2));
    imc2 = cell(1,size(fits{4,i},2));
    flatexp{1,i} = fits{3,i}{1}.exposure;
    flatexp{2,i} = fits{4,i}{1}.exposure;
    for k=1:size(fits{3,i},2)
        imc1{k} = fits{3,i}{k}.data - fits{1,i} - ((flatexp{1,i} / darkexp{i}) * fits{2,i});
        imc2{k} = fits{4,i}{k}.data - fits{1,i} - ((flatexp{2,i} / darkexp{i}) * fits{2,i});
    end
    fits{3,i} = immedian(imc1);
    fits{3,i} = fits{3,i} / mean(fits{3,i},'all');
    wfits(fits{3,i},strcat('./data/set_0',string(i),'/masters/flats-',string(i),'-',filters{1},'.fit'));
    fits{4,i} = immedian(imc2);
    fits{4,i} = fits{4,i} / mean(fits{4,i},'all');
    wfits(fits{4,i},strcat('./data/set_0',string(i),'/masters/flats-',string(i),'-',filters{2},'.fit'));
end

% Science image dark (adjusting for exposure) and biasing, dividing by flat norm
sciexp = cell(2,sets);
for i=1:sets
    imc1 = cell(1,size(fits{5,i},2));
    imc2 = cell(1,size(fits{6,i},2));
    sciexp{1,i} = fits{5,i}{1}.exposure;
    sciexp{2,i} = fits{6,i}{1}.exposure;
    for k=1:size(fits{5,i},2)
        imc1{k} = (fits{5,i}{k}.data - fits{1,i} - ((sciexp{1,i} / darkexp{i}) * fits{2,i})) ./ fits{3,i};
        wfits(imc1{k},strcat('./data/set_0',string(i),'/corrected/NGC-672-',string(i),'-',string(k),'-',filters{1},'.fit'));
        imc2{k} = (fits{6,i}{k}.data - fits{1,i} - ((sciexp{2,i} / darkexp{i}) * fits{2,i})) ./ fits{4,i};
        wfits(imc2{k},strcat('./data/set_0',string(i),'/corrected/NGC-672-',string(i),'-',string(k),'-',filters{2},'.fit'));
    end
    fits{5,i} = imc1;
    fits{6,i} = imc2;
end

sci = cell(1,2);
sci{1} = cat(2,fits{5,:});
sci{2} = cat(2,fits{6,:});

% Removing cosmic rays with local Poisson noise
for z=1:2
    [J,K] = size(sci{1}{1});
    loc = zeros(1,4);
    for i=1:size(sci{1},2)
        for j=1:J
            for k=1:K
                if(j==J), loc(1)=sci{z}{i}(j-1,k); else, loc(1)=sci{z}{i}(j+1,k); end
                if(k==K), loc(2)=sci{z}{i}(j,k-1); else, loc(2)=sci{z}{i}(j,k+1); end
                if(j==1), loc(3)=sci{z}{i}(j+1,k); else, loc(3)=sci{z}{i}(j-1,k); end
                if(k==1), loc(4)=sci{z}{i}(j,k+1); else, loc(4)=sci{z}{i}(j,k-1); end

                avg = mean(loc); % Median instead?
                N = sqrt(avg);

                if(abs(sci{z}{i}(j,k) - avg) > N), sci{z}{i}(j,k) = avg; end
            end
        end
        wfits(sci{z}{i},strcat('./data/corrected_cosmic_ray/NGC-672-',string(i),'-',filters{z},'.fit'));
    end
end

% Image shifting
for z=1:2
    X = zeros(1,size(sci{z},2));
    Y = zeros(1,size(sci{z},2));
    for i=1:size(sci{z},2)
        figure();
        imagesc(sci{z}{i}); colorbar();
        ax = gca; gca.ColorScale = 'log'; colormap(prism);
        [X(i),Y(i),key] = ginput(1);
        if(key=='x') 
            sci{z}{i} = zeros(size(sci{z}{i})); 
            X(i) = X(1);
            Y(i) = Y(1);
        end
    end

    for i=1:size(sci{z},2)
        sci{z}{i} = imshift(sci{z}{i},Y(1) - Y(i),X(1) - X(i));
    end

    imf = zeros(size(sci{z}{1}));

    for j=1:size(imf,1)
        for k=1:size(imf,2)
            m = zeros(1,size(sci{z},2));
            for i=1:size(sci{z},2)
                m(i) = sci{z}{i}(j,k);
            end
            imf(j,k) = sum(m);
        end
    end

    wfits(imf,strcat('./data/NGC-672-',filters{z},'-master.fit'));
end