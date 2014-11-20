require('plyr');

All_Features = read.csv(file='../Features/201411/All_True_Features.txt',sep='\t');

names = names(All_Features);

names[1] = 'candidate';

colnames(All_Features) = names;

candidates = list(axed="axed",canned="canned",downsized="downsized",
	outsourced="outsourced",pinkslip="pink slip",lostjob="lost job",fired="fired",beenfired="been fired",
	laidoff="laid off",unemployment="unemployment");

# candidates = list(all="all", all_old="all old", hashtags="hashtags",
# 	job_opening="job opening", job_opportunity="job opportunity", job_posting="job posting", we_are_hiring="we are hiring");

Features = list();

for(candidate_name in names(candidates))
{
	Features[[candidate_name]] = subset(All_Features,candidate==candidates[[candidate_name]],select=-c(candidate));
}

for(candidate_name in names(Features))
{
	feature_names = names(Features[[candidate_name]]);
	feature_names = paste(feature_names,candidate_name,sep='_');
	feature_names[1] = 'WeekId';
	colnames(Features[[candidate_name]]) = feature_names;
}

Features_Full = join_all(Features,by='WeekId',type='full');

Features_Full$WeekId = strptime(Features_Full$WeekId,"%m/%d/%Y");

Features_Full = Features_Full[order(Features_Full$WeekId),];

write.csv(Features_Full, file='../Features/201411/Features_All_candiate_seperated_Absolute.csv',row.names=F);