classdef ImageInterpolator2D < ImageInterpolator
% Abstract class that groups 2D image interpolators.
%
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-04-08,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%% Static methods
methods(Static)
    function interp = create(img, type)
        % Create an image interpolator based on its name and and image.
        %
        % Valid types are:
        %   - 'nearest'
        %   - 'linear'
        %
        % Example:
        % img = Image2D(uint8(ones(20, 20)*255));
        % interp = ImageInterpolator2D.create('linear', img);
        %
        img = Image2D(img);
        switch lower(type)
            case 'linear'
                interp = LinearInterpolator2D(img);
            case 'nearest'
                interp = NearestNeighborInterpolator2D(img);
            otherwise
                error('Unknown string for specifying interpolator');
        end
    end
end % static methods

%% Constructors
methods (Access = protected)
    function obj = ImageInterpolator2D(image)
        % Constructs a new ImageInterpolator2D object.
        % interp = ImageInterpolator2D(IMG);
        % with IMG being a Image2D.
        
        obj = obj@ImageInterpolator(image);
    end % constructor declaration    
end % methods

end  % classdef