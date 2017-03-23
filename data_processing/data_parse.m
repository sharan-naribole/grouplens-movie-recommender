clear all;
close all;
clc;

% - - - DATA PARSING - - - 

% - - - COMPRESSED TRAIN RATINGS - - - 
train_ratings_compressed = csvread('Data/train_ratings_compressed.csv',1,0);

% - - - TRAIN RATINGS - - - 
fid = fopen('Data/train_ratings.csv');
format ='';
for i=1:1:3187
    format = [format ' %s'];
end
train_ratings_txtscn= textscan(fid,format,'delimiter',',');
fclose(fid);

Nusers = length(train_ratings_txtscn{1}) - 1;
Nmovies = size(train_ratings_txtscn,2);
train_ratings= zeros(Nusers,Nmovies); % ID, User ID, Movie ID 

for j=1:1:Nmovies
    for i=1:1:Nusers
        if(strcmp(train_ratings_txtscn{j}{i+1},'NA') == 0)
          train_ratings(i,j) = str2num(train_ratings_txtscn{j}{i+1});
        else
            train_ratings(i,j) = 0;
        end
    end
end

% - - - USER INFO - - - 
fid = fopen('Data/userInfo.csv');
userInfo = textscan(fid,'%s %s %s %s','delimiter',',');
fclose(fid);

userInfo_mat = zeros(Nusers,3);

for i=1:1:Nusers
    if(strcmp(userInfo{2}{i+1},'M'))
        userInfo_mat(i,1) = 1;
    end
    
    for j=2:1:3
      userInfo_mat(i,j) = str2num(userInfo{j+1}{i+1});
    end
    
end

% - - - MOVIE INFO - - -
fid = fopen('Data/movieInfo.csv');
format ='';
for i=1:1:8
    format = [format ' %s'];
end
movieInfo = textscan(fid,format,'delimiter',',');
fclose(fid);

movieInfo_mat = zeros(Nmovies,6);

for i=1:1:Nmovies
    for j=1:1:6
      movieInfo_mat(i,j) = str2num(movieInfo{j+2}{i+1});
    end 
end

uniq_id=csvread('Data/ids_movielens.csv',1,0);

save('data_parsed_simple.mat','train_ratings_compressed','train_ratings','userInfo','userInfo_mat','movieInfo','movieInfo_mat','uniq_id','Nusers','Nmovies');

