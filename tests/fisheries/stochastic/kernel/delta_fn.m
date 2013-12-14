function v = delta_fn(u,x,t)
  b = x(1);
  e = x(2);
  
  % These are the standard deviation values for the noise on b and
  % e.  Set to zero to make deterministic.
  sigma_b = 15;
  sigma_e = 0.015;
  
  v = [0.4*b*(1 - b/600) - 0.5*e*b, u, sigma_b, sigma_e];
end