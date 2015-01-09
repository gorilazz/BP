def factorial(n):
	if n<0:
		print('This number is not valid')
	elif n<=1:
		return 1
	else:
		return n*factorial(n-1)

print(factorial(-1))