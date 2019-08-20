function [fval, grad] = computeValueAndGradient(obj)
%COMPUTEVALUEANDGRADIENT Compute metric value and gradient using current state
%
%   [FVAL GRAD] = obj.computeValueAndGradient()
%
%   Example
%   computeValue
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2011-01-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.


% extract number of images (which is also the number of transforms)
nImages = length(obj.Images);

% number of parameter for each transform (assumes obj is the same)
nParams = length(obj.Transforms{1}.Params);
    
% initialize empty metric value
fval = 0;

% initialize empty gradient
grad = zeros(1, nImages*nParams);

% index of current params vactor within global param vector
ind = 1;

nPoints = size(obj.Points, 1);
allValues = zeros(nPoints, nImages);

% compute values in each image
for i = 1:nImages
    [values, inside] = evaluate(obj.TransformedImages{i}, obj.Points);
    allValues(:, i) = values;
    allValues(~inside, i) = 0;
end


% Main iteration over all images (image1)
% image1 is assumed to be the moving image
for i = 1:nImages
    % extract data specific to current image
    transfo = obj.Transforms{i};
    gradient = obj.TransformedGradients{i};
    
    % initialize zero gradient vector for current transform
    grad_i = zeros(1, nParams);
            
    % evaluate gradient, and re-compute points within image frame, as
    % gradient evaluator can have different behaviour at image borders.
    [gradVals, gradInside] = evaluate(gradient, obj.Points);
    
    % convert to indices
    inds    = find(gradInside);
    nbInds  = length(inds);
    g = zeros(nbInds, nParams);
    
    for k = 1:nbInds
        iInd = inds(k);
        
        % compute spatial jacobien for current point
        % (in physical coords)
        p0  = obj.Points(iInd, :);
        jac = parametricJacobian(transfo, p0);
        
        % local contribution to metric gradient
        g(iInd, :) = gradVals(iInd, :)*jac;
    end
    
    % second iteration over all other images
    % image2 is fixed image, and we look for average transform towards all
    % images
    for j = [1:i-1 i+1:nImages]
        % compute differences
        diff = allValues(:,i) - allValues(:,j);
        
        % Sum of squared differences normalized by number of test points
        fij = mean(diff.^2);

        % re-compute differences, by considering position that can be used
        % for computing gradient
        diff = allValues(gradInside,i) - allValues(gradInside,j);

        % compute gradient vectors weighted by local differences
        gd = g(inds,:).*diff(:, ones(1, nParams));

        % mean of valid gradient vectors
        gij = mean(gd, 1);

        % compute sum of values for all images
        fval    = fval + fij;
        grad_i  = grad_i + gij;
    end
    
    % update global parameter vector
    grad(ind:ind+nParams-1) = grad_i;
    ind = ind + nParams;
end

