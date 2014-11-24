require(quadprog);

# The common linear regression using lm()
LinearRegression = function(feature_training, feature_testing, label)
{
	
	if(typeof(feature_training)=="list"&&ncol(feature_training)>1){
		model = lm(label ~ ., data=feature_training);
		prediction = predict(model, newdata=feature_testing);
	} else{
		model = lm(label ~ feature_training);
		prediction = predict(model, newdata=data.frame(feature_training=feature_testing));
	}

	return(list(model=model,prediction=prediction));
}

# The linear regression solved using quadprog package
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

# Training model and get measurements using the rolling testing set
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

# Training model and get measurements using booststrapping
ModelTraining_RandomSampling = function(df,label,consensus,iteration=100,sampleSize=10,lambda=0.0,directionalConstraint=FALSE)
{
	
	metricList = matrix(nrow=0,ncol=7);
	for(i in 1:iteration)
	{
		num_rows = nrow(df);
		sample_rows = sample(1:num_rows, sampleSize, replace=F);

		df_training = df[-sample_rows,];
		df_testing = df[sample_rows,];

		label_training = label[-sample_rows];
		label_testing = label[sample_rows];

		consensus_training = consensus[-sample_rows];
		consensus_testing = consensus[sample_rows];

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

	colnames(metricList) = c("L1","medianL1","L2","medianL2","Win","DirectionalWin",
		"WeightedWin");

	return(metricList);
}