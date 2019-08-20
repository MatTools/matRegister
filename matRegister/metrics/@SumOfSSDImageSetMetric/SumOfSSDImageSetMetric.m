classdef SumOfSSDImageSetMetric < ImageSetMetric
%SUMOFSSDIMAGESETMETRIC  One-line description here, please.
%
%   output = SumOfSSDImageSetMetric(input)
%
%   Example
%   SumOfSSDImageSetMetric
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-09-29,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Constructor
methods
    function obj = SumOfSSDImageSetMetric(varargin)
        % calls the parent constructor
        obj = obj@ImageSetMetric(varargin{:});
        
    end % constructor
    
end % methods

end % classdef
