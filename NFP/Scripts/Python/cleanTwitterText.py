import csv
import re

in_file = open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Model\\NFPGuess\\201411\\NFPGuess_Prediction.txt','rt',encoding='utf-8')

out_file = open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Model\\NFPGuess\\201411\\NFPGuess_Prediction_clean.txt','wt',encoding='utf-8')

data = csv.reader(in_file,delimiter='\t')

out_data = []

for row in data:
	re.sub('[^\x00-\x7F]', ' ', row[1])
	out_data.append('\t'.join(row))

out_file.write('\n'.join(out_data))

out_file.close()