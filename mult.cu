#include "iostream"
#include <fstream>
#include <string>

#define N	1024        // size of matrix is N*N
#define BLOCK_SIZE  16

__global__ void gpuMult ( float * a, float * b, int n, float * c )
{
    int   bx  = blockIdx.x;     
    int   by  = blockIdx.y;
    int   tx  = threadIdx.x;        
    int   ty  = threadIdx.y;
    float result = 0.0f;          
    int   idxA  = n * BLOCK_SIZE * by + n * ty;  
    int   idxB  = BLOCK_SIZE * bx + tx;

    for ( int idx = 0; idx < n; idx++ )
        result += a [idxA + idx] * b [idxB + idx*n];

    int idxC = n * BLOCK_SIZE * by + BLOCK_SIZE * bx;
    c [idxC + n * ty + tx] = result;
}

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
	
	//CPU-------------------------------------
	clock_t start_s = clock();
	cpuMult(a, b, N, c);
	clock_t stop_s = clock();
	std::cout << "Time CPU: " << (stop_s - start_s) / double(CLOCKS_PER_SEC) * 1000 <<  " ms\n";
	
	//GPU-------------------------------------
	int size = N * N * sizeof(float);
	
    float * adev = NULL;
    float * bdev = NULL;
    float * cdev = NULL;
    cudaMalloc((void**)&adev, size);
    cudaMalloc((void**)&bdev, size);
    cudaMalloc((void**)&cdev, size);

    dim3 threads(BLOCK_SIZE, BLOCK_SIZE);
    dim3 blocks(N / threads.x, N / threads.y);

    cudaEvent_t start, stop;
	cudaEventCreate(&start);
    cudaEventCreate(&stop);
    float gpuTime = 0.0f;

    cudaEventRecord(start, 0);
    cudaMemcpy(adev, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(bdev, b, size, cudaMemcpyHostToDevice);

    gpuMult<<<blocks, threads>>>(adev, bdev, N, cdev);

    cudaMemcpy(c, cdev, size, cudaMemcpyDeviceToHost);
    cudaEventRecord( stop, 0);

    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&gpuTime, start, stop);
	std::cout << "Time GPU: " << gpuTime << " ms\n";
	
	cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(adev);
    cudaFree(bdev);
    cudaFree(cdev);
    delete a;
    delete b;
    delete c;
	
	return 0;
}