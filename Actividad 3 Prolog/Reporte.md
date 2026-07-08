# Reporte de Sistemas Expertos Desarrollados
## Introducción

Se han implementado tres sistemas expertos utilizando diferentes tecnologías, cada uno orientado a resolver un problema específico en el ámbito académico y de gestión de recursos. Los sistemas desarrollados son:

Sistema Experto en SWI‑Prolog para la elección de cursos en un programa educativo de Ingeniería en Sistemas Computacionales (ISC), respetando seriación y aprovechamiento del alumno.

Sistema Experto en Tau‑Prolog para la asignación de proyectos de software a programadores según su nivel de experiencia, con verificación de personal necesario y detección de faltantes.

Sistema Experto en Go para el control de ingredientes de platillos en un menú, permitiendo consultar disponibilidad y faltantes en el inventario.

A continuación se detalla cada sistema, su arquitectura, funcionalidades, ejemplos de uso y las dificultades encontradas durante su implementación.

---

1. Sistema Experto en SWI‑Prolog – Elección de Cursos (ISC)

- 1.1. Propósito
Apoyar a alumnos, tutores y gestores académicos en la elección de cursos, garantizando que se respeten los prerrequisitos, el número máximo de materias según el promedio y el historial de reprobación, y detectando situaciones de bajo rendimiento o necesidad de baja académica.

- 1.2. Base de Conocimientos
La base de conocimiento incluye:

Materias: con clave, nombre, semestre y área (ej. materia('M101', 'Matemáticas 1', 1, 'Básicas')).

Prerrequisitos: relaciones entre materias (ej. prerreq('M102', 'M101')).

Alumnos: identificador y nombre.

Cursó: registro de cada intento de cursar una materia con su calificación (ej. cursó(1, 'M101', 85, 1)).

- 1.3. Reglas de Negocio
Aprobación: un alumno aprueba una materia si su última calificación es ≥ 70.

Carga máxima: si el promedio general es < 80 o tiene más de una materia reprobada, solo puede cargar 4 materias; en caso contrario, hasta 6.

Baja: si un alumno reprueba una misma materia tres veces, debe ser dado de baja.

Alto rendimiento: alumnos con promedio ≥ 90.

Aspirantes: para una materia dada, se listan los alumnos que pueden cursarla (cumplen prerrequisitos y no la han aprobado aún) y se cuenta el total.

Materias por semestre y área: agrupación para visualización.

- 1.4. Implementación
El sistema se implementa como un servidor HTTP en SWI‑Prolog, exponiendo endpoints REST que devuelven respuestas en formato JSON.

### Endpoints principales:

Endpoint	Descripción
/student/ID/courses	Cursos que puede llevar el alumno ID
/student/ID/load	Carga máxima permitida para el alumno ID
/student/ID/dropout	Indica si el alumno debe ser dado de baja
/high_achievers	Lista de alumnos de alto rendimiento
/subjects	Materias agrupadas por semestre y área
/course/Clave/aspirants	Aspirantes a una materia y su número total

- 1.5. Ejemplo de Uso
Consulta: GET /student/1/courses

Respuesta: {"id":1, "cursos":["M102","F102","P102"]}

- 1.6. Dificultades y Soluciones
Parsing de números en la URL: se utilizó atom_number/2 para convertir el ID a entero.

Manejo de múltiples intentos: se definió ultimo_intento/3 para obtener la última calificación de cada materia.

Formato de respuesta: se empleó reply_json_dict/1 para generar JSON válido.

---

2. Sistema Experto en Tau‑Prolog – Asignación de Proyectos a Programadores

- 2.1. Propósito
Asignar proyectos de software a programadores según su nivel (junior, avanzado, senior), verificando que el equipo cumpla con los requerimientos de cada proyecto y, en caso contrario, identificar el personal faltante.

- 2.2. Base de Conocimientos
Desarrolladores: 10 ficticios con nombre y nivel.

Proyectos: 10 ficticios con nivel de dificultad (bajo, medio, alto, muy alto).

Requerimientos: cada nivel de proyecto requiere una combinación específica de roles:

Bajo: 1 avanzado + 1 junior

Medio: 1 senior + 1 avanzado

Alto: 1 senior + 1 avanzado + 1 junior

Muy alto: 1 senior + 2 avanzados + 2 juniors

- 2.3. Reglas de Negocio
Conteo de roles: se cuenta cuántos desarrolladores hay de cada nivel disponible.

Cubierto: se verifica que para cada rol requerido, la cantidad disponible sea ≥ la requerida.

Faltantes: se calcula la diferencia (rol por rol) y se genera una lista con las repeticiones necesarias.

