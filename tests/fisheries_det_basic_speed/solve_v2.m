function Iterations = solve_v2(states, time_step)
  global Iterations;

  delta_file = 'fisheries_delta';
  cost_file = 'fisheries_cost';

  lb = [60 0.1];
  ub = [600  1];

  state_step = (ub - lb) ./ (states - 1);

  state_lb = lb - state_step;
  state_ub = ub + state_step;

  discount_rate = 0.01;

  problem_file = 'fisheries_det_basic';
  options = {'MaxFunEvals', '400', ...
             'TolFun', '1e-12'};

  A = [];
  b = [];
  Aeq = [];
  beq = [];

  control_lb = -0.01;
  control_ub = 0.01;

  user_constraint_function = 'fisheries_constraint';

  InfSOCSol(delta_file, cost_file, ...
            state_lb, state_ub, ...
            state_step, time_step, ...
            discount_rate, ...
            problem_file, options, ...
            A, b, Aeq, beq, ...
            control_lb, control_ub, ...
            user_constraint_function);
end
