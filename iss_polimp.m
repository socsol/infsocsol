function [UOptimal, OCM, Flags] = iss_polimp(UOptimal, OCM, Value, ...
                                             DeltaFunction, ...
                                             StageReturnFunction, ...
                                             StateLB, StateUB, Conf)

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
  UStart = zeros(1, Options.ControlDimension); %FIXME
  UOptimal = ones(Conf.TotalStates, Options.ControlDimension);
  Flags = ones(1,Conf.TotalStates);

  for StateNum=1:TotalStates
    
    StateVect=SnToSVec(StateNum,CodingVector,Dimension);
    StateVars=(StateVect-1).*Options.StateStepSize+StateLB;
    
    [UOptimal(StateNum,:), Flags(StateNum)] = Optimizer(UStart, Value, ...
                                                      StateVars, ...
                                                      DeltaFunction, ...
                                                      StageReturnFunction, ...
                                                      StateLB, StateUB, Conf);
    
    %NumFminconCalls=NumFminconCalls+1;
    for j=1:Options.ControlDimension
      OCM{j}(StateNum)=UOptimal(StateNum,j);
    end;
  end; % for state=1:TotalStates
end
