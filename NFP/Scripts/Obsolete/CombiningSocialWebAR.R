source('utility.R');



PrepareFeatureCombos_Web = function(featureWeb)
{
	featureNames = names(featureWeb);
	featureNames = featureNames[-c(1)];

	featureCombos = GetAllCombinations(featureNames, 2);
	
	return(featureCombos);
}


#readin data & initialization
path_featureAR = "../Features/AR/ARDelta_Full.csv";
path_featureSocial = "../Features/201408/DaysBack_7_Window2.csv";
path_featureWeb = "../Features/201408/Web_Log.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_ARSocialMetric = "../Model/experiments_AR_Social_Full.csv";
path_outMetric = "../Model/experiments_AR_Social_Web_Full.csv";

featureARFull = read.csv(file=path_featureAR, head=TRUE, sep=",");
for(i in 1:nrow(featureARFull))
{
	featureARFull[i,'MonthId'] = DateToMonthTag(featureARFull[i,'Date']);
}

featureSocialFull = read.csv(file=path_featureSocial, head=TRUE, sep=",");
featureWebFull = read.csv(file=path_featureWeb, head=TRUE, sep=",");
consensusFull = read.csv(file=path_consensus, head=TRUE, sep=",");

start_featureAR = which(featureARFull$MonthId=="201103")[1];
start_featureSocial = which(featureSocialFull$MonthId=="201103")[1];
end_featureSocial = which(featureSocialFull$MonthId=="201408")[1];
start_featureWeb = which(featureWebFull$MonthId=="201103")[1];
end_featureWeb = which(featureWebFull$MonthId=="201408")[1];
start_consensus = 113;

#feature processing
featureAR = featureARFull[start_featureAR:nrow(featureARFull),];
featureSocial = featureSocialFull[start_featureSocial:end_featureSocial,];
featureWeb = featureWebFull[start_featureWeb:end_featureWeb,];

label = featureAR$Label;

consensusTesting = consensusFull[start_consensus:nrow(consensusFull),];

ARSocialMetric = read.csv(file=path_ARSocialMetric, head=TRUE, sep=",");
candidate = ARSocialMetric[ARSocialMetric$L1<=43,];
candidate = candidate[candidate$WeightedWin1>=8,];
candidate = candidate[candidate$Win1>=7,];

candidateCombos = list();
pos = 1;
for(i in 1:length(candidate$Features))
{
	combo = unlist(strsplit(as.character(candidate$Features[i]),split='[+]'));
	if(length(combo)>7)
	{
		next;
	}
	candidateCombos[[pos]] = combo;
	pos = pos+1;
}

featureWebCombos = PrepareFeatureCombos_Web(featureWeb);

featureFull = merge(featureAR, featureWeb, by="MonthId");
featureFull = merge(featureFull, featureSocial, by="MonthId");


#train model and output metrics
featureFullCombos = list();
pos = 1;
for(i in 1:length(candidateCombos))
{
	for(j in 1:length(featureWebCombos))
	{
			currentFeatureCombo = c(candidateCombos[[i]], featureWebCombos[[j]]);
			if(length(currentFeatureCombo)==0)
			{
				next;
			}
			print(c(i,j));

			featureFullCombos[[pos]] = currentFeatureCombo;
			pos = pos+1;
	}
}

metricList = CompileTrainingResults(featureFull,featureFullCombos,label,consensusTesting);

write.csv(metricList, file = path_outMetric);