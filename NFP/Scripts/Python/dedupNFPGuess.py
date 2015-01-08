import csv
from datetime import datetime

in_file = open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Model\\NFPGuess\\201411\\NFPGuess_Consensus_Thu_6.txt','rt',encoding='utf-8')

out_file = open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Model\\NFPGuess\\201411\\NFPGuess_Consensus_Thu_6_clean.txt','wt',encoding='utf-8')

data = csv.reader(in_file, delimiter='\t')

next(data)

users = {}

for row in data:
	handle = row[3]
	date = datetime.strptime(row[4],'%m/%d/%Y %H:%M:%S %p')

	if not handle in users:
		users[handle] = '\t'.join(row)
	else:
		cur_row = users[handle]
		cur_date = datetime.strptime(cur_row.split('\t')[4],'%m/%d/%Y %H:%M:%S %p')
		if date>cur_date:
			users[handle] = '\t'.join(row)

for handle in users:
	out_file.write(users[handle]+'\n')

out_file.close()