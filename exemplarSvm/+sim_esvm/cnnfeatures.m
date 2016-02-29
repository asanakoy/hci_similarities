function x = cnnfeatures(I, params)
%Return the CNN FC7 feature function, same as esvm_features

assert(iastruct(I));
assert(isfield(I, 'id'));
assert(isfield(I, 'flipval'));

error('Not implemented. You should load the features before running Exemplar SVM!');

end