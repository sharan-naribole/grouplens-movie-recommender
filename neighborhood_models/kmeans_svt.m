clear all;
close all;
clc;

load('data_parsed_final.mat');
load('user_info_vector.mat');

movie_rating = train_ratings;

[Nsamples,Nfeatures] = size(user_vect);

% - - - K-MEANS CLUSTERING ALGORITHM SECTION - - - 
Nclusters = 10;
max_iter = 500;
data_act = zscore(user_vect);
opts = statset('MaxIter',1000,'Display','off');

[idx_act,ctrs_act,sumd_act] = kmeans(data_act,Nclusters,'Options',opts,'Start','sample','replicates',max_iter,'emptyaction','singleton'); 

% - - - SVT ON EACH CLUSTER - - - 
tol = 1e-8;
%rank = [];
maxit = 5000;

movie_rating_final =zeros(Nusers,Nmovies);

for k=1:1:Nclusters
   k
   rank = [];  
    
   users_clu = find(idx_act == k);
   movie_rating_clu = movie_rating(users_clu,:);
    
   [X S Y dist] = OptSpace(movie_rating_clu,rank,maxit,tol); 
    movie_rating_final(users_clu,:) = X*S*Y'; 
    
end


rmse_train = sqrt(sum((movie_rating(movie_rating > 0) - movie_rating_final(movie_rating > 0)).^2)/size(train_ratings_compressed,1))

submission
    
    


