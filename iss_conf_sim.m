function [Vertices, TotalSimulationStages, Time, SimTime, ControlTime, ...
          UserSuppliedNoise] = iss_conf_sim(StateLB, StateUB, Conf)
  Vertices = 2^Conf.Dimension-1;
  SimulationTimeStep = Conf.Options.SimulationTimeStep;
  TotalSimulationStages = length(SimulationTimeStep);
  Time = cumsum(Conf.Options.TimeStep);
  SimTime = [0,cumsum(SimulationTimeStep)];
  ControlTime = SimTime(1:(length(SimTime)-1));
  
  if Conf.Options.UserSuppliedNoise == 0
    UserSuppliedNoise = zeros(TotalSimulationStages, ...
                              Conf.Options.NoisyVars);
  else
    UserSuppliedNoise = Conf.Options.UserSuppliedNoise;
  end
end