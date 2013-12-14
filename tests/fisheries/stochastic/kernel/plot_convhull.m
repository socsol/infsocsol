load fisheries_stochastic_kernel_v.mat

pts = zeros(length(VS),2);

count = 0;
for x = 1:length(xs)
  for e = 1:length(es)
    if VS(e,x) == 0
      count = count + 1;      
      pts(count, :) = [xs(x), es(e)];
    end
  end
end

hold on
K = convhull(pts(:,1), pts(:,2));
plot(pts(K,1), pts(K,2), 'LineWidth', 2);

axis([60 600 0.1 1]);
