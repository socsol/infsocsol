
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
function value=CostDeter(U,DeltaFunction,StageReturnFunction,...
    UserConstraintFunction,StateLB,StateStepSize,TimeStep,...
    DiscountFactor,Dimension,States,CodingVector,StateVars,...
    PrevValue,Conf) %#ok<INUSL>
% This is the cost function minimized by fmincon at the policy improvement
% step of the policy improvement algorithm in the deterministic case.

% Compute the time derivative vector.
Delta=feval(DeltaFunction,U,StateVars,1).*TimeStep;

% Compute the stage return by left hand endpoint rectangular approximation.
value=feval(StageReturnFunction,U,StateVars,1,Conf)*TimeStep;

% Compute "approximate" state vector. This is where the system evolves to
% before it is constrained to the state grid.
AppState=(StateVars+Delta-StateLB)./StateStepSize+1;

% Compute the adjacent nodes on the state grid and the transition
% probabilities.
UpState=ceil(AppState);
DownState=floor(AppState);
UpProb=AppState-DownState;
for i=1:Dimension
    if DownState(i)>=States(i)&&UpState(i)~=States(i)
		UpState(i)=States(i);
		DownState(i)=States(i);
		UpProb(i)=1;
	elseif UpState(i)<=1&&DownState(i)~=1
		DownState(i)=1;
		UpState(i)=1;
		UpProb(i)=1;
	elseif UpState(i)==DownState(i)
		UpProb(i)=1;
    end; % if DownState(i)>=States(i)&&UpState(i)~=States(i)
end; % for i=1:Dimension
DownProb=1-UpProb;

% Compute the number of vertices.
Vertices=2^Dimension-1;

% Compute the return for this by weighting the cost to go at each node by
% its associated transition probability for each of the 2^Dimension
% possible transition states.
for i=0:Vertices
	VertexNum=i;
	
	% Reduce the vertex number to binary in a vector.
	BinVect=zeros(1,Dimension);
    for j=Dimension:-1:1
		BinVect(j)=floor(VertexNum /2^(j-1));
		VertexNum=VertexNum-BinVect(j)*2^(j-1);
    end; % for j=Dimension:-1:1
	
	% Compute the state vector for the current vertex.
	Vertex=UpState.*BinVect+DownState.*(~BinVect);

	% Compute the state number corresponding to the state vector.
	VertexStateNum=(Vertex-1)*CodingVector'+1;
	
	% Compute the probability of being at that vertex.
	VertexProb=prod(UpProb.*BinVect+DownProb.*(~BinVect));
	
	% Add the weighted return at this vertex to the value.
    value=value+DiscountFactor*VertexProb*PrevValue(VertexStateNum);
end; % for i=0:Vertices