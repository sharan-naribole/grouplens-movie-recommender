clear all;
close all;
clc;

load('data_parsed_final.mat');
load('user_info_vector.mat');

[Nsamples,Nfeatures] = size(user_vect);

K_max = 15;
max_iter = 1;

Wc_act = zeros(K_max,1);%Mean, Std
Wc_uni = zeros(K_max,2);%Mean, Std

feature_min = min(user_vect);
feature_max = max(user_vect);

% [coeff,score_act,latent] = princomp(zscore(user_vect));
% 
% data_act = score_act(:,1:6);

data_act = zscore(user_vect);

k1 = pdist(data_act);
gili = sort(k1);
thresh = gili(floor(0.5*length(gili)));
k2 = k1 < thresh;
adj_act = squareform(k2);

%data_act = zscore(user_vect);

for k=1:1:K_max
    k
    Wc_uni_iter= zeros(max_iter,1);
    %opts = statset('MaxIter',1000,'Display','off');

    %[idx_act,ctrs_act,sumd_act] = kmeans(data_act,k,'Options',opts,'Start','sample','replicates',max_iter,'emptyaction','singleton'); 
    
    C_act = SpectralClustering(adj_act,k,2);
    
    idx_act = zeros(Nsamples,1);
    for i=1:1:Nsamples
        for j=1:1:k
            if(C_act(i,j) == 1)
                idx_act(i) = j;
                break;
            end
        end
    end
    
    %Wc_act(k,1) = sum(sumd_act);
    
    wc_out = within_cluster_diss(data_act,idx_act);
    Wc_act(k) = wc_out;
    
    for j=1:1:max_iter
       
       data_uni = zeros(Nsamples,Nfeatures);
       for i=1:1:Nfeatures
           data_uni(:,i) = feature_min(i) + (feature_max(i) - feature_min(i))*rand(Nsamples,1);
       end
       
       data_uni = zscore(data_uni);
       
       ka = pdist(data_uni);
       gili = sort(ka);
       thresh = gili(floor(0.5*length(gili)));
       kb = ka < thresh;
       adj_uni = squareform(kb);
       
       %[idx_uni,ctrs_uni,sumd_uni] = kmeans(adj_uni,k,'Options',opts,'Start','sample','emptyaction','singleton');
       
       C_uni = SpectralClustering(adj_uni,k,2);    
       
       idx_uni = zeros(Nsamples,1);
        for i=1:1:Nsamples
            for j=1:1:k
                if(C_uni(i,j) == 1)
                    idx_uni(i) = j;
                    break;
                end
            end
        end      
       
       wc_out = within_cluster_diss(data_uni,idx_uni);
       %Wc_uni_iter(j) = sum(sumd_uni);
       Wc_uni_iter(j) = wc_out;
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

