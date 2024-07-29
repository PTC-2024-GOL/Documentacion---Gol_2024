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


SELECT * FROM vista_detalle_partidos_tecnicos WHERE id_tecnico= 6;