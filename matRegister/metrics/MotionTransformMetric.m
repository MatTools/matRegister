classdef MotionTransformMetric < TransformMetric & ParametricFunction
%MOTIONTRANSFORMMETRIC Simple metric on motion transform
%
%   output = MotionTransformMetric(input)
%
%   Example
%   MotionTransformMetric
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-10-27,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.


%% Constructor
methods
    function obj = MotionTransformMetric(varargin)
        % Initialize the metric with a transform.
        
        transfo = varargin{1};
        if ~isa(transfo, 'Transform')
            error('Input argument must be a transform');
        end
        
        obj = obj@TransformMetric(transfo);
    end
end % constructor


methods
    function setParameters(obj, params)
        setParameters(obj.Transform, params);
    end
end

methods
    function res = computeValue(obj)
        
        transfo = obj.Transform;
        if ~isa(transfo, 'AffineTransform')
            error('Sorry, requires a motion transform as input');
        end
        
        mat = affineMatrix(transfo);
        
        linearPart = mat(1:end-1, 1:end-1);
        
        if size(linearPart, 2)==2
            theta = atan2(mat(2,1), mat(1,1));
            
        elseif size(linearPart, 1)==3
            % compute rotation angle theta around the rotation axis 
            % (the rotation axis is not computed)
            % valid only for 3D rotation matrices...
            theta = acos((trace(linearPart) - 1) / 2);
            
        else
            error('dimension not managed');
        end
        
        rotLog = 2*theta^2;
        
        transPart = mat(1:end-1, end);
        
        res = sum(transPart.^2) + rotLog;
        
    end
    
end % methods implementing the 'ParametricFunction' interface

end % classdef
