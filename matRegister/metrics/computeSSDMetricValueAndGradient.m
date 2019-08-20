function [res, grad] = computeSSDMetricValueAndGradient(img1, img2, points, transfo, gx, gy)
%COMPUTESSDMETRIC  One-line description here, please.
%   output = computeSSDMetric(input)
%
%   Example
%   computeSSDMetric
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-06-10,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Process input arguments

if isa(img1, 'ImageFunction')
    % ok
elseif isa(img1, 'Image')
    % if points are no specified, compute their position from image
    if nargin==2
        x = getX(img1);
        y = getY(img1);
        points = [x(:) y(:)];
    end
    % convert image to interpolator
    disp('convert img1 to interpolator');
    img1 = LinearInterpolator2D(img1);
else
    error('First argument must be an image function');
end

if isa(img2, 'ImageFunction')
    % ok
elseif isa(img2, 'Image')
    % convert image to interpolator
    disp('convert img2 to interpolator');
    img2 = LinearInterpolator2D(img2);
else
    error('Second argument must be an image function');
end


%% Compute metric value 

% compute values in image 1
[values1, inside1] = evaluate(img1, points);

% compute values in image 2
[values2, inside2] = evaluate(img2, points);

% keep only valid values
insideBoth = inside1 & inside2;

% compute result
diff = values2(insideBoth) - values1(insideBoth);
res = sum(diff.^2);


%% Compute gradient direction

% convert to indices
inds = find(insideBoth);
nbInds = length(inds);

%nPoints = size(points, 1);
nParams = length(getParameters(transfo));
g = zeros(nbInds, nParams);

% convert from physical coordinates to index coordinates
% (assumes spacing is 1 and origin is 0)
% also converts from (x,y) to (i,j)
points2 = transformPoint(transfo, points);
index = round(points2(inds, [2 1]))+1;

for i = 1:length(inds)
    % calcule jacobien pour points valides (repere image fixe)
    jac = parametricJacobian(transfo, points(inds(i),:));
    
    % local gradient in moving image
    i1 = index(i, 1);
    i2 = index(i, 2);
    grad = [gx(i1,i2) gy(i1,i2)];
    
    % local contribution to metric gradient
    g(inds(i),:) = grad * jac;
end

% calcul du vecteur gradient pondere par difference locale
gd = g(inds,:) .* diff(:, ones(1, nParams));

% moyenne des vecteurs gradient valides
grad = mean(gd, 1);

