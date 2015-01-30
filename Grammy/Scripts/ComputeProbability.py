import csv
import operator


def main():
	features = csv.reader(open('C:\\Users\\yuzhan\\Git\\Predictions\\Grammy\\Data\\ranking_2015_nogrammy.txt', 'rt', encoding='utf-8'), delimiter='\t')
	probabilities = open('C:\\Users\\yuzhan\\Git\\Predictions\\Grammy\\Data\\probabilities_2015_nogrammy.txt', 'wt', encoding='utf-8')
	parsed_probabilities = open('C:\\Users\\yuzhan\\Git\\Predictions\\Grammy\\Data\\probabilities_2015_nogrammy_parsed.txt', 'wt', encoding='utf-8')
	
	feature_names = next(features)[1:]
	prob = {}
	parsed_prob = {}

	for row in features:
		award = row[0]
		prob[award] = []
		for item in row[1:]:
			total = sum([float(entry.split(',')[1]) for entry in item.split(';')])
			if total==0.0:
				continue
			prob[award].append(';'.join([entry.split(',')[0]+','+str(float(entry.split(',')[1])/total) for entry in item.split(';')]))
		
	probabilities.write(''+'\t'+'\t'.join(feature_names)+'\n')
	for award in prob:
		probabilities.write(award+'\t'+'\t'.join(prob[award])+'\n')
		
	probabilities.close()

	for award in prob:
		length = len(prob[award][0].split(';'))
		parsed_prob[award] = []
		for i in range(length):
			cur = [item.split(';')[i] for item in prob[award]]
			parsed_prob[award].append(cur)

	parsed_probabilities.write(''+'\t'+'\t'.join(feature_names)+'\n')
	for award in parsed_prob:
		for i in range(len(parsed_prob[award])):
			parsed_probabilities.write(award+'\t'+'\t'.join(parsed_prob[award][i])+'\n')
		
	parsed_probabilities.close()

if __name__ == '__main__':
	main()