import csv

def OrderCombo(combo):
	features = combo.split('+')
	features.sort()

	return '+'.join(features)


with open('C:\\Users\\yuzhan\\SkyDrive\\Data\\BingPrediction\\NonFarmPayroll\\Test\\Combos_201409_2.txt', 'rt', encoding='UTF-8') as Features_2, \
open('C:\\Users\\yuzhan\\SkyDrive\\Data\\BingPrediction\\NonFarmPayroll\\Test\\Combos_201409.txt', 'rt', encoding='UTF-8') as Features_1, \
open('C:\\Users\\yuzhan\\SkyDrive\\Data\\BingPrediction\\NonFarmPayroll\\Test\\Combos_201409_Common.txt', 'wt', encoding='UTF-8') as Features_Common:

	features_2 = csv.reader(Features_2,delimiter="\t")
	features_1 = csv.reader(Features_1,delimiter="\t")

	L1 = []
	L_Common = []

	for row in features_1:
		L1.append(OrderCombo(row[0]))

	for row in features_2:
		if L1.__contains__(OrderCombo(row[0])):
			L_Common.append(row[0])


	output = '\n'.join(L_Common)
	Features_Common.write(output)
