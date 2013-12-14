delta_file = 'example_a_delta'
cost_file = 'example_a_cost'

state_lb = 0
state_ub = 0.5

state_step = 0.01
time_step = 0.02
discount_rate = 0.9

problem_file = 'example_a'
options = {}

A = []
b = []
Aeq = []
beq = []

control_lb = -Inf
control_ub = Inf

user_constraint_function = []

InfSOCSol(delta_file, cost_file, ...
  state_lb, state_ub, ...
  state_step, time_step, discount_rate, ...
  problem_file, options, ...
  A, b, Aeq, beq, ...
  control_lb, control_ub, ...
  user_constraint_function);
