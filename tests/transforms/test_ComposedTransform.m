function test_suite = test_ComposedTransform(varargin)
%TEST_COMPOSEDTRANSFORM  One-line description here, please.
%   output = test_ComposedTransform(input)
%
%   Example
%   test_ComposedTransform
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-06-02,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

test_suite = buildFunctionHandleTestSuite(localfunctions);

function testTwoTranslations %#ok<*DEFNU>

t1 = Translation([1 2]);
t2 = Translation([3 4]);
tc = ComposedTransform(t1, t2);
pt2 = tc.transformPoint([3 3]);

assertEqual([7 9], pt2);