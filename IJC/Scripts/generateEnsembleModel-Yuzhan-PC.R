source('utility.R');



PrepareFeatureCombos_Web = function(featureWeb)
{
	featureNames = names(featureWeb);
	featureNames = featureNames[-c(1)];

	featureCombos = GetAllCombinations(featureNames, 2);
	
	return(featureCombos);
}


socialOnly = T;	#use social and AR features when T; use web features as well when F
DirectionalWinThreshold=23;
WinThreshold=0;

#readin data & initialization
path_featureAR = "../Features/AR/Features_AR_Delta.csv";
path_featureSocial = "../Features/201410_2/Features_NFP_All_candiate_seperated_AbsoluteFull.csv";
#path_featureWeb = "../Features/201408/Web_Log.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_ARSocialMetric = "../Model/201410_2/experiments_NFP_Model_2.csv";
#path_ARSocialWebMetric = "../Model/experiments_AR_Social_Web_Full.csv";
path_outMetric = paste("../Model/201410_2/experiments_NFP_Model_2_Ensemble_NoConsensus",paste(DirectionalWinThreshold,"Metric.csv",sep='_'),sep='_');
path_outPredictions = paste("../Model/201410_2/experiments_NFP_Model_2_Ensemble_NoConsensus",paste(DirectionalWinThreshold,"Prediction.csv",sep='_'),sep='_');


if(socialOnly==T)
{
	path_inMetric = path_ARSocialMetric;
} else
{
	path_inMetric = path_ARSocialWebMetric;
}

featureARFull = read.csv(file=path_featureAR, head=TRUE, sep=",");
featureARFull$Date = as.character(featureARFull$Date)
for(i in 1:nrow(featureARFull))
{
	featureARFull[i,'WeekId'] = DateToWeekTag(featureARFull[i,'Date']);
}

featureSocialFull = read.csv(file=path_featureSocial, head=TRUE, sep=",");
featureSocialFull$WeekId = as.character(featureSocialFull$WeekId)
for(i in 1:nrow(featureSocialFull))
{
	date = strsplit(featureSocialFull[i,'WeekId'], "[-]");
	weekid = paste(date[[1]][2],date[[1]][3],date[[1]][1],sep="/");	
	featureSocialFull[i,'WeekId'] = DateToWeekTag(weekid);
}

consensusFull = read.csv(file=path_consensus, head=TRUE, sep=",");
consensusFull$Date = as.character(consensusFull$Date)
for(i in 1:nrow(consensusFull))
{
	consensusFull[i,'WeekId'] = DateToWeekTag(consensusFull[i,'Date']);
}

start_date = "20120106";
end_date = "20141017";

start_consensus_testing = "20140131";
end_consensus_testing = "20141003";

featureAR = featureARFull[which(featureARFull$WeekId==start_date)[1]:which(featureARFull$WeekId==end_date)[1],];
featureSocial = featureSocialFull[which(featureSocialFull$WeekId==start_date)[1]:which(featureSocialFull$WeekId==end_date)[1],];
featureConsensus = consensusFull[which(consensusFull$WeekId==start_date)[1]:which(consensusFull$WeekId==end_date)[1],];

consensus = featureConsensus[(nrow(featureConsensus)-36):(nrow(featureConsensus)-1),];


label = featureAR$Label;

CurrentMetric = read.csv(file=path_inMetric, head=TRUE, sep=",");
candidate = CurrentMetric[CurrentMetric$DirectionalWin>=DirectionalWinThreshold,];
candidate = candidate[candidate$Win>=WinThreshold,];
index = grep("Consensus",candidate$Features);
candidate = candidate[-index,];


candidateCombos = list();
pos = 1;
for(i in 1:length(candidate$Features))
{
	combo = unlist(strsplit(as.character(candidate$Features[i]),split='[+]'));

	candidateCombos[[pos]] = combo;
	pos = pos+1;
}

if(length(candidateCombos)==0)
{
	next;
}

featureFull = merge(featureAR, featureSocial, by="WeekId");
featureFull = merge(featureFull, featureConsensus, by="WeekId");

metricList = data.frame(Features=character(),"L1"=character(),"medianL1"=character(),"L2"=character(),"medianL2"=character(),"Win"=character(),"DirectionalWin"=character(),"WeightedWin"=character(),"Prediction"=character(),stringsAsFactors=FALSE);

predictions = GeneratePredictions(featureFull, candidateCombos, label);

write.csv(predictions, file = path_outPredictions);

metrics_median = GenerateEnsembleModel(predictions,label,consensus,'median');
metricList[1,] <- c("median",metrics_median);	

metrics_mean = GenerateEnsembleModel(predictions,label,consensus,'mean');
metricList[2,] <- c("mean",metrics_mean);	

write.csv(metricList, file = path_outMetric);