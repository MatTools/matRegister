classdef ImageInterpolator < ImageFunction
%IMAGEINTERPOLATOR Abstract class that groups image interpolators.
%
%   This class is both an abstract class for deriving more specialized
%   interpolators, and a static factory for building the most appropriate
%   interpolator for a given image.
%
%   Example
%     img = Image.read('cameraman.tif');
%     interp = ImageInterpolator.create(img, 'linear');
%     interp.setFillValue(127);
%     interp.evaluate(-1, -1)
%     ans =
%         127
%
%   See Also
%   NearestNeighborInterpolator, LinearInterpolator2D, LinearInterpolator3D
%   

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-04-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

properties
    % inner image that will be interpolated
    Image;
    
    % The value used when intepolation is made outside the image extent.
    % Initialized to 0, but should be set to a more appropriate value in
    % the case of vector images.
    FillValue = 0;
end

%% Static methods
methods(Static)
    function interp = create(img, type, varargin)
        % Create an image interpolator based on its name and and image.
        %
        % INTERP = ImageInterpolator.create(IMG, TYPE);
        % IMG is an image object, TYPE is a string specifying interpolation
        % type. Valid types are:
        %   - 'nearest'
        %   - 'linear'
        %
        % Example
        % img = Image2D(uint8(ones(20, 20)*255));
        % interp = ImageInterpolator.create(img, 'linear');
        %
        
        nd = ndims(img);
        
        if strcmpi(type, 'linear')
            % depending on the dimension, create a specific interpolator
            if nd == 2
                interp = LinearInterpolator2D(img);
            elseif nd == 3
                interp = LinearInterpolator3D(img);
            else
                error(['Could not create linear interpolator for image of dimension ' ...
                    num2str(nd)]);
            end
            
        elseif strcmpi(type, 'nearest')
            % create a dimension-generic Nearest-Neighbor interpolator
            interp = NearestNeighborInterpolator(img);
                
        else
            error('Unknown string for specifying interpolator type');
        end
        
        % parse optional arguments
        while length(varargin) > 1
            paramName = varargin{1};
            if ~ischar(paramName)
                error('Argument must be a character string');
            end
            switch lower(paramName)
                case 'fillvalue'
                    interp.FillValue = varargin{2};
                otherwise
                    error(['Unknown parameter: ' paramName]);
            end
            varargin(1:2) = [];
        end
    end
end % static methods

methods  (Access = protected)
    function obj = ImageInterpolator(image)
        % Construct a new ImageInterpolator object.
        
        obj.Image = image;
    end % constructor declaration
end

%% Abstract methods
methods (Abstract)
    evaluate(varargin)
    
    evaluateAtIndex(varargin)
    
end % abstract methods

%% General methods
methods
    function img = getImage(obj)
        % Return the inner image of the interpolator
        img = obj.Image;
    end
    
    function val = getFillValue(obj)
        % Return the value returnd when points are outside image bounds
        val = obj.FillValue;
    end
    
    function setFillValue(obj, val)
        % Change the value returnd when points are outside image bounds
        obj.FillValue = val;
    end
    

    function d = getDimension(obj)
        %GETDIMENSION  Dimension of the interpolated image
        %
        %   D = img.getDimension();
        %   Returns the dimension of the inner image
        d = ndims(obj.Image);
    end
    
    function dim = getElementSize(obj, varargin)
        % GETELEMENTSIZE Return the size of the interpolated elements
        % 
        %   Result is [1 1] for scalar images, [Nc 1] for color or vector
        %   images, [1 Nf] for frame images (movies).
        %
        
        if isempty(varargin)
            dim = obj.Image.DataSize(4:5);
            
        else
            d = varargin{1};
            if d > 2
                error('Second argument must be 1 or 2');
            end
            dim = obj.Image.DataSize(d + 3);
        end
    end
end

end  % classdef
