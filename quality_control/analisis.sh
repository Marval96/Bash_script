#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------------------->

# Iniciar el temporizador
start_time=$(date +%s.%N)

# Una vez con los programas instalados dentro del ambiente conda (el cual debe estar activo) podemos realizar nuestro análisis de calidad.

# Verificación de que hay un número par de archivos fastq en el directorio:
# El número debe ser par porque son lecturas paredas, la mitad será R1 y la otra R2. 
# Hay espacio a una ambiguedad donde no tengo archivos pareados correctamente pero aún así el total de archivos es par y curiosamente R1=R2
# No hago una verificación considerando el nombre de los archivos porque no hay un formato universal.

echo
echo "Verificando número par de archivos fastq y presencia de archivos R1 y R2:"

# Contar archivos que contienen 'R1' y 'R2' en sus nombres
file_count_R1=$(ls *R1*.f*q.gz 2>/dev/null | wc -l)
file_count_R2=$(ls *R2*.f*q.gz 2>/dev/null | wc -l)

# Verifica que los números de archivos 'R1' y 'R2' sean iguales
if (( file_count_R1 != file_count_R2 )); then
    echo "Error: El número de archivos R1 y R2 no coincide. Asegúrate de que cada muestra tenga su archivo R1 & R2."
    exit 1
fi

# Verifica que el total sea un número par
total_files=$((file_count_R1 + file_count_R2))
if (( total_files % 2 != 0 )); then
    echo "Error: El número total de archivos no es par. Asegúrate de que cada muestra tenga un archivo de par."
    exit 1
fi

echo "Verificación completa: Número de archivos par y pareados R1 y R2."
echo

# Verifica que todos los archivos son fastq 
# Sé que solo considero la extensión y que sería mejor usar el comando "file" para la verificación...pero no quisera descomprimir los archivos 
# con el objetivo de no ocupar más  espacio en el disco ni hacer más lento el proceso, pues podría descomprimir, correr "file" y volver a comprimir.

echo 
echo "Verificando que todos los archivos tengan formato .fastq.gz o .fq.gz..."
for file in *.f*q.gz; do
    if [[ ! "$file" =~ \.f(ast)?q\.gz$ ]]; then
        echo "Error: $file no es un archivo .fastq.gz o .fq.gz."
        exit 1
    fi
done
echo "Todos los archivos tienen la extensión correcta (.fastq.gz o .fq.gz)."
echo 

# Un archivo fastq es un archivo de texto plano (txt) que contiene la caldiad de las secuencias por base, codificado en ASCII.
# Cada archivo fastq consta de 4 líneas, por ello, si dividimos el número total de lineas de los archivos entre 4 esto debería dar igual a 0.
# Los archivos fastq contiene la caldiad de secuencias codificado en 4 líneas: la primera es el ID e inica con un @, la segunda son los núcleotidos
# y puede iniciar con A,T,C,G,N; la tarcera es un signo "+" y al final viene la codificación Phred en código ASCII, que puede ser cualquier signo.
# Analizo una lectura al azar porque analizar todo el archivo fastq línea por línea es un proceso muy pesado, entonces se toma un lectura al azar.
# Igual tengo la verificacíon de que todas las reads tienen sus respectivas 4 líneas, entonces asumo el riesgo de confiar en que todo esta bien
# en lugar de invertir demasiado tiempo de computo.

# Validación del formato de los archivos fastq de manera aleatoria
echo 
echo "Validando el formato de cada archivo fastq con una lectura aleatoria..."
for file in *.f*q.gz; do
    echo "Revisando una lectura aleatoria en $file..."
    
    # Obtener el número total de líneas en el archivo
    total_lines=$(zcat "$file" | wc -l)
    
    # Asegurarse de que el número de líneas es múltiplo de 4
    if (( total_lines % 4 != 0 )); then
        echo "Error: $file no cumple con el formato de fastq. El número de líneas no es múltiplo de 4."
        exit 1
    fi

    # Seleccionar una posición de línea aleatoria que sea el comienzo de una lectura (1, 5, 9, ..., total_lines - 3)
    start_line=$(( (RANDOM % (total_lines / 4)) * 4 + 1 ))

    # Extraer las 4 líneas correspondientes a esa lectura
    read_block=$(zcat "$file" | sed -n "${start_line},$((start_line+3))p")
    
    # Separar cada línea del bloque
    line1=$(echo "$read_block" | sed -n '1p')
    line2=$(echo "$read_block" | sed -n '2p')
    line3=$(echo "$read_block" | sed -n '3p')
    line4=$(echo "$read_block" | sed -n '4p')

    # Validar el formato de las 4 líneas
    if [[ $line1 != @* ]]; then
        echo "Error: La primera línea de $file no empieza con '@'."
        exit 1
    fi
    if [[ ! "$line2" =~ ^[ATCGN]+$ ]]; then
        echo "Error: La segunda línea de $file contiene caracteres no válidos. Debería contener solo A, T, C, G o N."
        exit 1
    fi
    if [[ $line3 != "+" ]]; then
        echo "Error: La tercera línea de $file no es '+'."
        exit 1
    fi
    if [[ -z "$line4" ]]; then
        echo "Error: La cuarta línea de $file (calidad de secuencias) está vacía."
        exit 1
    fi
done
echo "Formato de archivos fastq validado correctamente con una lectura aleatoria."
echo


# -------------------------------------------------------------------------------------------------------------------------------------------------------->

# Análisis de Calidad con FastQC y MultiQC

echo
echo "Iniciando análisis de calidad con FastQC para cada archivo..."
mkdir -p FastQC_Results
for file in *.f*q.gz; do
    echo "Procesando $file ..."
    fastqc -o FastQC_Results "$file"
done
echo

# Ejecutar MultiQC para generar el informe global

echo
echo "Generando informe global con MultiQC..."
multiqc FastQC_Results -o FastQC_Results

# Calcular el tiempo de ejecución
end_time=$(date +%s.%N)
execution_time=$(echo "$end_time - $start_time" | bc)
# Convertir segundos a minutos:segundos
minutes=$(echo "scale=0; $execution_time / 60" | bc)
seconds=$(echo "scale=0; $execution_time % 60" | bc)
total_minutes=$(echo "$minutes + ($seconds > 0)" | bc)

echo "Análisis de calidad completado. Los resultados se encuentran en la carpeta FastQC_Results."
echo "Tiempo de ejecución: $minutes minutos $seconds segundos."
echo

# -------------------------------------------------------------------------------------------------------------------------------------------------------->

