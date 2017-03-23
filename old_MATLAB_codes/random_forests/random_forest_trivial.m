clear all;
close all;
clc;

load('data_parsed_final.mat');
load('user_info_vector.mat');

movie_rating = train_ratings;

[Nsamples,Nfeatures] = size(user_vect);

% - - - RANDOM FOREST INPUT GENERATION - - - 
tree_ip = zeros(size(train_ratings_compressed,1),size(user_vect,2) + size(movieInfo_mat,2));
tree_op = zeros(size(train_ratings_compressed,1),1);

for i=1:1:size(train_ratings_compressed,1)
    loc_movie = ceil(train_ratings_compressed(i,1)/Nusers);
    loc_user = rem(train_ratings_compressed(i,1),Nusers);
    
    if(loc_user == 0)
        loc_user = Nusers;
    end
    
    tree_ip(i,:) = [user_vect(loc_user,:) movieInfo_mat(loc_movie,:)];
    tree_op(i) = train_ratings_compressed(i,2);
end

% - - - TREEBAGGER CLASS - - - 
Ntrees = 2;
random_forest = TreeBagger(Ntrees,tree_ip,tree_op,'method','regression');

% - - - MATRIX COMPLETION - - - 
movie_rating_final =zeros(Nusers,Nmovies);
predict_ip = zeros(Nusers*Nmovies,size(user_vect,2) + size(movieInfo_mat,2));

for j=1:1:Nmovies
    for i=1:1:Nusers
        loc = ((j-1)*Nmovies) + i;
        predict_ip(loc,:) = [user_vect(i,:) movieInfo_mat(j,:)];
        %output = predict(random_forest,predict_ip(loc,:))
        %movie_rating_final(i,j) = output;
    end
end

movie_rating_pred = predict(random_forest,predict_ip);
% cnt =0;
% for j=1:1:Nmovies
%     for i=1:1:Nusers
%         cnt = cnt + 1;
%         movie_rating_final(i,j) = movie_rating_pred(cnt);
%     end
% end

movie_rating_final = reshape(movie_rating_pred,Nusers,Nmovies);

rmse_train = sqrt(sum((movie_rating(movie_rating > 0) - movie_rating_final(movie_rating > 0)).^2)/size(train_ratings_compressed,1))

%submission
        
        
        

    
    
