%% This function needs to return hopefully negative numbers
function [c, ceq] = fisheries_deterministic_basic_constraints(u,x,conf)
  h = conf.Options.TimeStep;
  next = x + h*fisheries_deterministic_basic_delta(u,x,0);

  lower = [60 0.1];
  upper = [600 1];
  
  ceq = [];
  c = [lower - next, next - upper];
end
