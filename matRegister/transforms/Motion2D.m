classdef Motion2D <  AffineTransform
%MOTION2D Composition of a rotation (around origin) and a translation
%
%   T = Motion2D(THETA, U)
%   THETA is the angle of rotation around origin, given in DEGREES
%   U is the 1*2 row vector containing translation components applied after
%   rotation.
%   
%   Example
%   T = Motion2D(10, [3 4]);
%
%   See also
%   Translation
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-02-17,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

properties
    % angle of rotation around origin, in degrees
    theta = 0;
        
    % translation after rotation
    translation = zeros(1, 2);
end

%% Constructors
methods
    function this = Motion2D(varargin)
        % Create a new model for translation transform model
        if isempty(varargin)
            % parameters already set to default values
            return;
        end
        
        var = varargin{1};
        if isa(var, 'Motion2D')
            % copy constructor
            this.theta = var.theta;
            this.translation = var.translation;
        else
            % extract first argument, and try to interpret
            if isnumeric(var) && length(varargin)==2
                this.theta = var;
                this.translation = varargin{2};
            else
                error('Unable to understand input arguments');
            end
        end
        
    end % constructor declaration
end

%% Standard methods
methods
    function dim = getDimension(this) %#ok<MANU>
        dim = 2;
    end

    
    function mat = getAffineMatrix(this)
        % Returns the 3*3 affine matrix that represents this transform
        
        % pre-computation
        thetaInRadians = deg2rad(this.theta);
        cot = cos(thetaInRadians);
        sit = sin(thetaInRadians);

        mat = [ ...
            cot -sit this.translation(1); ...
            sit  cot this.translation(2); ...
            0 0 1];
    end
    
end % methods

%% Serialization methods
methods
    function str = toStruct(this)
        % Converts to a structure to facilitate serialization
        str = struct('type', 'Motion2D', ...
            'translation', this.translation, ...
            'rotationAngle', this.theta);
    end
end
methods (Static)
    function motion = fromStruct(str)
        % Creates a new instance from a structure
        trans = str.translation;
        theta = str.rotationAngle;
        motion = Motion2D(theta, trans);
    end
end


end % classdef