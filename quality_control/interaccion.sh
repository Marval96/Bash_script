#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------------------->
echo
echo "Hola, $USER !"
echo
echo -e "Este script realiza un análisis de calidad de datos obtenidos mediante secuenciación de nueva generación (NGS) de tipo paired-end.\n\
Utiliza la herramienta FastQC y MultiQC.\n\
Primero realiza el análisis de calidad para cada una de las muestras con FastQC y después con MultiQC genera un resumen global más fácil de interpretar."
echo
echo -e "Recuerda activar el ambiente Conda llamado 'QualityControl' el cual contiene las herramientas necesarias para el análisis.\n\
Para tener el ambiente Conda, sigue los siguientes pasos:\n\
    1. Descargar el archivo QualityControl.yml, el cual contiene el ambiente Conda.\n\
    2. Generar el ambiente Conda ejecutando: conda env create -f QualityControl.yml\n\
    3. Activar el ambiente Conda ejecutando: conda activate QualityControl."
echo
echo "¿Estás listo para ejecutar el análisis? (si/no)"
read respuesta
echo

# Comprobación de la respuesta
if [[ "$respuesta" == "si" || "$respuesta" == "SI" || "$respuesta" == "Si" ]]; then
    # Verificar si el ambiente "QualityControl" está activo y si FastQC y MultiQC están disponibles
    if conda info --envs | grep -q "QualityControl" && command -v fastqc >/dev/null && command -v multiqc >/dev/null; then
        echo "¡Perfecto! El ambiente 'QualityControl' está activo y contiene FastQC y MultiQC."
        
        # Ejecutar el análisis en segundo plano
        echo "Comenzando el análisis..."
        nohup ./analisis.sh &
        pid=$!  # Obtiene el PID del último proceso ejecutado en segundo plano
        echo "El análisis ha comenzado en segundo plano. El PID es: $pid" 
        echo "El registro se guardará en el archivo 'nohup.out'. Puedes monitorearlo ejecutando: tail -f nohup.out"
    else
        echo "Error: El ambiente 'QualityControl' no está activo o no contiene FastQC y/o MultiQC."
        echo "Por favor, asegúrate de que el ambiente esté activo y que las herramientas estén instaladas."
        exit 1
    fi
elif [[ "$respuesta" == "no" || "$respuesta" == "NO" || "$respuesta" == "No" ]]; then
    echo "Gracias, vuelva pronto, mil besos."
    exit 0  # Termina el script si la respuesta es no
else
    echo "Respuesta no válida. Por favor, responde con 'si' o 'no'."
    exit 1  # Termina el script si la respuesta no es válida
fi
echo

#-------------------------------------------------------------------------------------------------------------------------------------------------------->
