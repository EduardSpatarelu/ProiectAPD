# ProiectAPD

# Procesare Paralela de Imagini: Analiza Performantei (Secvential vs OpenMP vs CUDA)

## 📌 Topicul Proiectului
Acest proiect demonstreaza aplicarea filtrelor de convolutie (in special **Edge Detection** si **Blur**) pe imagini digitale, folosind arhitecturi de calcul paralel. Scopul principal este analiza comparativa a performantei (timpul de executie si factorul de accelerare/speedup) intre o abordare clasica secventiala, paralelizarea pe un procesor multi-core folosind memorie partajata si paralelizarea masiva pe o unitate de procesare grafica (GPU). 

## 💻 Limbajele de Programare
* **C++** (pentru logica principala si paralelizarea pe CPU)
* **CUDA C/C++** (pentru scrierea kernel-urilor executate pe placa video)

## ⚙️ Sistemele si Framework-urile folosite
* **NVIDIA CUDA Toolkit:** Utilizat pentru alocarea memoriei video (VRAM) si lansarea miilor de fire de executie simultane.
* **OpenMP (Open Multi-Processing):** API utilizat pentru paralelizarea buclelor la nivel de CPU (Shared Memory).
* **Librariile stb (`stb_image.h`, `stb_image_write.h`):** Utilizate pentru decodarea si salvarea imaginilor.
* **Microsoft Visual Studio 2022:** Mediul de dezvoltare integrat.

## 👨‍💻 Autor
Proiect realizat integral de Eduard.

## 🚀 Cum se ruleaza
1. Proiectul se deschide folosind solutia `.sln` in Visual Studio.
2. Asigurati-va ca fisierul de test `input.jpg` se afla in acelasi director cu sursele (`.cu`, `.h`).
3. Compilati si rulati. Fisierul de iesire va fi generat automat in acelasi folder, iar timpii de executie vor fi afisati in consola.
