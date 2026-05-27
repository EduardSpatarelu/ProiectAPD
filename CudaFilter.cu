#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "filters.h"
#include <iostream>
#include <chrono>

/* KERNEL CUDA(__global__) : Aceasta functie este lansata de CPU(Host),
 dar se executa efectiv pe Placa Video (Device / GPU).
 Aici dispare bucla 'for' dubla, deoarece MII de fire de executie ruleaza in acelasi timp! */
__global__ void applyFilterCUDA_Kernel(const unsigned char* input, unsigned char* output, int width, int height, int channels) {
    // Calculam ce pixel (X, Y) din imagine ii corespunde acestui thread grafic
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    int offset = 1;

    // Fiecare thread din GPU isi cunoaste filtrul (memorie locala rapida)
    float kernel[3][3] = {
        {-1.0f, -1.0f, -1.0f},
        {-1.0f,  8.0f, -1.0f},
        {-1.0f, -1.0f, -1.0f}
    };

    // Boundary check (Verificam sa nu incercam sa procesam in afara pozei)
    if (x >= offset && x < width - offset && y >= offset && y < height - offset) {
        // GPU-ul mai calculeaza iterativ doar canalele de culoare si vecinii mici (3x3)
        for (int c = 0; c < channels; ++c) {
            float sum = 0.0f;
            for (int ky = -offset; ky <= offset; ++ky) {
                for (int kx = -offset; kx <= offset; ++kx) {
                    int index = ((y + ky) * width + (x + kx)) * channels + c;
                    sum += input[index] * kernel[ky + offset][kx + offset];
                }
            }
            if (sum < 0.0f) sum = 0.0f;
            if (sum > 255.0f) sum = 255.0f;

            output[(y * width + x) * channels + c] = static_cast<unsigned char>(sum);
        }
    }
}

// Functia de Host care pregateste placa video
void runCUDATest(unsigned char* h_input, unsigned char* h_output, int width, int height, int channels) {
    size_t imgSize = width * height * channels * sizeof(unsigned char);
    unsigned char* d_input, * d_output; // 'd_' inseamna Device (Placa Video)

    // 1. Alocam memorie in VRAM-ul placii video
    cudaMalloc(&d_input, imgSize);
    cudaMalloc(&d_output, imgSize);

    // 2. Copiem imaginea din RAM (Host) in VRAM (Device)
    cudaMemcpy(d_input, h_input, imgSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_output, h_input, imgSize, cudaMemcpyHostToDevice);

    // 3. Impartim firele de executie in "Blocuri" de 16x16
    dim3 threadsPerBlock(16, 16);
    // Calculam de cate blocuri e nevoie ca sa acoperim toata latimea/inaltimea pozei
    dim3 numBlocks((width + threadsPerBlock.x - 1) / threadsPerBlock.x,
        (height + threadsPerBlock.y - 1) / threadsPerBlock.y);

    auto startCUDA = std::chrono::high_resolution_clock::now();

    // 4. Lansam executia pe GPU
    applyFilterCUDA_Kernel << <numBlocks, threadsPerBlock >> > (d_input, d_output, width, height, channels);

    // Verificam daca arhitectura sau parametrii au aruncat erori in CUDA
    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess) std::cout << "EROARE CUDA: " << cudaGetErrorString(error) << std::endl;

    // 5. OBLIGATORIU: Procesorul asteapta ca placa video sa termine munca inainte sa continue
    cudaDeviceSynchronize();

    auto stopCUDA = std::chrono::high_resolution_clock::now();
    std::chrono::duration<float, std::milli> durationCUDA = stopCUDA - startCUDA;
    std::cout << "Timp CUDA (Executie GPU): " << durationCUDA.count() << " ms\n";

    // 6. Aducem rezultatul procesat inapoi din VRAM in memoria RAM pentru a-l salva in fisier
    cudaMemcpy(h_output, d_output, imgSize, cudaMemcpyDeviceToHost);

    // 7. Eliberam memoria de pe placa video
    cudaFree(d_input);
    cudaFree(d_output);
}