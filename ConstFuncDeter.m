
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
function [c,ceq] = ConstFuncDeter(U,DeltaFunction,StageReturnFunction,...
    UserConstraintFunction,StateLB,StateStepSize,TimeStep,...
    DiscountFactor,Dimension,States,CodingVector,StateVars,...
    Value,Conf) %#ok<INUSD,INUSL>
% This function acts as a 'shell' about the user-defined constraint
% function, altering its arguments to match those passed in the fmincon
% calls within InfSOCSol.
    
[c,ceq]=feval(UserConstraintFunction,U,StateVars,Conf);