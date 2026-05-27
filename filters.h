#pragma once

// HEADER FILE: Aici doar anuntam (declaram) functiile pe care le vom folosi. Astfel, fisierul principal (kernel.cu) stie ca ele exista in alte fisiere.

void applyFilterSequential(unsigned char* input, unsigned char* output, int width, int height, int channels);
void applyFilterOpenMP(unsigned char* input, unsigned char* output, int width, int height, int channels);
void runCUDATest(unsigned char* h_input, unsigned char* h_output, int width, int height, int channels);