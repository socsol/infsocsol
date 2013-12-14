function v = fisheries_stochastic_both_2controls_delta(u,x,t)
  b = x(1);
  e = x(2);
  
  v = [0.4*b*(1 - b/500) - 0.5*e*b, sum(u), 10, 0.01];
end