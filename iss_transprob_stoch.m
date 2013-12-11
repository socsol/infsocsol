
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
%% ISS_TRANSPROB_STOCH Computes stochastic transition probabilities
function TransProb = iss_transprob_stoch(DeltaFunction, StateVars, ...
                                         U, StateLB, StateUB, Conf)

  %% Extract options
  Dimension = Conf.Dimension;
  
  Options = Conf.Options;
  Noise = Options.Noise;
  NoiseSteps = Options.NoiseSteps;
  NoiseProb = Options.NoiseProb;
  NoisyVars = Options.NoisyVars;
  
  StateStepSize = Options.StateStepSize;
  TimeStep = Options.TimeStep;
  TotalStates = Conf.TotalStates;

  %% Iterate over the noise
  TransProb = zeros(1, TotalStates);
  for NoiseCount = 1:NoisyVars*NoiseSteps
    NoiseNum=NoiseCount-1;
    
    % Reduce the NoiseNum to base NoiseSteps in a vector.
    NoiseVect=zeros(1,Dimension);
    for j=Dimension:-1:1
      NoiseVect(j)=floor(NoiseNum/NoiseSteps^(j-1));
      NoiseNum=NoiseNum-NoiseVect(j)*NoiseSteps^(j-1);
    end; % for j=Dimension:-1:1
    
    TotalNoiseProb=prod(NoiseProb(NoiseVect+1));
    TotalNoiseVect=[Noise(NoiseVect+1),zeros(1,Dimension- ...
                                             NoisyVars)];
    
    Next = iss_next_euler_muruyama(DeltaFunction, StateVars, U, ...
                                   TimeStep, TotalNoiseVect, Conf);
    
    AppState = (Next-StateLB)./StateStepSize+1;
    
    % Add to the probability vector
    TransProb = TransProb + iss_transprob(AppState, Conf) * TotalNoiseProb;
  end; % for NoiseCount=1:NoisyVars*NoiseSteps
end
