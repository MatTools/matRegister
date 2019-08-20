classdef NearestNeighborInterpolator2D < ImageInterpolator2D
% Nearest-neighbor interpolator of a 2D image.
%   output = NearestNeighborInterpolator2D(IMG)
%
%   Example
%   I = Image2D('rice.png');
%   interp = NearestNeighborInterpolator2D(I);
%   val1 = interp.evaluate([9.7 9.7]);
%   val2 = interp.evaluate([10.3 10.3]);
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-01-07,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Constructors
methods
    function obj = NearestNeighborInterpolator2D(varargin)
        % Constructs a new NearestNeighborInterpolator2D object.
        % interp = LinearInterpolator(IMG);
        % with IMG being a Image2D.
        
        if isa(varargin{1}, 'NearestNeighborInterpolator2D')
            % copy constructor
            var = varargin{1};
            image = var.Image;
        elseif isa(varargin{1}, 'Image')
            % initialisation constructor
            image = varargin{1};
            if ndims(image)~=2 %#ok<ISMAT>
                error('Image dimension should equal 2');
            end
            
        else
            error('Wrong parameter when constructing a nearest neighbor interpolator');
        end
        
        % call superclass constructor
        obj = obj@ImageInterpolator2D(image);
        
    end % constructor declaration
    
end % methods

end % classdef