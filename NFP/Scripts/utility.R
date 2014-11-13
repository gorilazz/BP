require(quadprog);

DateToMonthTag = function(date)
{
	date_split = strsplit(as.character(date),"/");
	if(as.numeric(date_split[[1]][1])>=10)
	{
		return(paste(date_split[[1]][3],date_split[[1]][1],sep=""));
	}
	else
	{
		return(paste(date_split[[1]][3],"0",date_split[[1]][1],sep=""));	
	}
}

LinearRegression = function(feature_training, feature_testing, label)
{
	
	if(ncol(feature_training)>1){
		model = lm(label ~ ., data=feature_training);
		prediction = predict(model, newdata=feature_testing);
	} else{
		model = lm(label ~ feature_training);
		prediction = predict(model, newdata=data.frame(feature_training=feature_testing));
	}

	return(list(model=model,prediction=prediction));
}

LinearRegression_QP = function(feature_training, feature_testing, label, consensus_training, lambda)
{
	
	feature_training = data.matrix(feature_training);
	feature_training = cbind(matrix(1,nrow(feature_training),1),feature_training);
	feature_testing = data.matrix(feature_testing);
	feature_testing = cbind(matrix(1,nrow(feature_testing),1),feature_testing);
	label = data.matrix(label);

	Dmat = 2*t(feature_training)%*%feature_training;

	dvec = 2*t(label)%*%feature_training + lambda*t(label)%*%feature_training - lambda*t(consensus_training)%*%feature_training;
	dvec = t(dvec);

	Amat = matrix(0, ncol(feature_training), 1);
	bvec = c(0);

	sol = solve.QP(Dmat,dvec,Amat,bvec=bvec);

	prediction = sol$solution%*%t(feature_testing);

	return(list(solution=sol, prediction=prediction));
}

GeneralLinearModel = function(feature_training, feature_testing, featureNames, label)
{
	
	if(length(featureNames)>1){
		model = glm(label ~ ., data=feature_training,family=poisson());
		prediction = predict(model, newdata=feature_testing,type="response");
	} else{
		model = lm(label ~ feature_training,family=poisson);
		prediction = predict(model, newdata=data.frame(feature_training=feature_testing),type="response");
	}

	return(list(model=model,prediction=prediction));
}

ModelTraining_RollingTesting = function(df,label,consensus,rollingWindow=12,lambda=0.0,directionalConstraint=FALSE)
{
	
	predictions = c();
	residuals = c();
	labels = c();
	for(i in rollingWindow:1)
	{
		num_rows = nrow(df)-i;
		df_training = df[1:num_rows,];
		label_training = label[1:num_rows];
		consensus_training = consensus[1:num_rows];
		df_testing = df[num_rows+1,];
		label_testing = label[num_rows+1];
		label_testing_prev = label[num_rows];

		if(directionalConstraint==FALSE)
		{
			result = LinearRegression(df_training, df_testing, label_training);
		} else{
			result = LinearRegression_QP(df_training, df_testing, label_training, consensus_training, lambda);
		}

		predictions = c(predictions,result[['prediction']]);
		residuals = c(residuals, abs(result[['prediction']]-label_testing[1]));
		labels = c(labels, label_testing[1]);
	}

	return(list(predictions=predictions, residuals=residuals, labels=labels));
}

ModelTraining_RandomSampling = function(df,label,consensus,iteration=100,sampleSize=10,lambda=0.0,directionalConstraint=FALSE)
{
	
	metricList = matrix(nrow=0,ncol=10);
	for(i in 1:iteration)
	{
		num_rows = nrow(df);
		sample_rows = sample(1:num_rows, sampleSize, replace=F);

		df_training = df[-sample_rows,];
		df_testing = df[sample_rows,];

		label_training = label[-sample_rows];
		label_testing = label[sample_rows];

		consensus_training = consensus[-sample_rows,]$Consensus1;
		consensus_testing = consensus[sample_rows,];

		if(directionalConstraint==FALSE)
		{
			result = LinearRegression(df_training, df_testing, label_training);
		} else{
			result = LinearRegression_QP(df_training, df_testing, label_training, consensus_training, lambda);
		}

		model = list(predictions=result$prediction, residuals=abs(label_testing-result$prediction), labels=label_testing);
		metrics = ComputeMetrics(model, consensus_testing);

		metricList <- rbind(metricList, metrics);
	}

	colnames(metricList) = c("L1","medianL1","L2","medianL2","Win1","Win2","DirectionalWin1",
		"DirectionalWin2","WeightedWin1","WeightedWin2");

	return(metricList);
}

metricAggregation = function(metrics,type)
{
	if(type=="median")
	{
		result = apply(metrics,2,median);

		for(i in 1:ncol(metrics))
		{
			metric = metrics[,i];
			confidence = ConfidenceInterval(metric, 0.95, "median");
			result = c(result, confidence[2]-confidence[1]);
		}
		
	}else if(type=="mean")
	{
		result = apply(metrics,2,mean);

		for(i in 1:ncol(metrics))
		{
			metric = metrics[,i];
			confidence = ConfidenceInterval(metric, 0.95, "mean");
			result = c(result, confidence[2]-confidence[1]);
		}
	}
	
	return(result);
}

