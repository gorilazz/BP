import csv
import operator


def main():
	features = csv.reader(open('C:\\Users\\yuzhan\\Git\\Predictions\\Grammy\\Data\\general\\0202\\Features_2015_parsed.txt', 'rt', encoding='utf-8'), delimiter='\t')
	ranking_file = open('C:\\Users\\yuzhan\\Git\\Predictions\\Grammy\\Data\\general\\0202\\ranking_2015.txt', 'wt', encoding='utf-8')
	parsed_features = {}
	awards = {}
	feature_names = next(features)[1:]
	ranking = {}

	for row in features:
		candidate = row[0]
		f = [0 if item=='NA' else float(item) for item in row[1:]]
		award = candidate.split('-')[-1].lower()
		award = ' '.join([item for item in award.split() if item])
		candidate = '-'.join(candidate.split('-')[:-1]).lower()
		parsed_features[award] = parsed_features.get(award, {})
		parsed_features[award][candidate] = f

	for award in parsed_features:
		ranking[award] = []	
		for i in range(len(feature_names)):
			cands = {}
			for candidate in parsed_features[award]:
				cands[candidate] = parsed_features[award][candidate][i]
			sorted_cands = sorted(cands.items(), key=operator.itemgetter(1), reverse=True)
			rank = ';'.join([cand[0]+','+str(cand[1]) for cand in sorted_cands])
			ranking[award].append(rank)


	ranking_file.write(''+'\t'+'\t'.join(feature_names)+'\n')
	for award in parsed_features:
		ranking_file.write(award+'\t'+'\t'.join(ranking[award])+'\n')
		
	ranking_file.close()

if __name__ == '__main__':
	main()





				






