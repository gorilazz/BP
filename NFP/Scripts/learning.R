source('utility.R');

lambda = 0.0;

# path initialization
path_featureAR = "../Features/AR/ARDelta_Full.csv";
path_featureSocial = "../Features/201410/DaysBack_7_Features_All_candiate_seperated_AbsoluteFull.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_IJC = "../Features/IJC/IJC.csv";
path_outMetric = paste("../Model/201410/experiments_AR_Social_Model_13",".csv",sep="");

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
data_end = "201409"

data_feature_end = "201410"

start_featureAR = which(featureARFull$Date==data_start)[1];
end_featureAR = which(featureARFull$Date==data_feature_end)[1];
start_featureSocial = which(featureSocialFull$Date==data_start)[1];
end_featureSocial = which(featureSocialFull$Date==data_feature_end)[1];
start_featureConsensus = which(consensusFull$Date==data_start)[1];
end_featureConsensus = which(consensusFull$Date==data_feature_end)[1];
start_featureIJC = which(IJCFull$Date==data_start)[1];
end_featureIJC = which(IJCFull$Date==data_feature_end)[1];
start_consensus = which(consensusFull$Date==data_start)[1];
end_consensus = which(consensusFull$Date==data_end)[1];

featureAR = featureARFull[start_featureAR:end_featureAR,];
featureSocial = featureSocialFull[start_featureSocial:end_featureSocial,];
featureConsensus = consensusFull[start_featureConsensus:end_featureConsensus,];
featureIJC = IJCFull[start_featureIJC:end_featureIJC,];
consensus = consensusFull[start_consensus:end_consensus,];
label = featureAR$Label;

featureFull = merge(featureAR, featureSocial, by="Date");
featureFull = merge(featureFull, featureConsensus, by="Date");
featureFull = merge(featureFull, featureIJC, by="Date");

#prepare feature combos
featureARCombos = PrepareFeatureCombos_AR(featureAR);
featureIJCCombos = PrepareFeatureCombos_IJC(featureIJC)
featureSocialCombos = PrepareFeatureCombos_Social();
featureConsensusCombos = PrepareFeatureCombos_Consensus();

#train model and output metrics
featureFullCombos = list();
pos = 1;
for(i in 1:length(featureARCombos))
{
	for(t in 1:length(featureIJCCombos))
	{
		# for(j in 1:length(featureConsensusCombos))
		# {
			for(k in 1:length(featureSocialCombos))
			{
				currentFeatureCombo = c(featureARCombos[[i]], featureIJCCombos[[t]], featureSocialCombos[[k]]);
				if(length(currentFeatureCombo)==0)
				{
					next;
				}

				featureFullCombos[[pos]] = currentFeatureCombo;
				pos = pos+1;
				print(pos);
			}
		# }
	}
	
}

# options(warn=2)

metricList = CompileTrainingResults(featureFull,featureFullCombos,label,consensus,lambda,directionalConstraint=TRUE);

write.csv(metricList, file = path_outMetric);
