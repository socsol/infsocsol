function [UOptimal, Flags] = iss_polimp(UOptimal, Value, DeltaFunction, ...
                                        StageReturnFunction, StateLB, ...
                                        StateUB, Conf)

  %% Extract relevant settings from Conf
  Dimension = Conf.Dimension;
  States = Conf.States;
  TotalStates = Conf.TotalStates;
  CodingVector = Conf.CodingVector;
  DiscountFactor = Conf.DiscountFactor;
  UserConstraintFunctionFile = Conf.UserConstraintFunctionFile;
  UserConstraintFunction = Conf.UserConstraintFunction;
  Options = Conf.Options;

  Optimizer = Conf.Optimizer;

  Flags = ones(1,Conf.TotalStates);

  for StateNum=1:TotalStates
    StateVect=SnToSVec(StateNum,CodingVector,Dimension);
    StateVars=(StateVect-1).*Options.StateStepSize+StateLB;

    [UOptimal(StateNum,:), Flags(StateNum)] = ...
        Optimizer(Options.ControlUB, Value, StateVars, DeltaFunction, ...
                  StageReturnFunction, StateLB, StateUB, Conf);
  end; % for state=1:TotalStates
end
