classdef MatlabSimplexOptimizer < Optimizer
% Encapsulation of Matlab function fminsearch.
%
%   output = MatlabSimplexOptimizer(input)
%
%   Example
%   % Run the simplex otpimizer on the Rosenbrock function
%     optimizer = MatlabSimplexOptimizer;
%     optimizer.setCostFunction(@rosenbrock);
%     optimizer.setParameters([0 0]);
%     [xOpt value] = optimizer.startOptimization();
%     xOpt
%       xOpt =
%           0.9993    0.9984
%     value
%       value =
%           5.5924e-006
%
%
%   Requires
%   Optimization Toolbox
%
%   See also
%     NelderMeadSimplexOptimizer
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-10-06,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%% Properties
properties
    NIters = 200;
end

%% Constructor
methods
    function obj = MatlabSimplexOptimizer(varargin)
        obj = obj@Optimizer();
    end
end

methods
    function [params, value] = startOptimization(obj)
        % Run the optimizer, and return optimized parameters.
        %
        %   PARAMS = startOptimization(OPTIM)
        %   PARAMS = OPTIM.startOptimization()
        %
        %   [PARAMS, VALUE] = startOptimization(OPTIM)
        %   [PARAMS, VALUE] = OPTIM.startOptimization()
        %
        %   Example
        %   startOptimization
        %
        %   See also
        %
        
        % ------
        % Author: David Legland
        % e-mail: david.legland@inra.fr
        % Created: 2010-10-06,    using Matlab 7.9.0.529 (R2009b)
        % Copyright 2010 INRA - Cepia Software Platform.
        
        
        % Notify beginning of optimization
        notify(obj, 'OptimizationStarted');
        
        % some options
        options = optimset(...
            'TolX', 1e-2, ...
            'MaxIter', obj.NIters, ...
            'Display', obj.DisplayMode);
        
        % Setup the eventual output function
        if ~isempty(obj.OutputFunction)
            options.OutputFcn = obj.OutputFunction;
        end
        options.OutputFcn = @outputFunctionHandler;
        
        % resume parameter array
        if ~isempty(obj.InitialParameters)
            obj.Params = obj.InitialParameters;
        end
        
        % run the simplex optimizer, by calling Matlab optimisation function
        [params, value] = fminsearch(obj.CostFunction, obj.Params, options);
        
        % update inner data
        obj.Params = params;
        obj.Value = value;
        
        % Notify the end of optimization
        notify(obj, 'OptimizationTerminated');
        
        
        function stop = outputFunctionHandler(x, optimValues, state, varargin)
            
            stop = false;
            
            % update current values
            obj.Params = x;
            obj.Value = optimValues.fval;
            
            % If an input function was specified, propagates processing
            if ~isempty(obj.OutputFunction)
                stop = obj.OutputFunction(x, optimValues, state);
            end
            
            % Notify iteration
            if strcmp(state, 'iter')
                obj.CostFunction(x);
                notify(obj, 'OptimizationIterated');
            end
        end
        
    end
end
end