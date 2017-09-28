function [res, isInside] = computeValue(this)
%COMPUTEVALUE Compute metric value
%
% [VALUE INSIDE] = METRIC.computeValue();
% Computes and return the value. Returns also a flag that indicates
% which test points belong to both images.
%

% compute values in image 1
[values1, inside1] = this.img1.evaluate(this.points);

% compute values in image 2
[values2, inside2] = this.img2.evaluate(this.points);

% keep only valid values
isInside = inside1 & inside2;

% compute result
% diff = (values1(isInside) - values2(isInside)).^2;
% res = sum(diff);
diff = (values1 - values2).^2;
res = sum(diff);
