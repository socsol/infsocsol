% This runs InfSOCSol to find the OCM matrix for the problem.
compute_ocm

% Add simulation count at this stage.
conf = iss_conf(state_lb, state_ub, opts{:}, ...
                'NumberOfSimulations', 50);

viable_fn = @viable;

% This is the grid that simulations will be run over.  This may not be
% the same size as the grid used when computing the OCM.  See
% compute_ocm.m.
discretisation_sim = [21 21];
xs = linspace(60, 600, discretisation_sim(1));
es = linspace(0.1, 1, discretisation_sim(2));

[XS, ES] = meshgrid(xs, es);

% We run the avg_sim function, which makes the stochastic version
% of InfSim work kind of like the deterministic version
% (i.e. return only one value, which will be zero when no violation
% occurred).
fprintf(1, 'Running InfSim ...\n');
tic
VS = arrayfun (@(X, E) avg_sim([X E], ocm, delta_fn, viable_fn, ...
                               state_lb, state_ub, conf), XS, ES);
toc

% Save kernel data for plotting later
save fisheries_stochastic_kernel_v.mat xs es XS ES VS