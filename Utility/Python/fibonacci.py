def fibonacciRec(n):
	if n==0:
		return [1]
	elif n==1:
		return [1,1]
	else:
		prev = fibonacciRec(n-1)
		return prev+[prev[n-2]+prev[n-1]]

def fibonacciIter(n):


	if n==0:
		return [1]
	else:
		result = [1,1]
		for i in range(2,n+1):
			cur = result[i-2]+result[i-1]
			result.append(cur)

		return result

print(fibonacciRec(5))
print(fibonacciIter(5))