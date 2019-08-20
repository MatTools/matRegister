classdef MultiMetricManager < ParametricFunction
%MULTIMETRICMANAGER  One-line description here, please.
%
%   output = MultiMetricManager(input)
%
%   Example
%   MultiMetricManager
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-10-27,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%% Properties
properties
    MetricSet;
end
 
%% Constructor
methods
    function obj = MultiMetricManager(varargin)
        
        % check that each input is itself a ParametricFunction
        var = varargin{1};
        if ~iscell(var)
            error('Input must be a cell array of Parametric functions');
        end
        for i = 1:length(var)
            metric = var{i};
            if ~isa(metric, 'ParametricFunction')
                error('MultiMetricManager:WrongClass', ...
                    'The element number %d is not a ParametricFunction, but a %s', ...
                    i, class(metric));
            end
        end
        
        % stores the set of metrics
        obj.MetricSet = var;
        
    end % constructor
 
end % construction function
 
%% General methods
methods
    
    function setParameters(obj, params)
        % Setup the parameters of the object
        
        % number of parameters
        nFP = length(params);
        
        % number of functions
        nF = length(obj.MetricSet);
        
        % number of parameter by function
        nP = nFP/nF;
        
        % update each child function
        for i=1:nF
            par = params((i-1)*nP+1:i*nP);
            metric = obj.MetricSet{i};
            setParameters(metric, par);
        end
    end
    
    function res = evaluate(obj, params)
        % Update parameters of each child and compute sum of values
        
        % setup paramters
        setParameters(obj, params);
        
        % compute the value
        res = computeValue(obj);
    end
        
    function res = computeValue(obj)
        % Compute the sum of the value computed by each child function
        
        % intialize
        res = 0;
        
        % compute the sum
        for i = 1:length(obj.MetricSet)
            metric = obj.MetricSet{i};
            res = res + computeValue(metric);
        end
    end
end % general methods
 
end % classdef

