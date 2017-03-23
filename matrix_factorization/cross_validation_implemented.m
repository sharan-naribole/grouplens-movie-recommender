  clear all
  close all
  
  load('data_parsed.mat');
  
  %General params
  options.subscore=0;
  options.num_feat = 10; % Rank 10 decomposition 4-20
  options.maxepoch1=50; %50 initial mat fact(PMF) step (dont over fit)
  options.maxepoch2=100; %200 bayes (as big as possible) 

  
  %params for PMF (dont really matter)
  options.epsilon=200; % Learning rate (more important,resolution)
  options.lambda  = 0.01; % Regularization parameter 
  options.momentum=0.8; %momentum thingy
  options.N=10;
  
  %Params for Bayesian PMF (important)
  options.beta=2; % observation noise (precision) 1-3
  options.b0_u = 2; % inverse Wishart param 1-3
  options.b0_m = 2; % inverse Wishart param 1-3
  
  
%   load moviedata
%   options.probe_vec = probe_vec;
%   options.train_vec = train_vec;
%   tic
%   out = bpmf(options);
 %  toc
 
%  % - - - CROSS-VALIDATION - - - 
%  Nfolds = 5;
%  cv_ind = crossvalind('KFold',1:size(train_ratings_compressed,1),Nfolds);
 
%  total_train_vec = zeros(size(train_ratings_compressed,1),3); 
% 
%  for i = 1:size(train_ratings_compressed,1)
%     curid = train_ratings_compressed(i,1);
%     total_train_vec(i,1)=uniq_id(curid,2);
%     total_train_vec(i,2)=uniq_id(curid,3);
%     total_train_vec(i,3)=train_ratings_compressed(i,2);
%  end

 % - - - VARYING THE NUMBER OF FEATURES opt.num_feat - - - 
 % - - - FROM 3 TO 15 - - -  
 sweep_var = 3:1:15;
 cv_err_avg = zeros(length(sweep_var),1);
 
 for i = 1:1:length(sweep_var)
     fprintf(1,'NUMBER OF FEATURES: %d\n',sweep_var(i)); 
     options.num_feat = sweep_var(i);
     cv_err = zeros(Nfolds,1);
     
     for j=1:1:Nfolds
         options.train_vec = total_train_vec(cv_ind ~= j,:);
         options.probe_vec = total_train_vec(cv_ind == j,:);
         
         out = bpmf(options);
         cv_err(j) = out.err;
     end
     cv_err_avg(i) = mean(cv_err);
 end
         
         
     
 