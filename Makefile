MATLAB_PATH = /usr/local/MATLAB/R2011a_Student
LD_LIBRARY_PATH = $(MATLAB_PATH)/bin/glnx86 
TESTS ?= tests/*_spec.pure

test:
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) pure -Ipure/puritan -Ipure/matlab -b tests/setup.pure $(TESTS) tests/run.pure

testzips:
	cd tests/fisheries/deterministic/basic_old_iss && zip -r ../../../../fisheries-deterministic-basic_old_iss.zip *.m helpers infsocsol/*.m
	cd tests/fisheries/deterministic/basic && zip -r ../../../../fisheries-deterministic-basic.zip *.m helpers infsocsol/*.m
	cd tests/fisheries/deterministic/2controls && zip -r ../../../../fisheries-deterministic-2controls.zip *.m helpers infsocsol/*.m
	cd tests/fisheries/stochastic/basic && zip -r ../../../../fisheries-stochastic-basic.zip *.m helpers infsocsol/*.m
	cd tests/fisheries/stochastic/both && zip -r ../../../../fisheries-stochastic-both.zip *.m helpers infsocsol/*.m
	cd tests/fisheries/stochastic/2controls && zip -r ../../../../fisheries-stochastic-2controls.zip *.m helpers infsocsol/*.m
	cd tests/fisheries/stochastic/both_2controls && zip -r ../../../../fisheries-stochastic-both_2controls.zip *.m helpers infsocsol/*.m
	cd tests/fisheries/stochastic/kernel && zip -r ../../../../fisheries-stochastic-kernel.zip *.m *.mat helpers/*.m helpers/*.mat infsocsol/*.m
