function [States, TotalStates, CodingVector] = ...
    ConstructCodingVector(StateLB, StateUB, StateStepSize)

% Problem dimensionality
Dimension=size(StateLB,2);

States=round((StateUB-StateLB)./StateStepSize+1);
c=cumprod(States);
TotalStates=c(Dimension);
CodingVector=[1,c(1:Dimension-1)];
