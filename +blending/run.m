function run(category_name, i)
blending.computeAverageNN('hoglda',category_name,i)
blending.computeAverageNN('imagenet',category_name,i)
blending.computeAverageNN('ours',category_name,i)

end