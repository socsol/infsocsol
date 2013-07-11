function [SimulatedValue, StateEvolution, DeltaEvolution, Control] = ...
        iss_sim(InitialCondition, ODM, DeltaFunction, StageReturnFunction, ...
                Minimum, Maximum, varargin)

  %% Construct options
  Conf = iss_conf(Minimum, Maximum, varargin{:});

  SimulationTimeStep = Conf.Options.SimulationTimeStep;
  NumberOfSimulations = Conf.Options.NumberOfSimulations;

  Dimension=Conf.Dimension;
  TotalSimulationStages=Conf.TotalSimulationStages;
  Time=Conf.Time;
  SimTime=Conf.SimTime;
  ControlTime=Conf.ControlTime;
  ControlDimension=Conf.Options.ControlDimension;
  StochasticProblem=Conf.Options.StochasticProblem;
  Vertices=Conf.Vertices;


  %% These options were previously determined on each loop
  Min = Minimum(1,:);
  Max = Maximum(1,:);
  StateStep = Conf.Options.StateStepSize;
  States = Conf.States;
  CodingVector = Conf.CodingVector;


  %% Predefine empty holders 
  %   to speed execution and improve memory management.
  Control=zeros(TotalSimulationStages,ControlDimension);
  
  StateEvolution=zeros(TotalSimulationStages+1,Dimension);
  DeltaEvolution=zeros(TotalSimulationStages,Dimension);
  
  SimulatedValue=zeros(1,NumberOfSimulations);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%                 MAIN LOOP                  %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % For each of the NumberOfSimulations trajectories.
  for count=1:NumberOfSimulations
    %fprintf(['Computing trajectory number ',int2str(count),' of ',...
    %      int2str(NumberOfSimulations),'.\n']);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%             COMPUTE TRAJECTORY             %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Convert the initial condition to a state vector
    AppState= (InitialCondition-Min)./StateStep+1;
    
    % For each stage in turn.
    for SimulationStage=1:TotalSimulationStages
      
      % Time is based on the simulation step and not on 
      % the discretization time step.
      t=SimTime(SimulationStage);
      
      % Take the current state, which is not constrained
      % to lie on the state grid, and find the adjacent
      % states together with their associated transition
      % probabilities.
      UpState=ceil(AppState);
      DownState=floor(AppState);
      UpProb=AppState-DownState;
      
      % Deal with the case of the approximated state
      % lying outside the discrete state space.
      [UpState,DownState,UpProb]=ConState(Dimension,UpState,DownState,...
                                          UpProb,States);
      DownProb=1-UpProb;

      % Compute the control for this by weighting the control at
      % each node by its associated transition probability.
      U=CompCont(Vertices,Dimension,UpState,DownState,CodingVector,...
                 UpProb,DownProb,ODM);
      
      % Record the state and control for this simulation stage.
      StateVars=(AppState-1).*StateStep+Min;
      StateEvolution(SimulationStage,:)=StateVars; 
      Control(SimulationStage,:)=U;
      DiscountFactor=Dis(Conf.Options.DiscountRate,t);
      SimulatedValue(count)=SimulatedValue(count)+ ...
          feval(StageReturnFunction,U,StateVars,1,Conf)* ...
          SimulationTimeStep(SimulationStage)*DiscountFactor;

      % Stochastic case.
      if StochasticProblem
        % Compute deltas using Euler-Muruyama method.
        Delta=feval(DeltaFunction,U,StateVars,t);
        DeltaDeter=Delta(1:Dimension)*...
            SimulationTimeStep(SimulationStage);
        DeltaStoch=Delta(Dimension+1:Dimension+NoisyVars)*...
            sqrt(SimulationTimeStep(SimulationStage));
        
        % Compute noise.
        NoiseRealization=zeros(1,Dimension);
        if UserSuppliedNoise==-1
          NoiseRealization(1,1:NoisyVars)=randn(1,NoisyVars);
        else
          NoiseRealization(1,1:NoisyVars)=...
              UserSuppliedNoise(SimulationStage,:);
        end; % if UserSuppliedNoise==-1
        
        % Compute "approximate" state vector. This is where the system
        % evolves to before it is constrained to the state grid.
        AppState=(StateVars+DeltaDeter+...
                  DeltaStoch.*NoiseRealization-Min)./StateStep+1;
        
        % Deterministic case.
      else
        % Compute delta using Euler-Muruyama method.
        Delta=feval(DeltaFunction,U,StateVars,t)*...
              SimulationTimeStep(SimulationStage);
        
        % Compute "approximate" state vector. This is where the system
        % evolves to before it is constrained to the state grid.
        AppState=(StateVars+Delta-Min)./StateStep+1;
      end; % if StochasticProblem
      
      DeltaEvolution(SimulationStage, :) = Delta;
    end; % for SimulationStage=1:TotalSimulationStages

    % Record the values of the terminal state and add the terminal
    % state cost to the computed payoff.
    StateVars=(AppState-1).*StateStep+Min;
    StateEvolution(TotalSimulationStages+1,:)=StateVars;
  end; % for count=1:NumberOfSimulations
end