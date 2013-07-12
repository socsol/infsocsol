function v = iss_sqp_h(u, x, A, b, nonlcon, conf)
  if all([size(A), size(b)] > 0)
    v1 = b - A * u;
  else
    v1 = [];
  end

  v2 = [];
  if ~isempty(nonlcon)
    [c,ceq] = nonlcon(u, x, conf.Options.TimeStep, conf);   
    if ~isempty(c)
      v2 = -c;
    end
  end
  
  v = [v1,v2]';
end