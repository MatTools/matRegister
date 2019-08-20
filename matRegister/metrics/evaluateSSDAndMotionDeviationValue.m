function value = evaluateSSDAndMotionDeviationValue(params, tim1, tim2, points, weights)
%EVALUATESUMOFSSDVALUE  One-line description here, please.
%
%   SSSD = evaluateSSDAndMotionDeviationValue(PARAMS, TIM1, TIM2, POINTS, WEIGHTS)
%   PARAMS: concatenated vector of parameters
%   TIM1:   transformed image 1
%   TIM2:   transformed image 2
%   POINTS: the set of test points used for evaluating SSD
%   WEIGHTS weights associated to (1) the metric and (2) the transform
%       regularisation
%
%   Example
%   evaluateSumOfSSDValue
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2010-09-28,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

%% Update transform parameters

% total length of parameter vector
n = length(params);

% update each transform
setParameters(tim1.Transform, params(1:n/2));
setParameters(tim2.Transform, params(n/2+1:end));


%% Compute metric value 

% compute values in image 1
[values1, inside1] = evaluate(tim1, points);

% compute values in image 2
[values2, inside2] = evaluate(tim2, points);

% keep only valid values
inds = inside1 & inside2;

% compute result
diff = (values2(inds)-values1(inds)).^2;
metricValue = sum(diff);


%% Compute transform regularisation

regul1 = computeMotionDeviation(tim1.Transform);
regul2 = computeMotionDeviation(tim2.Transform);

regulValue = regul1^2 + regul2^2;


%% compute weighjted sum of metric and regularisation

value = metricValue*weights(1) + regulValue*weights(2);

