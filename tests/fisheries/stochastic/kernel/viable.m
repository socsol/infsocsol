function v = viable(u, x, t, conf)
  lower = [6   0.1];
  upper = [600 1];
  
  profit = 2*x(2)*x(1) - 10*x(2) - 150;
  
  % eps is used because of rounding issues.
  c = [lower - x - eps(x), x - upper - eps(x), -profit];
  v = any(c > 0);
end