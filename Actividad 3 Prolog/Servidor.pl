:- use_module(library(http/http_server)).
:- use_module(library(http/json)).
:- use_module(library(http/http_json)).
:- use_module(library(apply)).
:- use_module(library(lists)).

% ------------------------------------------------------------
% BASE DE CONOCIMIENTOS
% ------------------------------------------------------------

% materias(Clave, Nombre, Semestre, Area)
materia('M101', 'Matemáticas 1', 1, 'Básicas').
materia('M102', 'Matemáticas 2', 2, 'Básicas').
materia('M201', 'Matemáticas 3', 3, 'Básicas').
materia('F101', 'Física 1', 1, 'Básicas').
materia('F102', 'Física 2', 2, 'Básicas').
materia('P101', 'Programación 1', 1, 'Programación').
materia('P102', 'Programación 2', 2, 'Programación').
materia('P201', 'Programación 3', 3, 'Programación').
materia('B101', 'Base de Datos 1', 3, 'Bases de Datos').
materia('B201', 'Base de Datos 2', 4, 'Bases de Datos').
materia('S101', 'Sistemas Operativos', 4, 'Sistemas').
materia('R101', 'Redes', 5, 'Sistemas').
% más materias según sea necesario

% prerrequisito(Materia, Prerreq)
prerreq('M102', 'M101').
prerreq('M201', 'M102').
prerreq('F102', 'F101').
prerreq('P102', 'P101').
prerreq('P201', 'P102').
prerreq('B201', 'B101').
prerreq('S101', 'P102').
prerreq('R101', 'S101').

% alumno(ID, Nombre)
alumno(1, 'Ana López').
alumno(2, 'Carlos Pérez').
alumno(3, 'María Gómez').
alumno(4, 'Luis Torres').
alumno(5, 'Elena Ruiz').

% cursó(Alumno, Materia, Calificación, Intento)
cursó(1, 'M101', 85, 1).
cursó(1, 'F101', 70, 1).
cursó(1, 'P101', 90, 1).
cursó(1, 'M102', 40, 1).  % reprobada
cursó(1, 'M102', 50, 2).  % segunda reprobada
cursó(1, 'M102', 65, 3).  % aprobada en tercera
cursó(1, 'P102', 80, 1).
cursó(1, 'F102', 55, 1).  % reprobada
cursó(1, 'F102', 70, 2).  % aprobada

cursó(2, 'M101', 95, 1).
cursó(2, 'P101', 88, 1).
cursó(2, 'F101', 92, 1).
cursó(2, 'M102', 90, 1).
cursó(2, 'P102', 85, 1).

cursó(3, 'M101', 60, 1).
cursó(3, 'M101', 55, 2).
cursó(3, 'M101', 50, 3).  % tres reprobadas -> baja
cursó(3, 'P101', 75, 1).

cursó(4, 'M101', 70, 1).
cursó(4, 'F101', 65, 1).
cursó(4, 'P101', 60, 1).
cursó(4, 'M102', 45, 1).

cursó(5, 'M101', 95, 1).
cursó(5, 'F101', 90, 1).
cursó(5, 'P101', 98, 1).
cursó(5, 'M102', 92, 1).
cursó(5, 'P102', 94, 1).
cursó(5, 'F102', 89, 1).

% ------------------------------------------------------------
% REGLAS DE NEGOCIO
% ------------------------------------------------------------

% aprobó(Alumno, Materia) : calificación >= 70 (considerando el último intento)
aprobó(Alumno, Materia) :-
    cursó(Alumno, Materia, Calif, _),
    Calif >= 70,
    \+ ( cursó(Alumno, Materia, _, Int2), Int2 > Int1 ).  % asumimos que el último intento es el mayor número (podría mejorarse con findall)
% Mejor: obtener el último intento
ultimo_intento(Alumno, Materia, Calif) :-
    findall(Int, cursó(Alumno, Materia, _, Int), Ints),
    max_list(Ints, MaxInt),
    cursó(Alumno, Materia, Calif, MaxInt).
aprobó(Alumno, Materia) :-
    ultimo_intento(Alumno, Materia, Calif),
    Calif >= 70.

% reprobó(Alumno, Materia, Intentos) : cuenta de reprobadas (calif < 70)
reprobó(Alumno, Materia, Intentos) :-
    findall(Calif, cursó(Alumno, Materia, Calif, _), Califs),
    include(<(70), Califs, Reprobadas),
    length(Reprobadas, Intentos).

% promedio general (todas las calificaciones de todos los intentos? o último intento?)
% Usamos el último intento de cada materia
promedio_general(Alumno, Prom) :-
    findall(Calif, ( cursó(Alumno, Materia, Calif, Int), 
                     \+ ( cursó(Alumno, Materia, _, Int2), Int2 > Int ) ), Califs),
    sum_list(Califs, Sum),
    length(Califs, N),
    N > 0,
    Prom is Sum / N.

