function [ hyperParams, options, wordMap, relationMap ] = SST(expName, dataflag, embDim, dim, topDepth, penult, lambda, composition, bottomDropout, topDropout, collo, dp, mult)
% Configuration for experiments involving the SemEval SICK challenge and ImageFlickr 30k. 

[hyperParams, options] = Defaults();

% Generate an experiment name that includes all of the hyperparameter values that
% are being tuned.
hyperParams.name = [expName, '-', dataflag, '-l', num2str(lambda), '-dim', num2str(dim),...
    '-ed', num2str(embDim), '-td', num2str(topDepth),...
    '-do', num2str(bottomDropout), '-', num2str(topDropout), '-co', num2str(collo),...
    '-comp', num2str(composition), ...
    '-mdn', num2str(dp), '-dp', num2str(mult)];

hyperParams.sentimentMode = 1;

hyperParams.parensInSequences = 0;

hyperParams.dataPortion = mult;

hyperParams.dim = dim;
hyperParams.embeddingDim = embDim;

if collo == 1
    hyperParams.vocabPath = ['/scr/nlp/data/glove_vecs/glove.6B.' num2str(embDim) 'd.txt'];
elseif collo == 2
    hyperParams.vocabPath = '/u/nlp/data/senna_embeddings/combined.txt';  
    assert(embDim == 50, 'The Collobert and Weston-sourced vectors only come in dim 50.'); 
elseif collo == 3
    hyperParams.vocabPath = ['/scr/nlp/data/glove_vecs/glove.840B.' num2str(embDim) 'd.txt'];
end

% The number of embedding transform layers. topDepth > 0 means NN layers will be
% added above the embedding matrix. This is likely to only be useful when
% learnWords is false, and so the embeddings do not exist in the same space
% the rest of the constituents do.
hyperParams.embeddingTransformDepth = 0;

% The number of comparison layers. topDepth > 1 means NN layers will be
% added between the RNTN composition layer and the softmax layer.
hyperParams.topDepth = topDepth;

% If set, store embedding matrix gradients as spare matrices, and only apply regularization
% to the parameters that are in use at each step.
hyperParams.fastEmbed = true;

% The dimensionality of the classifier extra layers.
hyperParams.penultDim = dim;

% Regularization coefficient.
hyperParams.lambda = lambda; % 0.002 works?;

% How many examples to run before taking a parameter update step on the accumulated gradients.
options.miniBatchSize = 32;

% TODO:
% hyperParams.maxDeltaNorm = dp;
% hyperParams.connectionCostScale = mult;

% Apply dropout to the top feature vector of each tree, preserving activations
% with this probability. If this is set to 1, dropout is effectively not used.
hyperParams.bottomDropout = bottomDropout;
hyperParams.topDropout = topDropout;

if composition == -1
  hyperParams.useThirdOrderComposition = 0;
  hyperParams.useThirdOrderMerge = 0;
  hyperParams.useSumming = 1;
elseif composition < 2
  hyperParams.useThirdOrderComposition = composition;
  hyperParams.useThirdOrderMerge = composition;
elseif composition == 2
  hyperParams.lstm = 1;
  hyperParams.useTrees = 0;
  hyperParams.eyeScale = 0;
  hyperParams.useThirdOrderComposition = 0;
  hyperParams.useThirdOrderMerge = 1;
  hyperParams.parensInSequences = 0;
elseif composition == 3
  hyperParams.lstm = 0;
  hyperParams.useTrees = 0;
  hyperParams.useThirdOrderComposition = 0;
  hyperParams.useThirdOrderMerge = 1;
  hyperParams.parensInSequences = 0;
elseif composition == 4
  hyperParams.usePyramids = 1;
  hyperParams.lstm = 0;
  hyperParams.useTrees = 0;
  hyperParams.useThirdOrderComposition = 0;
  hyperParams.useThirdOrderMerge = 0;
  hyperParams.parensInSequences = 0;
elseif composition == 5
  hyperParams.usePyramids = 1;
  hyperParams.lstm = 0;
  hyperParams.useTrees = 0;
  hyperParams.useThirdOrderComposition = 0;
  hyperParams.useThirdOrderMerge = 1;
  hyperParams.parensInSequences = 0;
end

hyperParams.loadWords = true;
hyperParams.trainWords = true;

hyperParams.fragmentData = false;

% TODO: Wordlist
wordMap = InitializeMaps('./sst-data/sst-words.txt');
hyperParams.vocabName = 'sst'; 

hyperParams.numRelations = [5];

hyperParams.relations = {{'0', '1', '2', '3', '4'}};
relationMap = cell(1, 1);
relationMap{1} = containers.Map(hyperParams.relations{1}, 1:length(hyperParams.relations{1}));

hyperParams.trainFilenames = {'./sst-data/train.txt'};    
hyperParams.splitFilenames = {};    
hyperParams.testFilenames = {'./sst-data/test.txt'};

end