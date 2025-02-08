Para compilar se requiere el engine [XeLaTeX](https://tug.org/xetex/), y el paquete [pygment](https://pygments.org/) de python dado que el antes mencionado paquete minted tiene esa dependencia.
Por lo mismo para compilar se requiere que se pase una opción extra a xelatex:

```
$xelatex -shell-escape …
```

En Ubuntu, se pueden instalar todas estas dependencias por medio del gestor de paquetes y se puede usar [Kile](https://kile.sourceforge.io/index.php) como IDE haciendo mínimos cambios en la configuración.

La primera vez, para compilar desde cero, se puede hacer:

1.Ejecutar XeLaTeX
1.Ejecutar XeLaTeX
1.Ver el pdf

