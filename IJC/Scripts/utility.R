DateToWeekTag = function(date)
{
	date_split = strsplit(as.character(date),"[/,-]");
	
	if(nchar(date_split[[1]][1])>1)
	{
		week_id = paste(date_split[[1]][3],date_split[[1]][1],sep="");
	}
	else
	{
		week_id = paste(date_split[[1]][3],'0',date_split[[1]][1],sep="");
	}

	if(nchar(date_split[[1]][2])>1)
	{
		return(paste(week_id,date_split[[1]][2],sep=""));
	}
	else
	{
		return(paste(week_id,'0',date_split[[1]][2],sep=""));
	}
}


LinearRegression = function(feature_training, feature_testing, label, featureNames)
{
	
	if(length(featureNames)>1){
		model = lm(label ~ ., data=feature_training);
		prediction = predict(model, newdata=feature_testing);
	} else{
		model = lm(label ~ feature_training);
		prediction = predict(model, newdata=data.frame(feature_training=feature_testing));
	}

	return(list(model=model,prediction=prediction));
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

ModelTraining = function(df,featureNames,label)
{
	
	predictions = c();
	residuals = c();
	labels = c();
	for(i in 37:1)
	{
		num_rows = nrow(df)-i;
		df_training = df[1:num_rows,];
		label_training = label[1:num_rows];
		df_testing = df[num_rows+1,];
		label_testing = label[num_rows+1];

		result = LinearRegression(df_training, df_testing, label_training, featureNames);

		predictions = c(predictions,result[['prediction']]);
		residuals = c(residuals, abs(result[['prediction']]-label_testing[1]));
		labels = c(labels, label_testing[1]);
	}

	prediction_latest = predictions[length(predictions)];
	predictions = predictions[1:(length(predictions)-1)];
	residuals = residuals[1:(length(residuals)-1)];
	labels = labels[1:(length(labels)-1)];

	return(list(predictions=predictions, residuals=residuals, labels=labels, prediction_latest=prediction_latest));
}

ComputeMetrics = function(model, consensus)
{
	L1 = mean(model$residuals);
	medianL1 = median(model$residuals);
	L2 = sqrt(mean(model$residuals^2));
	medianL2 = sqrt(median(model$residuals^2));
	Win = sum(model$residuals<abs(consensus$DeltaConsensus-model$labels));
	DirectionalWin = sum((model$predictions-consensus$DeltaConsensus)*(model$labels-consensus$DeltaConsensus)>0);
	WeightedWin = sum((-1)^((model$residuals<abs(consensus$DeltaConsensus-model$labels))-1)*abs(model$residuals-abs(consensus$DeltaConsensus-model$labels)));

	return(c(L1,medianL1,L2,medianL2,Win,DirectionalWin,WeightedWin));
}


CompileTrainingResults = function(featureFull,featureCombos,label,consensusTesting)
{
	metricList = data.frame(Features=character(),"L1"=character(),"medianL1"=character(),"L2"=character(),"medianL2"=character(),"Win"=character(),"DirectionalWin"=character(),"WeightedWin"=character(),"Prediction"=character(), "PHistory"=character(),stringsAsFactors=FALSE);
	for(i in 1:length(featureCombos))
	{
		print(i);
		currentFeatureCombo = featureCombos[[i]];
		# if(!all(currentFeatureCombo,names(featureFull)))
		# {
		# 	next;
		# }
		df = featureFull[currentFeatureCombo];
		currentModel = ModelTraining(df,currentFeatureCombo,label);
		metrics = ComputeMetrics(currentModel, consensusTesting);
		metricList[nrow(metricList)+1,] <- c(paste(currentFeatureCombo,collapse="+"),metrics,currentModel$prediction_latest,paste(currentModel$predictions,collapse=","));	
	}

	return(metricList);
}

GeneratePredictions = function(featureFull,featureCombos,label)
{
	predictions = data.frame(matrix(ncol=37));

	for(i in 1:length(featureCombos))
	{
		print(i);
		currentFeatureCombo = featureCombos[[i]];
		df = featureFull[currentFeatureCombo];
		currentModel = ModelTraining(df,currentFeatureCombo,label);
		predictions[i,] = c(currentModel$predictions,currentModel$prediction_latest);
	}

	return(predictions)
}

GenerateEnsembleModel = function(predictions,labels,consensusTesting,type)
{
	predictions_current = predictions[[ncol(predictions)]];

	if(type=="mean")
	{
		result = apply(predictions,2,mean);
		confidence = ConfidenceInterval(predictions_current, 0.95, "mean");
	} else
	{
		result = apply(predictions,2,median);
		confidence = ConfidenceInterval(predictions_current, 0.95, "median");
	}

	labels = label[(length(label)-36):(length(label)-1)];

	prediction_latest = result[length(result)];
	predictions = result[1:(length(result)-1)];
	residuals = abs(predictions-labels);

	model = list(predictions=predictions, residuals=residuals, labels=labels, prediction_latest=prediction_latest);

	metrics = ComputeMetrics(model, consensusTesting);

	return(c(metrics, prediction_latest, paste(confidence,collapse=",")));
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