%% This function needs to return hopefully negative numbers
function [c, ceq] = fisheries_stochastic_2controls_constraints(u,x,conf)
  h = conf.Options.TimeStep;
  delta = fisheries_stochastic_2controls_delta(u,x,0);
  next = x + h*delta(1:2);

  lower = [60 0.1];
  upper = [600 1];
  
  ceq = [];
  c = [lower - next, next - upper];
end
