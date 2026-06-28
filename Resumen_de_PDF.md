1. '0-ingenieria-del-conocimiento.pdf'.
# Resumen hecho con notebooklm.google

Conceptos Básicos La Ingeniería de Conocimiento (IC) es una disciplina de la Inteligencia Artificial vinculada al desarrollo de sistemas de software donde el conocimiento y razonamiento son fundamentales, como en los Sistemas Expertos.

Involucra diferentes tipos de conocimiento: declarativo (hechos o atributos), procedural (reglas para solucionar problemas) y metaconocimiento (conocimiento sobre las capacidades de razonamiento).

Los actores principales son el Experto Humano (quien aporta su experiencia), el Ingeniero de Conocimiento (ICO, especialista que extrae y modela la información) y el Usuario final.

# Procesos Fundamentales de la Ingeniería del Conocimiento La IC se basa fundamentalmente en procesos iterativos:

Adquisición del conocimiento: Es la extracción de la información desde fuentes estáticas (documentos) o dinámicas (expertos humanos).

Se divide en 5 etapas: Identificación del problema, Entendimiento, Formalización (organizar cómo se representará), Implementación (programación) y Pruebas (validación).

Para extraer el conocimiento se usan métodos manuales (entrevistas estructuradas/no estructuradas, análisis de protocolos), semiautomatizados (herramientas de apoyo al experto o al ingeniero, como el análisis de rejilla) y automatizados (reglas de inducción como el algoritmo ID3 o aprendizaje automatizado).

Representación del conocimiento (KR): Consiste en estructurar el conocimiento extraído de manera inteligible para el sistema, debiendo ser una representación sencilla, modificable, transparente e independiente.

Utiliza esquemas como reglas lógicas (proposicional o de predicados), redes semánticas (nodos y enlaces), mapas conceptuales, árboles de decisiones, marcos (frames/slots) y diagramas lógicos.

* Base de Conocimiento: Es donde se almacena la información codificada (frecuentemente mediante reglas de producción), donde el orden no influye en los resultados porque cada elemento es comprensible por sí mismo.

* Validación, Inferencia y Explicación: El conocimiento debe ser validado para asemejarse a la realidad; luego interviene la inferencia (software que saca conclusiones basadas en el conocimiento) y un mecanismo para justificar al usuario las respuestas dadas.

# Resumen: C-sistemasExpertosBasadosEnReglas(referencia).pdf

Elementos de un Sistema Basado en Reglas Estos sistemas son eficientes para situaciones deterministas y constan de dos elementos que forman la base de conocimiento:

* Hechos: Son dinámicos, dependen de la situación particular y se almacenan en la memoria de trabajo.

* Reglas: Son afirmaciones lógicas estáticas que relacionan objetos y dictan su comportamiento. Se componen de una premisa o antecedente (condición con operadores lógicos) y una conclusión o consecuente (acción a tomar).

Para facilitar su programación, las reglas complejas pueden simplificarse mediante "sustitución de reglas" (por ejemplo, dividiendo condiciones con "o" en múltiples reglas simples).

# Motor de Inferencia y Estrategias El motor de inferencia aplica la lógica a las reglas para deducir nuevas conclusiones, basándose en reconocimiento de patrones, resolución de conflictos y ejecución. 

Utiliza reglas de inferencia clásicas:

* Modus Ponens: Razonamiento hacia adelante (si la premisa es cierta, la conclusión es cierta). Permite llegar a nuevos hechos.

* Modus Tollens: Razonamiento hacia atrás (si la conclusión es falsa, la premisa también lo es). Funciona de forma complementaria al Modus Ponens para descubrir información que de otro modo quedaría oculta.

* Mecanismo de Resolución: Combina y simplifica expresiones lógicas equivalentes para obtener conclusiones compuestas a partir de múltiples reglas.

Para el control del flujo, el sistema emplea estrategias de encadenamiento. El encadenamiento de reglas (hacia adelante) parte de hechos iniciales conocidos y repite ciclos deduciendo nuevos hechos hasta que no puede más. El encadenamiento orientado a un objetivo (hacia atrás) inicia con una meta específica y busca reglas que concluyan ese objetivo, preguntando al usuario por información faltante si es necesario.

Coherencia y Explicación. Es crítico contar con un subsistema de control de coherencia que evite que ingresen hechos o reglas contradictorias, previniendo conclusiones absurdas. Una regla es coherente si existe al menos un conjunto de valores que no produzcan choques; los valores que rompen las reglas se catalogan como "no factibles" y se eliminan continuamente de las listas de posibilidades del usuario. Finalmente, estos sistemas incluyen un subsistema de explicación de conclusiones que justifica sus resultados devolviendo al usuario la lista de reglas y hechos encadenados utilizados en el proceso.