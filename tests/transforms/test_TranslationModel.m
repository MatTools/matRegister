function test_suite = test_TranslationModel(varargin)
%test_TranslationModel  Test function for class Translation
%   output = test_TranslationModel(input)
%
%   Example
%   testTranslationModel
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-06-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

test_suite = buildFunctionHandleTestSuite(localfunctions);

function testEmptyConstructor %#ok<*DEFNU>

% test empty constructor
trans = TranslationModel();
assertTrue(trans.isvalid());

function testConstructor2D

% test constructor with separate arguments
trans = TranslationModel(2, 3);
assertTrue(trans.isvalid());

% test constructor with bundled arguments
trans = TranslationModel([2, 3]);
assertTrue(trans.isvalid());

% test copy constructor
trans2 = TranslationModel(trans);
assertTrue(trans2.isvalid());

function testConstructor3D

% test constructor with separate arguments
trans = TranslationModel(2, 3, 4);
assertTrue(trans.isvalid());

% test constructor with bundled arguments
trans = TranslationModel([2, 3, 4]);
assertTrue(trans.isvalid());

% test copy constructor
trans2 = TranslationModel(trans);
assertTrue(trans2.isvalid());


function testGetAffineMatrix

refMat = [1 0 2;0 1 3;0 0 1];
trans = TranslationModel([2 3]);
mat = trans.getAffineMatrix();
assertElementsAlmostEqual(refMat, mat);


function testIsa

trans = TranslationModel([2 3]);
assertTrue(isa(trans, 'Transform'));
assertTrue(isa(trans, 'AffineTransform'));

function testSetParameters

refMat = [1 0 2;0 1 3;0 0 1];
trans = TranslationModel();
trans.setParameters([2 3]);
mat = trans.getAffineMatrix();
assertElementsAlmostEqual(refMat, mat);


function test_ToStruct
% Test call of function without argument

transfo = TranslationModel([30 20 10]);
str = toStruct(transfo);
transfo2 = TranslationModel.fromStruct(str);

assertTrue(isa(transfo2, 'TranslationModel'));
assertElementsAlmostEqual(transfo2.params, transfo.params, 'absolute', .01);


function test_readWrite
% Test call of function without argument

% prepare
fileName = 'TranslationModel.transfo';
if exist(fileName, 'file')
    delete(fileName);
end

% arrange
transfo = TranslationModel([30 20 10]);

% act
write(transfo, fileName);
transfo2 = Transform.read(fileName);

% assert
assertTrue(isa(transfo2, 'TranslationModel'));
assertElementsAlmostEqual(transfo2.params, transfo.params, 'absolute', .01);

% clean up
delete(fileName);

