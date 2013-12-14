function plot_contour(log_scale)

if (nargin < 2)
  log_scale = 0;

  if (nargin < 1)
    all = 0;
  end
end

load fisheries_stochastic_kernel_v.mat

%h = figure;
hold on;
view(2);

xlabel('X');
ylabel('E');
[C, h] = contour(XS, ES, VS);

plot(60:600, (150*ones(1,length(60:600))) ./ (2 * (60:600) - 10));