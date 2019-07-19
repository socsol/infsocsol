function cost = fisheries_cost(u,s,t,Conf)
  % Extract the named values from the state vector
  x = s(1);
  e = s(2);

  % Constants
  p = 4;
  q = 0.5;
  c = 10;
  C = 150;
  
  % Profit
  pi = p*q*e*x - c*e - C;

  % Convert to cost
  cost = -pi;
end
