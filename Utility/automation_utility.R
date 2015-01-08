require(Matrix);

# Computing the predictions on a rolling testing set
ComputePredictions_RollingTesting = function(featureFull,featureCombos,label,consensus,predictionWindow,predictionDates,lambda,directionalConstraint=FALSE, algo='lr')
{
	predictionResult = data.frame(matrix(nrow=0,ncol=(predictionWindow+1)));

	consensusTraining = consensus;

	for(i in 1:length(featureCombos))
	{
		print(i);
		currentFeatureCombo = featureCombos[[i]];
		df = featureFull[currentFeatureCombo];
		df_mat = data.matrix(df, rownames.force=NA);
		if(rankMatrix(df_mat)[[1]]<ncol(df))
		{
			next;
		}
		currentModel = ModelTraining_RollingTesting(df, label, consensusTraining, predictionWindow, lambda, directionalConstraint, algo);
		predictionResult[nrow(predictionResult)+1,] = c(paste(currentFeatureCombo,collapse="+"),currentModel$predictions);
	}

	colnames(predictionResult) = c("Features",predictionDates);

	return(predictionResult);
}

# Compiling the model training results measured on a rolling testing set
# CompileTrainingResults_RollingTesting = function(featureFull,featureCombos,label,consensus,lambda,directionalConstraint=FALSE)
# {
# 	metricList = data.frame(Features=character(),"L1"=character(),"medianL1"=character(),
# 		"L2"=character(),"medianL2"=character(),"Win"=character(),"DirectionalWin"=character(),"WeightedWin"=character(),sstringsAsFactors=FALSE);
# 	for(i in 1:length(featureCombos))
# 	{
# 		print(i);
# 		currentFeatureCombo = featureCombos[[i]];
# 		df = featureFull[currentFeatureCombo];
# 		currentModel = ModelTraining_RollingTesting(df,label,consensus$Consensus1,12,lambda,directionalConstraint);
# 		consensusTesting = consensus[(nrow(consensus)-11):nrow(consensus),];
# 		metrics = ComputeMetrics(currentModel, consensusTesting);
# 		metricList[nrow(metricList)+1,] <- c(paste(currentFeatureCombo,collapse="+"),metrics);	
# 	}

# 	return(metricList);
# }

# Compiling the model training results using bootstrapping
CompileTrainingResults_RandomSampling = function(featureFull,featureCombos,label,consensus,lambda,directionalConstraint=FALSE,aggregationType)
{
	metricList = matrix(nrow=0,ncol=15);

	colnames(metricList) = c("Features","L1","medianL1","L2","medianL2","Win","DirectionalWin","WeightedWin", 
		"L1_conf","medianL1_conf","L2_conf","medianL2_conf","Win_conf","DirectionalWin_conf","WeightedWin_conf");

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
		df_mat = data.matrix(df, rownames.force=NA);
		if(rankMatrix(df_mat)[[1]]<ncol(df))
		{
			next;
		}
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

# Compiling the model training results using cross-validation
CompileTrainingResults_CV = function(featureFull,featureCombos,label,consensus,lambda,directionalConstraint=FALSE,aggregationType, num_folds = 10)
{
	metricList = matrix(nrow=0,ncol=15);

	colnames(metricList) = c("Features","L1","medianL1","L2","medianL2","Win","DirectionalWin","WeightedWin", 
		"L1_conf","medianL1_conf","L2_conf","medianL2_conf","Win_conf","DirectionalWin_conf","WeightedWin_conf");

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
		testing_sets = GenerateTesting_CV(nrow(df), num_folds);
		metrics = ModelTraining_CV(df,label,consensus,testing_sets,lambda,directionalConstraint);
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
