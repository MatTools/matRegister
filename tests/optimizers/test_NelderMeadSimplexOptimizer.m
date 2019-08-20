function test_suite = test_NelderMeadSimplexOptimizer(varargin)
%TESTTRANSLATION  Test function for class Translation
%   output = testTranslation(input)
%
%   Example
%   testTranslation
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-06-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

test_suite = buildFunctionHandleTestSuite(localfunctions);

function testEmptyConstructor %#ok<*DEFNU>

optim = NelderMeadSimplexOptimizer(); %#ok<NASGU>


function test_Rosenbrock_0_0

optim = NelderMeadSimplexOptimizer(@rosenbrock, [0 0], [.1 .1]);
optim.DisplayMode = 'none';

[params, value] = startOptimization(optim);

assertElementsAlmostEqual(params, [1 1], 'absolute', 1e-5);
assertElementsAlmostEqual(value, 0, 'absolute', 1e-5);


function test_Rosenbrock_M1D2_1

optim = NelderMeadSimplexOptimizer(@rosenbrock, [-1.2 1], [.1 .1]);
optim.DisplayMode = 'none';
optim.NIters = 200;

[params, value] = startOptimization(optim);

assertElementsAlmostEqual(params, [1 1], 'absolute', 1e-5);
assertElementsAlmostEqual(value, 0, 'absolute', 1e-5);


