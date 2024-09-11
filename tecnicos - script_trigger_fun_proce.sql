-- TRIGGERS, FUNCIONES Y PROCEDIMIENTOS ALMACENADOS TECNICOS
USE db_gol_sv;

-- VISTAS PARA EQUIPOS
CREATE VIEW vista_equipos_tecnicos AS
    SELECT
        e.id_equipo,
        e.nombre_equipo,
        e.genero_equipo,
        e.telefono_contacto,
        e.id_cuerpo_tecnico,
        e.logo_equipo,
        e.id_categoria,
        c.nombre_categoria,
        t.nombre_tecnico,
        dt.id_tecnico
FROM equipos e
INNER JOIN cuerpos_tecnicos ct ON e.id_cuerpo_tecnico = ct.id_cuerpo_tecnico
INNER JOIN detalles_cuerpos_tecnicos dt ON ct.id_cuerpo_tecnico = dt.id_cuerpo_tecnico
INNER JOIN tecnicos t ON dt.id_tecnico = t.id_tecnico
INNER JOIN categorias c ON e.id_categoria = c.id_categoria;

-- VISTA PARA PARTIDOS, READ ALL TECNICOS
CREATE VIEW vista_detalle_partidos_tecnicos AS
SELECT
    p.id_partido,
    DATE_FORMAT(p.fecha_partido, '%e de %M del %Y') AS fecha,
    p.localidad_partido,
    p.resultado_partido,
    i.logo_rival,
    e.logo_equipo,
    e.nombre_equipo,
    i.nombre_rival AS nombre_rival,
    p.tipo_resultado_partido,
    e.id_equipo,
    d.id_tecnico
FROM
    partidos p
INNER JOIN
    equipos e ON p.id_equipo = e.id_equipo
INNER JOIN
	rivales i ON p.id_rival = i.id_rival
INNER JOIN
    detalles_cuerpos_tecnicos d ON e.id_cuerpo_tecnico = d.id_cuerpo_tecnico
ORDER BY p.fecha_partido DESC;

-- VISTA PARA SELECT DE PARTIDOS CON IMAGENES
CREATE VIEW vista_select_equipos_con_imagen AS
SELECT
	e.id_equipo,  
	e.nombre_equipo, 
	e.logo_equipo,
	d.id_tecnico 
	FROM equipos e
INNER JOIN
	 detalles_cuerpos_tecnicos d ON e.id_cuerpo_tecnico = d.id_cuerpo_tecnico;
	 

-- VISTA PARA ENTRENAMIENTOS READ ALL TECNICO
CREATE VIEW vista_jornadas_entrenamientos_tecnico AS
SELECT 
    j.id_jornada, 
    e.id_entrenamiento,
    e.fecha_entrenamiento,
    d.id_tecnico,
    CONCAT(DATE_FORMAT(e.fecha_entrenamiento, '%e de %M del %Y'), ' - ', e.sesion) AS detalle_entrenamiento
FROM 
    jornadas j
JOIN 
    entrenamientos e ON j.id_jornada = e.id_jornada
JOIN 
	equipos c ON e.id_equipo = c.id_equipo
INNER JOIN 
	detalles_cuerpos_tecnicos d ON c.id_cuerpo_tecnico = d.id_cuerpo_tecnico;
	
SELECT * FROM vista_jornadas_entrenamientos_tecnico WHERE id_jornada = 5 AND id_tecnico = 7;

-- VISTA PARA DETALLES POR CONTENIDOS READ ALL TENICO
CREATE VIEW vista_equipos_categorias_tecnico AS
SELECT 
    e.id_equipo, 
    c.nombre_categoria, 
    e.nombre_equipo,
    d.id_tecnico
FROM 
    equipos e
JOIN 
    categorias c ON e.id_categoria = c.id_categoria
INNER JOIN
	detalles_cuerpos_tecnicos d ON e.id_cuerpo_tecnico = d.id_cuerpo_tecnico;

