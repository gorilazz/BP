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
ComputeMetrics_Prediction = function(predictions,labels,consensus)
{

	prediction_latest = predictions[length(predictions)];
	predictions = predictions[1:(length(predictions)-1)];
	residuals = abs(predictions-labels);

	model = list(predictions=predictions, residuals=residuals, labels=labels, prediction_latest=prediction_latest);

	metrics = ComputeMetrics(model, consensus);

	return(c(metrics,prediction_latest));
}

# Give a list of names, get all possible subsets
GetAllSubsets = function(nameList, maxLength)
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
		result = GetAllSubsets(nameList[1:(length(nameList)-1)], maxLength);
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

# Give a list of names, get all possible combinations
GetAllCombinations = function(nameList, l)
{

	result = list();
	pos = 1;
	if(length(nameList)<l || l==0)
	{
		return(result);
	}
	else
	{
		if(l==1)
		{
			for(i in 1:length(nameList))
			{
				result[[pos]] = c(nameList[i]);
				pos = pos + 1;
			}
		}
		else
		{
			result = GetAllCombinations(nameList[1:(length(nameList)-1)], l);
			prev_result = GetAllCombinations(nameList[1:(length(nameList)-1)], l-1);

			num_result = length(result);
			pos = num_result+1;
			for(i in 1:length(prev_result))
			{
				combo = prev_result[[i]];
				result[[pos]] = c(combo,nameList[[length(nameList)]]);
				pos = pos+1;
			}
		}
	}

	return(result);
}