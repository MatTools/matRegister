classdef TranslationModel < ParametricTransform & AffineTransform
%Transformation model for a translation defined by ND parameters
%   output = TranslationModel(input)
%
%   Parameters of the transform:
%   inner optimisable parameters of the transform have following form:
%   params(1): tx       (in user spatial unit)
%   params(2): ty       (in user spatial unit)
%
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-02-17,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Constructors
methods
    function this = TranslationModel(varargin)
        % Create a new model for translation transform model
        
        % set parameters to default translation in 2D
        this.params = [0 0];
        
        if ~isempty(varargin)
            % extract first argument, and try to interpret
            var = varargin{1};
            if isa(var, 'TranslationModel')
                % copy constructor
                this.params = var.params;
                
            elseif isnumeric(var)
                if isscalar(var)
                    % interpret the scalar as the working dimension
                    this.params = zeros(1, var);
                elseif size(var, 1)==1
                    % interpret the vector as the translation parameter
                    this.params = var;
                else
                    error('Input argument must be a scalar or a row vector');
                end
                
            else
                error('Unable to understand input arguments');
            end
        end
        
        % update parameter names
        np = length(this.params);
        switch np
            case 2
                this.paramNames = {'X shift', 'Y shift'};
            case 3
                this.paramNames = {'X shift', 'Y shift', 'Z shift'};
            otherwise
                this.paramNames = cellstr(num2str((1:4)', 'Shift %d'));
        end
        
    end % constructor declaration
end

%% Standard methods
methods
    function mat = affineMatrix(this)
        % Returns the affine matrix that represents this transform
        nd = length(this.params);
        mat = eye(nd+1);
        mat(1:end-1, end) = this.params(:);
    end
    
    function jac = parametricJacobian(this, x, varargin) %#ok<INUSD>
        % Compute jacobian matrix, i.e. derivatives for each parameter
        nd = length(this.params);
        jac = eye(nd);
    end
    
end % methods


%% Serialization methods
methods
    function str = toStruct(this)
        % Converts to a structure to facilitate serialization
        str = struct('type', 'TranslationModel', ...
            'parameters', this.params);
    end
end
methods (Static)
    function motion = fromStruct(str)
        % Creates a new instance from a structure
        params = str.parameters;
        motion = TranslationModel(params);
    end
end


end % classdef