PrepareFeatureCombos_AR = function(features)
{
	# featureNames = names(features);
	# featureNames = featureNames[-c(1:2)];

	a = c("OneMonthBefore","TwoMonthBefore");
	b = c("UnRevised","Revised");

	aCombos = GetAllSubsets(a,2);
	bCombos = GetAllSubsets(b,1);
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

	return(featureCombos);

}

PrepareFeatureCombos_IJC = function(features)
{


	featureCombos = list();

	featureCombos[[1]] = c(NULL);
	featureCombos[[2]] = c("IJC");
	
	return(featureCombos);
}

PrepareFeatureCombos_Consensus = function()
{
	featureNames = c("Consensus1");

	featureCombos = GetAllSubsets(featureNames,2);
	return(featureCombos);

}

PrepareFeatureCombos_Social = function()
{

	featureCombos = list()
	
	rawFeatureNames = c("NumTweets","NumPopularTweets","NumVerifiedTweets","NumDistinctTweets","NumDistinctUsers");
	timeIntervals = c("Month1","Month2","Week1","Week2");
	processingTypes = c("A","N", "AD", "ND");
	filteringTypes = c("all","allold","opportunity","opening","posting","hiring","hashtags");

	Combos_rawFeatureNames = GetAllSubsets(rawFeatureNames, 2);
	Combos_timeIntervals = GetAllSubsets(timeIntervals, 2);
	Combos_processingTypes = GetAllSubsets(processingTypes, 1);
	Combos_filteringTypes = GetAllSubsets(filteringTypes, 2);

	pos = 1;
	maxNumFeatures = 5;

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