import csv
import operator


def main():
	features = csv.reader(open('C:\\Users\\yuzhan\\Git\\Predictions\\Grammy\\Data\\general\\Features_2014_parsed.txt', 'rt', encoding='utf-8'), delimiter='\t')
	results = csv.reader(open('C:\\Users\\yuzhan\\Git\\Predictions\\Grammy\\Data\\Winners_2014.txt', 'rt', encoding='utf-8'), delimiter='\t')
	win_loss_performance = open('C:\\Users\\yuzhan\\Git\\Predictions\\Grammy\\Data\\general\\win_loss_2014.txt', 'wt', encoding='utf-8')
	distance_performance = open('C:\\Users\\yuzhan\\Git\\Predictions\\Grammy\\Data\\general\\distance_2014.txt', 'wt', encoding='utf-8')
	parsed_features = {}
	awards = {}
	feature_names = next(features)[1:]
	win_loss = {}
	distance = {}

	for row in features:
		candidate = row[0]
		f = [0 if item=='NA' else float(item) for item in row[1:]]
		award = candidate.split('-')[-1].lower()
		award = ' '.join([item for item in award.split() if item])
		candidate = '-'.join(candidate.split('-')[:-1]).lower()
		parsed_features[award] = parsed_features.get(award, {})
		parsed_features[award][candidate] = f

	for row in results:
		award, winner = [item.lower() for item in row]
		awards[award] = winner

	for award in parsed_features:
		win_loss[award] = []
		distance[award] = []
		winner = awards[award]
		for i in range(len(feature_names)):
			cands = {}
			
			for candidate in parsed_features[award]:
				cands[candidate] = parsed_features[award][candidate][i]

			sorted_cands = sorted(cands.items(), key=operator.itemgetter(1), reverse=True)

			
			rank = 0
			while rank<len(sorted_cands) and sorted_cands[rank][0]!=winner:
				rank += 1
			win = 1 if rank==0 else 0
			win_loss[award].append(1 if rank==0 else 0)
			distance[award].append(rank)

	win_loss_performance.write(''+'\t'+'\t'.join(feature_names)+'\n')
	distance_performance.write(''+'\t'+'\t'.join(feature_names)+'\n')
	for award in parsed_features:
		win_loss_performance.write(award+'\t'+'\t'.join([str(item) for item in win_loss[award]])+'\n')
		distance_performance.write(award+'\t'+'\t'.join([str(item) for item in distance[award]])+'\n')

	win_loss_performance.close()
	distance_performance.close()

if __name__ == '__main__':
	main()





				






