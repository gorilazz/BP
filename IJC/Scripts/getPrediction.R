# Get predictions for each individual model
start = Sys.time();

lambda = 0.0;

source('../../Utility/IJC_utility.R');
source('../../Utility/utility.R');
source('../../Utility/learning_utility.R');
source('../../Utility/automation_utility.R');


#readin data & initialization
path_featureAR = "../Features/AR/Features_AR_Delta.csv";
path_featureSocial = "../Features/201411/Features_NFP_All_candiate_seperated_AbsoluteFull.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_outPrediction = "../Prediction/201411/Model_NFP_Predictions.csv";

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

start_date = "20120106";	#earliest data to use
end_date = "20141107";	#latest data to use

featureAR = featureARFull[which(featureARFull$WeekId==start_date)[1]:which(featureARFull$WeekId==end_date)[1],];
featureSocial = featureSocialFull[which(featureSocialFull$WeekId==start_date)[1]:which(featureSocialFull$WeekId==end_date)[1],];
consensus = consensusFull[which(consensusFull$WeekId==start_date)[1]:which(consensusFull$WeekId==end_date)[1],];

label = featureAR$Label;


#prepare feature combos
featureARCombos = PrepareFeatureCombos_AR(featureAR);
featureSocialCombos = PrepareFeatureCombos_Social();
featureConsensusCombos = PrepareFeatureCombos_Consensus();

featureFull = merge(featureAR, featureSocial, by="WeekId");
featureFull = merge(featureFull, consensus, by="WeekId");

#train model and output metrics
featureFullCombos = list();
pos = 1;
for(i in 1:length(featureARCombos))
{
	for(j in 1:length(featureConsensusCombos))
	{
		for(k in 1:length(featureSocialCombos))
		{
			print(c(i,j,k));
			currentFeatureCombo = c(featureARCombos[[i]], featureConsensusCombos[[j]], featureSocialCombos[[k]]);
			if(length(currentFeatureCombo)==0)
			{
				next;
			}

			featureFullCombos[[pos]] = currentFeatureCombo;
			pos = pos+1;
		}
	}
}

# options(warn=2)

predictionWindow = 60;

predictionResult = ComputePredictions_RollingTesting(featureFull,featureFullCombos,label,consensus$DeltaConsensus,predictionWindow,lambda,directionalConstraint=TRUE);
write.csv(predictionResult, file = path_outPrediction);

end = Sys.time();

print(end-start);