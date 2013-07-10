function v = SqpG(x, Aeq, beq, UserConstraintFunction)
  if all([size(Aeq), size(beq)] > 0)
    v1 = beq - Aeq * x;
  else
    v1 = [];
  end
  
  v2 = [];
  if ~isempty(nonlcon)
    [c,ceq] = UserConstraintFunction(x);
    if ~isempty(ceq)
      v2 = -ceq;
    end
  end
  
  v = [v1,v2];
end