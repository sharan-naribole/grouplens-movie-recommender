clear all;
close all;
clc;

load('data_parsed_simple.mat');

movie_rating = train_ratings;

user_sim = zeros(Nusers,Nusers);
user_common = zeros(Nusers,Nusers);

for k=1:1:Nmovies
    for i=1:1:Nusers
        for j=1:1:Nmovies
            if((movie_rating(i,k)~= 0) && (movie_rating(j,k)~=0))
                user_sim(i,j) = user_sim(i,j) + abs(movie_rating(i,k) - movie_rating(j,k));
                user_common(i,j) = user_common(i,j) + 1;
            end
        end
    end
end

save('user_sim_common.mat','user_sim','user_common');

% - - - USER CORRELATION SCORE MATRIX ---
user_corr_mat = zeros(Nusers,Nusers);
for i=1:1:Nusers
    for j=1:1:Nusers
      if(user_common(i,j) > 0)  
        user_corr_mat(i,j) = user_common(i,j)/user_sim(i,j);
      end
    end
    b = user_corr_mat(i,:);
    max_nonInf = max((find(b ~= Inf)));
    
    for j = find(b == Inf)
        user_corr_mat(i,j) = max_nonInf + user_common(i,j);
    end
end

save('user_corr.mat','user_corr_mat');

% --- PRIORITISED LIST GENERATION - - - 
user_sorted_list = zeros(Nusers,Nusers);

for i=1:1:Nusers  
    corr_tmp = user_corr_mat(i,:);
    k=1;  
    while(k <= Nusers)
        pos = find(corr_tmp == max(corr_tmp));
        pos = pos(1);
        user_sorted_list(i,k) = pos;
        corr_tmp(pos) = -1;
        k = k + 1;
    end
end

save('user_sorted_list.mat','user_sorted_list');

% - - - KNN SELECTION - - - 

k_knn = 9;

movie_rating_final = zeros(Nusers,Nmovies);

for j=1:1:Nmovies
    for i=1:1:Nusers
        
        % - - - FINDING THE TOP K_KNN USERS - - - 
        cnt =0;
        top_loc = zeros(k_knn,1);
        for p=1:Nusers
            loc = user_sorted_list(p);
            if((loc ~=i) && (movie_rating(loc) > 0))
                cnt = cnt + 1;
                top_loc(cnt) = loc;
            end
            if(cnt == k_knn)
                break;
            end
        end
        
        % - - - WEIGHTED MEAN OF RATINGS - - - 
        rating_num =0;
        rating_den = 0;
        for k=1:1:k_knn
               loc = top_loc(k);
               rating_num = rating_num + (user_corr_mat(i,loc)*movie_rating(loc,j));
               rating_den = rating_den + user_corr_mat(i,loc);
        end
        movie_rating_final(i,j) = max(1,min(rating_num/rating_den,5));
    end
end

save('movie_final_rating.mat','movie_rating_final');

% - - - MOVIE RATING IN OUTPUT FORMAT - - - 

filename = ['submission' date '.csv'];
fid = fopen(filename,'wt');

submission_rating = zeros(Nusers*Nmovies,2);
cnt =0;

fprintf(fid,'%s,%s\n','ID','Rating');

for j=1:1:Nmovies
    for i=1:1:Nusers
        cnt =  cnt + 1;
        fprintf(fid,'%s,%s\n',num2str(uniq_id(cnt)),num2str(movie_rating_final(i,j)));
    end
end



        


