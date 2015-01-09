def pascalTriangle(n):
	if n == 1:
		return [[1]]

	if n == 2:
		return [[1],[1,1]]

	if n<=0:
		return None

	triangle = pascalTriangle(n-1)

	prev_row = triangle[n-2]

	cur_row = [1]

	for i in range(1,len(prev_row)):
		cur_row.append(prev_row[i-1]+prev_row[i])

	cur_row.append(1)

	triangle.append(cur_row)

	return triangle


triangle = pascalTriangle(5)

print(triangle)