function solve(state_step, time_step, max_fun_evals, tol_fun)
  iss_solve('delta', 'cost', 0 - state_step, 0.5 + state_step, ...
            'StateStepSize', state_step, ...
            'TimeStep', time_step, ...
            'DiscountRate', 0.9, ...
            'ProblemFile', 'example_a', ...
            'MaxFunEvals', max_fun_evals, ...
            'TolFun', tol_fun, ...
            'PoolSize', 4);
end