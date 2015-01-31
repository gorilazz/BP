source('utility.R')
require('quadprog')

TestCombo = function(featureFull, label, consensus, featureCombo, sep = '[+]', breakCombo = TRUE)
{
	if(breakCombo)
	{
		combo = strsplit(featureCombo,sep);
		combo = combo[[1]]
	} else{
		combo = featureCombo
	}

	metricList = data.frame(Features=character(),"L1"=character(),"medianL1"=character(),"L2"=character(),"medianL2"=character(),
		"Win1"=character(),"Win2"=character(),"DirectionalWin1"=character(),"DirectionalWin2"=character(),"WeightedWin1"=character(),
		"WeightedWin2"=character(),"Testing Prediction"=character(),"Prediction"=character(),stringsAsFactors=FALSE);
	
	df = featureFull[combo];
	currentModel = ModelTraining(df,combo,label,consensus$Consensus1,TRUE);
	consensusTesting = consensus[(nrow(consensus)-11):nrow(consensus),]
	metrics = ComputeMetrics(currentModel, consensus);
	metricList[nrow(metricList)+1,] <- c(paste(combo,collapse="+"),metrics,paste(currentModel$prediction,collapse="+"),currentModel$prediction_latest);	

	return(metricList);
}