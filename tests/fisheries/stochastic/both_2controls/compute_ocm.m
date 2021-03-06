addpath('infsocsol');

delta_fn = 'fisheries_stochastic_both_2controls_delta';
cost_fn = 'fisheries_stochastic_both_2controls_cost';
state_lb = [60 0.1];
state_ub = [600  1];
opts = {'ControlLB', [-0.005, -0.005], ...
        'ControlUB', [0.005, 0.005], ...
        'ControlDimension', 2, ...
        'StochasticProblem', 1, ...
        'DiscountRate', 0.1, ...
        'UserConstraintFunctionFile', ...
        'fisheries_stochastic_both_2controls_constraints', ...
        'StateStepSize', (state_ub - state_lb) / 20};

for i=1:2
  conf = iss_conf(state_lb, state_ub, opts{:}, 'PoolSize', i);

  save fisheries_stochastic_both_2controls_conf.mat delta_fn cost_fn state_lb state_ub opts

  tic
  ocm = iss_solve(delta_fn, ...
                  cost_fn, ...
                  state_lb, state_ub, conf);
  toc
end

save fisheries_stochastic_both_2controls_ocm.mat ocm