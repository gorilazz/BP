import csv
import re

def main():
	data_file = open('C:\\Users\\yuzhan\\Git\\Predictions\\Superbowl\\Pulse\\ngrams.txt', 'rt', encoding='utf-8')
	top_ngrams = open('C:\\Users\\yuzhan\\Git\\Predictions\\Superbowl\\Pulse\\top_ngrams.txt', 'wt', encoding='utf-8')

	ngrams = csv.reader(data_file, delimiter='\t')

	for line in ngrams:
		candidate = line[0]
		date = line[1]
		if date=='20150201':
			ngrams = []
			for i in range(14,22):
				toks = [item.split('|')[0]+':'+item.split(':')[1] for item in line[i].split('||')]
				result = toks[:10] if len(toks)>=10 else toks
				ngrams.append(','.join(result))
		
			top_ngrams.write(candidate + '\t' + '\t'.join(ngrams) + '\n')

	top_ngrams.close()

if __name__=='__main__':
	main()