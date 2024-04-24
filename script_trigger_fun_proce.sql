
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

    SET alias_base = CONCAT(LEFT(nombre, 2), LEFT(apellido, 2), YEAR(fecha_creacion));

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


-- FUNCION
-- Esta función generá el alías del técnico automáticamente.
DELIMITER //

CREATE FUNCTION generar_alias_tecnico(nombre VARCHAR(50), apellido VARCHAR(50), fecha_creacion DATETIME) RETURNS VARCHAR(25)
BEGIN
    DECLARE alias_base VARCHAR(10);
    DECLARE contador INT;
    DECLARE alias_final VARCHAR(25);

    SET alias_base = CONCAT(LEFT(nombre, 2), LEFT(apellido, 2), YEAR(fecha_creacion));

    -- Encuentra el siguiente número disponible para el alias
    SET contador = 1;
    WHILE EXISTS (SELECT 1 FROM tecnicos WHERE alias_tecnico = CONCAT(alias_base, contador)) DO
        SET contador = contador + 1;
    END WHILE;

    -- Concatena el número al alias base para obtener el alias final
    SET alias_final = CONCAT(alias_base, contador);
    RETURN alias_final;
END //

DELIMITER ;

-- FUNCION
-- Esta función generá el alías del jugador automáticamente.
DELIMITER //

CREATE FUNCTION generar_alias_jugador(nombre VARCHAR(50), apellido VARCHAR(50), perfil ENUM('Zurdo', 'Diestro', 'Ambidiestro'), fecha_creacion DATETIME) RETURNS VARCHAR(25)
BEGIN
    DECLARE alias_base VARCHAR(10);
    DECLARE contador INT;
    DECLARE alias_final VARCHAR(25);

    SET alias_base = CONCAT(LEFT(nombre, 2), LEFT(apellido, 2), LEFT(perfil, 1), YEAR(fecha_creacion));

    -- Encuentra el siguiente número disponible para el alias
    SET contador = 1;
    WHILE EXISTS (SELECT 1 FROM jugadores WHERE alias_jugador = CONCAT(alias_base, '_', contador)) DO
        SET contador = contador + 1;
    END WHILE;

    -- Concatena el número al alias base para obtener el alias final
    SET alias_final = CONCAT(alias_base, '_', contador);
    RETURN alias_final;
END //

DELIMITER ;

-- FUNCION
-- Esta función generá el nombre del horario automáticamente.
DELIMITER //

CREATE FUNCTION generar_nombre_horario(dia_semana ENUM('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')) RETURNS VARCHAR(60)
BEGIN
    DECLARE contador INT;
    DECLARE nombre_final VARCHAR(60);

    -- Encuentra el siguiente número disponible para el contador
    SET contador = 1;
    WHILE EXISTS (SELECT 1 FROM horarios WHERE nombre_horario = CONCAT('Horario del ', dia_semana, ' ', contador)) DO
        SET contador = contador + 1;
    END WHILE;

    -- Concatena el nombre del horario con el contador
    SET nombre_final = CONCAT('Horario del ', dia_semana, ' ', contador);
    RETURN nombre_final;
END //

DELIMITER ;


-- FUNCION
-- Esta función generá el nombre de la jornada automáticamente.
DELIMITER //

CREATE FUNCTION generar_nombre_jornada(numero_jornada INT, nombre_temporada VARCHAR(25)) RETURNS VARCHAR(100)
BEGIN
    DECLARE nombre_jornada VARCHAR(100);

    SET nombre_jornada = CONCAT('Jornada ', numero_jornada, ' ', nombre_temporada);
    RETURN nombre_jornada;
END //

DELIMITER ;

-- PROCEDIMIENTO ALMACENADO INSERTAR JORNADAS
DELIMITER //

CREATE PROCEDURE insertar_jornada(
    IN numero_jornada INT,
    IN id_plantilla INT,
    IN fecha_inicio DATE,
    IN fecha_fin DATE
)
BEGIN
    DECLARE nombre_temporada VARCHAR(25);
    DECLARE nombre_jornada VARCHAR(100);

    -- Verificar que las fechas no estén vacías y que la fecha de inicio sea anterior a la fecha de fin
    IF fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_inicio >= fecha_fin THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Las fechas de inicio y fin de la jornada son inválidas';
    END IF;

    -- Obtener el nombre de la temporada asociada a la plantilla
    SELECT nombre_temporada INTO nombre_temporada
    FROM plantillas_equipos
    INNER JOIN temporadas ON plantillas_equipos.id_temporada = temporadas.id_temporada
    WHERE plantillas_equipos.id_plantilla = id_plantilla;

    -- Verificar que se obtuvo el nombre de la temporada
    IF nombre_temporada IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se pudo obtener el nombre de la temporada asociada a la plantilla';
    END IF;

    -- Generar el nombre de la jornada utilizando la función
    SET nombre_jornada = generar_nombre_jornada(numero_jornada, nombre_temporada);

    -- Insertar los datos en la tabla jornadas
    INSERT INTO jornadas (nombre_jornada, numero_jornada, id_plantilla, fecha_inicio_jornada, fecha_fin_jornada)
    VALUES (nombre_jornada, numero_jornada, id_plantilla, fecha_inicio, fecha_fin);

    -- Verificar que se insertó la jornada correctamente
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se pudo insertar la jornada';
    END IF;
END //

DELIMITER ;


-- PROCEDIMIENTO ALMACENADO PARTIDOS
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

-- VISTA para tabla de ingresos
DELIMITER //
CREATE VIEW vista_ingresos AS
SELECT nombre_jugador, apellido_jugador, becado, cantidad_pago, pago_tardio, mes_pago, fecha_pago
FROM jugadores
INNER JOIN pagos ON jugadores.id_jugador = pagos.id_jugador;
//
DELIMITER  ;

SELECT * FROM vista_ingresos;
