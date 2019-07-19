state_samples = 3;
num_states = linspace(51, 501, state_samples);
state_step = 0.5 ./ (num_states - 1);

time_step = linspace(100, 1000, state_samples);

vals = zeros(4, state_samples);

%figure
%hold on
%grid on

for j = 1:4
  for i = 1:state_samples
    disp([j, state_step(i), 2/time_step(i)]);
    
    tic();
    iss_solve('delta', 'cost', 0, 0.5, ...
              'StateStepSize', state_step(i), ...
              'TimeStep', 2/time_step(i), ...
              'DiscountRate', 0.9, ...
              'ProblemFile', 'example_a', ...
              'MaxFunEvals', 400, ...
              'TolFun', 1e-12, ...
              'PoolSize', j);
    vals(j,i) = toc();
  end

  plot(num_states, vals(j,:), ...
       'Color', [1 - j/4, 0, j/4], ...
       'LineWidth', 2);
end