- 2.4. Implementación
Se desarrolló una interfaz web utilizando Tau‑Prolog (versión JavaScript) que se ejecuta completamente en el navegador. La base de conocimientos y las reglas están escritas en Prolog y se consultan mediante funciones JavaScript.

Funcionalidades de la interfaz:

Listar desarrolladores: muestra tabla con nombre y nivel, más resumen por nivel.

Listar proyectos: tabla con nombre y nivel, más resumen por nivel.

Consultas predefinidas: botones para project_ready(proyecto1), missing_personnel(proyecto1, Faltantes), etc.

Consulta personalizada: campo de texto para ingresar cualquier predicado.

- 2.5. Ejemplo de Uso
Consulta: missing_personnel(proyecto7, Faltantes).

Respuesta: Faltantes = [] (si hay personal suficiente) o Faltantes = [avanzado, junior] (si faltan esos roles).

- 2.6. Dificultades y Soluciones
Falta de predicados estándar: Tau‑Prolog no incluye sort/2, msort/2, bagof/3, setof/3 ni forall/2. Se implementaron manualmente usando findall, member y recursión.

Sintaxis de consultas: Tau‑Prolog exige que todas las consultas terminen con punto (.). Se añadió una función asegurarPunto() en JavaScript.

Acceso a variables en respuestas: pl.answer_to_object no existe; se accede directamente a ans.links para obtener las ligaduras.

Carga de la librería: al abrir el HTML localmente, algunos navegadores bloquean la carga de scripts desde CDN. Se optó por usar el archivo tau-prolog.js local (proporcionado por el usuario).

Rendimiento: inicialmente algunas consultas se quedaban colgadas debido a recursiones mal definidas. Se simplificaron las reglas y se añadió un timeout de 5 segundos para depuración.

---

3. Sistema Experto en Go – Control de Ingredientes de Platillos

- 3.1. Propósito
Ayudar a un cocinero a conocer los ingredientes de cada platillo, verificar si todos están disponibles en el inventario y listar los faltantes para un guiso dado.

- 3.2. Base de Conocimientos
Menú: lista de platillos con su nombre y lista de ingredientes.

Inventario: mapa de ingrediente → cantidad disponible (entero).

- 3.3. Funcionalidades
Ingredientes de un platillo: muestra la lista de ingredientes.

Disponibilidad: indica si todos los ingredientes están en stock (cantidad > 0).

Faltantes: devuelve los ingredientes con cantidad ≤ 0 o que no existen en el inventario.

Listar: muestra todos los platillos con sus ingredientes.

- 3.4. Implementación
Se desarrolló una aplicación de consola en Go que lee comandos del usuario mediante bufio.NewScanner(os.Stdin) y responde con mensajes formateados.

Estructura de datos:

go
type Platillo struct {
    Nombre      string
    Ingredientes []string
}
type Inventario map[string]int
Funciones principales:

obtenerIngredientes(nombre string) ([]string, bool)

estanDisponibles(ingredientes []string) bool

faltantes(ingredientes []string) []string

- 3.5. Ejemplo de Uso
text
> listar
Platillos disponibles:
- Enchiladas: [tortilla pollo salsa verde queso crema]
...
> ingredientes Mole poblano
Ingredientes de Mole poblano: [pollo mole arroz tortilla]
> disponible Mole poblano
Faltan ingredientes para Mole poblano.
> faltante Mole poblano
Faltan los siguientes ingredientes para Mole poblano: [mole]

- 3.6. Dificultades y Soluciones
Entrada de usuario: se manejó con strings.TrimSpace y strings.SplitN para separar comando y argumento.

Comparación de nombres: se usó strings.EqualFold para ignorar mayúsculas/minúsculas.

Estructura del código: se organizó en funciones para mantener claridad y reutilización.

---

## Conclusión
Los tres sistemas expertos demuestran la versatilidad de diferentes enfoques de programación para resolver problemas de decisión basados en reglas:

SWI‑Prolog destaca por su madurez, su capacidad de manejar lógica compleja y la facilidad para exponer servicios web, lo que lo hace ideal para aplicaciones empresariales o educativas.

Tau‑Prolog permite ejecutar sistemas expertos directamente en el navegador, facilitando la distribución sin necesidad de servidores, aunque requiere adaptaciones debido a la limitación de predicados nativos.

Go ofrece un enfoque imperativo y eficiente para sistemas de consola, con un manejo claro de estructuras de datos y entrada/salida, adecuado para herramientas rápidas y ligeras.

Cada sistema cubre un dominio específico y puede ser extendido con nuevas reglas o datos según las necesidades del usuario. La experiencia adquirida incluye el manejo de bases de conocimiento, la implementación de reglas de inferencia, la depuración de errores sintácticos y semánticos, y la integración con interfaces de usuario.