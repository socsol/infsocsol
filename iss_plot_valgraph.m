
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
function iss_plot_valgraph(FileName, InitialCondition, ...
                           VariableOfInterestValues, varargin)
  
  %% Load settings from file.
  [DeltaFunction, StageReturnFunction, StateLB, StateUB, Conf] = ...
      iss_load_conf(FileName);

  ODM = iss_load_solution(Conf);
  

  %% Augment configuration.
  Conf = iss_conf(StateLB, StateUB, Conf, varargin{:});


  %% Extract options
  VariableOfInterest = Conf.Options.VariableOfInterest;
  ScaleFactor = Conf.Options.ScaleFactor;
  LineSpec = Conf.Options.LineSpec;

  %% Run simulations
  
  % Predefine vector for better memory management and speed.
  ValueVector=zeros(1,length(VariableOfInterestValues));

  for i=1:length(VariableOfInterestValues)
    InitialCondition(VariableOfInterest) = VariableOfInterestValues(i);
    
    values = iss_sim(InitialCondition, ODM, ...
                     DeltaFunction, StageReturnFunction, ...
                     StateLB, StateUB, Conf);
    
    ValueVector(i) = ScaleFactor*mean(cell2mat(values));
  end
  
  %% Plot simulations
  plot(VariableOfInterestValues,ValueVector,LineSpec);
  ylabel('Value');
  xlabel(['x_',int2str(VariableOfInterest)]);
  grid;
  
end

