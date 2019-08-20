function [val, isInside] = evaluate(obj, varargin)
% Evaluate intensity of image at a given physical position.
%
% VAL = INTERP.evaluate(POS);
% where POS is a Nx2 array containing alues of x- and y-coordinates
% of positions to evaluate image, return an array with as many
% values as POS.
%
% VAL = INTERP.evaluate(X, Y)
% X and Y should be the same size. The result VAL has the same size
% as X and Y.
%
% [VAL INSIDE] = INTERP.evaluate(...)
% Also return a boolean flag the same size as VAL indicating
% whether or not the given position as located inside the
% evaluation frame.
%


% eventually convert inputs to a single nPoints-by-ndims array
[point, dim] = ImageFunction.mergeCoordinates(varargin{:});

% Evaluates image value for a given position
coord = pointToContinuousIndex(obj.Image, point);

% size of elements: number of channels by number of frames
elSize = elementSize(obj.Image);

% number of dimension of input coordinates
dim0 = dim;
if dim0(2) == 1
    dim0 = dim0(1);
end
nd = length(dim);

% Create default result image
dim2 = [dim0 elSize];
val = ones(dim2) * obj.FillValue;

% extract x and y
xt = round(coord(:, 1));
yt = round(coord(:, 2));

% select points located inside interpolation area
% (smaller than image physical size)
siz = size(obj.Image);
isInside = ~(xt < 1 | yt < 1 | xt > siz(1) | yt > siz(2));
xt = xt(isInside);
yt = yt(isInside);

% values of the nearest neighbor
if prod(elSize) == 1
    % case of scalar image, no movie
    val(isInside) = double(getPixels(obj.Image, xt, yt));
    
else
    % compute interpolated values
    res = double(getPixels(obj.Image, xt, yt));
    
    % compute spatial index of each inerpolated point
    subs = cell(1, nd);
    [subs{:}] = ind2sub(dim, find(isInside));
    
    % pre-compute some indices of interpolated values
    subs2 = cell(1, length(dim2));
    subs2{nd+1} = 1:elSize(1);
    subs2{nd+2} = 1:elSize(2);
    
    % iterate on interpolated values
    for i = 1:length(subs{1})
        % compute indices of interpolated value
        for d = 1:nd
            subInds = subs{d};
            subs2{d} = subInds(i);
        end
        
        val(subs2{:}) = res(i, :);
    end
end

isInside = reshape(isInside, dim);
