source('../../Utility/utility.R');
source('../../Utility/learning_utility.R');
source('../../Utility/automation_utility.R');


L1Threshold = 45;
DirectionalWin1Threshold=5;
DirectionalWin2Threshold=0;
Win1Threshold=0;
Win2Threshold=0;
WeightedWin1Threshold=70;


#readin data & initialization
path_featureAR = "../Features/AR/ARDelta_Full.csv";
path_IJC = "../Features/IJC/IJC_3_weeks.csv";
path_featureSocial = "../Features/201410/DaysBack_7_Features_All_candiate_seperated_AbsoluteFull.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_ARSocialMetric = "../Model/201410/experiments_AR_Social_Model_14_revised_median.csv";

path_outComboName = paste("../Model/201410/experiments_AR_Social_Model_14_revised_median_Ensemble","ComboName.csv",sep='_');
path_outPrediction = paste("../Model/201410/experiments_AR_Social_Model_14_revised_median_Ensemble","Prediction.csv",sep='_');
path_outMetric = paste("../Model/201410/experiments_AR_Social_Model_14_revised_median_Ensemble","Metric.csv",sep='_');


path_inMetric = path_ARSocialMetric;

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


# get the data
data_start = "201103"
data_end = "201410"

start_featureAR = which(featureARFull$Date==data_start)[1];
end_featureAR = which(featureARFull$Date==data_end)[1];
start_featureSocial = which(featureSocialFull$Date==data_start)[1];
end_featureSocial = which(featureSocialFull$Date==data_end)[1];
start_featureIJC = which(IJCFull$Date==data_start)[1];
end_featureIJC = which(IJCFull$Date==data_end)[1];
start_consensus = which(consensusFull$Date==data_start)[1];
end_consensus = which(consensusFull$Date==data_end)[1];

featureAR = featureARFull[start_featureAR:end_featureAR,];
featureSocial = featureSocialFull[start_featureSocial:end_featureSocial,];
featureIJC = IJCFull[start_featureIJC:end_featureIJC,];
consensus = consensusFull[start_consensus:end_consensus,];
label = featureAR$Label;

featureFull = merge(featureAR, featureSocial, by="Date");
featureFull = merge(featureFull, consensus, by="Date");
featureFull = merge(featureFull, featureIJC, by="Date");


CurrentMetric = read.csv(file=path_inMetric, head=TRUE, sep=",");
candidate = CurrentMetric[CurrentMetric$L1<=L1Threshold,];
candidate = candidate[candidate$DirectionalWin1>=DirectionalWin1Threshold,];
candidate = candidate[candidate$DirectionalWin2>=DirectionalWin2Threshold,];
candidate = candidate[candidate$Win1>=Win1Threshold,];
candidate = candidate[candidate$Win2>=Win2Threshold,];
# index = grep("MonthBefore",candidate$Features);
# candidate = candidate[-index,];	

candidateCombos = list();
pos = 1;
for(i in 1:length(candidate$Features))
{
	combo = unlist(strsplit(as.character(candidate$Features[i]),split='[+]'));
	# if(length(combo)>8)
	# {
	# 	next;
	# }
	candidateCombos[[pos]] = combo;
	pos = pos+1;
}

if(length(candidateCombos)==0)
{
	next;
}

metricList = data.frame(Features=character(),"L1"=character(),"medianL1"=character(),"L2"=character(),"medianL2"=character(),"Win1"=character(),"Win2"=character(),"DirectionalWin1"=character(),"DirectionalWin2"=character(),"WeightedWin1"=character(),"WeightedWin2"=character(),"Prediction"=character(),stringsAsFactors=FALSE);

predictions = GeneratePredictions(featureFull, candidateCombos, label, consensus, 13, lambda, TRUE);

write.csv(candidate, file=path_outComboName);

write.csv(predictions, file = path_outPrediction);

labelTesting = label[(length(label)-12):(length(label)-1)];
consensusTesting = consensus[(nrow(consensus)-12):(nrow(consensus)-1),];

metrics_median = ComputeMetrics_Prediction(predictions,labelTesting,consensusTesting,'median');
metricList[1,] <- c("median",metrics_median);	

metrics_mean = ComputeMetrics_Prediction(predictions,labelTesting,consensusTesting,'mean');
metricList[2,] <- c("mean",metrics_mean);	

write.csv(metricList, file = path_outMetric);