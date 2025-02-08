Read.me
Este repositorio contiene todos los materiales del taller: que se imparte en el marco del [Congreso de Inteligencia Artificial](), los días 7 y 9 de abril del 2025. Aunque el taller se impartió de manera remota la sede oficial fue la [FES Acatlán](https://www.acatlan.unam.mx/).

Hay dos grandes secciones en este repositorio:

## [Presentacion](presentacion)
Que contiene las diapositivas usadas durante el taller. Estan escritas en LaTeX usando Beamer.

## [Codigo](codigo)
Que contiene todo el código fuente, que se mostró en el taller, así como los ejercicios resueltos durante el mismo.

Dado que es un taller de [Shadertoy](https://www.shadertoy.com/) todo el código está escrito en [GLSL](https://www.khronos.org/opengl/wiki/Core_Language_(GLSL)) y requiere de la infraestructura del sitio web para funcionar.

Es decir, debes de poder copiar y pegar el código en ventanas del navegador y debería de funcionar.

Las diapositivas están bajo una licencia creative commons, mientras que el código está bajo una licencia GNU/GPL.


Readme presentacion

Para compilar se requiere el engine [XeLaTeX](https://tug.org/xetex/), y el paquete [pygment](https://pygments.org/) de python dado que el antes mencionado paquete minted tiene esa dependencia. Por lo mismo para compilar se requiere que se pase una opción extra a xelatex:

```
$xelatex -shell-escape …
```

En Ubuntu, se pueden instalar todas estas dependencias por medio del gestor de paquetes y se puede usar [Kile](https://kile.sourceforge.io/index.php) como IDE haciendo mínimos cambios en la configuración.

La primera vez, para compilar desde cero, se puede hacer:

1.Ejecutar XeLaTeX
1.Ejecutar XeLaTeX
1.Ver el pdf

Readme codigo
Todo el código en este folder está escrito en [GLSL](https://www.khronos.org/opengl/wiki/Core_Language_(GLSL)), pero al ser este un taller de [Shadertoy](https://www.shadertoy.com/) requiere la infraestructura del sitio para funcionar correctamente.

Es decir puedes copiar y pegar en los respectivos tabuladores dentro del navegador y debería de funcionar. Sin embargo, si lo quieres usar como parte de una standalone app de [OpenGL](https://www.opengl.org/) o [Vulkan](https://www.vulkan.org/), deberás adaptar el código a tus necesidades.
