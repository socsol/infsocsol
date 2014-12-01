function Iterations = solve_v2(states)
  global Iterations;

  delta_file = 'delta';
  cost_file = 'cost';

  state_step = 0.5 / (states - 1);
  time_step = 0.02; %2 * state_step;

  state_lb = 0;
  state_ub = 0.5;

  discount_rate = 0.9;

  problem_file = 'example_a';
  options = {'MaxFunEvals', '400', ...
             'TolFun', '1e-12'};

  A = [];
  b = [];
  Aeq = [];
  beq = [];

  control_lb = -Inf;
  control_ub = Inf;

  user_constraint_function = [];

  InfSOCSol(delta_file, cost_file, ...
            state_lb, state_ub, ...
            state_step, time_step, ...
            discount_rate, ...
            problem_file, options, ...
            A, b, Aeq, beq, ...
            control_lb, control_ub, ...
            user_constraint_function);
end
