function value=ValDetStoch(DeltaFunction,StageReturnFunction,StateLB,...
    StateStepSize,TimeStep,DiscountFactor,Dimension,States,TotalStates,...
    CodingVector,U,Noise,NoiseSteps,NoiseProb,NoisyVars,Conf)
% This function performs the value determination step of the policy
% improvement algorithm in the stochastic case.

% Predefine matrices for better memory management and speed.
TransProb=zeros(TotalStates,TotalStates);
Return=zeros(TotalStates,1);

% Compute the number of vertices.
Vertices=2^Dimension-1;

for StateNum=1:TotalStates
    % Convert from the state number to a state vector having a state number
	% for each dimension.
    StateVect=SnToSVec(StateNum,CodingVector,Dimension);
    
    % Convert from the vector of state numbers to actual values of the
	% state variables.
    StateVars=(StateVect-1).*StateStepSize+StateLB;

    % Compute the stage return by left hand endpoint rectangular
    % approximation.
    Return(StateNum)=feval(StageReturnFunction,U(StateNum,:),StateVars,1,Conf)...
        *TimeStep;
    
    % Compute the time derivative vector.
    Delta=feval(DeltaFunction,U(StateNum,:),StateVars,1);
    DeltaMain=Delta(1:Dimension)*TimeStep;
    DeltaStoch=Delta(Dimension+1:Dimension+NoisyVars)*sqrt(TimeStep);

    % Compute "approximate" state vector. This is where the system evolves
    % to before it is constrained to the state grid.
    for NoiseCount=1:NoisyVars*NoiseSteps
        NoiseNum=NoiseCount-1;
        
        % Reduce the NoiseNum to base NoiseSteps in a vector.
        NoiseVect=zeros(1,Dimension);
        for j=Dimension:-1:1
        	NoiseVect(j)=floor(NoiseNum/NoiseSteps^(j-1));
        	NoiseNum=NoiseNum-NoiseVect(j)*NoiseSteps^(j-1);
        end; % for j=Dimension:-1:1
        TotalNoiseProb=prod(NoiseProb(NoiseVect+1));
        TotalNoiseVect=[Noise(NoiseVect+1),zeros(1,Dimension-NoisyVars)];
        AppState=(StateVars+DeltaMain+DeltaStoch.*TotalNoiseVect-...
            StateLB)./StateStepSize+1;

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
        end; % i=1:Dimension
        DownProb=1-UpProb;

        % Compute the return for this by weighing the cost to go at each
        % node by its associated transition probability for each of the
        % 2^Dimension possible transition states.
        for i=0:Vertices
            VertexNum=i;
        
            % Reduce the vertex number to binary in a vector.
            BinVect=zeros(1,Dimension);
            for j=Dimension:-1:1
                BinVect(j)=floor(VertexNum/2^(j-1));
                VertexNum=VertexNum-BinVect(j)*2^(j-1);
            end; % for j=Dimension:-1:1
        
            % Compute the state vector for the current vertex.
            Vertex=UpState.*BinVect+DownState.*(~BinVect);
        
            % Compute the state number corresponding to the state vector.
            VertexStateNum=(Vertex-1)*CodingVector'+1;
        
            % Compute the probability of being at that vertex, given noise.
            VertexProb=prod(UpProb.*BinVect+DownProb.*(~BinVect));
            
            % Add the additional probability of being at that vertex.
            TransProb(StateNum,VertexStateNum)=TransProb(StateNum,...
                VertexStateNum)+TotalNoiseProb*VertexProb;
        end; % for i=0:Vertices
    end; % for NoiseCount=1:NoisyVars*NoiseSteps
end; % StateNum=1:TotalStates
value=(eye(TotalStates)-DiscountFactor*TransProb)\Return;