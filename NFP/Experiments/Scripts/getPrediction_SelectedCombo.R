# Get predictions for each individual model
rm(list=ls());
start = Sys.time();

source('../../Utility/NFP_utility.R');
source('../../Utility/utility.R');
source('../../Utility/learning_utility.R');
source('../../Utility/automation_utility.R');

lambda = 0.0;
labelType = "unrevised";
randomSample = FALSE;
numFeatures = 3;

# path initialization
path_featureAR = "../Features/AR/ARDelta_Full.csv";
path_featureSocial = "../Features/201412/DaysBack_7_Features_All_candidate_seperated_AbsoluteFull.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_IJC = "../Features/IJC/IJC_3_weeks.csv";
path_label = "../GroundTruth/NonFarmPayrollHistoryDelta.csv";
path_outDir = "../Prediction/201412/SingleCombo/forwardSelection/DWin";
if(!file.exists(path_outDir))
{
	dir.create(path_outDir);
}

# featureNames = list(
# 	c('IJC', 'NumDistinctUsers_Week2_hiring_Absolute','NumTweets_Month1_hashtags_AbsoluteDelta','NumPopularTweets_Week1_all_AbsoluteDelta', 'NumDistinctTweets_Month2_hiring_AbsoluteDelta',
# 		'NumTweets_Week1_opening_Absolute', 'NumPopularTweets_Week1_allold_AbsoluteDelta', 'NumVerifiedTweets_Month1_allold_Absolute', 'NumPopularTweets_Week2_hiring_Absolute', 'NumTweets_Week2_hiring_AbsoluteDelta'));

featureNames = list(
	c('NumDistinctTweets_Month1_posting_Absolute', 'NumDistinctTweets_Month1_posting_AbsoluteDelta','NumTweets_Month1_opportunity_AbsoluteDelta','NumTweets_Month2_hashtags_Absolute', 'NumTweets_Month1_opportunity_Absolute',
		'NumPopularTweets_Week2_posting_AbsoluteDelta', 'NumTweets_Week1_hashtags_Absolute', 'NumVerifiedTweets_Week1_allold_AbsoluteDelta', 'NumTweets_Week2_hashtags_AbsoluteDelta', 'NumVerifiedTweets_Month2_opening_AbsoluteDelta'));

# featureNames = list(
# 	c('Consensus1', 'NumDistinctUsers_Month1_posting_AbsoluteDelta','NumDistinctUsers_Month1_posting_Absolute','NumVerifiedTweets_Month1_posting_AbsoluteDelta', 'NumVerifiedTweets_Month1_posting_Absolute'),
# 	c('Consensus1', 'NumDistinctUsers_Month1_posting_AbsoluteDelta','NumDistinctUsers_Month1_posting_Absolute','NumVerifiedTweets_Month1_posting_AbsoluteDelta'),
# 	c('Consensus1', 'NumDistinctUsers_Month1_posting_AbsoluteDelta','NumDistinctUsers_Month1_posting_Absolute'),
# 	c('Consensus1', 'NumDistinctUsers_Month1_posting_AbsoluteDelta'),
# 	c('Consensus1'));

# featureNames = list(
# 	c('IJC', 'Consensus1', 'NumDistinctUsers_Month1_posting_AbsoluteDelta','NumDistinctUsers_Month1_posting_Absolute','NumVerifiedTweets_Month1_posting_AbsoluteDelta', 'NumVerifiedTweets_Month1_posting_Absolute'));

for(i in 1:10)
{
file_outPrediction = paste(paste(paste("Model",i,sep="_"), labelType, sep="_"),"Predictions.csv",sep="_");
path_outPrediction = file.path(path_outDir,file_outPrediction);

features = list(featureNames[[1]][1:(11-i)]);

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
data_end = "201412";	# latest data to use for testing

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


# merge to get all the feature combos
featureFullCombos = list();
if(randomSample==FALSE)
{
	featureFullCombos = features;
} else{
	featureFullCombos = GetAllCombinations(features[[1]], numFeatures);
}


# options(warn=2)

# training the model to get the full predictions
predictionWindow = 24;
predictionDates = consensus$Date[(nrow(consensus)-predictionWindow+1):nrow(consensus)];

predictionResult = ComputePredictions_RollingTesting(featureFull,featureFullCombos,label,consensus$Consensus1,predictionWindow,predictionDates,lambda,directionalConstraint=TRUE);
write.csv(predictionResult, file = path_outPrediction);
}


end = Sys.time();

print(end-start);