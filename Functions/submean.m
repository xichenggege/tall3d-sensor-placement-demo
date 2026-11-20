function [fsub,fmean] = submean(f)
%submean: Subtract mean along samples (or features)
    % compute mean
    [numDimension,numFeature] = size(f);
    fmean=mean(f,2);
    % subtract mean
    fsub = f- repmat(fmean,[1,numFeature]);
end
