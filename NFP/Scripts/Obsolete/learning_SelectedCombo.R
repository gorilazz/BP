source('../../Utility/utility.R');
source('../../Utility/learning_utility.R');
source('../../Utility/automation_utility.R');

lambda = 0.0;
aggregationType = c("median","mean");
labelType = "unrevised";
randomSample = FALSE;
numFeatures = 2;

# path initialization
path_featureAR = "../Features/AR/ARDelta_Full.csv";
path_featureSocial = "../Features/201410/DaysBack_7_Features_All_candiate_seperated_AbsoluteFull.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_IJC = "../Features/IJC/IJC_3_weeks.csv";
path_label = "../GroundTruth/NonFarmPayrollHistoryDelta.csv"
path_outMetric = paste(paste("../Model/201410/RandomCombo/experiments_AR_Social_Sample_2", labelType, sep="_"),".csv",sep="");

# read in data
featureARFull = read.csv(file=path_featureAR, head=TRUE, sep=",");
featureARFull$Date = as.character(featureARFull$Date);
for(i in 1:nrow(featureARFull))
{
	featureARFull[i,'Date'] = DateToMonthTag(featureARFull[i,'Date']);
}

featureSocialFull = read.csv(file=path_featureSocial, head=TRUE, sep=",");

consensusFull = read.csv(file=path_consensus, head=TRUE, sep=",");
consensusFull$Date = as.character(consensusFull$Date);
for(i in 1:nrow(consensusFull))
{
	consensusFull[i,'Date'] = DateToMonthTag(consensusFull[i,'Date']);
}

IJCFull = read.csv(file=path_IJC, head=TRUE, sep=",");
IJCFull$Date = as.character(IJCFull$Date);
for(i in 1:nrow(IJCFull))
{
	IJCFull[i,'Date'] = DateToMonthTag(IJCFull[i,'Date']);
}

labelFull = read.csv(file=path_label, head=TRUE, sep=",");
labelFull$Date = as.character(labelFull$Date);
for(i in 1:nrow(labelFull))
{
	labelFull[i,'Date'] = DateToMonthTag(labelFull[i,'Date']);
}

# get the data
data_start = "201103";		# earliest data to use	
data_end = "201409";	# latest data to use for testing

# subset the data frames to get the right segments
start_featureAR = which(featureARFull$Date==data_start)[1];
end_featureAR = which(featureARFull$Date==data_end)[1];
start_featureSocial = which(featureSocialFull$Date==data_start)[1];
end_featureSocial = which(featureSocialFull$Date==data_end)[1];
start_featureIJC = which(IJCFull$Date==data_start)[1];
end_featureIJC = which(IJCFull$Date==data_end)[1];
start_consensus = which(consensusFull$Date==data_start)[1];
end_consensus = which(consensusFull$Date==data_end)[1];
start_label = which(labelFull$Date==data_start)[1];
end_label = which(labelFull$Date==data_end)[1];


featureAR = featureARFull[start_featureAR:end_featureAR,];
featureSocial = featureSocialFull[start_featureSocial:end_featureSocial,];
featureIJC = IJCFull[start_featureIJC:end_featureIJC,];
consensus = consensusFull[start_consensus:end_consensus,];		#consensus to be used for testing

if(labelType=='unrevised')
{
	label = labelFull[start_label:end_label,]$Delta_Unrevised;
}else
{
	label = labelFull[start_label:end_label,]$Delta_Revised;
}

# merge AR, social, consensus, IJC features to get the full feature set
featureFull = merge(featureAR, featureSocial, by="Date");
featureFull = merge(featureFull, consensus, by="Date");
featureFull = merge(featureFull, featureIJC, by="Date");

# prepare feature combos
# features = list(c('IJC', 'Consensus1', 'NumVerifiedTweets_Week2_opportunity_AbsoluteDelta', 'NumPopularTweets_Week1_posting_AbsoluteDelta', 'NumPopularTweets_Week2_all_AbsoluteDelta', 'NumVerifiedTweets_Week1_posting_AbsoluteDelta', 'NumVerifiedTweets_Month1_all_AbsoluteDelta'),
# 	c('IJC', 'Consensus1', 'NumVerifiedTweets_Week2_opportunity_AbsoluteDelta', 'NumPopularTweets_Week2_all_AbsoluteDelta', 'NumVerifiedTweets_Week1_posting_AbsoluteDelta'),
# 	c('IJC', 'Consensus1'),
# 	c('NumVerifiedTweets_Week2_opportunity_AbsoluteDelta', 'NumPopularTweets_Week1_posting_AbsoluteDelta', 'NumPopularTweets_Week2_all_AbsoluteDelta', 'NumVerifiedTweets_Week1_posting_AbsoluteDelta', 'NumVerifiedTweets_Month1_all_AbsoluteDelta'),
# 	c('IJC', 'NumVerifiedTweets_Week2_opportunity_AbsoluteDelta'),
# 	c('IJC', 'NumVerifiedTweets_Week2_opportunity_AbsoluteDelta', 'NumPopularTweets_Week2_all_AbsoluteDelta', 'NumVerifiedTweets_Week1_posting_AbsoluteDelta'),
# 	c('Consensus1', 'NumVerifiedTweets_Week2_opportunity_AbsoluteDelta'),
# 	c('Consensus1', 'NumVerifiedTweets_Week2_opportunity_AbsoluteDelta', 'NumPopularTweets_Week2_all_AbsoluteDelta', 'NumVerifiedTweets_Week1_posting_AbsoluteDelta'));

features = list(c('IJC','Consensus1','NumVerifiedTweets_Week2_opportunity_AbsoluteDelta',
	'NumPopularTweets_Week2_all_AbsoluteDelta','NumVerifiedTweets_Week1_posting_AbsoluteDelta', 
	'NumVerifiedTweets_Month1_all_AbsoluteDelta','NumPopularTweets_Week1_posting_AbsoluteDelta'));


# merge to get all the feature combos
featureFullCombos = list();
if(randomSample==FALSE)
{
	featureFullCombos = features;
} else{
	featureFullCombos = GetAllCombinations(features[[1]], numFeatures);
}

# options(warn=2)

# training the model to get the full result
metricList = CompileTrainingResults_RandomSampling(featureFull,featureFullCombos,label,consensus$Consensus1,lambda,directionalConstraint=TRUE,aggregationType);

for(type in aggregationType)
{
	path_outMetric_type = gsub(".csv", paste(paste("_",type,sep=""),".csv",sep=""), path_outMetric);
	write.csv(metricList[[type]], file = path_outMetric_type);
}