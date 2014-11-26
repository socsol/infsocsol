function solve(states, time_step)

lb = [60 0.1];
ub = [600  1];

state_step = (ub - lb) ./ (states - 1);

state_lb = lb - state_step;
state_ub = ub + state_step;

conf = iss_conf(state_lb, state_ub, ...
                'ControlLB', {[-0.005 -0.005]}, ...
                'ControlUB', {[0.005 0.005]}, ...
                'ControlDimension', 2, ...
                'DiscountRate', 0.01, ...
                'TimeStep', time_step, ...
                'UserConstraintFunctionFile', 'fisheries_deterministic_2controls_constraints', ...
                'StateStepSize', state_step, ...
                'ProblemFile', 'fisheries_det_2controls', ...
                'PoolSize', 4);

iss_solve('fisheries_deterministic_2controls_delta', ...
          'fisheries_deterministic_2controls_cost', ...
          state_lb, state_ub, conf);

