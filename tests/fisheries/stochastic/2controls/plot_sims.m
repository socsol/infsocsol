addpath('infsocsol');
addpath('helpers');

load fisheries_stochastic_2controls_conf.mat
load fisheries_stochastic_2controls_ocm.mat

conf = iss_conf(state_lb, state_ub, opts{:});

figure
hold on
plot_kernel;

matlabpool(2);

for i = 1:2:size(pts,1)
  [value, states, deltas, control] = iss_sim(pts(i,:), ocm, delta_fn, ...
                                             cost_fn, state_lb, ...
                                             state_ub, conf);
  
  for j = 1:conf.Options.NumberOfSimulations
    plot(states{j}(:,1), states{j}(:,2), '-m', 'LineWidth', 1);
  end
end

matlabpool close;