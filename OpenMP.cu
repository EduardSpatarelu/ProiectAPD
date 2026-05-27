#include "filters.h"
#include <omp.h> // Obligatoriu pentru paralelizare pe CPU

// EXECUTIE PARALELA CPU (OpenMP): Imparte bucla for pe toate nucleele procesorului.
// Foloseste arhitectura de Memorie Partajata (Shared Memory).
void applyFilterOpenMP(unsigned char* input, unsigned char* output, int width, int height, int channels) {
    int offset = 1;

    float kernel[3][3] = {
        {-1.0f, -1.0f, -1.0f},
        {-1.0f,  8.0f, -1.0f},
        {-1.0f, -1.0f, -1.0f}
    };

    // "LINIA MAGICA"
    /*Aceasta directiva ordona compilatorului sa creeze fire de executie(threads)
    egale cu numarul de nuclee fizice ale procesorului. Fiecare nucleu va 
    procesa o alta "felie" din randurile imaginii (variabila y). */
#pragma omp parallel for
    for (int y = offset; y < height - offset; ++y) {
        for (int x = offset; x < width - offset; ++x) {
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
}