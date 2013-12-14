addpath('infsocsol');
addpath('helpers');

state_lb = [60 0.1];
state_ub = [600  1];

figure
hold on
plot_kernel;

tic
global StateEvolution
for i = 1:2:size(pts,1)
  InfSim('fisheries_deterministic_basic_old_iss', pts(i,:), ...
         ones(1, 250), -1);
  states = StateEvolution;
  plot(states(:,1), states(:,2), '-m', 'LineWidth', 1);
end
toc