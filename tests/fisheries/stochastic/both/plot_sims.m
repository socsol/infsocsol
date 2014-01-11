addpath('infsocsol');
addpath('helpers');

load fisheries_stochastic_both_conf.mat
load fisheries_stochastic_both_ocm.mat

conf = iss_conf(state_lb, state_ub, opts{:});

figure;
hold on
plot_kernel;

if strcmp(conf.System, 'matlab')
  matlabpool(2);
end

tic
for i = 1:5:size(V,1)
  [value, states, deltas, control] = iss_sim(V(i,:), ocm, delta_fn, ...
                                             cost_fn, state_lb, ...
                                             state_ub, ...
                                             conf);
  
  for j = 1:length(value)
    plot(states{j}(:,1), states{j}(:,2), '-m', 'LineWidth', 1, ...
         'Color', [j/length(value), 0.5, 1]);
  end
end
toc

if strcmp(conf.System, 'matlab')
  matlabpool close
end