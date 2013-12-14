addpath('infsocsol');
addpath('helpers');

load fisheries_stochastic_both_2controls_conf.mat
load fisheries_stochastic_both_2controls_ocm.mat

conf = iss_conf(state_lb, state_ub, opts{:});
pts = plot_kernel(state_lb, state_ub);

for i = 1:2:size(pts,1)
  [value, states, deltas, control] = iss_sim(pts(i,:), ocm, delta_fn, ...
                                             cost_fn, state_lb, ...
                                             state_ub, conf);
  plot(states(:,1), states(:,2), '-m', 'LineWidth', 1);
end