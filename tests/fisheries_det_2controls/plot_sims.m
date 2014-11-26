load fisheries_det_2controls_options.mat
load fisheries_det_2controls_solution.mat

conf = iss_conf(StateLB, StateUB, iss_conf(StateLB, StateUB), Options);

figure;
hold on

[X,E] = meshgrid(linspace(60,600,10), linspace(0.1, 1, 10));

tic
for i = 1:numel(X)
  [value, states, deltas, control] = ...
      iss_sim_individual([X(i), E(i)], OCM, ...
                         DeltaFunction, ...
                         StageReturnFunction, ...
                         StateLB, StateUB, conf);

  plot(states(:,1), states(:,2), '-m', 'LineWidth', 2);
end
toc

axis([60, 600, 0.1, 1])