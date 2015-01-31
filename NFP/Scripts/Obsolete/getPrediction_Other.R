# Get predictions for any other model (without social features)
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
path_feature = "../Features/AR/ARDelta_Full.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_label = "../GroundTruth/NonFarmPayrollHistoryDelta.csv";
path_outDir = "../Prediction/201411/AR";
if(!file.exists(path_outDir))
{
	dir.create(path_outDir);
}
file_outPrediction = "AR_Predictions.csv";
path_outPrediction = file.path(path_outDir,file_outPrediction);

featureFull = read.csv(file=path_feature, head=TRUE, sep=",");
featureFull$Date = as.character(featureFull$Date);
for(i in 1:nrow(featureFull))
{
	featureFull[i,'Date'] = DateToMonthTag(featureFull[i,'Date']);
}

consensusFull = read.csv(file=path_consensus, head=TRUE, sep=",");
consensusFull$Date = as.character(consensusFull$Date);
for(i in 1:nrow(consensusFull))
{
	consensusFull[i,'Date'] = DateToMonthTag(consensusFull[i,'Date']);
}

labelFull = read.csv(file=path_label, head=TRUE, sep=",");
labelFull$Date = as.character(labelFull$Date);
for(i in 1:nrow(labelFull))
{
	labelFull[i,'Date'] = DateToMonthTag(labelFull[i,'Date']);
}

# get the data
data_start = "200403";		# earliest data to use	
data_end = "201411";	# latest data to use for testing

# subset the data frames to get the right segments
start_feature = which(featureFull$Date==data_start)[1];
end_feature = which(featureFull$Date==data_end)[1];
start_consensus = which(consensusFull$Date==data_start)[1];
end_consensus = which(consensusFull$Date==data_end)[1];
start_label = which(labelFull$Date==data_start)[1];
end_label = which(labelFull$Date==data_end)[1];


feature = featureFull[start_feature:end_feature,];
consensus = consensusFull[1:end_consensus,];		#consensus to be used for testing
if(labelType=='unrevised')
{
	label = labelFull[start_label:end_label,]$Delta_Unrevised;
}else
{
	label = labelFull[start_label:end_label,]$Delta_Revised;
}

label_training = feature$Label;

# features = list(c('IJC','Consensus1','NumVerifiedTweets_Week2_opportunity_AbsoluteDelta',
# 	'NumPopularTweets_Week2_all_AbsoluteDelta','NumVerifiedTweets_Week1_posting_AbsoluteDelta', 
# 	'NumVerifiedTweets_Month1_all_AbsoluteDelta','NumPopularTweets_Week1_posting_AbsoluteDelta'));

features = list(names(feature)[-c(1,2)]);

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
predictionWindow = 95;
predictionDates = consensus$Date[(nrow(consensus)-predictionWindow+1):nrow(consensus)];

predictionResult = ComputePredictions_RollingTesting(featureFull,featureFullCombos,label_training,consensus$Consensus1,predictionWindow,predictionDates,lambda,directionalConstraint=FALSE);
write.csv(predictionResult, file = path_outPrediction);

end = Sys.time();

print(end-start);