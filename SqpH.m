function v = SqpH(x, A, b, nonlcon)
  if all([size(A), size(b)] > 0)
    v1 = b - A * x;
  else
    v1 = [];
  end

  v2 = [];
  if ~isempty(nonlcon)
    [c,ceq] = UserConstraintFunction(x);   
    if ~isempty(c)
      v2 = -c;
    end
  end
  
  v = [v1,v2];
end