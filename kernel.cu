#include <iostream>
#include <chrono>
#include "filters.h" 

// Librariile de citit/scris imagine (stb) se implementeaza o singura data, in fisierul main.
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

int main() {
    std::cout << "=== PROIECT APD: EDGE DETECTION ===\n" << std::endl;

    int width, height, channels;
    const char* inputFile = "input.jpg";

    // 1. CITIREA IMAGINII
    // stbi_load incarca imaginea in memoria RAM si populeaza variabilele de latime si inaltime
    unsigned char* imgInput = stbi_load(inputFile, &width, &height, &channels, 0);
    if (imgInput == NULL) {
        std::cout << "Eroare la incarcarea imaginii! Lipseste input.jpg" << std::endl;
        return -1;
    }
    std::cout << "Imagine incarcata! Rezolutie: " << width << "x" << height << "\n" << std::endl;

    // 2. PREGATIREA MEMORIEI PENTRU REZULTATE
    size_t imgSize = width * height * channels;
    unsigned char* imgOutputSeq = new unsigned char[imgSize];
    unsigned char* imgOutputOMP = new unsigned char[imgSize];
    unsigned char* imgOutputCUDA = new unsigned char[imgSize];

    // Copiem imaginea curata in output-uri ca sa le pastram marginile neprocesate
    memcpy(imgOutputSeq, imgInput, imgSize);
    memcpy(imgOutputOMP, imgInput, imgSize);
    memcpy(imgOutputCUDA, imgInput, imgSize);

    // 3. RULARE TEST 1: SECVENTIAL
    std::cout << "----------------------------------------\n";
    std::cout << "1. Executie SECVENTIALA\n";
    auto startCPU = std::chrono::high_resolution_clock::now();

    applyFilterSequential(imgInput, imgOutputSeq, width, height, channels);

    auto stopCPU = std::chrono::high_resolution_clock::now();
    std::chrono::duration<float, std::milli> durationCPU = stopCPU - startCPU;
    std::cout << "Timp Secvential: " << durationCPU.count() << " ms\n";

    // 4. RULARE TEST 2: OPENMP
    std::cout << "----------------------------------------\n";
    std::cout << "2. Executie PARALELA (OpenMP)\n";
    auto startOMP = std::chrono::high_resolution_clock::now();

    applyFilterOpenMP(imgInput, imgOutputOMP, width, height, channels);

    auto stopOMP = std::chrono::high_resolution_clock::now();
    std::chrono::duration<float, std::milli> durationOMP = stopOMP - startOMP;
    std::cout << "Timp OpenMP: " << durationOMP.count() << " ms\n";

    // 5. RULARE TEST 3: CUDA (GPU)
    std::cout << "----------------------------------------\n";
    std::cout << "3. Executie PARALELA MASIVA (CUDA GPU)\n";

    runCUDATest(imgInput, imgOutputCUDA, width, height, channels);

    std::cout << "----------------------------------------\n";

    // 6. SALVAREA REZULTATULUI
    // Scriem rezultatul final de pe placa video pe SSD
    stbi_write_jpg("output_jerry_edges.jpg", width, height, channels, imgOutputCUDA, 100);

    // 7. CLEAN-UP
    // Eliberam obligatoriu memoria RAM ca sa nu cream "memory leaks"
    stbi_image_free(imgInput);
    delete[] imgOutputSeq;
    delete[] imgOutputOMP;
    delete[] imgOutputCUDA;

    std::cout << "\nTeste finalizate! Verifica folderul proiectului." << std::endl;
    return 0;
}