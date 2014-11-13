require(quadprog);

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

# Compute the metrics given a model
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

# Compute the metrics given the predictions
ComputeMetrics_Prediction = function(predictions,labels,consensus,type)
{

	if(type=="mean")
	{
		result = apply(predictions,2,mean);
	} else
	{
		result = apply(predictions,2,median);
	}

	prediction_latest = result[length(result)];
	predictions = result[1:(length(result)-1)];
	residuals = abs(predictions-labels);

	model = list(predictions=predictions, residuals=residuals, labels=labels, prediction_latest=prediction_latest);

	metrics = ComputeMetrics(model, consensus);

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