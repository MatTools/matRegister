classdef SumOfLocalVariances < ImageSetMetric
%SUMOFLOCALVARIANCES  One-line description here, please.
%
%   output = SumOfLocalVariances(input)
%
%   Example
%   SumOfLocalVariances
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-11-09,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%% Constructor
methods
    function obj = SumOfLocalVariances(varargin)
        % calls the parent constructor
        obj = obj@ImageSetMetric(varargin{:});
        
    end % constructor
    
end % methods

end % classdef
