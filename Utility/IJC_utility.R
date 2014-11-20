source('utility.R');

PrepareFeatureCombos_AR = function(featureAR)
{
	featureNames_OneWeek = c("OneWeekBefore","OneWeekDelta");
	featureNames_TwoWeek = c("TwoWeekBefore","TwoWeekDelta");

	featureCombos_OneWeek = GetAllCombinations(featureNames_OneWeek,1);
	featureCombos_TwoWeek = GetAllCombinations(featureNames_TwoWeek,1);

	featureCombos = list();

	pos = 1;
	for (i in 1:length(featureCombos_OneWeek))
	{
		for (j in 1:length(featureCombos_TwoWeek))
		{
			featureCombos[[pos]] = c(featureCombos_OneWeek[[i]],featureCombos_TwoWeek[[j]]);
			pos = pos + 1;
		}
	}

	return(featureCombos);

}

PrepareFeatureCombos_Consensus = function(consensus)
{
	featureNames = c("Consensus","DeltaConsensus");

	featureCombos = GetAllCombinations(featureNames,2);
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

	featureCombos = list();
	featureCombos[[1]] = c();
	
	rawFeatureNames = c("NumTweets","NumDistinctUsers","NumPopularTweets","NumDistinctTweets","NumVerifiedTweets");
	timeIntervals = c("Week1","Week2");
	processingTypes = c("Absolute","AbsoluteDelta");
	# filteringTypes = c("canned","downsized","outsourced","fired","beenfired");
	filteringTypes = c("all", "all_old", "hashtags", "job_opening", "job_opportunity", "job_posting", "we_are_hiring");

	Combos_rawFeatureNames = GetAllCombinations(rawFeatureNames, 2);
	Combos_timeIntervals = GetAllCombinations(timeIntervals, 2);
	Combos_processingTypes = GetAllCombinations(processingTypes, 2);
	Combos_filteringTypes = GetAllCombinations(filteringTypes, 2);

	pos = 2;
	maxNumFeatures = 4;

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