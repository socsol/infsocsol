addpath('infsocsol');

delta_fn = 'det_delta_fn';
cost_fn = 'cost_fn';

% Here we are setting up a search grid that is slightly bigger than
% the constraint set.
cons_lb = [60 0.1];
cons_ub = [600  1];
cons_step = (cons_ub - cons_lb) / 50;

state_lb = cons_lb - cons_step;
state_ub = cons_ub + cons_step;
state_step = cons_step;

% We probably need at least 3 simulations.
opts = {'ControlLB', -0.01, ...
        'ControlUB', 0.01, ...
        'StochasticProblem', 0, ...
        'DiscountRate', 0.1, ...
        'UserConstraintFunctionFile', 'det_constraint_fn', ...
        'StateStepSize', state_step};

conf = iss_conf(state_lb, state_ub, opts{:});

save fisheries_det_kernel_conf.mat delta_fn cost_fn state_lb state_ub opts

ocm = iss_solve(delta_fn, ...
                cost_fn, ...
                state_lb, state_ub, conf);

save fisheries_det_kernel_ocm.mat ocm