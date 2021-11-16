function [im] = immedian(imc)
%IMMEDIAN Creates a median image from cell array input.
%   Detailed explanation goes here

% Average
im = zeros(size(imc{1}));
for i=1:size(imc{1},1)
    for j=1:size(imc{1},2)
        m = zeros(1,size(imc,2));
        for k=1:size(imc,2)
            m(k) = imc{k}(i,j);
        end
        im(i,j) = median(m);
    end
end

end

