clear all;
close all;
clc;

load('data_parsed_final.mat');
load('user_info_vector.mat');
movie_rating = train_ratings;

movie_means = zeros(Nmovies,1);

Nmovies = 100;

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


% - - - K-MEANS CLUSTERING ALGORITHM SECTION - - - 
Nclusters = 10;
max_iter = 500;
data_act = zscore(user_vect);
opts = statset('MaxIter',1000,'Display','off');

[idx_act,ctrs_act,sumd_act] = kmeans(data_act,Nclusters,'Options',opts,'Start','sample','replicates',max_iter,'emptyaction','singleton'); 

movie_rating_final =zeros(Nusers,Nmovies);

% - - - APPLYING RANDOM FOREST ON EACH CLUSTER - - - 

for k=1:1:Nclusters
    
    user_clu = find(idx_act == k);
    movie_rating_clu = movie_rating(user_clu,:);

    Nusrs = length(user_clu);
    %Nmovies = 3187;
    %Ntrain_compr = size(train_ratings_compressed,1);
    
    %tree_ip = zeros(Nusrs*Nmovies,size(user_vect,2) + size(movieInfo_mat,2) + Nmovies);
    tree_op = zeros(Nusrs*Nmovies,1);
    
    cnt =0;
    for j=1:1:Nmovies
        for i=1:1:Nusrs
            if(movie_rating(i,j) > 0)
                cnt = cnt + 1;
                tree_ip(cnt,:) = [user_vect(user_clu(i),:) movieInfo_mat(j,:) movie_simple_pred(user_clu(i),:)];
                tree_op(cnt) = movie_rating(i,j);               
            end
        end
    end
    tree_ip = tree_ip(1:cnt,:);
    tree_op = tree_op(1:cnt);

%     % - - - RANDOM FOREST INPUT GENERATION - - - 
%     tree_ip = zeros(Ntrain_compr,size(user_vect,2) + size(movieInfo_mat,2) + Nmovies);
%     tree_op = zeros(Ntrain_compr,1);
% 
%     for i=1:1:Ntrain_compr
%         loc_movie = ceil(train_ratings_compressed(i,1)/Nusers);
%         loc_user = rem(train_ratings_compressed(i,1),Nusers);
% 
%         if(loc_user == 0)
%             loc_user = Nusers;
%         end
% 
%         tree_ip(i,:) = [user_vect(loc_user,:) movieInfo_mat(loc_movie,:) movie_simple_pred(loc_user,:)];
%         tree_op(i) = train_ratings_compressed(i,2);
%     end

    % - - - TREEBAGGER CLASS - - - 
    Ntrees = 5;
    random_forest = TreeBagger(Ntrees,tree_ip,tree_op,'method','regression');

    % - - - MATRIX COMPLETION - - - 
    %movie_rating_final =zeros(Nusers,Nmovies);
    %predict_ip = zeros(Nusrs*Nmovies,size(user_vect,2) + size(movieInfo_mat,2) +  Nmovies);

    for j=1:1:Nmovies
        %predict_ip = zeros(Nusers,size(user_vect,2) + size(movieInfo_mat,2) + Nmovies);
        for i=1:1:Nusrs
            %loc = ((j-1)*Nmovies) + i;
            %predict_ip(i,:) = [user_vect(i,:) movieInfo_mat(j,:) movie_simple_pred(i,:)];
            temp_pred = [user_vect(user_clu(i),:) movieInfo_mat(j,:) movie_simple_pred(user_clu(i),:)];
            output = predict(random_forest,temp_pred);
            movie_rating_final(user_clu(i),j) = output;
        end

        %movie_rating_pred = predict(random_forest,predict_ip);
        %movie_rating_final(:,j) = movie_rating_pred;
    %     cnt =0;
    %     for i=1:1:Nusers
    %         cnt = cnt + 1;
    %         movie_rating_final(i,j) = movie_rating_pred(cnt);
    %     end
    end
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
