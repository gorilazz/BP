# Computing the predictions on a rolling testing set
ComputePredictions_RollingTesting = function(featureFull,featureCombos,label,consensus,predictionWindow,lambda,directionalConstraint=FALSE)
{
	predictionResult = data.frame(matrix(nrow=0,ncol=(predictionWindow+1)));

	for(i in 1:length(featureCombos))
	{
		print(i);
		currentFeatureCombo = featureCombos[[i]];
		df = featureFull[currentFeatureCombo];
		currentModel = ModelTraining_RollingTesting(df, label, consensus$Consensus1, predictionWindow, lambda, directionalConstraint);
		predictionResult[nrow(predictionResult)+1,] = c(paste(currentFeatureCombo,collapse="+"),currentModel$predictions);
	}

	predictionDates = consensus$Date[(nrow(consensus)-predictionWindow+1):nrow(consensus)];

	colnames(predictionResult) = c("Features",predictionDates);

	return(predictionResult);
}

# Compiling the model training results measured on a rolling testing set
CompileTrainingResults_RollingTesting = function(featureFull,featureCombos,label,consensus,lambda,directionalConstraint=FALSE)
{
	metricList = data.frame(Features=character(),"L1"=character(),"medianL1"=character(),
		"L2"=character(),"medianL2"=character(),"Win1"=character(),"Win2"=character(),"DirectionalWin1"=character(),
		"DirectionalWin2"=character(),"WeightedWin1"=character(),"WeightedWin2"=character(),stringsAsFactors=FALSE);
	for(i in 1:length(featureCombos))
	{
		print(i);
		currentFeatureCombo = featureCombos[[i]];
		df = featureFull[currentFeatureCombo];
		currentModel = ModelTraining_RollingTesting(df,label,consensus$Consensus1,12,lambda,directionalConstraint);
		consensusTesting = consensus[(nrow(consensus)-11):nrow(consensus),];
		metrics = ComputeMetrics(currentModel, consensusTesting);
		metricList[nrow(metricList)+1,] <- c(paste(currentFeatureCombo,collapse="+"),metrics);	
	}

	return(metricList);
}

# Compiling the model training results using bootstrapping
CompileTrainingResults_RandomSampling = function(featureFull,featureCombos,label,consensus,lambda,directionalConstraint=FALSE,aggregationType)
{
	metricList = matrix(nrow=0,ncol=21);

	colnames(metricList) = c("Features","L1","medianL1","L2","medianL2","Win1","Win2","DirectionalWin1",
		"DirectionalWin2","WeightedWin1","WeightedWin2", "L1_conf","medianL1_conf","L2_conf","medianL2_conf","Win1_conf","Win2_conf","DirectionalWin1_conf",
		"DirectionalWin2_conf","WeightedWin1_conf","WeightedWin2_conf");

	result = list();

	for(type in aggregationType)
	{
		result[[type]] = metricList;
	}

	for(i in 1:length(featureCombos))
	{
		print(i);
		currentFeatureCombo = featureCombos[[i]];
		df = featureFull[currentFeatureCombo];
		metrics = ModelTraining_RandomSampling(df,label,consensus,50,10,lambda,directionalConstraint);
		row.names(metrics)=NULL;

		for(type in aggregationType)
		{
			aggregatedMetric = metricAggregation(metrics,type);
			result[[type]] = rbind(result[[type]],c(paste(currentFeatureCombo,collapse="+"),aggregatedMetric));
		}

	}

	return(result);
}

# Generate predictions for a list of feature combos
GeneratePredictions = function(featureFull,featureCombos,label, consensus, nprediction, lambda, directionalConstraint)
{
	predictions = data.frame(matrix(ncol=nprediction));

	for(i in 1:length(featureCombos))
	{
		print(i);
		currentFeatureCombo = featureCombos[[i]];
		df = featureFull[currentFeatureCombo];
		currentModel = ModelTraining_RollingTesting(df,label,consensus,nprediction,lambda,directionalConstraint);
		predictions[i,] = currentModel$predictions;
	}

	return(predictions);
}
