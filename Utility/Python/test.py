import csv

in_file = open('C:\\Users\\yuzhan\\Git\\Predictions\\EOY\\Tech\\MonthlyCounts.txt','rt',encoding='utf-8')
out_file_path = 'C:\\Users\\yuzhan\\Git\\Predictions\\EOY\\Tech\\MonthlyCounts'



data = csv.reader(in_file,delimiter='\t')

next(data)

entities = {}


for row in data:
	entity = ' '.join(row[0].split(' ')[:-1])
	area = row[0].split(' ')[-1]
	year = row[1][0:4]
	month = row[1][4:6]

	if month=='12':
		continue

	num_tweets = int(row[4])

	if area in entities:
		if entity in entities[area]:
			entities[area][entity][year] = entities[area][entity].get(year,0) + num_tweets
		else:
			entities[area][entity] = {year:num_tweets}
	else:
		entities[area] = {entity:{year:num_tweets}}


for area in entities:
	out_file_cur = out_file_path + '_' + area + '.csv'
	out_file = open(out_file_cur,'wt',encoding='utf-8')

	out_list = []

	for entity in entities[area]:
		if not '2013' in entities[area][entity]:
			val_2013 = '0'
		else:
			val_2013 = str(entities[area][entity]['2013'])

		if not '2014' in entities[area][entity]:
			val_2014 = '0'
		else:
			val_2014 = str(entities[area][entity]['2014'])

		out_list.append(entity+','+val_2013+','+val_2014)

	out_file.write('\n'.join(out_list))
	out_file.close()
