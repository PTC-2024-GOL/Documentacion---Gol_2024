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


ALTER VIEW vista_horarios_equipos_movil AS
SELECT 
  e.id_equipo,
  e.id_entrenamiento,
  e.fecha_entrenamiento,
  CONCAT(h.dia, DATE_FORMAT(e.fecha_entrenamiento, ' %d de %M'), ' de ', TIME_FORMAT(h.hora_inicial, '%H:%i'), ' A ', TIME_FORMAT(h.hora_final, '%H:%i')) AS horario
FROM 
  entrenamientos e
INNER JOIN 
  horarios_categorias r ON e.id_horario_categoria = r.id_horario_categoria
INNER JOIN 
  horarios h ON r.id_horario = h.id_horario;
SELECT * FROM vista_horarios_equipos_movil WHERE id_equipo = 4;
SELECT 
                id_entrenamiento,
                horario,
                fecha_entrenamiento,
                id_equipo
                FROM vista_horarios_equipos_movil vhem
                WHERE vhem.id_equipo = 4
                AND NOT EXISTS (
                SELECT 1
                FROM asistencias a
                WHERE a.id_entrenamiento = vhem.id_entrenamiento
                )
                ORDER BY fecha_entrenamiento DESC;

SELECT * FROM equipos;