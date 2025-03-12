Para compilar se requiere el engine [XeLaTeX](https://tug.org/xetex/), y el paquete [pygment](https://pygments.org/) de python dado que el antes mencionado paquete minted tiene esa dependencia.
Por lo mismo para compilar se requiere que se pase una opción extra a xelatex:

```
$xelatex -shell-escape …
```

En Ubuntu, se pueden instalar todas estas dependencias por medio del gestor de paquetes y se puede usar [Kile](https://kile.sourceforge.io/index.php) como IDE haciendo mínimos cambios en la configuración.

La primera vez, para compilar desde cero, se puede hacer:

1. Ejecutar XeLaTeX
1. Ejecutar XeLaTeX
1. Ver el pdf

Shield: [![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

Esta obra está bajo una
[Licencia Creative Commons Atribución-NoComercial-CompartirIgual 4.0 Internacional][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: https://creativecommons.org/licenses/by-nc-sa/4.0/deed.es
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg

