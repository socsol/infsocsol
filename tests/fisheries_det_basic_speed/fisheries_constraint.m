function [c, ceq] = fisheries_constraint(u, s, Conf)
  if isstruct(Conf)
    h = Conf.Options.TimeStep;
  else
    h = Conf;
  end
  
  % Determine the "next" state.  The zero can be ignored.
  next_s = s + h*fisheries_delta(u, s, 0);

  % Extract the named values from the state vector
  x = next_s(1);
  e = next_s(2);
  
  % Constaints
  e_min = 0.1;
  e_max = 1;
  x_min = 60;
  
  profit = -fisheries_cost(u, [x,e], 0);

  % The inequality constraints should be a vector of numbers that are
  % negative iff the constraints are satisfied.
  c = [e_min - e, e - e_max, x_min - x];
  
  % There are no equality constraints
  ceq = [];
end
