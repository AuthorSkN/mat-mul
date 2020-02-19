#include "iostream"
#include <fstream>
#include <string>

#define N	4        // size of matrix is N*N

void cpuMult( float * a, float * b, int n, float * c ) {
	for (int rowIdxC = 0; rowIdxC < n; rowIdxC++) {
		for (int colIdxC = 0; colIdxC < n; colIdxC++) {
			float resultC = 0.0f;
			for (int idx = 0; idx < n; idx++) {
				int idxA = (rowIdxC * n) + idx;
				int idxB = colIdxC + (idx * n);
				resultC += a[idxA] * b[idxB];
			}
			int idxC = rowIdxC * n + colIdxC;
			c[idxC] = resultC;
		}
	}
}

int main() {
	float * a = new float [N*N];
    float * b = new float [N*N];
    float * c = new float [N*N];

    for ( int i = 0; i < N; i++ ) {
        for ( int j = 0; j < N; j++ ) {
            int k = N * i + j;

            a [k] = k;
            b [k] = k;
        }
	}
	
	clock_t start_s = clock();
	cpuMult(a, b, N, c);
	clock_t stop_s = clock();
	std::cout << "Time CPU: " << (stop_s - start_s) / double(CLOCKS_PER_SEC) * 1000 <<  " ms\n";
	
	return 0;
}