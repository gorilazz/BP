import csv
import operator


def main():
	features = csv.reader(open('C:\\Users\\yuzhan\\Git\\Predictions\\Grammy\\Data\\ranking_2015_nogrammy.txt', 'rt', encoding='utf-8'), delimiter='\t')
	ranking_file = open('C:\\Users\\yuzhan\\Git\\Predictions\\Grammy\\Data\\ranking_2015_nogrammy_parsed.txt', 'wt', encoding='utf-8')
	
	feature_names = next(features)[1:]
	parsed_ranking = {}

	for row in features:
		award = row[0]
		length = len(row[1].split(';'))
		parsed_ranking[award] = []
		for i in range(length):
			cur = [item.split(';')[i] for item in row[1:]]
			parsed_ranking[award].append(cur)

	ranking_file.write(''+'\t'+'\t'.join(feature_names)+'\n')
	for award in parsed_ranking:
		for i in range(len(parsed_ranking[award])):
			ranking_file.write(award+'\t'+'\t'.join(parsed_ranking[award][i])+'\n')
		
	ranking_file.close()

if __name__ == '__main__':
	main()