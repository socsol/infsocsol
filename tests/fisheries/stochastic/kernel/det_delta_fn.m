function v = det_delta_fn(u,x,t)
  b = x(1);
  e = x(2);
  
  v = [0.4*b*(1 - b/600) - 0.5*e*b, u];
end