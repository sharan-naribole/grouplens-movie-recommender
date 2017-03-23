clear all;
close all;
clc;

load('data_parsed_final.mat');
load('user_info_vector.mat');

[Nsamples,Nfeatures] = size(user_vect);

K_max = 15;
max_iter = 20;

Wc_act = zeros(K_max,1);%Mean, Std
Wc_uni = zeros(K_max,2);%Mean, Std

feature_min = min(user_vect);
feature_max = max(user_vect);

% [coeff,score_act,latent] = princomp(zscore(user_vect));
% 
% data_act = score_act(:,1:6);

data_act = zscore(user_vect);

for k=1:1:K_max
    k
    Wc_uni_iter= zeros(max_iter,1);
    opts = statset('MaxIter',1000,'Display','off');

    [idx_act,ctrs_act,sumd_act] = kmeans(data_act,k,'Options',opts,'Start','sample','replicates',max_iter,'emptyaction','singleton');    
    
    Wc_act(k) = sum(sumd_act);
    
    for j=1:1:max_iter
       
       data_uni = zeros(Nsamples,Nfeatures);
       for i=1:1:Nfeatures
           data_uni(:,i) = feature_min(i) + (feature_max(i) - feature_min(i))*rand(Nsamples,1);
       end
       
       data_uni = zscore(data_uni);
       
       [idx_uni,ctrs_uni,sumd_uni] = kmeans(data_uni,k,'Options',opts,'Start','sample','emptyaction','singleton');
       
       Wc_uni_iter(j) = sum(sumd_uni);
    end
    
    Wc_uni(k,1) = mean(Wc_uni_iter);
    Wc_uni(k,2) = std(Wc_uni_iter);
    
end

logWc_act = log(Wc_act);
logWc_uni = log(Wc_uni(:,1));

plot(logWc_act,'g');
hold on
plot(logWc_uni,'b');


Nclusters = 1:1:K_max;

plot(Nclusters,Wc_act - Wc_act(1),'g');
hold on
plot(Nclusters,Wc_uni(:,1) - Wc_uni(1,1),'b');

y = Wc_uni(:,1) - Wc_uni(1,1) - Wc_act + Wc_act(1);
E = Wc_uni(:,2);
figure
errorbar(y,E)

