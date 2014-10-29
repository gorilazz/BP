source('utility.R');



PrepareFeatureCombos_Web = function(featureWeb)
{
	featureNames = names(featureWeb);
	featureNames = featureNames[-c(1)];

	featureCombos = GetAllCombinations(featureNames, 2);
	
	return(featureCombos);
}


socialOnly = T;	#use social and AR features when T; use web features as well when F
L1Threshold = 45;
DirectionalWin1Threshold=9;
DirectionalWin2Threshold=7;
Win1Threshold=8;
Win2Threshold=6;
WeightedWin1Threshold=70;


	#readin data & initialization
	path_featureAR = "../Features/AR/ARDelta_Full.csv";
	path_IJC = "../Features/IJC/IJC.csv";
	path_featureSocial = "../Features/201410/DaysBack_7_Features_All_candiate_seperated_AbsoluteFull.csv";
	path_consensus = "../GroundTruth/Consensus.csv";
	path_ARSocialMetric = "../Model/201410/experiments_AR_Social_Model_13.csv";

	path_outPrediction = paste("../Model/201410/experiments_AR_Social_Model_13a_Ensemble","Prediction.csv",sep='_');
	path_outMetric = paste("../Model/201410/experiments_AR_Social_Model_13a_Ensemble","Metric.csv",sep='_');


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
	featureIJC = IJCFull[start_featureIJC:end_featureIJC,];
	featureConsensus = consensusFull[start_featureConsensus:end_featureConsensus,];
	consensus = consensusFull[start_consensus:end_consensus,];
	label = featureAR$Label;

	featureFull = merge(featureAR, featureSocial, by="Date");
	featureFull = merge(featureFull, featureConsensus, by="Date");
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
		if(as.character(candidate$Features[i])=="NumTweets_Month1_all_Absolute+NumPopularTweets_Month1_all_Absolute+NumTweets_Week1_all_Absolute+NumPopularTweets_Week1_all_Absolute+NumTweets_Week2_all_Absolute+NumPopularTweets_Week2_all_Absolute")
		{
			print(candidate$Features[i]);
		}
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

	write.csv(predictions, file = path_outPrediction);

	metrics_median = GenerateEnsembleModel(predictions,label,consensus,'median');
	metricList[1,] <- c("median",metrics_median);	

	metrics_mean = GenerateEnsembleModel(predictions,label,consensus,'mean');
	metricList[2,] <- c("mean",metrics_mean);	

	write.csv(metricList, file = path_outMetric);