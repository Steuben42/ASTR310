function [imc] = loadfits(dir,disc)
%LOADFITS Creates cell of all fits files in dir.
%   Detailed explanation goes here

if(nargin==1), disc=''; end

[~,f] = fileattrib(strcat(dir,'*',disc,'.fit'));
imc = cell(1,size(f,2));
for i=1:size(f,2)
    imc{i} = rfits(f(i).Name,'nowcs');
end
end

