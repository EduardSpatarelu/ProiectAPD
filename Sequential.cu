#include "filters.h"

// EXECUTIE SECVENTIALA: Ruleaza pe un singur fir de executie (Thread) pe CPU.
void applyFilterSequential(unsigned char* input, unsigned char* output, int width, int height, int channels) {
    /* Matricea 3x3 a pixelului are nevoie de o margine de 1 pixel(offset)
     ca sa nu iesim in afara imaginii cand calculam vecinii. */
    int offset = 1;

    // Definim matricea de convolutie pentru "Edge Detection" (Detectare margini)
    float kernel[3][3] = {
        {-1.0f, -1.0f, -1.0f},
        {-1.0f,  8.0f, -1.0f},
        {-1.0f, -1.0f, -1.0f}
    };

    // Parcurgem matricea imaginii: Y (randuri) si X (coloane)
    for (int y = offset; y < height - offset; ++y) {
        for (int x = offset; x < width - offset; ++x) {

            // O imagine color are 3 canale (RGB: Rosu, Verde, Albastru). Le procesam pe rand.
            for (int c = 0; c < channels; ++c) {
                float sum = 0.0f;

                // Aplicam matricea (filtrul) de 3x3 peste pixelii vecini
                for (int ky = -offset; ky <= offset; ++ky) {
                    for (int kx = -offset; kx <= offset; ++kx) {
                        // Formula pentru a gasi pixelul in array-ul 1D al imaginii
                        int index = ((y + ky) * width + (x + kx)) * channels + c;
                        // Inmultim culoarea pixelului cu numarul din matricea noastra
                        sum += input[index] * kernel[ky + offset][kx + offset];
                    }
                }

                // Normalizare: Un pixel pe ecran poate avea doar culori intre 0 (Negru) si 255 (Alb).
                // Daca suma a dat cu minus, o fortam la 0. Daca a depasit 255, o taiem la 255.
                if (sum < 0.0f) sum = 0.0f;
                if (sum > 255.0f) sum = 255.0f;

                // Salvam culoarea finala in imaginea de output
                output[(y * width + x) * channels + c] = static_cast<unsigned char>(sum);
            }
        }
    }
}