% número de reprobadas (considerando última calificación < 70)
num_reprobadas(Alumno, N) :-
    findall(1, ( cursó(Alumno, Materia, _, Int),
                 \+ ( cursó(Alumno, Materia, _, Int2), Int2 > Int ),
                 ultimo_intento(Alumno, Materia, Calif),
                 Calif < 70 ), List),
    length(List, N).

% carga máxima según promedio y reprobadas
carga_maxima(Alumno, Max) :-
    promedio_general(Alumno, Prom),
    num_reprobadas(Alumno, Rep),
    ( Prom < 80 -> Max0 = 4 ; Max0 = 6 ),   % si promedio < 80 máximo 4, sino 6
    ( Rep > 1 -> Max1 = 4 ; Max1 = Max0 ),  % si más de una reprobada, máximo 4
    Max = Max1.

% puede_llevar(Alumno, Materia) : cumple prerrequisitos y no está reprobada 3 veces
puede_llevar(Alumno, Materia) :-
    materia(Materia, _, _, _),
    % no debe haber reprobado 3 veces
    reprobó(Alumno, Materia, Intentos),
    Intentos < 3,
    % todos los prerrequisitos aprobados
    forall(prerreq(Materia, P), aprobó(Alumno, P)).

% debe_darse_baja(Alumno) : si reprobó alguna materia 3 veces
debe_darse_baja(Alumno) :-
    reprobó(Alumno, Materia, 3).

% alto_rendimiento : promedio >= 90
alto_rendimiento(Alumno) :-
    promedio_general(Alumno, Prom),
    Prom >= 90.

% aspirantes a una materia (alumnos que pueden llevarla pero aún no la han aprobado)
aspirantes(Materia, Lista) :-
    findall(Alumno, ( alumno(Alumno, _), 
                      puede_llevar(Alumno, Materia),
                      \+ aprobó(Alumno, Materia) ), Lista).

% materias_por_semestre_area : agrupar
materias_por_semestre_area(Semestre, Area, ListaMaterias) :-
    findall(Nombre, materia(Clave, Nombre, Semestre, Area), ListaMaterias).

% ------------------------------------------------------------
% SERVIDOR HTTP
% ------------------------------------------------------------

% Iniciar servidor: server.
server :-
    http_server(http_dispatch, [port(8080)]).

% Endpoints
:- http_handler(root(student/ID/courses), student_courses(ID), []).
:- http_handler(root(student/ID/load), student_load(ID), []).
:- http_handler(root(student/ID/dropout), student_dropout(ID), []).
:- http_handler(root(high_achievers), high_achievers_handler, []).
:- http_handler(root(subjects), subjects_handler, []).
:- http_handler(root(course/ID/aspirants), course_aspirants(ID), []).

% Manejar /student/ID/courses
student_courses(ID, Request) :-
    memberchk(method(get), Request),
    atom_number(ID, Num),   % convertir a número
    findall(Materia, puede_llevar(Num, Materia), Cursos),
    reply_json_dict(_{id: Num, cursos: Cursos}).

% /student/ID/load
student_load(ID, Request) :-
    memberchk(method(get), Request),
    atom_number(ID, Num),
    carga_maxima(Num, Max),
    reply_json_dict(_{id: Num, carga_maxima: Max}).

% /student/ID/dropout
student_dropout(ID, Request) :-
    memberchk(method(get), Request),
    atom_number(ID, Num),
    ( debe_darse_baja(Num) -> Estado = true ; Estado = false ),
    reply_json_dict(_{id: Num, baja: Estado}).

% /high_achievers
high_achievers_handler(_Request) :-
    findall(Nombre, ( alumno(Alumno, Nombre), alto_rendimiento(Alumno) ), Nombres),
    reply_json_dict(_{altos_rendimiento: Nombres}).

% /subjects
subjects_handler(_Request) :-
    findall(_{semestre: S, area: A, materias: Ms}, 
            ( materia(_, _, S, A), 
              materias_por_semestre_area(S, A, Ms) ), 
            Lista),
    reply_json_dict(_{materias: Lista}).

% /course/ID/aspirants
course_aspirants(ID, Request) :-
    memberchk(method(get), Request),
    atom_string(Course, ID),   % ID es atom, Course string
    aspirantes(Course, Lista),
    length(Lista, Count),
    reply_json_dict(_{curso: Course, aspirantes: Lista, total: Count}).

% ------------------------------------------------------------
% EJECUCIÓN
% ------------------------------------------------------------
% Para iniciar: cargar el archivo y ejecutar server.