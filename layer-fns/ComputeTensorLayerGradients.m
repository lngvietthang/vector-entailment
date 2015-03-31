% Want to distribute this code? Have other questions? -> sbowman@stanford.edu
function [ matricesGradients, matrixGradients, ...
           deltaLeft, deltaRight ] = ...
      ComputeTensorLayerGradients(l, r, matrices, matrix, delta, ...
                                  nonlinearityDeriv, tensorInnerOutput)
% Compute the gradients and deltas for an RNTN layer for a given batch of examples.

outDim = size(matrix, 1);
[ inDim, B ] = size(l);

% Compute the layer output if it isn't provided.
if nargin < 8
    tensorInnerOutput = ComputeInnerTensorLayer(l, r, matrices, matrix);
end

NLDeriv = nonlinearityDeriv(tensorInnerOutput);

delta = delta .* NLDeriv;

matricesGradients = zeros(inDim, inDim, outDim, B);
matrixGradients = zeros(outDim, 2 * inDim + 1, B);

% Calculate third order tensor gradients.
% Sadly, there doesn't seem to be an efficient vectorized option here.
inputProduct = zeros(inDim, inDim, B);
for b = 1:B
	inputProduct(:, :, b) = l(:, b) * r(:, b)';
end

% Old readable version
% for i = 1:outDim
% 	matricesGradients(:, :, i, :) = permute(bsxfun(@times, permute(delta(i, :), [1, 3, 2]), inputProduct), [1, 2, 4, 3]);
% end

matricesGradients = bsxfun(@times, permute(delta, [3, 4, 1, 2]), permute(inputProduct, [1, 2, 4, 3]));

for b = 1:B
	matrixGradients(:, :, b) = delta(:, b) * [1; l(:, b); r(:, b)]';
end

% Compute the deltas.
innerTensorLayerMatrixL = zeros(inDim, outDim, B);
innerTensorLayerMatrixR = zeros(inDim, outDim, B);
for i = 1:outDim  % TODO: Need reshape?
	innerTensorLayerMatrixL(:, i, :) = permute(l' * matrices(:, :, i), [2, 3, 1]);
    innerTensorLayerMatrixR(:, i, :) = permute(matrices(:, :, i) * r, [1, 3, 2]);
end


for i = 1:outDim
	innerTensorLayerMatrixL(:, i, 1) = l(:,1)' * matrices(:,:,i);
    innerTensorLayerMatrixR(:, i, 1) = matrices(:,:,i) * r(:,1);
end

leftBackpropMatrix = bsxfun(@plus, innerTensorLayerMatrixR, matrix(:, 2:inDim + 1)');
rightBackpropMatrix = bsxfun(@plus, innerTensorLayerMatrixL, matrix(:, inDim + 2:2 * inDim + 1)');    

deltaLeft = zeros(inDim, b);
deltaRight = zeros(inDim, b);
for b = 1:B
	deltaLeft(:, b) = (leftBackpropMatrix(:, :, b) * delta(:, b));
	deltaRight(:, b) = (rightBackpropMatrix(:, :, b) * delta(:, b));
end

end