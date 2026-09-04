# Gaita Sistemas RE ↔ DO para MuseScore 4

Plugin para **MuseScore Studio 4** que permite convertir partituras de gaita entre los sistemas de escritura **RE** y **DO** sin usar una transposición cromática convencional.

La conversión se basa en la **posición diatónica de las notas en el pentagrama**, no en el sonido real que produce la gaita.

---

## ¿Qué problema resuelve?

En partituras de gaita, una misma digitación puede escribirse con nombres de nota distintos según el sistema utilizado.

Por ejemplo:

| Sistema RE | Sistema DO |
|---|---|
| Do | Re |
| Re | Mi |
| Mi | Fa |
| Fa | Sol |
| Sol | La |
| La | Si |
| Si | Do |

Una transposición normal de MuseScore trabaja con **semitonos**, por lo que puede introducir sostenidos o bemoles que no tienen sentido para este tipo de notación.

Este plugin evita ese problema moviendo cada nota **una posición diatónica**.

---

## Funciones

El plugin incluye dos comandos:

- **Gaita — RE → DO**
- **Gaita — DO → RE**

### RE → DO

```text
Do  → Re
Re  → Mi
Mi  → Fa
Fa  → Sol
Sol → La
La  → Si
Si  → Do
```

### DO → RE

Realiza exactamente la conversión inversa.

---

## Cómo funciona

El plugin no aplica una transposición del tipo:

```text
+2 semitonos
```

En su lugar, cambia el nombre/posición escrita de cada nota siguiendo la escala diatónica.

Esto significa que:

```text
Do → Re   = 2 semitonos
Mi → Fa   = 1 semitono
Si → Do   = 1 semitono
```

Aunque las distancias cromáticas sean diferentes, visualmente todas las notas avanzan o retroceden **una posición en la escala**.

---

## Alteraciones

Esta primera versión es conservadora con los sostenidos y bemoles.

- Las notas afectadas únicamente por la **armadura** se procesan normalmente.
- Si una nota tiene una **alteración explícita**, el plugin no intenta adivinar su equivalencia.
- Las notas alteradas de forma excepcional se dejan intactas para evitar conversiones incorrectas.

La versión actual tampoco modifica automáticamente la armadura de la partitura.

---

## Instalación

1. Descarga o clona este repositorio.
2. Copia los archivos:

```text
Gaita_RE_a_DO.qml
Gaita_DO_a_RE.qml
```

en la carpeta de plugins de MuseScore 4.

Puedes consultar la ruta configurada desde:

```text
Preferencias → General → Carpetas → Plugins
```

Rutas habituales:

### Windows

```text
Documentos\MuseScore4\Plugins\
```

### macOS

```text
~/Documents/MuseScore4/Plugins/
```

### Linux

```text
~/Documents/MuseScore4/Plugins/
```

3. Abre MuseScore.
4. Ve a:

```text
Plugins → Gestionar plugins
```

5. Activa:

```text
Gaita — RE → DO
Gaita — DO → RE
```

Los comandos aparecerán en el menú de plugins.

---

## Uso

### Convertir toda la partitura

Si no hay ninguna selección activa, el plugin procesa toda la partitura.

### Convertir solo una parte

Selecciona uno o varios compases y ejecuta el comando correspondiente.

Solo se convertirá el fragmento seleccionado.

### Deshacer

La conversión puede deshacerse normalmente con:

```text
Ctrl + Z
```

o:

```text
Cmd + Z
```

en macOS.

---

## Prueba rápida

Crea una partitura con:

```text
Do Re Mi Fa Sol La Si
```

Ejecuta:

```text
Gaita — RE → DO
```

El resultado debería ser:

```text
Re Mi Fa Sol La Si Do
```

Después ejecuta:

```text
Gaita — DO → RE
```

y la partitura debería volver al estado original.

---

## Limitaciones actuales

Esta es una primera versión del plugin.

Actualmente:

- no convierte automáticamente la armadura;
- no intenta interpretar alteraciones cromáticas explícitas;
- está pensado principalmente para partituras de gaita basadas en posiciones de digitación;
- conviene probarlo primero sobre una copia de la partitura.

---

## Posibles mejoras

Algunas mejoras que podrían añadirse en futuras versiones:

- conversión automática de armaduras;
- soporte configurable para alteraciones;
- selector único con botones `RE → DO` y `DO → RE`;
- detección automática del sistema de origen;
- interfaz propia dentro de MuseScore;
- soporte para más convenciones de escritura de gaita.

---

## Archivos

```text
Gaita_RE_a_DO.qml
Gaita_DO_a_RE.qml
README.md
```

---

## Contribuciones

Si encuentras una partitura o caso concreto en el que la conversión no sea correcta, abre un **Issue** incluyendo, si es posible:

- nota original;
- sistema original;
- resultado esperado;
- captura o fragmento de la partitura.

Esto ayudará a definir correctamente casos especiales de armaduras y alteraciones.

---

## Licencia

Puedes añadir aquí la licencia que quieras utilizar para el proyecto, por ejemplo **MIT**.

---

## Estado del proyecto

Versión inicial experimental.

Se recomienda probar el plugin con partituras pequeñas antes de utilizarlo sobre trabajos importantes.
