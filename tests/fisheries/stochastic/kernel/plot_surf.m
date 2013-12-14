function plot_surf(log_scale)

if (nargin < 2)
  log_scale = 0;

  if (nargin < 1)
    all = 0;
  end
end

load fisheries_stochastic_kernel_v.mat

%h = figure;
hold on;
view(3);

xlabel('X');
ylabel('E');
surf(XS, ES, VS);

