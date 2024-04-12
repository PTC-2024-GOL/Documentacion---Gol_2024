-- TRIGGERS, FUNCIONES Y PROCEDIMIENTOS ALMACENADOS

USE db_gol_sv;

-- TRIGGER
-- Cuando se haga un insert en la tabla registro médico, automaticamente el campo de estado en la tabla jugador
-- va cambiar a Baja por lesión
DELIMITER //
CREATE TRIGGER registrar_lesion
AFTER INSERT ON registros_medicos
FOR EACH ROW
BEGIN
  UPDATE jugadores
  SET estatus_jugador = 'Baja temporal'
  WHERE id_jugador = NEW.id_jugador;
END;
//
DELIMITER ;

-- FUNCION
-- Esta función generá el alías del administador automáticamente.
DELIMITER //

CREATE FUNCTION generar_alias_administrador(nombre VARCHAR(50), apellido VARCHAR(50), fecha_creacion DATETIME) RETURNS VARCHAR(25)
BEGIN
    DECLARE alias_base VARCHAR(10);
    DECLARE contador INT;
    DECLARE alias_final VARCHAR(25);

    SET alias_base = CONCAT(LEFT(nombre, 1), LEFT(apellido, 1), YEAR(fecha_creacion));

    -- Encuentra el siguiente número disponible para el alias
    SET contador = 1;
    WHILE EXISTS (SELECT 1 FROM administradores WHERE alias_administrador = CONCAT(alias_base, contador)) DO
        SET contador = contador + 1;
    END WHILE;

    -- Concatena el número al alias base para obtener el alias final
    SET alias_final = CONCAT(alias_base, contador);
    RETURN alias_final;
END //

DELIMITER ;

-- PROCEDIMIENTO ALMACENADO
DELIMITER //

CREATE PROCEDURE insertar_o_actualizar_partido(
    IN insertorUpdate INT,
    IN id_entrenamiento_param INT,
    IN id_equipo_param INT,
    IN logo_rival_param VARCHAR(50),
    IN rival_partido_param VARCHAR(50),
    IN fecha_partido_param DATETIME,
    IN cancha_partido_param VARCHAR(100),
    IN resultado_partido_param VARCHAR(10),
    IN localidad_partido_param ENUM('Local', 'Visitante'),
    IN tipo_resultado_partido_param ENUM('Victoria', 'Empate', 'Derrota')
)
BEGIN
    IF insertorUpdate = 0 THEN
        INSERT INTO partidos (
            id_entrenamiento, 
            id_equipo, 
            logo_rival, 
            rival_partido, 
            fecha_partido, 
            cancha_partido, 
            resultado_partido, 
            localidad_partido, 
            tipo_resultado_partido
        ) 
        VALUES (
            id_entrenamiento_param, 
            id_equipo_param, 
            logo_rival_param, 
            rival_partido_param, 
            fecha_partido_param, 
            cancha_partido_param, 
            resultado_partido_param, 
            localidad_partido_param, 
            tipo_resultado_partido_param
        );
    ELSE
        UPDATE partidos 
        SET id_entrenamiento = id_entrenamiento_param, 
            id_equipo = id_equipo_param, 
            logo_rival = logo_rival_param, 
            rival_partido = rival_partido_param, 
            fecha_partido = fecha_partido_param, 
            cancha_partido = cancha_partido_param, 
            resultado_partido = resultado_partido_param, 
            localidad_partido = localidad_partido_param, 
            tipo_resultado_partido = tipo_resultado_partido_param
        WHERE id_partido = insertorUpdate;
    END IF;
END //

DELIMITER ;

-- VISTA
-- Vista que calcula el promedio de las notas de las subcaracteristicas de los jugadores.
DELIMITER //
CREATE VIEW vista_promedio_subcaracteristicas_por_jugador AS
SELECT id_jugador, AVG(nota_caracteristica_analisis) AS promedio_subcaracteristicas
FROM caracteristicas_analisis
GROUP BY id_jugador;
//
DELIMITER ;