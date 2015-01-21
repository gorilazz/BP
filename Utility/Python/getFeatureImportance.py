import csv

with open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Model\\201412\\CV\\experiments_All_Model_1_unrevised_median.csv','rt',encoding='utf-8') as csv_combos, \
open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Model\\201412\\CV\\experiments_All_Model_1_unrevised_median_FeatureImportance.csv','wt',encoding='utf-8') as csv_importance:
	
	combos = csv.reader(csv_combos,delimiter=',')
	next(combos)

	goodCombos = dict()

	for row in combos:
		combo = row[1]
		L1 = float(row[2])
		Win = float(row[6])
		DWin = float(row[7])

		if L1<50 and DWin>3.9:
			features = combo.split('+')
			for feature in features:
				if not feature in goodCombos:
					goodCombos[feature] = 1
				else:
					goodCombos[feature] = goodCombos[feature] + 1


	for feature in goodCombos:
		csv_importance.write('%s' % (feature + ',' + str(goodCombos[feature]))+'\n')

	csv_importance.close()