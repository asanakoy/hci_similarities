function [leaf_order] = sim_matrix_clustering(sim_matrix)

max_dist = max(sim_matrix(:));
dist = max_dist - sim_matrix;
dist = dist - diag(diag(dist));

tree = linkage(sim_matrix, 'ward', 'euclidean');
leaf_order = optimalleaforder(tree, dist);
save('leaf_order.mat', '-v7.3', 'leaf_order');

end

