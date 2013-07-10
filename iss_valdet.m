function Value = iss_valdet(U, DeltaFunction, StageReturnFunction, ...
                            StateLB, StateUB, Conf)
 
  Dimension = Conf.Dimension;
  States = Conf.States;
  TotalStates = Conf.TotalStates;
  CodingVector = Conf.CodingVector;
  DiscountFactor = Conf.DiscountFactor;
  Options = Conf.Options;
  
  if Options.StochasticProblem
    Value = ValDetStoch(DeltaFunction,StageReturnFunction,StateLB,...
                        Options.StateStepSize,Options.TimeStep,DiscountFactor,Dimension,States,...
                        TotalStates,CodingVector,U,...
                        Options.Noise,Options.NoiseSteps,Options.NoiseProb,Options.NoisyVars,Conf);
  else
    Value = ValDetDeter(DeltaFunction,StageReturnFunction,StateLB, ...
                        Options.StateStepSize,Options.TimeStep,DiscountFactor, ...
                        Dimension,States, TotalStates,CodingVector,U,Conf);
  end % if StochasticProblem
end