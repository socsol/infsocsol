addpath('infsocsol');

load fisheries_stochastic_kernel_conf.mat
load fisheries_stochastic_kernel_ocm.mat

% This plots a convex hull of the stochastic kernel.  After
% running, the variable "pts" contains a list of viable points, so
% we use these to run simulations.
plot_convhull

count = 3;
conf = iss_conf(state_lb, state_ub, opts{:}, ...
                'NumberOfSimulations', count);

% Make a plot for every fourth point.
for i = 1:20:size(pts,1)
  [value, states, deltas, control] = iss_sim(pts(i,:), ocm, delta_fn, ...
                                             cost_fn, state_lb, ...
                                             state_ub, conf);
  
  for i = 1:count
    % Plot colour ranges from red to blue over each sim.
    plot(states(i,:,1), states(i,:,2), '-', ...
         'LineWidth', 1, ...
         'Color', [0.5 + (i/count/2), 0, i/count]);
  end
end