classdef CenteredAffineTransformModel3D < AffineTransform & ParametricTransform & CenteredTransformAbstract
%Transformation model for a centered 3D affine transform followed by a translation
%
%   output = CenteredAffineTransformModel3D(input)
%
%   Example
%   CenteredAffineTransformModel3D
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-11-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Constructors
methods
    function this = CenteredAffineTransformModel3D(varargin)
        % Create a new centered affine transform model
        
        this.params = [1 0 0 0   0 1 0 0   0 0 1 0];
        
        if ~isempty(varargin)
            % extract first argument, and try to interpret
            var = varargin{1};
            if isa(var, 'CenteredAffineTransformModel3D')
                % copy constructor
                this.params = var.params;
                
            elseif isnumeric(var)
                len = length(var);
                if len==12
                    % all parameters are specified as a row vector
                    this.params = var;
                    
                elseif sum(size(var)~=[4 4])==0 || sum(size(var)~=[3 4])==0
                    % the parameter matrix is specified
                    var = var(1:3, :)';
                    this.params = var(:)';
                    
                elseif len==1
                    % give the possibility to call constructor with the
                    % dimension of image
                    % Initialize with identity transform
                    if var~=3
                        error('Defined only for 3 dimensions');
                    end
                    
                else
                    error('Please specify affine parameters');
                end
                
            else
                error('Unable to understand input arguments');
            end
        end
        
        % eventually parse additional arguments
        if nargin>2
            if strcmp(varargin{2}, 'center')
                % setup rotation center
                this.center = varargin{3};
            end
        end
        
        % setup parameter names
        this.paramNames = {...
            'm00', 'm01', 'm02', 'm03', ...
            'm10', 'm11', 'm12', 'm13', ...
            'm20', 'm21', 'm22', 'm23', ...
            };
    end     
    
end

%% Methods specific to this class
methods
    function initFromAffineTransform(this, transform)
        % Initialize parameters from an affine transform (class or matrix)
        %
        % Example
        % T = CenteredAffineTransformModel3D();
        % mat = createEulerAnglesRotation(.1, .2, .3);
        % T.initFromAffineTransform(mat);
        % T.getParameters()
        %
        
        % if the first argument is a Transform, extract its affine matrix
        if isa(transform, 'AffineTransform')
            transform = getAffineMatrix(transform);
        end
        
        % format matrix to have a row vector of 12 elements
        params0 = transform(1:3, :)';
        this.params = params0(:)';
    end

end


%% Implementation of methods inherited from AffineTransform
methods
    function dim = getDimension(this) %#ok<MANU>
        dim = 3;
    end

    function mat = getAffineMatrix(this)
        % Compute affine matrix associated with this transform
        
        % convert parameters to a 4-by-4 affine matrix
        mat = [reshape(this.params, [4 3])' ; 0 0 0 1];
        
        % setup transform such that center is invariant (up to the
        % translation part of the transform)
        trans = createTranslation3d(this.center);
        mat = trans * mat / trans;
    end
end


%% Implementation of methods inherited from ParametricTransform
methods
    function jacobian = getParametricJacobian(this, x, varargin)
        % Compute jacobian matrix, i.e. derivatives for each parameter
        
        % extract coordinate of input point(s)
        if isempty(varargin)
            y = x(:,2);
            z = x(:,3);
            x = x(:,1);
        else
            y = varargin{1};
            z = varargin{2};
        end
        
        % jacobians are computed with respect to transformation center
        x = x - this.center(1);
        y = y - this.center(2);
        z = z - this.center(3);
        
        % compute the Jacobian matrix using pre-computed elements
        jacobian = [...
            x y z 1     zeros(1,4)  zeros(1,4); ...
            zeros(1,4)  x y z 1     zeros(1,4); ...
            zeros(1,4)  zeros(1,4)  x y z 1   ];
        
    end
    
end % parametric transform methods 


%% Serialization methods
methods
    function str = toStruct(this)
        % Converts to a structure to facilitate serialization
        str = struct('type', 'CenteredAffineTransformModel3D', ...
            'center', this.center, ...
            'parameters', this.params);
        
    end
end
methods (Static)
    function transfo = fromStruct(str)
        % Creates a new instance from a structure
        params = str.parameters;
        transfo = CenteredAffineTransformModel3D(params, 'center', str.center);
    end
end


end
