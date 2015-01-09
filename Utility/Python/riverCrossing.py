def riverCrossing(m,c,m_next,c_next,sol):

	if m<c or m_next<c_next:
		return False;

	if sol[m][c]:
		return True

	if m==0 and c==0:
		sol[m][c] = [0,0]
		return True

	for i in range(0,m+1):
		for j in range(0,c+1):
			if (i+j)<=2 and (i+j)>0:
				result = riverCrossing(m-i,c-j,m_next+i,c_next+j,sol)

				if result:
					sol[m][c]=[i,j]
					return result

	return False


m = 3
c = 3

sol = []

for t in range(0,m+1):
	sol.append([None]*(c+1))

a = riverCrossing(m,c,0,0,sol)

print(a)
print(sol)