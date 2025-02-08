# Ejercicios

Todo el código en este folder está escrito en [GLSL](https://www.khronos.org/opengl/wiki/Core_Language_(GLSL)), pero al ser este un taller de [Shadertoy](https://www.shadertoy.com/) requiere la infraestructura del sitio para funcionar correctamente.

Es decir puedes copiar y pegar en los respectivos tabuladores dentro del navegador y debería de funcionar. Sin embargo, si lo quieres usar como parte de una standalone app de [OpenGL](https://www.opengl.org/) o [Vulkan](https://www.vulkan.org/), deberás adaptar el código a tus necesidades.

Recuerda que hay varias maneras de resolver cada ejercicio, dado que esto es programación creativa.
Es decir, las respuestas aquí presentadas son solo una de varias maneras de llegar al resultado.

# [Ejercicio 1: Bandera a cuadros](Ejercicio1)
Este ejercicio sirve para familiarizarte con el editor de ShaderToy.

* Puedes empezar con el código que está por default en el editor.
* El objetivo es escribir un shader que pinte una bandera a cuadros (parecida a un tablero de ajedrez)

# [Ejercicio 2: Cuadrado y círculo](Ejercicio2)
Este ejercicio sirve para aprender a organizar tu código al menos en dos archivos (Image y Common).
Puedes empezar tambien desde el codigo de default de shadertoy
En teoría debes de:
* Usar la siguiente tabla de colores como constante para el ejercicio.
* Transformar las coordenadas a coordenadas del mundo
* Abstraer el fondo en una función aparte de la escena
* Deber de usar las signed distance functions de un círculo y de un cuadrado.

# [Ejercicio 3: Transformaciones afines](Ejercicio3)
Este ejercicio sirve como ejemplo para aprender el uso de transformaciones afines.
Puedes usar el final del ejercicio anterior
* Debes de crear una escena en 2D con varias figuras escaladas, rotadas y trasladadas
* Idealmente alguna animación
* Tener algún tipo de efecto para el fondo de la escena
* Entender cómo funciona el “algoritmo del pintor” (que figura esta encima de que otra)
