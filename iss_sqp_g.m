function v = iss_sqp_g(u, x, Aeq, beq, nonlcon, conf)
  if all([size(Aeq), size(beq)] > 0)
    v1 = beq - Aeq * u;
  else
    v1 = [];
  end
  
  v2 = [];
  if ~isempty(nonlcon)
    [c,ceq] = nonlcon(u, x, conf.Options.TimeStep, conf);
    if ~isempty(ceq)
      v2 = -ceq;
    end
  end
  
  v = [v1,v2]';
end