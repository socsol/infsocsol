function v = fisheries_delta(u,s,t)
  % Extract the named values from the state vector
  x = s(1);
  e = s(2);

  % Equation of motion for biomass
  xdot = 0.4*x*(1 - x/600) - 0.5*e*x;

  % Equation of motion for effort
  edot = u;

  % Combine into a vector
  v = [xdot, edot];
end
