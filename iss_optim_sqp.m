
%%
%  Copyright 2013 Jacek B. Krawczyk and Alastair Pharo
%
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.
function [UOptimal, flag] = iss_optim_sqp(UStart, Value, StateVars, ...
                                          DeltaFunction, ...
                                          StageReturnFunction, ...
                                          StateLB, StateUB, Conf)

  States = Conf.States;
  CodingVector = Conf.CodingVector;
  DiscountFactor = Conf.DiscountFactor;
  UserConstraintFunctionFile = Conf.UserConstraintFunctionFile;
  UserConstraintFunction = Conf.UserConstraintFunction;
  Options = Conf.Options;

  % Test an evaluation of the user constraint function, if there is one.
  if ~isempty(UserConstraintFunction)
    [test_c, test_ceq] = UserConstraintFunction(UStart, StateVars, Conf);
  else
    test_c = [];
    test_ceq = [];
  end

  if all([size(Options.Aeq), size(Options.beq)] > 0) || ~isempty(test_ceq)
    G = @(u) iss_sqp_g(u, StateVars, Options.Aeq, Options.beq, UserConstraintFunction, Conf);
  else
    G = [];
  end

  if all([size(Options.A), size(Options.b)] > 0) || ~isempty(test_c)
    H = @(u) iss_sqp_h(u, StateVars, Options.A, Options.b, UserConstraintFunction, Conf);
  else
    H = [];
  end


  if Options.StochasticProblem
    fn = @(U) CostStoch(U, DeltaFunction, StageReturnFunction, ...
                        UserConstraintFunction, StateLB, ...
                        Options.StateStepSize, Options.TimeStep, ...
                        DiscountFactor, size(StateLB, 2), States, ...
                        CodingVector, StateVars, Value, Conf, ...
                        Options.Noise, Options.NoiseSteps, Options.NoiseProb, ...
                        Options.NoisyVars);
  else
    fn = @(U) CostDeter(U, DeltaFunction, StageReturnFunction, ...
                        UserConstraintFunction, StateLB, ...
                        Options.StateStepSize, Options.TimeStep, ...
                        DiscountFactor,size(StateLB, 2), States, ...
                        CodingVector,StateVars, Value, Conf);
  end

  try  
    [UOptimal, obj, info, iter, nf, lambda] = sqp(UStart, fn, G, H, ...
                                                  Options.ControlLB, ...
                                                  Options.ControlUB, ...
                                                  max(Options.MaxIter, ...
                                                      Options.MaxFunEvals), ...
                                                  min(Options.TolX, ...
                                                      Options.TolFun));

    if info == 101
      flag = 1;
    else
      flag = -2;
    end
  catch
    err = lasterror;
    %err.message
    %
    %for i = 1:length(err.stack)
    %  fprintf('%s on line %i\n', err.stack(i).file, err.stack(i).line);
    %end

    UOptimal = UStart;
    flag = -2;
  end
end