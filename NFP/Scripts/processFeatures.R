require('plyr');

All_Features = read.csv(file='../Features/201410/All_True_DaysBack_7_Features.txt',sep='\t');

names = names(All_Features);

names[1] = 'candidate';

colnames(All_Features) = names;

Features_all = subset(All_Features,candidate=='all',select=-c(candidate));
Features_allold = subset(All_Features,candidate=='all old',select=-c(candidate));
Features_opening = subset(All_Features,candidate=='job opening',select=-c(candidate));
Features_posting = subset(All_Features,candidate=='job posting',select=-c(candidate));
Features_opportunity = subset(All_Features,candidate=='job opportunity',select=-c(candidate));
Features_hiring = subset(All_Features,candidate=='we are hiring',select=-c(candidate));
Features_hashtags = subset(All_Features,candidate=='hashtags',select=-c(candidate));

names = names(Features_all);
names = paste(names,'_all',sep='');
names[1]='MonthId';
colnames(Features_all)<-names;

names = names(Features_allold);
names = paste(names,'_allold',sep='');
names[1]='MonthId';
colnames(Features_allold)<-names;

names = names(Features_opening);
names = paste(names,'_opening',sep='');
names[1]='MonthId';
colnames(Features_opening)<-names;

names = names(Features_posting);
names = paste(names,'_posting',sep='');
names[1]='MonthId';
colnames(Features_posting)<-names;

names = names(Features_opportunity);
names = paste(names,'_opportunity',sep='');
names[1]='MonthId';
colnames(Features_opportunity)<-names;

names = names(Features_hiring);
names = paste(names,'_hiring',sep='');
names[1]='MonthId';
colnames(Features_hiring)<-names;

names = names(Features_hashtags);
names = paste(names,'_hashtags',sep='');
names[1]='MonthId';
colnames(Features_hashtags)<-names;

# Features_all = data.frame(Features_all);
# Features_allold = data.frame(Features_allold);
# Features_opening = data.frame(Features_opening);
# Features_posting = data.frame(Features_posting);
# Features_opportunity = data.frame(Features_opportunity);
# Features_hiring = data.frame(Features_hiring);
# Features_hashtags = data.frame(Features_hashtags);

Features_Full = join_all(list(Features_all,Features_allold,Features_opening,Features_posting,Features_opportunity,Features_hiring,Features_hashtags),by='MonthId',type='full');

write.csv(Features_Full, file='../Features/201410/DaysBack_7_Features_All_candiate_seperated.csv');