# Get predictions for each individual model
rm(list=ls());
start = Sys.time();

source('../../Utility/NFP_utility.R');
source('../../Utility/utility.R');
source('../../Utility/learning_utility.R');
source('../../Utility/automation_utility.R');

lambda = 0.0;
algo = "lr";
randomSample = FALSE;
numFeatures = 3;

# path initialization
path_featureAR = "../Features/AR/ARDelta_Full.csv";
path_featureSocial = "../Features/201501/DaysBack_7_Features_All_candidate_seperated_AbsoluteFull.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_IJC = "../Features/IJC/IJC_Monthly.csv";
path_sentiment = "../Features/Sentiment/Sentiment.csv";
path_label = "../GroundTruth/NonFarmPayrollHistoryDelta.csv";
path_outDir = "../Prediction/201501/SingleCombo/Test/";
if(!file.exists(path_outDir))
{
	dir.create(path_outDir, recursive=TRUE);
}

featureNames = list(
	c('Consensus1', 'Consensus2', 'IJC', 'NumDistinctUsers_Month1_posting_AD', 'NumVerifiedTweets_Month1_posting_AD'),
	c('Consensus1', 'Consensus2', 'IJC'),
	c('Consensus1', 'Consensus2'));


for(i in 1:3)
{
file_outPrediction = paste(paste(paste("Model",i,sep="_"), algo, sep="_"),"Predictions.csv",sep="_");
path_outPrediction = file.path(path_outDir,file_outPrediction);

features = list(featureNames[[i]]);

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

sentimentFull = read.csv(file=path_sentiment, head=TRUE, sep=",");
sentimentFull$Date = as.character(sentimentFull$Date);
for(i in 1:nrow(sentimentFull))
{
	sentimentFull[i,'Date'] = DateToMonthTag(sentimentFull[i,'Date']);
}

labelFull = read.csv(file=path_label, head=TRUE, sep=",");
labelFull$Date = as.character(labelFull$Date);
for(i in 1:nrow(labelFull))
{
	labelFull[i,'Date'] = DateToMonthTag(labelFull[i,'Date']);
}

# get the data
data_start = "201102";		# earliest data to use	
data_end = "201501";	# latest data to use for testing

# subset the data frames to get the right segments
start_featureAR = which(featureARFull$Date==data_start)[1];
end_featureAR = which(featureARFull$Date==data_end)[1];
start_featureSocial = which(featureSocialFull$Date==data_start)[1];
end_featureSocial = which(featureSocialFull$Date==data_end)[1];
start_featureIJC = which(IJCFull$Date==data_start)[1];
end_featureIJC = which(IJCFull$Date==data_end)[1];
start_sentiment = which(sentimentFull$Date==data_start)[1];
end_sentiment = which(sentimentFull$Date==data_end)[1];
start_consensus = which(consensusFull$Date==data_start)[1];
end_consensus = which(consensusFull$Date==data_end)[1];
start_label = which(labelFull$Date==data_start)[1];
end_label = which(labelFull$Date==data_end)[1];


featureAR = featureARFull[start_featureAR:end_featureAR,];
featureSocial = featureSocialFull[start_featureSocial:end_featureSocial,];
featureIJC = IJCFull[start_featureIJC:end_featureIJC,];
sentiment = sentimentFull[start_sentiment:end_sentiment,];
consensus = consensusFull[start_consensus:end_consensus,];		#consensus to be used for testing
label = labelFull[start_label:end_label,]$Delta_Unrevised;

# merge AR, social, consensus, IJC features to get the full feature set
featureFull = merge(featureAR, featureSocial, by="Date");
featureFull = merge(featureFull, consensus, by="Date");
featureFull = merge(featureFull, featureIJC, by="Date");
featureFull = merge(featureFull, sentiment, by="Date");


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

predictionResult = ComputePredictions_RollingTesting(featureFull,featureFullCombos,label,consensus$Consensus1,predictionWindow,predictionDates,lambda,directionalConstraint=TRUE, algo=algo);
write.csv(predictionResult, file = path_outPrediction);
}


end = Sys.time();

print(end-start);