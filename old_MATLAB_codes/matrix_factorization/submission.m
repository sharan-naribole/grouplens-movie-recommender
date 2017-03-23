%load('movie_final_rating.mat');
% submission_rating = zeros(Nusers,Nmovies);
% 
% for j=1:1:Nmovies
%     for i=1:1:Nusers
%         if(train_ratings(i,j) > 0)
%             submission_rating(i,j) = train_ratings(i,j);
%         else
%             submission_rating(i,j) = movie_rating_final(i,j);
%         end
%     end
% end
% 
% 
% trainres = movie_rating_final(puncidx); 
% truth = train_ratings(puncidx); 
% 
% rmse_punc =sqrt(sum((trainres-truth).^2)/size(truth,1))

% - - - MOVIE RATING IN OUTPUT FORMAT - - - 
load output_bayes
load data_parsed
filename = ['submission' date '_PMF.csv'];
fid = fopen(filename,'wt');

% - - - CHANGING THE KNOWN RATINGS BACK TO THEIR ORIGINAL - - - 
Nuniq = size(pred_outbayes,1);
submission_rating = zeros(Nusers,Nmovies);
uniq_cnt =0;
for j=1:1:Nmovies
   for i=1:1:Nusers
       uniq_cnt = uniq_cnt + 1;
        if(train_ratings(i,j) > 0)
            submission_rating(i,j) = train_ratings(i,j);
        else
            submission_rating(i,j) = pred_outbayes(uniq_cnt,3);
        end
   end
end       

cnt =0;

fprintf(fid,'%s,%s\n','ID','Rating');

y = [uniq_id(1:19249480); submission_rating(1:19249480)];

fprintf(fid,'%d,%.2f\n',y);
fclose(fid);

