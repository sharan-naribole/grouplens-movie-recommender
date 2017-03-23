list = find(train_ratings);
train_punc = train_ratings; 
sizelist = size(list,1);
numpunc = floor(size(list,1)*0.1);%puncture 10% of rated movies 
r = randperm(sizelist); 
puncidx = list(r(1:numpunc)); 
train_punc(puncidx) = 0;


size(find(train_ratings),1)-size(find(train_punc),1);