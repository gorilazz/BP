import csv

for DwinThreshold in range(20,27):
	with open('C:\\Users\\yuzhan\\SkyDrive\\Data\\BingPrediction\\IJC\\Model\\201410\\experiments_AR_Model_2.csv','rt',encoding='utf-8') as csv_combos, \
	open('C:\\Users\\yuzhan\\SkyDrive\\Data\\BingPrediction\\IJC\\Model\\201410\\experiments_AR_Model_2_FeatureImportance'+'_Threshold_'+str(DwinThreshold)+'.csv','wt',encoding='utf-8') as csv_importance:
		
		combos = csv.reader(csv_combos,delimiter=',')
		next(combos)

		goodCombos = dict()

		for row in combos:
			combo = row[1]
			L1 = float(row[2])
			Win = float(row[6])
			DWin = float(row[7])
			

			if DWin>=DwinThreshold:
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