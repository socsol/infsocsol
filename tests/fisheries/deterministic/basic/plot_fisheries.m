addpath infsocsol

sim_axis1 = [1, 250, 0, 600];
sim_axis2 = [1, 250, 0.1, 1];
sim_axis3 = [1, 250, -0.01, 0.01];

%% Plot contrules for basic setup
for i=60:180:600
  figure
  iss_plot_contrule('fisheries', [i NaN], 'VariableOfInterest', 2, 'LineWidth',2);
  hold on
  axis([0.1, 1, -0.01, 0.01]);
  print('-depsc', ['fisheries-contrule-x', int2str(i), '.eps']);
  close
end

%% Plot sim for basic setup
% Add this in order to be able to plot all graphs together.
figure
hold on

% Use the 'LineSpec' option to change the colour of each simulation.
iss_plot_sim('fisheries', [78, 0.1], 'LineSpec', '-b', 'LineWidth',2);
iss_plot_sim('fisheries', [78, 0.9], 'LineSpec', '-c', 'LineWidth',2);
iss_plot_sim('fisheries', [582, 0.1], 'LineSpec', '-g', 'LineWidth',2);
iss_plot_sim('fisheries', [582, 0.9], 'LineSpec', '-m', 'LineWidth',2);

% Add a red dashed line to show where the SMBL is
subplot(3, 1, 1);
axis(sim_axis1);
plot([0, 250], [60, 60], 'r--');

subplot(3, 1, 2);
axis(sim_axis2);

subplot(3, 1, 3);
axis(sim_axis3);

% Save eps
print('-depsc', ['fisheries-sims.eps']);
close


%% Plot contrules for stochastic setup
for i=60:180:600
  figure
  iss_plot_contrule('fisheries_stoch', [i NaN], 'VariableOfInterest', 2, 'LineWidth',2);
  hold on
  axis([0.1, 1, -0.01, 0.01]);
  print('-depsc', ['fisheries-contrule-x', int2str(i), '-stoch.eps']);
  close
end

%% Plot sim for basic setup
% Add this in order to be able to plot all graphs together.
figure
hold on

% Use the 'LineSpec' option to change the colour of each simulation.
iss_plot_sim('fisheries_stoch', [78, 0.1], 'LineSpec', '-b', 'LineWidth',2);
iss_plot_sim('fisheries_stoch', [78, 0.9], 'LineSpec', '-c', 'LineWidth',2);
iss_plot_sim('fisheries_stoch', [582, 0.1], 'LineSpec', '-g', 'LineWidth',2);
iss_plot_sim('fisheries_stoch', [582, 0.9], 'LineSpec', '-m', 'LineWidth',2);

% Add a red dashed line to show where the SMBL is
subplot(3, 1, 1);
axis(sim_axis1);
plot([0, 250], [60, 60], 'r--');

subplot(3, 1, 2);
axis(sim_axis2);

subplot(3, 1, 3);
axis(sim_axis3);

% Save eps
print('-depsc', ['fisheries-sims-stoch.eps']);
close
