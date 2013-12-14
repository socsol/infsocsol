addpath helpers

%% Basic kernel plot
% Create figure
figure;
hold on

% Plot the deterministic and stochastic kernels
%plot_scatter
plot_convhull
plot_kernel

%% Simulation points
% Two points from the NE corner of the stochastic kernel and two
% from the NE corner of the deterministic kernel.
sim_start_pts = [589.2, 0.766; % Deterministic\stochastic
                 600, 0.7408;
                 546, 0.676; % Stochastic (& deterministic)
                 513, 0.694;
                 448.8, 0.712];

%% Deterministic simulation
load fisheries_det_kernel_conf
load fisheries_det_kernel_ocm

conf = iss_conf(state_lb, state_ub, opts{:});

% This is the colour used to plot deterministic paths.  If a path
% is non-viable, the inverse of the colour will be used instead.
det_color = [0, 0.7, 0.7];
for row = 1:size(sim_start_pts,1)
  start = sim_start_pts(row,:);
  
  [value, path, delta_path, control_path] = ...
      iss_sim(start, ocm, delta_fn, @viable, ...
              state_lb, state_ub, conf);
  
  if value == 0
    color = det_color;
  else
    color = 1 - det_color;
  end
  
  plot(path(1,1,1), path(1,1,2), 'rx', 'MarkerSize', 8);
  plot(path(1,:,1), path(1,:,2), 'Color', color, 'LineWidth', 2);
end

%% Stochastic simulation
load fisheries_stochastic_kernel_conf
load fisheries_stochastic_kernel_ocm

conf = iss_conf(state_lb, state_ub, opts{:}, ...
                'NumberOfSimulations', 3);

% This is the colour used to plot stochastic paths.  If a path
% is non-viable, the inverse of the colour will be used instead.
stoch_color = [1, 0, 0.7];
for row = 1:size(sim_start_pts,1)
  start = sim_start_pts(row,:);
  
  [value, path, delta_path, control_path] = ...
      iss_sim(start, ocm, delta_fn, @viable, ...
              state_lb, state_ub, conf);
  
  threshold = 0.62;
  v = max([0, threshold - (1 - length(nonzeros(value)) / length(value))]);  

  plot(path(1,1,1), path(1,1,2), 'rx', 'MarkerSize', 8);
  for i = 1:size(path, 1)
    green = [0, i / size(path, 1) / 3, 0];

    if v == 0
      color = stoch_color + green;
    else
      color = 1 - stoch_color - green;
    end
    
    plot(path(i,:,1), path(i,:,2), 'Color', color, 'LineWidth', 1);
  end
end