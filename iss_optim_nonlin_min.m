
%%
%  Copyright 2014 Jacek B. Krawczyk and Alastair Pharo
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
function [UOptimal, error] = iss_optim_nonlin_min(UStart, Value, StateVars, ...
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
    G = @(u) iss_sqp_g(u', StateVars, Options.Aeq, Options.beq, UserConstraintFunction, Conf);
  else
    G = [];
  end

  if all([size(Options.A), size(Options.b)] > 0) || ~isempty(test_c)
    H = @(u) iss_sqp_h(u', StateVars, Options.A, Options.b, UserConstraintFunction, Conf);
  else
    H = [];
  end

  if Options.StochasticProblem
    fn = @(U) CostStoch(U', DeltaFunction, StageReturnFunction, ...
                        UserConstraintFunction, StateLB, ...
                        Options.StateStepSize, Options.TimeStep, ...
                        DiscountFactor, size(StateLB, 2), States, ...
                        CodingVector, StateVars, Value, Conf, ...
                        Options.Noise, Options.NoiseSteps, Options.NoiseProb, ...
                        Options.NoisyVars);
  else
    fn = @(U) CostDeter(U', DeltaFunction, StageReturnFunction, ...
                        UserConstraintFunction, StateLB, ...
                        Options.StateStepSize, Options.TimeStep, ...
                        DiscountFactor,size(StateLB, 2), States, ...
                        CodingVector,StateVars, Value, Conf);
  end

  [p, objf, cvg, outp] = ...
      nonlin_min(fn, UStart', ...
                 optimset(Conf.NonlinMinOptions, ...
                          'lbound', Options.ControlLB', ...
                          'ubound', Options.ControlUB', ...
                          'inequc', {[], [], H}, ...
                          'equc', {[], [], G}));

  UOptimal = p';

  % nonlin_min doesn't seem to report errors in all cases, so we
  % explicitly check if the constraints are violated by the given
  % control.
  error = cvg <= 0 || ...
          (~isempty(H) && any(H(p) < 0)) || ...
          (~isempty(G) && any(G(p) ~= 0));

end