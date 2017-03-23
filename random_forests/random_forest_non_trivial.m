clear all;
close all;
clc;

load('data_parsed_final.mat');
load('user_info_vector.mat');
movie_rating = train_ratings;


Nusers = 6040;
Nmovies = 3187;
Ntrain_compr = size(train_ratings_compressed,1);

[Nsamples,Nfeatures] = size(user_vect);

movie_means = zeros(Nmovies,1);

% - - - MOVIE MEANS - - - 
for j=1:1:Nmovies
    movie_means(j) = mean(movie_rating(movie_rating(:,j) > 0,j));
end

movie_simple_pred = zeros(Nusers,Nmovies);

for j=1:1:Nmovies
    for i=1:1:Nusers
        if(movie_rating(i,j) == 0)
            movie_simple_pred(i,j) = movie_means(j) + user_effect(i);
        else
            movie_simple_pred(i,j) = movie_rating(i,j);
        end
    end
end

% - - - RANDOM FOREST INPUT GENERATION - - - 
tree_ip = zeros(Ntrain_compr,size(user_vect,2) + size(movieInfo_mat,2) + Nmovies);
tree_op = zeros(Ntrain_compr,1);

for i=1:1:Ntrain_compr
    loc_movie = ceil(train_ratings_compressed(i,1)/Nusers);
    loc_user = rem(train_ratings_compressed(i,1),Nusers);
    
    if(loc_user == 0)
        loc_user = Nusers;
    end
    
    tree_ip(i,:) = [user_vect(loc_user,:) movieInfo_mat(loc_movie,:) movie_simple_pred(loc_user,:)];
    tree_op(i) = train_ratings_compressed(i,2);
end

% - - - TREEBAGGER CLASS - - - 
Ntrees = 50;
random_forest = TreeBagger(Ntrees,tree_ip,tree_op,'method','regression');

% - - - MATRIX COMPLETION - - - 
movie_rating_final =zeros(Nusers,Nmovies);
%predict_ip = zeros(1000,size(user_vect,2) + size(movieInfo_mat,2) +  Nmovies);

for j=1:1:Nmovies
    predict_ip = zeros(Nusers,size(user_vect,2) + size(movieInfo_mat,2) + Nmovies);
    for i=1:1:Nusers
        %loc = ((j-1)*Nmovies) + i;
        %predict_ip(i,:) = [user_vect(i,:) movieInfo_mat(j,:) movie_simple_pred(i,:)];
        temp_pred = [user_vect(i,:) movieInfo_mat(j,:) movie_simple_pred(i,:)];
        output = predict(random_forest,temp_pred);
        movie_rating_final(i,j) = output;
    end
    
    %movie_rating_pred = predict(random_forest,predict_ip);
    %movie_rating_final(:,j) = movie_rating_pred;
%     cnt =0;
%     for i=1:1:Nusers
%         cnt = cnt + 1;
%         movie_rating_final(i,j) = movie_rating_pred(cnt);
%     end
end

% movie_rating_pred = predict(random_forest,predict_ip);
% cnt =0;
% for j=1:1:Nmovies
%     for i=1:1:Nusers
%         cnt = cnt + 1;
%         movie_rating_final(i,j) = movie_rating_pred(cnt);
%     end
% end

% movie_rating_final = reshape(movie_rating_pred,Nusers,Nmovies);

rmse_train = sqrt(sum((movie_rating(movie_rating > 0) - movie_rating_final(movie_rating > 0)).^2)/size(train_ratings_compressed,1))

submission
