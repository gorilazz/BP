import csv

with open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Model\\201410\\experiments_AR_Social_Model_10.csv','rt',encoding='utf-8') as csv_combos, \
open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Model\\201410\\experiments_AR_Social_Model_10_FeatureImportance.csv','wt',encoding='utf-8') as csv_importance:
	
	combos = csv.reader(csv_combos,delimiter=',')
	next(combos)

	goodCombos = dict()

	for row in combos:
		combo = row[1]
		L1 = float(row[2])
		Win1 = float(row[6])
		Win2 = float(row[7])
		DWin1 = float(row[8])
		DWin2 = float(row[9])

		if L1<=45 and Win1>=8 and Win2>=6 and DWin1>=9 and DWin2>=7:
			features = combo.split('+')
			for feature in features:
				if not feature in goodCombos:
					goodCombos[feature] = 1
				else:
					goodCombos[feature] = goodCombos[feature] + 1


	importance = csv.writer(csv_importance)

	for feature in goodCombos:
		importance.writerow([feature,goodCombos[feature]])

	csv_importance.close()