function [output,Wc_k] = within_cluster_diss(data,cluster_idx)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

idx = cluster_idx;
[Nsamples,Nfeatures] = size(data);

Nclusters = length(unique(idx));
Wc_k = zeros(Nclusters,1);

for k=1:1:Nclusters
    locs = find(idx == k);
    k1 = pdist(data(locs,:));
    k2 = k1.^2;
    Wc_k(k) = sum(k2);
%     dat = data(locs,:);
%     order = combnk(locs,2);
%     Ncombs = size(order,1);
% 
%     for i=1:1:Ncombs
%         i1 = order(i,1);
%         i2 = order(i,2);
%         Wc_k(k) = Wc_k(k) + sum((data(i1,:) - data(i2,:)).^2);
%     end
end

output = sum(Wc_k);

end