ComputeMetrics = function(model, consensus)
{
	L1 = mean(model$residuals);
	medianL1 = median(model$residuals);
	L2 = sqrt(mean(model$residuals^2));
	medianL2 = sqrt(median(model$residuals^2));
	Win1 = sum(model$residuals<abs(consensus$Consensus1-model$labels));
	Win2 = sum(model$residuals<abs(consensus$Consensus2-model$labels));
	DirectionalWin1 = sum((model$predictions-consensus$Consensus1)*(model$labels-consensus$Consensus1)>0);
	DirectionalWin2 = sum((model$predictions-consensus$Consensus2)*(model$labels-consensus$Consensus2)>0);
	WeightedWin1 = sum((-1)^((model$residuals<abs(consensus$Consensus1-model$labels))-1)*abs(model$residuals-abs(consensus$Consensus1-model$labels)));
	WeightedWin2 = sum((-1)^((model$residuals<abs(consensus$Consensus2-model$labels))-1)*abs(model$residuals-abs(consensus$Consensus2-model$labels)));

	return(c(L1,medianL1,L2,medianL2,Win1,Win2,DirectionalWin1,DirectionalWin2,WeightedWin1,WeightedWin2));
}

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

GeneratePredictions = function(featureFull,featureCombos,label, consensus, nprediction, lambda, directionalConstraint)
{
	predictions = data.frame(matrix(ncol=nprediction));

	for(i in 1:length(featureCombos))
	{
		print(i);
		currentFeatureCombo = featureCombos[[i]];
		df = featureFull[currentFeatureCombo];
		currentModel = ModelTraining_RollingTesting(df,label,consensus$Consensus1,13,lambda,directionalConstraint);
		predictions[i,] = c(currentModel$predictions,currentModel$prediction_latest);
	}

	return(predictions);
}

GenerateEnsembleModel = function(predictions,label,consensus,type)
{
	
	labels = label[(length(label)-12):(length(label)-1)];

	consensusTesting = consensus[(nrow(consensus)-11):nrow(consensus),];

	if(type=="mean")
	{
		result = apply(predictions,2,mean);
	} else
	{
		result = apply(predictions,2,median);
	}

	prediction_latest = result[13];
	predictions = result[1:12];
	residuals = abs(predictions-labels);

	model = list(predictions=predictions, residuals=residuals, labels=labels, prediction_latest=prediction_latest);

	metrics = ComputeMetrics(model, consensusTesting);

	return(c(metrics,prediction_latest));
}

# Give a list of names, get all possible combinations
GetAllCombinations = function(nameList, maxLength)
{
	currentLength = length(nameList);

	result = list();

	if(currentLength==1)
	{
		result[[1]] = c();
		result[[2]] = c(nameList[1]);
	}
	else
	{
		result = GetAllCombinations(nameList[1:(length(nameList)-1)], maxLength);
		num_result = length(result);
		pos = num_result+1;
		for(i in 1:num_result)
		{
			combo = result[[i]];
			if(length(combo)<maxLength)
			{
				result[[pos]] = c(combo,nameList[[length(nameList)]]);
				pos = pos+1;
			}
		}
	}

	return(result);
}

FeatureProcessing = function(x)
{
	result = 1-exp(-1*x);
	return(result)
}

PrepareFeatureCombos_AR = function(features)
{
	# featureNames = names(features);
	# featureNames = featureNames[-c(1:2)];

	a = c("OneMonthBefore","TwoMonthBefore");
	b = c("UnRevised","Revised");

	aCombos = GetAllCombinations(a,2);
	bCombos = GetAllCombinations(b,1);
	# featureNames = featureNames[-c(length(featureNames))];

	featureCombos = list();
	featureCombos[[1]] = NULL;

	pos=2;

	for(i in 1:length(aCombos))
	{
		for(j in 1:length(bCombos))
		{
			if(is.null(aCombos[[i]])||is.null(bCombos[[j]]))
			{
				next;
			}
			featureCombos[[pos]] = paste(aCombos[[i]], bCombos[[j]], sep="_");
			pos = pos + 1;
		}
	}

	# featureCombos = GetAllCombinations(featureNames,2);

	return(featureCombos);

}

PrepareFeatureCombos_IJC = function(features)
{
	# featureNames = names(features);
	# featureNames = featureNames[-c(1)];

	# featureCombos = GetAllCombinations(featureNames, 2);

	featureCombos = list();

	featureCombos[[1]] = c(NULL);
	featureCombos[[2]] = c("IJC");
	featureCombos[[3]] = c("DeltaIJC");
	
	return(featureCombos);
}

PrepareFeatureCombos_Consensus = function()
{
	featureNames = c("Consensus1");

	featureCombos = GetAllCombinations(featureNames,2);
	return(featureCombos);

}

PrepareFeatureCombos_Social = function()
{

	featureCombos = list()
	
	rawFeatureNames = c("NumTweets","NumPopularTweets","NumVerifiedTweets");
	timeIntervals = c("Month1","Week1","Week2");
	processingTypes = c("Absolute","AbsoluteDelta");
	filteringTypes = c("all","allold","opportunity","opening","posting","hiring");

	Combos_rawFeatureNames = GetAllCombinations(rawFeatureNames, 2);
	Combos_timeIntervals = GetAllCombinations(timeIntervals, 2);
	Combos_processingTypes = GetAllCombinations(processingTypes, 2);
	Combos_filteringTypes = GetAllCombinations(filteringTypes, 2);

	pos = 1;
	maxNumFeatures = 8;

	for(i in 1:length(Combos_rawFeatureNames)
)	{
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

ConfidenceInterval = function(samples, confidence, type)
{
	n = length(samples);
	a = mean(samples);
	s = sqrt(mean((samples-a)^2));

	cbound = 1-(1-confidence)/2;

	if(type=="mean")
	{
		error = qnorm(cbound)*s/sqrt(n);
		left = a-error;
		right = a+error;
	}
	else if(type=="median")
	{
		sorted_samples = sort(samples, decreasing=FALSE);
		left_idx = n/2 - cbound*sqrt(n)/2;
		right_idx = 1 + n/2 + cbound*sqrt(n)/2;

		left = sorted_samples[round(left_idx)];
		right = sorted_samples[round(right_idx)];
	}

	return(c(left, right));
}