# This is a temp version of 'learning.R', which trains the model with out the features of "all"

source('utility.R');

PrepareFeatureCombos_AR = function(featureAR)
{
	featureNames = names(featureAR);
	featureNames = featureNames[-c(1:2)];
	featureNames = featureNames[-c(length(featureNames))];

	featureCombos = GetAllCombinations(featureNames,3);
	return(featureCombos);

}

PrepareFeatureCombos_Web = function(featureWeb)
{
	featureNames = names(featureWeb);
	featureNames = featureNames[-c(1)];

	featureCombos = GetAllCombinations(featureNames, 2);
	
	return(featureCombos);
}

PrepareFeatureCombos_Social = function()
{

	featureCombos = list()
	
	rawFeatureNames = c("NumTweets","NumPopularTweets","NumVerifiedTweets");
	timeIntervals = c("Month1","Week1","Week2");
	processingTypes = c("Absolute","AbsoluteDelta");
	filteringTypes = c("all","allold","opportunity","opening","posting","hiring");

	Combos_rawFeatureNames = GetAllCombinations(rawFeatureNames, 4);
	Combos_timeIntervals = GetAllCombinations(timeIntervals, 3);
	Combos_processingTypes = GetAllCombinations(processingTypes, 2);
	Combos_filteringTypes = GetAllCombinations(filteringTypes, 4);

	pos = 1;
	maxNumFeatures = 8;

	for(i in 1:length(Combos_rawFeatureNames))
	{
		for(j in 1:length(Combos_timeIntervals))
		{
			for(k in 1:length(Combos_processingTypes))
			{
				for(t in 1:length(Combos_filteringTypes))
				{
					rawFeature = Combos_rawFeatureNames[[i]];
					timeInterval = Combos_timeIntervals[[j]];
					processingType = Combos_processingTypes[[k]];
					filteringType = Combos_filteringTypes[[t]];
					print(c(i,j,k,t));
					if((length(rawFeature)*length(timeInterval)*length(processingType)*length(filteringType)==0)||(length(rawFeature)*length(timeInterval)*length(processingType)*length(filteringType)>maxNumFeatures))
					{
						next;
					}
					fullFeatures = merge(rawFeature, timeInterval);
					fullFeatures = paste(fullFeatures$x, fullFeatures$y, sep="_");

					fullFeatures = merge(fullFeatures, filteringType);
					fullFeatures = paste(fullFeatures$x, fullFeatures$y, sep="_");

					fullFeatures = merge(fullFeatures, processingType);
					fullFeatures = paste(fullFeatures$x, fullFeatures$y, sep="_");
					featureCombos[[pos]] = fullFeatures
					pos = pos + 1;
				}
			}
		}
	}

	return(featureCombos);
}


#readin data & initialization
path_featureAR = "../Features/AR/ARDelta_Full.csv";
path_featureSocial = "../Features/201409_2/DaysBack_7_Features_All_candiate_seperated_AbsoluteFull.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_outMetric = "../Model/201409_2/experiments_AR_Social_Model_6.csv";

featureARFull = read.csv(file=path_featureAR, head=TRUE, sep=",");
for(i in 1:nrow(featureARFull))
{
	featureARFull[i,'MonthId'] = DateToMonthTag(featureARFull[i,'Date']);
}

# featureARFull$OneMonthBefore = (-1)^((featureARFull$OneMonthBefore>0)+1)*log(abs(featureARFull$OneMonthBefore)+1);
# featureARFull$TwoMonthBefore = (-1)^((featureARFull$TwoMonthBefore>0)+1)*log(abs(featureARFull$TwoMonthBefore)+1);
# featureARFull$ThreeMonthBefore = (-1)^((featureARFull$ThreeMonthBefore>0)+1)*log(abs(featureARFull$ThreeMonthBefore)+1);


featureSocialFull = read.csv(file=path_featureSocial, head=TRUE, sep=",");
consensusFull = read.csv(file=path_consensus, head=TRUE, sep=",");

start_featureAR = which(featureARFull$MonthId=="201103")[1];
start_featureSocial = which(featureSocialFull$MonthId=="201103")[1];
end_featureSocial = which(featureSocialFull$MonthId=="201409")[1];
start_consensus = 114;


#feature processing
featureAR = featureARFull[start_featureAR:nrow(featureARFull),];
featureSocial = featureSocialFull[start_featureSocial:end_featureSocial,];


label = featureAR$Label;

consensusTesting = consensusFull[start_consensus:nrow(consensusFull),];

#prepare feature combos
featureARCombos = PrepareFeatureCombos_AR(featureAR);
featureSocialCombos = PrepareFeatureCombos_Social();

featureFull = merge(featureAR, featureSocial, by="MonthId");


#train model and output metrics
featureFullCombos = list();
pos = 1;
for(i in 1:length(featureARCombos))
{
	for(k in 1:length(featureSocialCombos))
	{
		currentFeatureCombo = c(featureARCombos[[i]], featureSocialCombos[[k]]);
		if(length(currentFeatureCombo)==0)
		{
			next;
		}

		featureFullCombos[[pos]] = currentFeatureCombo;
		pos = pos+1;
	}
}

options(warn=2)

metricList = CompileTrainingResults(featureFull,featureFullCombos,label,consensusTesting);

write.csv(metricList, file = path_outMetric);