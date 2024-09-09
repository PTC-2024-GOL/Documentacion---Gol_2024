-- TRIGGERS, FUNCIONES Y PROCEDIMIENTOS ALMACENADOS JUGADORES
USE db_gol_sv;
-- Vista para partidos:
DROP VIEW IF EXISTS vista_detalle_partidos_jugadores;
CREATE VIEW vista_detalle_partidos_jugadores AS
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
    i.id_rival,
    e.id_categoria,
    c.nombre_categoria,
    pp.id_jugador
FROM
    partidos p
INNER JOIN
    equipos e ON p.id_equipo = e.id_equipo
INNER JOIN
	rivales i ON p.id_rival = i.id_rival
INNER JOIN
    categorias c ON e.id_categoria = c.id_categoria
INNER JOIN
    participaciones_partidos pp ON p.id_partido = pp.id_partido
ORDER BY p.fecha_partido DESC;

SELECT * FROM vista_detalle_partidos;
