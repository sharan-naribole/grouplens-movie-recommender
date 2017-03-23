function [ output ] = bpmf( input )
%BPMF Summary of this function goes here
%   Detailed explanation goes here


  epsilon=input.epsilon; % Learning rate 
  lambda  = input.lambda; % Regularization parameter 
  momentum=input.momentum; 
    
  probe_vec = input.probe_vec;
  train_vec = input.train_vec;
  
  
  maxepoch1=input.maxepoch1;
  
  num_feat = input.num_feat; % Rank 10 decomposition 
  maxepoch2=input.maxepoch2;
  beta=input.beta; % observation noise (precision) 
  b0_u = input.b0_u; %inv wishart param
  b0_m = input.b0_m; %inv wishart param

  subscore =input.subscore;
  
  
if(1)
restart=1;
fprintf(1,'Running Probabilistic Matrix Factorization (PMF) \n');
pmf
end

if(1)
restart=1;
fprintf(1,'\nRunning Bayesian PMF\n');
bayespmf
end

if(subscore)
%submission2
submission4
end

output.err = err; 
output.pred = pred_outbayes;

end

