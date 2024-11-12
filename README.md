# Bash_script
Espacio para compartir distintos programas de Bash que ayuden a optimizar tareas.

*May the Force be with you*

![May the Force be with you](linux_sw.jpg)


Aquí encontrarás el material necesario para realizar un análisis de calidad de lecturas, obtenidas por *Next-generation sequencing (NGS)*, para una secuenciación de tipo *paired-end*. 

El archivo **qc.sh** es el script necesario para automatizar esta tarea usando el *shell* **Bash**. Por ende, esto solo podrá ejecutarse en sistemas operativos tipo *Unix*.

El análisis requiere de las herraminetas [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) y [MultiQC](https://seqera.io/multiqc/). Para mayor comodidad puedes descargar el [ambiente Conda](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html) que hemos generado con las librerías necesarias. Descarga el archivo **QualityControl.yml** y ejecuta:

    conda env create -f QualityControl.yml

 Esto crea el ambiente de Conda con las herramientas necesarias. Ahora solo deberás activarlo. Para ello ejecuta:

    conda activate QualityControl

Para realizar el análsis debes ejecutar el script *qc.sh* en el mismo directorio donde tienes tus archivos de secuenciación.

Para correr un script normalmente se ejecuta:

    ./script.sh

Nosotros recomendamos ejecutarlo en segundo plano, así puedes seguir trabajando en la misma terminal y tu proceso se ejecuta sin importar que cierres dicha terminal. Así puedes irte casa mientras la computadora hace el análisis. 

    nohup ./qc.sh &

