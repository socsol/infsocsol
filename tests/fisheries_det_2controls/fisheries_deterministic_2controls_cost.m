function cost = fisheries_deterministic_2controls_cost(u,x,t,conf)
  b = x(1);
  e = x(2);
  
  p = 4;
  q = 0.5;
  c = 10;
  C = 150;
  
  pi = p*q*e*b - c*e - C;
  cost = -pi;
end
