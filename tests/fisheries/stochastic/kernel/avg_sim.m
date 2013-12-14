function v = avg_sim(varargin)

  % We expect iss_sim to return a vector of values.  We consider points
  % viable if they are ok at least some percentage of the time.
  vs = iss_sim(varargin{:});

  % This is the minimum portion of simulations that need to be viable.
  threshold = 0.62;

  % This works because we know that the cost function being used will be
  % non-zero whenever a constraint violation has occurred.  We
  % therefore return the gap or zero, whichever is greater.  This
  % means that this function behaves in a similar way to iss_sim
  % in the deterministic case.
  v = max([0, threshold - (1 - length(nonzeros(vs)) / length(vs))]);
end