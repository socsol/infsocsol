function plot_scatter(all, log_scale)

load fisheries_stochastic_kernel_v.mat

%h = figure;
hold on;
%view(3);

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

scatter(pts(:,1), pts(:,2), '+b');

xlabel('fish stock');
ylabel('effort');

axis([60 600 0.1 1]);
