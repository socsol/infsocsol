%% This function needs to return hopefully negative numbers
function [c, ceq] = det_constraint_fn(u,x,conf)
  h = conf.Options.TimeStep;
  delta = det_delta_fn(u,x,0);
  next_normal = x + h*delta(1:2);
  
  lower = [60 0.1];
  upper = [600 1];
  
  b = next_normal(1);
  e = next_normal(2);
  minus_pi = 150 + 10*e - 2*e*b;
  
  ceq = [];
  
  c = [lower - next_normal, ...
       next_normal - upper,  ...
       minus_pi];
end
