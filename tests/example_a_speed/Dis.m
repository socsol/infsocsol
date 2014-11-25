function Beta=Dis(DiscountRate,TimeStep)
% This function computes the discount factor. It is called by InfSim.

Beta=exp(-(DiscountRate*TimeStep));