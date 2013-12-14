%% This function needs to return hopefully negative numbers
function [c, ceq] = fisheries_deterministic_basic_old_iss_constraints(u,x,h)
  next = x + h*fisheries_deterministic_basic_old_iss_delta(u,x,0);

  lower = [60 0.1];
  upper = [600 1];
  
  ceq = [];
  c = [lower - next, next - upper];
end
