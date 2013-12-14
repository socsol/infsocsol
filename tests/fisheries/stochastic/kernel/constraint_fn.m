%% This function needs to return hopefully negative numbers
function [c, ceq] = constraint_fn(u,x,conf)
  h = conf.Options.TimeStep;
  delta = delta_fn(u,x,0);
  next_normal = x + h*delta(1:2);
  
  % We are precautionary for some number of standard deviations.
  sigma = 1;
  next_up = next_normal + sigma*delta(3:end)*sqrt(h);
  next_down = next_normal - sigma*delta(3:end)*sqrt(h);

  lower = [60 0.1];
  upper = [600 1];
  
  p = 4;
  q = 0.5;
  c = 10;
  C = 150;
  pi = @(b,e) p*q*e*b - c*e - C;
  
  pi_up = pi(next_up(1), next_up(2));
  pi_normal = pi(next_normal(1), next_normal(2));
  pi_down = pi(next_down(1), next_down(2));
  
  ceq = [];
  
  % It's probably only necessary to consider the up and down values ...
  c = [lower - next_up, lower - next_normal, lower - next_down, ...
       next_up - upper, next_normal - upper, next_down - upper, ...
       -pi_up, -pi_normal, -pi_down];
end