-- Vista para el combobox de técnicos en movil
CREATE VIEW vista_horarios_equipos_movil AS
SELECT 
  e.id_equipo,
  e.id_entrenamiento,
  e.fecha_entrenamiento,
  h.id_horario,
  CONCAT(h.dia, DATE_FORMAT(e.fecha_entrenamiento, ' %d de %M'), ' de ', TIME_FORMAT(h.hora_inicial, '%H:%i'), ' A ', TIME_FORMAT(h.hora_final, '%H:%i')) AS horario
FROM 
  entrenamientos e
INNER JOIN 
  horarios_categorias r ON e.id_horario_categoria = r.id_horario_categoria
INNER JOIN 
  horarios h ON r.id_horario = h.id_horario;
  
-- Vista para ver las asistencias poor jugador en movik técnicos
CREATE VIEW asistencias_por_jugador AS
 	SELECT
 	e.id_jugador,
 	e.observacion_asistencia,
 	e.asistencia,
 	e.fecha_asistencia,
	 DATE_FORMAT(e.fecha_asistencia, '%e de %M del %Y') AS fecha,
	j.id_jornada
FROM 
	asistencias e
INNER JOIN 
	entrenamientos u ON e.id_entrenamiento = u.id_entrenamiento
INNER JOIN
	jornadas j ON u.id_jornada = j.id_jornada;
-- Vista para movil de tecnicos para ver datos por jugador relacionados a estadisticas
CREATE VIEW vista_asistencias_por_jugador AS
SELECT 
    e.id_jugador,
    SUM(e.asistencia = 'Asistencia') AS cantidad_asistencia,
    (SUM(e.asistencia = 'Asistencia') / COUNT(*)) * 100 AS porcentaje_asistencia,
    SUM(e.asistencia = 'Ausencia injustificada') AS cantidad_ausencia_injustificada,
    (SUM(e.asistencia = 'Ausencia injustificada') / COUNT(*)) * 100 AS porcentaje_ausencia_injustificada,
    SUM(e.asistencia = 'Enfermedad') AS cantidad_enfermedad,
    (SUM(e.asistencia = 'Enfermedad') / COUNT(*)) * 100 AS porcentaje_enfermedad,
    SUM(e.asistencia = 'Otro') AS cantidad_otro,
    (SUM(e.asistencia = 'Otro') / COUNT(*)) * 100 AS porcentaje_otro,
    SUM(e.asistencia = 'Estudio') AS cantidad_estudio,
    j.id_jornada
FROM 
	asistencias e
INNER JOIN 
	entrenamientos u ON e.id_entrenamiento = u.id_entrenamiento
INNER JOIN
	jornadas j ON u.id_jornada = j.id_jornada
GROUP BY id_jugador;

DROP VIEW IF EXISTS notas_por_jugador;
CREATE VIEW notas_por_jugador AS
    SELECT
        c.id_jugador,
        cj.clasificacion_caracteristica_jugador,
        ROUND(AVG(c.nota_caracteristica_analisis), 1) AS nota_por_area,
        c.id_caracteristica_jugador
FROM caracteristicas_analisis c
INNER JOIN caracteristicas_jugadores cj ON c.id_caracteristica_jugador = cj.id_caracteristica_jugador
GROUP BY c.id_jugador, cj.clasificacion_caracteristica_jugador;

-- Vista para movil tecnicos para ver los jugadores en entrenamiento 
DROP VIEW IF EXISTS vista_jugadores_equipo_movil;
CREATE VIEW vista_jugadores_equipo_movil AS 
SELECT 
	e.id_equipo,
	CONCAT(j.nombre_jugador, ' ', j.apellido_jugador) AS jugador
FROM 
	plantillas_equipos pe
JOIN 
	equipos e ON e.id_equipo = pe.id_equipo
JOIN
    jugadores j ON j.id_jugador = pe.id_jugador;
