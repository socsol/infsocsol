addpath('infsocsol');

delta_fn = 'fisheries_deterministic_basic_old_iss_delta';
cost_fn = 'fisheries_deterministic_basic_old_iss_cost';
state_lb = [60 0.1];
state_ub = [600, 1];

tic
InfSOCSol(delta_fn, cost_fn, state_lb, state_ub, ...
          (state_ub - state_lb) / 20, 1, 0.1, ...
          'fisheries_deterministic_basic_old_iss', ...
          {}, [], [], [], [], -0.01, 0.01, ...
          'fisheries_deterministic_basic_old_iss_constraints');

toc