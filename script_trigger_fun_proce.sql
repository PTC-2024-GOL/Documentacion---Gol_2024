
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

-- PROCEDIMIENTO ALMACENADO JORNADAS
DELIMITER //

CREATE PROCEDURE insertar_actualizar_jornada(
    IN insertOrUpdate INT,
    IN numero_jornada INT,
    IN id_plantilla INT,
    IN fecha_inicio DATE,
    IN fecha_fin DATE
)
BEGIN
    DECLARE nombre_temporada VARCHAR(50);
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

    -- Insertar o actualizar los datos en la tabla jornadas
    IF insertOrUpdate = 0 THEN
        INSERT INTO jornadas (nombre_jornada, numero_jornada, id_plantilla, fecha_inicio_jornada, fecha_fin_jornada)
        VALUES (nombre_jornada, numero_jornada, id_plantilla, fecha_inicio, fecha_fin);
    ELSE
        UPDATE jornadas 
        SET nombre_jornada = nombre_jornada, 
            numero_jornada = numero_jornada, 
            id_plantilla = id_plantilla, 
            fecha_inicio_jornada = fecha_inicio, 
            fecha_fin_jornada = fecha_fin
        WHERE id_jornada = insertOrUpdate;
    END IF;

    -- Verificar que se insertó o actualizó la jornada correctamente
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se pudo insertar o actualizar la jornada';
    END IF;
END //

DELIMITER $$

CREATE PROCEDURE eliminar_jornada(
    IN p_id_jornada INT
)
BEGIN
    DECLARE contador_jornada_entrenamientos INT;
    DECLARE contador_jornada_partidos INT;

    SELECT COUNT(*)
    INTO contador_jornada_entrenamientos
    FROM entrenamientos
    WHERE id_jornada = p_id_jornada;
    
    SELECT COUNT(*)
    INTO contador_jornada_partidos
    FROM partidos
    WHERE id_jornada = p_id_jornada;

    IF contador_jornada_entrenamientos > 0 OR contador_jornada_partidos > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar la jornada, porque esta ya a sido asociada con otra tabla en la base de datos';
    ELSE
        DELETE FROM jornadas
        WHERE id_jornada = p_id_jornada;
    END IF;
END;

$$

-- PROCEDIMIENTO ALMACENADO PARTIDOS
DELIMITER //

CREATE PROCEDURE insertar_o_actualizar_partido(
    IN insertorUpdate INT,
    IN id_jornada_param INT,
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
    DECLARE fecha_inicio_jornada DATE;
    DECLARE fecha_fin_jornada DATE;

    -- Verificar que la fecha del partido esté dentro de las fechas de la jornada
    SELECT fecha_inicio_jornada, fecha_fin_jornada INTO fecha_inicio_jornada, fecha_fin_jornada
    FROM jornadas
    WHERE id_jornada = id_jornada_param;

    IF fecha_partido_param < fecha_inicio_jornada OR fecha_partido_param > fecha_fin_jornada THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha del partido está fuera del rango de fechas de la jornada';
    END IF;

    IF insertorUpdate = 0 THEN
        INSERT INTO partidos (
            id_jornada, 
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
            id_jornada_param, 
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
        SET id_jornada = id_jornada_param, 
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

DELIMITER $$

DELIMITER $$

CREATE PROCEDURE eliminar_partido(
    IN p_id_partido INT
)
BEGIN
    DECLARE contador_partido_participaciones INT;
    DECLARE contador_partido_registro_medico INT;

    SELECT COUNT(*)
    INTO contador_partido_participaciones
    FROM participaciones_partidos
    WHERE id_partido = p_id_partido;
    
    SELECT COUNT(*)
    INTO contador_partido_registro_medico
    FROM registros_medicos
    WHERE retorno_partido = p_id_partido;

    IF contador_partido_participaciones > 0 OR contador_partido_registro_medico > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar el partido, porque esta ya a sido asociado con otra tabla en la base de datos';
    ELSE
        DELETE FROM partidos
        WHERE id_partido = p_id_partido;
    END IF;
END;

$$


DROP PROCEDURE IF EXISTS insertar_administrador_validado;
DELIMITER $$
CREATE PROCEDURE insertar_administrador_validado(
   IN p_nombre_administrador VARCHAR(50),
   IN p_apellido_administrador VARCHAR(50),
   IN p_clave_administrador VARCHAR(100),
   IN p_correo_administrador VARCHAR(50),
   IN p_telefono_administrador VARCHAR(15),
   IN p_dui_administrador VARCHAR(10),
   IN p_fecha_nacimiento_administrador DATE,
   IN p_foto_administrador VARCHAR(50)
)
BEGIN
    DECLARE p_alias_administrador VARCHAR(25);
    IF p_correo_administrador REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
            -- Generar el alias utilizando la función
            SET p_alias_administrador = generar_alias_administrador(p_nombre_administrador, p_apellido_administrador, NOW());
            INSERT INTO administradores (nombre_administrador, apellido_administrador, clave_administrador, correo_administrador, telefono_administrador, dui_administrador, fecha_nacimiento_administrador, alias_administrador, foto_administrador)
            VALUES(p_nombre_administrador, p_apellido_administrador, p_clave_administrador, p_correo_administrador, p_telefono_administrador, p_dui_administrador, p_fecha_nacimiento_administrador, p_alias_administrador, p_foto_administrador);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato de correo electrónico no válido';
    END IF;
END;
$$


DROP PROCEDURE IF EXISTS actualizar_administrador_validado;
DELIMITER $$
CREATE PROCEDURE actualizar_administrador_validado(
   IN p_id_administrador INT,
   IN p_nombre_administrador VARCHAR(50),
   IN p_apellido_administrador VARCHAR(50),
   IN p_correo_administrador VARCHAR(50),
   IN p_telefono_administrador VARCHAR(15),
   IN p_dui_administrador VARCHAR(10),
   IN p_fecha_nacimiento_administrador DATE,
   IN p_foto_administrador VARCHAR(50)
)
BEGIN
    IF p_correo_administrador REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
            UPDATE administradores SET nombre_administrador = p_nombre_administrador, 
            apellido_administrador = p_apellido_administrador, 
            correo_administrador = p_correo_administrador,
            telefono_administrador = p_telefono_administrador, 
            dui_administrador = p_dui_administrador, 
            fecha_nacimiento_administrador = p_fecha_nacimiento_administrador,
            foto_administrador = p_foto_administrador
            WHERE id_administrador = p_id_administrador;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato de correo electrónico no válido';
    END IF;
END;
$$

DROP PROCEDURE IF EXISTS eliminar_administrador;
DELIMITER $$
CREATE PROCEDURE eliminar_administrador(
    IN p_id_administrador INT
)
BEGIN
	DELETE FROM administradores
	WHERE id_administrador = p_id_administrador;
END;
$$

DROP PROCEDURE IF EXISTS insertar_tecnico_validado;
DELIMITER $$
CREATE PROCEDURE insertar_tecnico_validado(
   IN p_nombre_tecnico VARCHAR(50),
   IN p_apellido_tecnico VARCHAR(50),
   IN p_clave_tecnico VARCHAR(100),
   IN p_correo_tecnico VARCHAR(50),
   IN p_telefono_tecnico VARCHAR(15),
   IN p_dui_tecnico VARCHAR(10),
   IN p_fecha_nacimiento_tecnico DATE,
   IN p_foto_tecnico VARCHAR(50)
)
BEGIN
    DECLARE p_alias_tecnico VARCHAR(25);
    IF p_correo_tecnico REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        -- Generar el alias utilizando la función, suponiendo que la función generar_alias_tecnico existe
        SET p_alias_tecnico = generar_alias_tecnico(p_nombre_tecnico, p_apellido_tecnico, NOW());
        INSERT INTO tecnicos (nombre_tecnico, apellido_tecnico, clave_tecnico, correo_tecnico, telefono_tecnico, dui_tecnico, fecha_nacimiento_tecnico, alias_tecnico, foto_tecnico)
        VALUES(p_nombre_tecnico, p_apellido_tecnico, p_clave_tecnico, p_correo_tecnico, p_telefono_tecnico, p_dui_tecnico, p_fecha_nacimiento_tecnico, p_alias_tecnico, p_foto_tecnico);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato de correo electrónico no válido';
    END IF;
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS actualizar_tecnico_validado;
DELIMITER $$
CREATE PROCEDURE actualizar_tecnico_validado(
   IN p_id_tecnico INT,
   IN p_nombre_tecnico VARCHAR(50),
   IN p_apellido_tecnico VARCHAR(50),
   IN p_correo_tecnico VARCHAR(50),
   IN p_telefono_tecnico VARCHAR(15),
   IN p_dui_tecnico VARCHAR(10),
   IN p_fecha_nacimiento_tecnico DATE,
   IN p_foto_tecnico VARCHAR(50)
)
BEGIN
    IF p_correo_tecnico REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        UPDATE tecnicos SET 
            nombre_tecnico = p_nombre_tecnico, 
            apellido_tecnico = p_apellido_tecnico, 
            correo_tecnico = p_correo_tecnico,
            telefono_tecnico = p_telefono_tecnico, 
            dui_tecnico = p_dui_tecnico, 
            fecha_nacimiento_tecnico = p_fecha_nacimiento_tecnico,
            foto_tecnico = p_foto_tecnico
        WHERE id_tecnico = p_id_tecnico;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato de correo electrónico no válido';
    END IF;
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS eliminar_tecnico;
DELIMITER $$
CREATE PROCEDURE eliminar_tecnico(
    IN p_id_tecnico INT
)
BEGIN
    DELETE FROM tecnicos
    WHERE id_tecnico = p_id_tecnico;
END;
$$
DELIMITER ;


DROP PROCEDURE IF EXISTS insertar_caracteristica_jugador;
DELIMITER $$
CREATE PROCEDURE insertar_caracteristica_jugador(
    IN p_nombre_caracteristica VARCHAR(50),
    IN p_clasificacion ENUM('Técnicos', 'Tácticos', 'Condicionales', 'Psicologicos', 'Personales')
)
BEGIN
    INSERT INTO caracteristicas_jugadores (nombre_caracteristica_jugador, clasificacion_caracteristica_jugador)
    VALUES (p_nombre_caracteristica, p_clasificacion);
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS actualizar_caracteristica_jugador;
DELIMITER $$
CREATE PROCEDURE actualizar_caracteristica_jugador(
    IN p_id_caracteristica INT,
    IN p_nuevo_nombre VARCHAR(50),
    IN p_nueva_clasificacion ENUM('Técnicos', 'Tácticos', 'Condicionales', 'Psicologicos', 'Personales')
)
BEGIN
    UPDATE caracteristicas_jugadores
    SET nombre_caracteristica_jugador = p_nuevo_nombre,
        clasificacion_caracteristica_jugador = p_nueva_clasificacion
    WHERE id_caracteristica_jugador = p_id_caracteristica;
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS eliminar_caracteristica_jugador;
DELIMITER $$
CREATE PROCEDURE eliminar_caracteristica_jugador(
    IN p_id_caracteristica INT
)
BEGIN
    DELETE FROM caracteristicas_jugadores
    WHERE id_caracteristica_jugador = p_id_caracteristica;
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertar_cuerpo_tecnico;
DELIMITER $$
CREATE PROCEDURE insertar_cuerpo_tecnico(
    IN p_nombre_cuerpo_tecnico VARCHAR(60)
)
BEGIN
    INSERT INTO cuerpos_tecnicos (nombre_cuerpo_tecnico)
    VALUES (p_nombre_cuerpo_tecnico);
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS actualizar_cuerpo_tecnico;
DELIMITER $$
CREATE PROCEDURE actualizar_cuerpo_tecnico(
    IN p_id_cuerpo_tecnico INT,
    IN p_nuevo_nombre VARCHAR(60)
)
BEGIN
    UPDATE cuerpos_tecnicos
    SET nombre_cuerpo_tecnico = p_nuevo_nombre
    WHERE id_cuerpo_tecnico = p_id_cuerpo_tecnico;
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS eliminar_cuerpo_tecnico;
DELIMITER $$
CREATE PROCEDURE eliminar_cuerpo_tecnico(
    IN p_id_cuerpo_tecnico INT
)
BEGIN
    DELETE FROM cuerpos_tecnicos
    WHERE id_cuerpo_tecnico = p_id_cuerpo_tecnico;
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertar_pago;
DELIMITER $$
CREATE PROCEDURE insertar_pago(
    IN p_fecha_pago DATE,
    IN p_cantidad_pago DECIMAL(5, 2),
    IN p_pago_tardio BOOLEAN,
    IN p_mora_pago DECIMAL(5, 2),
    IN p_mes_pago ENUM('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'),
    IN p_id_jugador INT
)
BEGIN
    INSERT INTO pagos (fecha_pago, cantidad_pago, pago_tardio, mora_pago, mes_pago, id_jugador)
    VALUES (p_fecha_pago, p_cantidad_pago, p_pago_tardio, p_mora_pago, p_mes_pago, p_id_jugador);
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS actualizar_pago;
DELIMITER $$
CREATE PROCEDURE actualizar_pago(
    IN p_id_pago INT,
    IN p_fecha_pago DATE,
    IN p_cantidad_pago DECIMAL(5, 2),
    IN p_pago_tardio BOOLEAN,
    IN p_mora_pago DECIMAL(5, 2),
    IN p_mes_pago ENUM('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'),
    IN p_id_jugador INT
)
BEGIN
    UPDATE pagos
    SET fecha_pago = p_fecha_pago,
        cantidad_pago = p_cantidad_pago,
        pago_tardio = p_pago_tardio,
        mora_pago = p_mora_pago,
        mes_pago = p_mes_pago,
        id_jugador = p_id_jugador
    WHERE id_pago = p_id_pago;
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS eliminar_pago;
DELIMITER $$
CREATE PROCEDURE eliminar_pago(
    IN p_id_pago INT
)
BEGIN
    DELETE FROM pagos
    WHERE id_pago = p_id_pago;
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertar_sub_tipologia;
DELIMITER $$
CREATE PROCEDURE insertar_sub_tipologia(
    IN p_nombre_sub_tipologia VARCHAR(60),
    IN p_id_tipologia INT
)
BEGIN
    INSERT INTO sub_tipologias (nombre_sub_tipologia, id_tipologia)
    VALUES (p_nombre_sub_tipologia, p_id_tipologia);
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS actualizar_sub_tipologia;
DELIMITER $$
CREATE PROCEDURE actualizar_sub_tipologia(
    IN p_id_sub_tipologia INT,
    IN p_nombre_sub_tipologia VARCHAR(60),
    IN p_id_tipologia INT
)
BEGIN
    UPDATE sub_tipologias
    SET nombre_sub_tipologia = p_nombre_sub_tipologia,
        id_tipologia = p_id_tipologia
    WHERE id_sub_tipologia = p_id_sub_tipologia;
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS eliminar_sub_tipologia;
DELIMITER $$
CREATE PROCEDURE eliminar_sub_tipologia(
    IN p_id_sub_tipologia INT
)
BEGIN
    DELETE FROM sub_tipologias
    WHERE id_sub_tipologia = p_id_sub_tipologia;
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS insertar_tipologia;
DELIMITER $$
CREATE PROCEDURE insertar_tipologia(
    IN p_tipologia VARCHAR(60)
)
BEGIN
    INSERT INTO tipologias (tipologia)
    VALUES (p_tipologia);
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS actualizar_tipologia;
DELIMITER $$
CREATE PROCEDURE actualizar_tipologia(
    IN p_id_tipologia INT,
    IN p_nueva_tipologia VARCHAR(60)
)
BEGIN
    UPDATE tipologias
    SET tipologia = p_nueva_tipologia
    WHERE id_tipologia = p_id_tipologia;
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS eliminar_tipologia;
DELIMITER $$
CREATE PROCEDURE eliminar_tipologia(
    IN p_id_tipologia INT
)
BEGIN
    DELETE FROM tipologias
    WHERE id_tipologia = p_id_tipologia;
END;
$$
DELIMITER ;


DROP PROCEDURE IF EXISTS insertar_temporada;
DELIMITER //
CREATE PROCEDURE insertar_temporada(IN p_nombre_temporada VARCHAR(50))
BEGIN
    INSERT INTO temporadas (nombre_temporada)
    VALUES (p_nombre_temporada);
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS actualizar_temporada;
DELIMITER //
CREATE PROCEDURE actualizar_temporada(IN p_id_temporada INT, IN p_nombre_temporada VARCHAR(50))
BEGIN
    UPDATE temporadas
    SET nombre_temporada = p_nombre_temporada
    WHERE id_temporada = p_id_temporada;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS eliminar_temporada;
DELIMITER //
CREATE PROCEDURE eliminar_temporada(IN p_id_temporada INT)
BEGIN
    DELETE FROM temporadas
    WHERE id_temporada = p_id_temporada;
END //

DELIMITER ;


DROP PROCEDURE IF EXISTS insertar_tarea;
DELIMITER //
CREATE PROCEDURE insertar_tarea(IN p_nombre_tarea VARCHAR(60))
BEGIN
    INSERT INTO tareas (nombre_tarea)
    VALUES (p_nombre_tarea);
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS actualizar_tarea;
DELIMITER //
CREATE PROCEDURE actualizar_tarea(IN p_id_tarea INT, IN p_nombre_tarea VARCHAR(60))
BEGIN
    UPDATE tareas
    SET nombre_tarea = p_nombre_tarea
    WHERE id_tarea = p_id_tarea;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS eliminar_tarea;
DELIMITER //
CREATE PROCEDURE eliminar_tarea(IN p_id_tarea INT)
BEGIN
    DELETE FROM tareas
    WHERE id_tarea = p_id_tarea;
END //

DELIMITER ;

-- Tabla plantillas

DELIMITER //

CREATE PROCEDURE insertar_plantilla(IN p_nombre_plantilla VARCHAR(150))
BEGIN
    INSERT INTO plantillas (nombre_plantilla)
    VALUES (p_nombre_plantilla);
END //

CREATE PROCEDURE actualizar_plantilla(IN p_id_plantilla INT, IN p_nombre_plantilla VARCHAR(150))
BEGIN
    UPDATE plantillas
    SET nombre_plantilla = p_nombre_plantilla
    WHERE id_plantilla = p_id_plantilla;
END //

CREATE PROCEDURE eliminar_plantilla(IN p_id_plantilla INT)
BEGIN
    DELETE FROM plantillas
    WHERE id_plantilla = p_id_plantilla;
END //

-- Tabla tipos_lesiones

DELIMITER //

CREATE PROCEDURE insertar_tipo_lesion(IN p_tipo_lesion VARCHAR(50))
BEGIN
    INSERT INTO tipos_lesiones (tipo_lesion)
    VALUES (p_tipo_lesion);
END //

CREATE PROCEDURE actualizar_tipo_lesion(IN p_id_tipo_lesion INT, IN p_tipo_lesion VARCHAR(50))
BEGIN
    UPDATE tipos_lesiones
    SET tipo_lesion = p_tipo_lesion
    WHERE id_tipo_lesion = p_id_tipo_lesion;
END //

CREATE PROCEDURE eliminar_tipo_lesion(IN p_id_tipo_lesion INT)
BEGIN
    DELETE FROM tipos_lesiones
    WHERE id_tipo_lesion = p_id_tipo_lesion;
END //

DELIMITER ;

-- Tabla rol_tecnico

DELIMITER //

CREATE PROCEDURE insertar_rol_tecnico(IN p_nombre_rol_tecnico VARCHAR(60))
BEGIN
    INSERT INTO rol_tecnico (nombre_rol_tecnico)
    VALUES (p_nombre_rol_tecnico);
END //

CREATE PROCEDURE actualizar_rol_tecnico(IN p_id_rol_tecnico INT, IN p_nombre_rol_tecnico VARCHAR(60))
BEGIN
    UPDATE rol_tecnico
    SET nombre_rol_tecnico = p_nombre_rol_tecnico
    WHERE id_rol_tecnico = p_id_rol_tecnico;
END //

CREATE PROCEDURE eliminar_rol_tecnico(IN p_id_rol_tecnico INT)
BEGIN
    DELETE FROM rol_tecnico
    WHERE id_rol_tecnico = p_id_rol_tecnico;
END //

DELIMITER ;

-- Procedimientos para la tabla jornadas
 
DROP PROCEDURE IF EXISTS insertar_jornada;
DELIMITER //
CREATE PROCEDURE insertar_jornada(
    IN p_nombre_jornada VARCHAR(60),
    IN p_numero_jornada INT,
    IN p_id_plantilla INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    -- Validar las fechas
    IF p_fecha_inicio >= p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de inicio debe ser anterior a la fecha de fin';
    END IF;

    -- Insertar una nueva jornada
    INSERT INTO jornadas (nombre_jornada, numero_jornada, id_plantilla, fecha_inicio_jornada, fecha_fin_jornada)
    VALUES (p_nombre_jornada, p_numero_jornada, p_id_plantilla, p_fecha_inicio, p_fecha_fin);
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS actualizar_jornada;
DELIMITER //
CREATE PROCEDURE actualizar_jornada(
    IN p_id_jornada INT,
    IN p_nombre_jornada VARCHAR(60),
    IN p_numero_jornada INT,
    IN p_id_plantilla INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN

    -- Validar las fechas
    IF p_fecha_inicio >= p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de inicio debe ser anterior a la fecha de fin';
    END IF;

    -- Actualizar la jornada existente
    UPDATE jornadas
    SET nombre_jornada = p_nombre_jornada,
        numero_jornada = p_numero_jornada,
        id_plantilla = p_id_plantilla,
        fecha_inicio_jornada = p_fecha_inicio,
        fecha_fin_jornada = p_fecha_fin
    WHERE id_jornada = p_id_jornada;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE sp_eliminar_jornada (IN p_id_jornada INT)
BEGIN
    DELETE FROM jornadas WHERE id_jornada = p_id_jornada;
END //

-- Procedimiento para insertar un nuevo horario
CREATE PROCEDURE sp_insertar_horario (
    IN p_nombre_horario VARCHAR(60),
    IN p_dia ENUM('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'),
    IN p_hora_inicial TIME,
    IN p_hora_final TIME,
    IN p_campo_de_entrenamiento VARCHAR(100)
)
BEGIN
    INSERT INTO horarios (nombre_horario, dia, hora_inicial, hora_final, campo_de_entrenamiento)
    VALUES (p_nombre_horario, p_dia, p_hora_inicial, p_hora_final, p_campo_de_entrenamiento);
END //

-- Procedimiento para actualizar un horario existente
DROP PROCEDURE IF EXISTS sp_actualizar_horario;
DELIMITER //
CREATE PROCEDURE sp_actualizar_horario (
    IN p_id_horario INT,
    IN p_nombre_horario VARCHAR(60),
    IN p_dia ENUM('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'),
    IN p_hora_inicial TIME,
    IN p_hora_final TIME,
    IN p_campo_de_entrenamiento VARCHAR(100)
)
BEGIN
    UPDATE horarios
    SET nombre_horario = p_nombre_horario,
        dia = p_dia,
        hora_inicial = p_hora_inicial,
        hora_final = p_hora_final,
        campo_de_entrenamiento = p_campo_de_entrenamiento
    WHERE id_horario = p_id_horario;
END //

-- Procedimiento para eliminar un horario
DROP PROCEDURE IF EXISTS sp_eliminar_horario;
DELIMITER //
CREATE PROCEDURE sp_eliminar_horario (
    IN p_id_horario INT
)
BEGIN
    DELETE FROM horarios WHERE id_horario = p_id_horario;
END //
DELIMITER ;

-- Procedimiento para insertar una nueva posición
DELIMITER //
CREATE PROCEDURE sp_insertar_posicion (
    IN p_posicion VARCHAR(60), 
    IN p_area_de_juego ENUM('Ofensiva', 'Defensiva', 'Ofensiva y defensiva')
)
BEGIN
    INSERT INTO posiciones(posicion, area_de_juego)
    VALUES (p_posicion, p_area_de_juego);
END //
DELIMITER ;

-- Procedimiento para actualizar una posición
DELIMITER //
CREATE PROCEDURE sp_actualizar_posicion (
    IN p_id_posicion INT, 
    IN p_posicion VARCHAR(60), 
    IN p_area_de_juego ENUM('Ofensiva', 'Defensiva', 'Ofensiva y defensiva')
)
BEGIN
    UPDATE posiciones 
    SET posicion = p_posicion, area_de_juego = p_area_de_juego
    WHERE id_posicion = p_id_posicion;
END //
DELIMITER ;

-- Procedimiento para eliminar una posición
DELIMITER //
CREATE PROCEDURE sp_eliminar_posicion (IN p_id_posicion INT)
BEGIN
    DELETE FROM posiciones WHERE id_posicion = p_id_posicion;
END //
DELIMITER ;

-- Procedimiento para insertar una nueva categoría
DELIMITER //
CREATE PROCEDURE sp_insertar_categoria (
    IN p_nombre_categoria VARCHAR(80), 
    IN p_edad_minima_permitida INT, 
    IN p_edad_maxima_permitida INT, 
    IN p_id_temporada INT
)
BEGIN
    INSERT INTO categorias(nombre_categoria, edad_minima_permitida, edad_maxima_permitida, id_temporada)
    VALUES (p_nombre_categoria, p_edad_minima_permitida, p_edad_maxima_permitida, p_id_temporada);
END //
DELIMITER ;

-- Procedimiento para actualizar una categoría
DELIMITER //
CREATE PROCEDURE sp_actualizar_categoria (
    IN p_id_categoria INT, 
    IN p_nombre_categoria VARCHAR(80), 
    IN p_edad_minima_permitida INT, 
    IN p_edad_maxima_permitida INT, 
    IN p_id_temporada INT
)
BEGIN
    UPDATE categorias 
    SET nombre_categoria = p_nombre_categoria, edad_minima_permitida = p_edad_minima_permitida, edad_maxima_permitida = p_edad_maxima_permitida, id_temporada = p_id_temporada
    WHERE id_categoria = p_id_categoria;
END //
DELIMITER ;

-- Procedimiento para eliminar una categoría
DELIMITER //
CREATE PROCEDURE sp_eliminar_categoria (IN p_id_categoria INT)
BEGIN
    DELETE FROM categorias WHERE id_categoria = p_id_categoria;
END //
DELIMITER ;

-- Procedimiento para insertar horarios_categorias
DELIMITER //
CREATE PROCEDURE sp_insertar_horario_categoria (
    IN p_id_categoria INT, 
    IN p_id_horario INT
)
BEGIN
    INSERT INTO horarios_categorias(id_categoria, id_horario)
    VALUES (p_id_categoria, p_id_horario);
END //
DELIMITER ;

-- Procedimiento para actualizar horarios_categorias
DELIMITER //
CREATE PROCEDURE sp_actualizar_horario_categoria (
    IN p_id_horario_categoria INT, 
    IN p_id_categoria INT, 
    IN p_id_horario INT
)
BEGIN
    UPDATE horarios_categorias 
    SET id_categoria = p_id_categoria, id_horario = p_id_horario
    WHERE id_horario_categoria = p_id_horario_categoria;
END //
DELIMITER ;

-- Procedimiento para eliminar horarios_categorias
DELIMITER //
CREATE PROCEDURE sp_eliminar_horario_categoria (IN p_id_horario_categoria INT)
BEGIN
    DELETE FROM horarios_categorias WHERE id_horario_categoria = p_id_horario_categoria;
END //
DELIMITER ;

-- Procedimiento para insertar registros_medicos
DELIMITER //
CREATE PROCEDURE sp_insertar_registro_medico (
    IN p_id_jugador INT, 
    IN p_fecha_lesion DATE, 
    IN p_fecha_registro DATE, 
    IN p_dias_lesionado INT, 
    IN p_id_lesion INT, 
    IN p_retorno_entreno DATE, 
    IN p_retorno_partido INT
)
BEGIN
    INSERT INTO registros_medicos(id_jugador, fecha_lesion, fecha_registro, dias_lesionado, id_lesion, retorno_entreno, retorno_partido)
    VALUES (p_id_jugador, p_fecha_lesion, p_fecha_registro, p_dias_lesionado, p_id_lesion, p_retorno_entreno, p_retorno_partido);
END //
DELIMITER ;

-- Procedimiento para actualizar registros_medicos
DELIMITER //
CREATE PROCEDURE sp_actualizar_registro_medico (
    IN p_id_registro_medico INT, 
    IN p_id_jugador INT, 
    IN p_fecha_lesion DATE, 
    IN p_fecha_registro DATE, 
    IN p_dias_lesionado INT, 
    IN p_id_lesion INT, 
    IN p_retorno_entreno DATE, 
    IN p_retorno_partido INT
)
BEGIN
    UPDATE registros_medicos 
    SET id_jugador = p_id_jugador, fecha_lesion = p_fecha_lesion, fecha_registro = p_fecha_registro, dias_lesionado = p_dias_lesionado, id_lesion = p_id_lesion, retorno_entreno = p_retorno_entreno, retorno_partido = p_retorno_partido
    WHERE id_registro_medico = p_id_registro_medico;
END //
DELIMITER ;

-- Procedimiento para eliminar registros_medicos
DELIMITER //
CREATE PROCEDURE sp_eliminar_registro_medico (IN p_id_registro_medico INT)
BEGIN
    DELETE FROM registros_medicos WHERE id_registro_medico = p_id_registro_medico;
END //
DELIMITER ;

-- Procedimientos para la tabla plantillas_equipos
DELIMITER //
CREATE PROCEDURE sp_insertar_plantilla_equipo (
    IN p_id_plantilla INT, 
    IN p_id_jugador INT, 
    IN p_id_temporada INT, 
    IN p_id_equipo INT
)
BEGIN
    INSERT INTO plantillas_equipos(id_plantilla, id_jugador, id_temporada, id_equipo)
    VALUES (p_id_plantilla, p_id_jugador, p_id_temporada, p_id_equipo);
END //

DROP PROCEDURE IF EXISTS sp_actualizar_plantilla_equipo;
DELIMITER //
CREATE PROCEDURE sp_actualizar_plantilla_equipo (
    IN p_id_plantilla_equipo INT, 
    IN p_id_plantilla INT, 
    IN p_id_jugador INT, 
    IN p_id_temporada INT, 
    IN p_id_equipo INT
)
BEGIN
    UPDATE plantillas_equipos 
    SET id_plantilla = p_id_plantilla, id_jugador = p_id_jugador, id_temporada = p_id_temporada, id_equipo = p_id_equipo
    WHERE id_plantilla_equipo = p_id_plantilla_equipo;
END //

DROP PROCEDURE IF EXISTS sp_eliminar_plantilla_equipo;
DELIMITER //
CREATE PROCEDURE sp_eliminar_plantilla_equipo (IN p_id_plantilla_equipo INT)
BEGIN
    DELETE FROM plantillas_equipos WHERE id_plantilla_equipo = p_id_plantilla_equipo;
END //
DELIMITER ;

-- Procedimientos para la tabla detalles_cuerpos_tecnicos

DELIMITER //
CREATE PROCEDURE sp_insertar_detalle_cuerpo_tecnico (
    IN p_id_cuerpo_tecnico INT, 
    IN p_id_tecnico INT, 
    IN p_id_rol_tecnico INT
)
BEGIN
    INSERT INTO detalles_cuerpos_tecnicos(id_cuerpo_tecnico, id_tecnico, id_rol_tecnico)
    VALUES (p_id_cuerpo_tecnico, p_id_tecnico, p_id_rol_tecnico);
END //

CREATE PROCEDURE sp_actualizar_detalle_cuerpo_tecnico (
    IN p_id_detalle_cuerpo_tecnico INT, 
    IN p_id_cuerpo_tecnico INT, 
    IN p_id_tecnico INT, 
    IN p_id_rol_tecnico INT
)
BEGIN
    UPDATE detalles_cuerpos_tecnicos 
    SET id_cuerpo_tecnico = p_id_cuerpo_tecnico, id_tecnico = p_id_tecnico, id_rol_tecnico = p_id_rol_tecnico
    WHERE id_detalle_cuerpo_tecnico = p_id_detalle_cuerpo_tecnico;
END //

CREATE PROCEDURE sp_eliminar_detalle_cuerpo_tecnico (IN p_id_detalle_cuerpo_tecnico INT)
BEGIN
    DELETE FROM detalles_cuerpos_tecnicos WHERE id_detalle_cuerpo_tecnico = p_id_detalle_cuerpo_tecnico;
END //

DELIMITER ;


-- VISTA

-- VISTA para tabla administradores
DROP VIEW IF EXISTS vista_tabla_administradores;
DELIMITER $$
CREATE VIEW vista_tabla_administradores AS
SELECT id_administrador AS 'ID',
foto_administrador AS 'IMAGEN', 
CONCAT(nombre_administrador, ' ', apellido_administrador) AS 'NOMBRE',
correo_administrador AS 'CORREO', 
telefono_administrador AS 'TELÉFONO',
dui_administrador AS 'DUI',
fecha_nacimiento_administrador AS 'NACIMIENTO',
    CASE 
        WHEN estado_administrador = 1 THEN 'Activo'
        WHEN estado_administrador = 0 THEN 'Bloqueado'
    END AS 'ESTADO'
FROM administradores;
$$

-- VISTA para tabla tecnicos
DROP VIEW IF EXISTS vista_tabla_tecnicos;
DELIMITER $$
CREATE VIEW vista_tabla_tecnicos AS
SELECT id_tecnico AS 'ID',
CONCAT(nombre_tecnico, ' ', apellido_tecnico) AS 'NOMBRE',
foto_tecnico AS 'IMAGEN', 
correo_tecnico AS 'CORREO', 
telefono_tecnico AS 'TELÉFONO',
dui_tecnico AS 'DUI',
fecha_nacimiento_tecnico AS 'NACIMIENTO',
    CASE 
        WHEN estado_tecnico = 1 THEN 'Activo'
        WHEN estado_tecnico = 0 THEN 'Bloqueado'
    END AS 'ESTADO'
FROM tecnicos;
$$
DELIMITER ;

-- VISTA para tabla caracteristica jugadores
DROP VIEW IF EXISTS vista_caracteristicas_jugadores;
DELIMITER $$
CREATE VIEW vista_caracteristicas_jugadores AS
SELECT id_caracteristica_jugador AS 'ID',
	   nombre_caracteristica_jugador AS 'NOMBRE',
       clasificacion_caracteristica_jugador AS 'CLASIFICACION'
FROM caracteristicas_jugadores;
$$

-- VISTA para tabla cuerpo cuerpo técnico
DROP VIEW IF EXISTS vista_cuerpos_tecnicos;
DELIMITER $$
CREATE VIEW vista_cuerpos_tecnicos AS
SELECT id_cuerpo_tecnico AS 'ID',
nombre_cuerpo_tecnico AS 'NOMBRE'
FROM cuerpos_tecnicos;
$$


SELECT id_cuerpo_tecnico AS 'ID',
nombre_cuerpo_tecnico AS 'NOMBRE'
FROM cuerpos_tecnicos;
SELECT * FROM vista_cuerpos_tecnicos;
DELIMITER ;

-- VISTA para tabla pagos
DROP VIEW IF EXISTS vista_pagos;
DELIMITER $$
CREATE VIEW vista_pagos AS
SELECT p.id_pago AS 'ID',
       p.fecha_pago AS 'FECHA',
       p.cantidad_pago AS 'CANTIDAD',
       p.pago_tardio AS 'TARDIO',
       p.mora_pago AS 'MORA',
       p.mes_pago AS 'MES',
       CONCAT(j.nombre_jugador,' ',j.apellido_jugador) AS 'NOMBRE'
FROM pagos p
INNER JOIN jugadores j ON p.id_jugador = j.id_jugador;
$$
DELIMITER ;


-- VISTA para tabla sub tipología
DROP VIEW IF EXISTS vista_sub_tipologias;
DELIMITER $$
CREATE VIEW vista_sub_tipologias AS
SELECT st.id_sub_tipologia AS 'ID',
       st.nombre_sub_tipologia AS 'NOMBRE',
       t.tipologia AS 'TIPOLOGIA'
FROM sub_tipologias st
INNER JOIN tipologias t ON st.id_tipologia = t.id_tipologia;
$$
DELIMITER ;

-- VISTA para tabla tipología
DROP VIEW IF EXISTS vista_tipologias;
DELIMITER $$
CREATE VIEW vista_tipologias AS
SELECT id_tipologia AS 'ID',
       tipologia AS 'NOMBRE'
FROM tipologias;
$$
DELIMITER ;

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

-- VISTA para la tabla temporadas
CREATE VIEW vista_temporadas AS
SELECT 
  id_temporada AS ID,
  nombre_temporada AS NOMBRE
FROM 
  temporadas;

-- VISTA para la tabla tareas
CREATE VIEW vista_tareas AS
SELECT 
  id_tarea AS ID,
  nombre_tarea AS NOMBRE
FROM 
  tareas;

-- VISTA para la tabla plantillas
CREATE VIEW vista_plantillas AS
SELECT 
  id_plantilla AS ID,
  nombre_plantilla AS NOMBRE
FROM 
  plantillas;

-- VISTA para la tabla tipos lesiones
CREATE VIEW vista_tipos_lesiones AS
SELECT 
  id_tipo_lesion AS ID,
  tipo_lesion AS NOMBRE
FROM 
  tipos_lesiones;


-- VISTA para la tabla rol tecnico
CREATE VIEW vista_rol_tecnico AS
SELECT 
  id_rol_tecnico AS ID,
  nombre_rol_tecnico AS NOMBRE
FROM 
  rol_tecnico;


-- Vista para jornadas
DROP VIEW IF EXISTS vw_jornadas;
CREATE VIEW vw_jornadas AS
SELECT 
    j.id_jornada AS ID,
    j.nombre_jornada AS NOMBRE,
    j.numero_jornada AS NUMERO,
    p.nombre_plantilla AS PLANTILLA,
    j.id_plantilla AS ID_PLANTILLA,
    j.fecha_inicio_jornada AS FECHA_INICIO,
    j.fecha_fin_jornada AS FECHA_FIN
FROM 
    jornadas j
INNER JOIN 
    plantillas p ON j.id_plantilla = p.id_plantilla;

-- Vista para plantillas_equipos
DROP VIEW IF EXISTS vw_plantillas_equipos_agrupadas;
CREATE VIEW vw_plantillas_equipos_agrupadas AS
SELECT 
    pe.id_plantilla_equipo AS ID,
    pe.id_plantilla AS ID_PLANTILLA,
    p.nombre_plantilla AS NOMBRE_PLANTILLA,
    COUNT(pe.id_jugador) AS TOTAL_JUGADORES,
    pe.id_temporada AS ID_TEMPORADA,
    t.nombre_temporada AS NOMBRE_TEMPORADA,
    pe.id_equipo AS ID_EQUIPO,
    e.nombre_equipo AS NOMBRE_EQUIPO
FROM 
    plantillas_equipos pe
INNER JOIN 
    plantillas p ON pe.id_plantilla = p.id_plantilla
INNER JOIN 
    temporadas t ON pe.id_temporada = t.id_temporada
INNER JOIN 
    equipos e ON pe.id_equipo = e.id_equipo
GROUP BY 
    pe.id_plantilla,
    p.nombre_plantilla,
    pe.id_temporada,
    t.nombre_temporada,
    pe.id_equipo,
    e.nombre_equipo;

SELECT * FROM vw_plantillas_equipos_agrupadas;

-- Vista para detalles_cuerpos_tecnicos
DROP VIEW IF EXISTS vw_detalles_cuerpos_tecnicos;
CREATE VIEW vw_detalles_cuerpos_tecnicos AS
SELECT 
    dct.id_detalle_cuerpo_tecnico AS ID,
    dct.id_cuerpo_tecnico AS ID_CUERPO_TECNICO,
    dct.id_tecnico AS ID_TECNICO,
    dct.id_rol_tecnico AS ID_ROL,
    ct.nombre_cuerpo_tecnico AS CUERPO_TECNICO,
    CONCAT(t.nombre_tecnico, ' ', t.apellido_tecnico) AS TECNICO,
    rt.nombre_rol_tecnico AS ROL_TECNICO
FROM 
    detalles_cuerpos_tecnicos dct
INNER JOIN 
    cuerpos_tecnicos ct ON dct.id_cuerpo_tecnico = ct.id_cuerpo_tecnico
INNER JOIN 
    tecnicos t ON dct.id_tecnico = t.id_tecnico
INNER JOIN 
    rol_tecnico rt ON dct.id_rol_tecnico = rt.id_rol_tecnico;

SELECT * FROM vw_detalles_cuerpos_tecnicos;

SELECT ROUTINE_NAME
FROM information_schema.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_SCHEMA = 'db_gol_sv';

SELECT TABLE_NAME
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'db_gol_sv';

-- Vista para ver los tipos de goles agregados.
CREATE VIEW vista_tipos_goles AS
    SELECT
        tg.id_tipo_gol,
        tg.id_tipo_jugada,
        tg.nombre_tipo_gol AS gol,
        tj.nombre_tipo_juego AS jugada
FROM
    tipos_goles tg
INNER JOIN
    tipos_jugadas tj on tg.id_tipo_jugada =   tj.id_tipo_jugada;

-- Vista para los jugadores.
CREATE VIEW vista_jugadores AS
    SELECT
        j.id_jugador,
        j.dorsal_jugador,
        j.nombre_jugador,
        j.apellido_jugador,
        j.estatus_jugador,
        j.fecha_nacimiento_jugador,
        j.genero_jugador,
        j.perfil_jugador,
        j.becado,
        j.id_posicion_principal,
        j.id_posicion_secundaria,
        j.alias_jugador,
        j.clave_jugador,
        j.foto_jugador,
        j.fecha_creacion,
        p1.posicion AS posicionPrincipal,
        p2.posicion AS posicionSecundaria
FROM jugadores j
INNER JOIN
    posiciones p1 ON j.id_posicion_principal = p1.id_posicion
INNER JOIN
    posiciones p2 ON j.id_posicion_secundaria = p2.id_posicion;

SELECT * FROM vista_jugadores;

-- Procedimiento para insertar un jugador
DELIMITER $$
CREATE PROCEDURE insertar_jugador(
   IN p_dorsal_jugador INT UNSIGNED,
   IN p_nombre_jugador VARCHAR(50),
   IN p_apellido_jugador VARCHAR(100),
   IN p_estatus_jugador VARCHAR(50),
   IN p_fecha_nacimiento_jugador DATE,
   IN p_genero_jugador VARCHAR(10),
   IN p_perfil_jugador VARCHAR(50),
   IN p_becado VARCHAR(50),
   IN p_id_posicion_principal INT,
   IN p_id_posicion_secundaria INT,
   IN p_clave_jugador VARCHAR(100),
   IN p_foto_jugador VARCHAR(50)
)
BEGIN
    DECLARE p_alias_jugador VARCHAR(25);
        -- Generar el alias utilizando la función, suponiendo que la función generar_alias_tecnico existe
        SET p_alias_jugador = generar_alias_jugador(p_nombre_jugador, p_apellido_jugador, p_perfil_jugador, NOW());
        INSERT INTO jugadores (dorsal_jugador, nombre_jugador, apellido_jugador, estatus_jugador, fecha_nacimiento_jugador, genero_jugador, perfil_jugador, becado, id_posicion_principal, id_posicion_secundaria, clave_jugador, foto_jugador, alias_jugador)
        VALUES(p_dorsal_jugador, p_nombre_jugador, p_apellido_jugador, p_estatus_jugador, p_fecha_nacimiento_jugador, p_genero_jugador, p_perfil_jugador, p_becado, p_id_posicion_principal, p_id_posicion_secundaria, p_clave_jugador, p_foto_jugador, p_alias_jugador);
END;
$$
DELIMITER ;

-- Procedimiento para actualizar jugador
DELIMITER //
CREATE PROCEDURE actualizar_jugador (
    IN id INT,
    IN dorsal INT,
    IN nombre VARCHAR(50),
    IN apellido VARCHAR(50),
    IN estatus VARCHAR(50),
    IN nacimiento DATE,
    IN genero VARCHAR(50),
    IN perfil VARCHAR(50),
    IN beca VARCHAR(50),
    IN posicionPrincipal INT,
    IN posicionSecundaria INT,
    IN foto VARCHAR(36)
)
BEGIN
    UPDATE jugadores
    SET id_jugador = id, dorsal_jugador = dorsal, nombre_jugador = nombre, apellido_jugador = apellido,
        estatus_jugador = estatus, fecha_nacimiento_jugador = nacimiento, genero_jugador = genero, perfil_jugador = perfil,
        becado = beca, id_posicion_principal = posicionPrincipal, id_posicion_secundaria = posicionSecundaria, foto_jugador = foto
    WHERE id_jugador = id;
END //
DELIMITER ;


-- PROCEDIMIENTO PARA INSERTAR LESIONES.
DELIMITER $$
CREATE PROCEDURE insertar_lesion(
   IN l_id_tipo_lesion INT,
   IN l_id_sub_tipologia INT
)
BEGIN
        INSERT INTO lesiones (id_tipo_lesion, id_sub_tipologia)
        VALUES(l_id_tipo_lesion, l_id_sub_tipologia);
END;
$$
DELIMITER ;


-- PROCEDIMIENTO PARA INSERTAR LOS CAMPOS TOTAL_POR_LESION Y PROMEDIO_POR_LESION EN LA TABLA LESIONES.
DELIMITER //
CREATE PROCEDURE insertar_campos_lesiones(IN p_id_lesion INT)
BEGIN
    -- Actualiza el número de lesiones para la lesión específica
    UPDATE lesiones
    SET total_por_lesion = (
        SELECT COUNT(*)
        FROM registros_medicos rm
        WHERE rm.id_lesion = p_id_lesion
    )
    WHERE lesiones.id_lesion = p_id_lesion;

    -- Calcula y actualizar el porcentaje de lesiones
    UPDATE lesiones
    SET porcentaje_por_lesion = (
        SELECT COUNT(*)
        FROM registros_medicos rm
        WHERE rm.id_lesion = p_id_lesion
    ) / (
        SELECT COUNT(*)
        FROM registros_medicos
    ) * 100
    WHERE lesiones.id_lesion = p_id_lesion;
END //

DELIMITER ;

-- TRIGGER PARA INSERTAR LOS CAMPOS DE LESIONES AUTOMATICAMENTE, DESPUES DE UNA INSERCION EN LA TABLA REGISTRO MEDICO
DELIMITER //

CREATE TRIGGER trigger_insertar_lesiones
AFTER INSERT ON registros_medicos
FOR EACH ROW
BEGIN
 CALL insertar_campos_lesiones(NEW.id_lesion);
END//

DELIMITER ;

-- TRIGGER QUE SE EJECUTA ANTES DE LA ACTUALIZACION DE UN REGISTRO EN LA TABLA DE REGISTRO MEDICO, ESTO PARA QUE TANTO EL TOTAL POR LESION
-- COMO EL PORCENTAJE_POR_LESION SE REDUZCAN DE LA TABLA LESIONES, SI SE ACTUALIZA EL ID_LESION DE LA TABLA REGISTRO MEDICO.
DELIMITER //

CREATE TRIGGER trigger_actualizacion_antes_lesiones
BEFORE UPDATE ON registros_medicos
FOR EACH ROW
BEGIN
    -- Reduce el conteo de lesiones para el id_lesion antiguo si cambió
    IF OLD.id_lesion <> NEW.id_lesion THEN
        UPDATE lesiones
        SET total_por_lesion = total_por_lesion - 1
        WHERE id_lesion = OLD.id_lesion;

     -- Actualizar el promedio de lesiones para el id_lesion antiguo
        UPDATE lesiones
        SET porcentaje_por_lesion = (
            SELECT COUNT(*)
            FROM registros_medicos rm
            WHERE rm.id_lesion = OLD.id_lesion
        ) / (
            SELECT COUNT(*)
            FROM registros_medicos
        ) * 100
        WHERE id_lesion = OLD.id_lesion;
    END IF;
END //

DELIMITER ;

-- TRIGGER PARA ACTUALIZAR LOS CAMPOS DE LESIONES AUTOMATICAMENTE, DESPUES DE UNA ACTUALIZACION EN LA TABLA REGISTRO MEDICO
DELIMITER //

CREATE TRIGGER trigger_actualizar_lesiones
AFTER UPDATE ON registros_medicos
FOR EACH ROW
BEGIN
    CALL insertar_campos_lesiones(NEW.id_lesion);
END //

DELIMITER ;

-- TRIGGER PARA REDUCIR LA CANTIDAD EN LESIONES Y PORCENTAJE DE LOS CAMPOS DE LESIONES AUTOMATICAMENTE,
-- DESPUES DE QUE SE HAYA ELIMINADO UNA INSERCION EN LA TABLA REGISTRO MEDICO
DELIMITER //

CREATE TRIGGER trigger_eliminar_lesiones
AFTER DELETE ON registros_medicos
FOR EACH ROW
BEGIN
    CALL insertar_campos_lesiones(OLD.id_lesion);
END //

DELIMITER ;

-- Vista para ver las lesiones
CREATE VIEW vista_lesiones AS
    SELECT
        l.id_lesion,
        l.id_tipo_lesion,
        l.id_sub_tipologia,
        l.total_por_lesion,
        l.porcentaje_por_lesion,
        tl.tipo_lesion,
        st.nombre_sub_tipologia
FROM lesiones l
INNER JOIN
    tipos_lesiones tl ON l.id_tipo_lesion = tl.id_tipo_lesion
INNER JOIN
    sub_tipologias st ON l.id_sub_tipologia = st.id_sub_tipologia;

-- VISTA PARA LOS EQUIPOS
CREATE VIEW vista_equipos AS
    SELECT
        e.id_equipo AS ID,
        e.nombre_equipo AS NOMBRE,
        e.genero_equipo,
        e.telefono_contacto,
        e.id_categoria,
        e.id_cuerpo_tecnico,
        e.logo_equipo,
        c.nombre_categoria
FROM equipos e
INNER JOIN
    categorias c ON e.id_categoria = c.id_categoria;

-- VISTA PARA VER EL CUERPO TECNICO DE UN EQUIPO
CREATE VIEW vista_tecnicos_equipos AS
    SELECT
        e.id_equipo AS ID,
        e.id_cuerpo_tecnico,
        e.id_categoria,
        dt.id_tecnico,
        t.nombre_tecnico,
        t.apellido_tecnico,
        dt.id_rol_tecnico,
        rt.nombre_rol_tecnico,
        t.foto_tecnico,
        t.correo_tecnico
FROM equipos e
INNER JOIN
    detalles_cuerpos_tecnicos dt ON e.id_cuerpo_tecnico = dt.id_cuerpo_tecnico
INNER JOIN
    tecnicos t ON dt.id_tecnico = t.id_tecnico
INNER JOIN
    rol_tecnico rt ON dt.id_rol_tecnico = rt.id_rol_tecnico;

-- ------------------------------------------------------------------------DETALLES CONTENIDOS----------------------------------------------------------------
-- Vista para el GET de detalles contenidos- elegir horarios
CREATE VIEW vista_equipos_categorias AS
SELECT 
    equipos.id_equipo, 
    categorias.nombre_categoria, 
    equipos.nombre_equipo
FROM 
    equipos
JOIN 
    categorias ON equipos.id_categoria = categorias.id_categoria;
    
 
-- Vista para conocer los horarios de un equipo en especifico, se usa en detalles contenidos - elegir horarios    
CREATE  VIEW vista_horarios_equipos AS
CREATE VIEW vista_horarios_equipos AS
SELECT 
  e.id_equipo,
  e.id_entrenamiento,
  CONCAT(h.dia, ' de ', TIME_FORMAT(h.hora_inicial, '%H:%i'), ' A ', TIME_FORMAT(h.hora_final, '%H:%i')) AS horario
  e.fecha_entrenamiento,
  CONCAT(h.dia, DATE_FORMAT(e.fecha_entrenamiento, ' %d de %M'), ' de ', TIME_FORMAT(h.hora_inicial, '%H:%i'), ' A ', TIME_FORMAT(h.hora_final, '%H:%i')) AS horario
FROM 
  entrenamientos e
INNER JOIN 
  horarios h ON e.id_horario = h.id_horario;

SELECT * FROM vista_horarios_equipos WHERE id_equipo = 1;
	SELECT * FROM entrenamientos;
-- Vista para el GET de detalles contenidos
CREATE VIEW vista_detalle_entrenamiento AS
SELECT 
    e.id_equipo,
    e.id_entrenamiento,
    dc.id_detalle_contenido,
    j.nombre_jugador,
    stc.sub_tema_contenido AS nombre_subtema,
    t.nombre_tarea
FROM 
    detalle_entrenamiento de
JOIN 
    entrenamientos e ON de.id_entrenamiento = e.id_entrenamiento
JOIN 
    detalles_contenidos dc ON de.id_detalle_contenido = dc.id_detalle_contenido
JOIN 
    jugadores j ON de.id_jugador = j.id_jugador
JOIN 
    sub_temas_contenidos stc ON dc.id_sub_tema_contenido = stc.id_sub_tema_contenido
LEFT JOIN 
    tareas t ON dc.id_tarea = t.id_tarea;

-- Vista para el UPDATE de detalles contenidos
CREATE VIEW vista_detalle_entrenamiento_especifico AS
SELECT 
    dc.id_detalle_contenido,
    j.id_jugador,
    stc.id_sub_tema_contenido,
    dc.minutos_contenido,
    dc.minutos_tarea,
    t.id_tarea,
    de.id_detalle
FROM 
    detalle_entrenamiento de
JOIN 
    detalles_contenidos dc ON de.id_detalle_contenido = dc.id_detalle_contenido
JOIN 
    jugadores j ON de.id_jugador = j.id_jugador
JOIN 
    sub_temas_contenidos stc ON dc.id_sub_tema_contenido = stc.id_sub_tema_contenido
JOIN 
    tareas t ON dc.id_tarea = t.id_tarea;    
    
SELECT * FROM vista_detalle_entrenamiento_especifico;

-- Vista para conocr los jugadores de un equipo, solo se necesita saber el id equipo, se usa en detalles contenidos
CREATE VIEW vista_equipos_jugadores AS
SELECT 
    e.id_equipo,
    j.nombre_jugador,
    j.id_jugador,
    pe.id_plantilla_equipo
FROM 
    equipos e
JOIN 
    plantillas_equipos pe ON e.id_equipo = pe.id_equipo
JOIN 
    jugadores j ON pe.id_jugador = j.id_jugador;

-- Procedimiento para insertar detalle contenido
DELIMITER $$

CREATE PROCEDURE insertarDetalleContenido(
    IN p_subContenido_id INT UNSIGNED,
    IN p_subContenido_minutos INT UNSIGNED,
    IN p_tarea_id INT UNSIGNED,
    IN p_tarea_minutos INT UNSIGNED,
    IN p_id_jugador INT UNSIGNED,
    IN p_id_entrenamiento INT UNSIGNED
)
BEGIN
    DECLARE v_id_detalle_contenido INT;
    DECLARE v_exists INT;
    DECLARE v_exists2 INT;
    DECLARE v_id INT;
    DECLARE done INT DEFAULT 0;

    -- Cursor para recorrer los registros
    DECLARE cur CURSOR FOR
        SELECT id_detalle FROM detalle_entrenamiento
        WHERE id_jugador = p_id_jugador AND id_entrenamiento = p_id_entrenamiento;

    -- Handler para salir del cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Insertar en detalles_contenidos
    INSERT INTO detalles_contenidos (id_tarea, id_sub_tema_contenido, minutos_contenido, minutos_tarea)
    VALUES (p_tarea_id, p_subContenido_id, p_subContenido_minutos, p_tarea_minutos);
    
    SET v_id_detalle_contenido = LAST_INSERT_ID();

    -- Verificar si ya existe el registro en detalle_entrenamiento
    SELECT COUNT(*) INTO v_exists
    FROM detalle_entrenamiento
    WHERE id_jugador = p_id_jugador AND id_entrenamiento = p_id_entrenamiento;

    -- Si no existe, insertar nuevo registro
    IF v_exists = 0 THEN
        INSERT INTO detalle_entrenamiento (id_entrenamiento, id_asistencia, id_caracteristica_analisis, id_detalle_contenido, id_jugador)
        VALUES (p_id_entrenamiento, NULL, NULL, v_id_detalle_contenido, p_id_jugador);
    ELSE
        -- Aquí se verifica si en los registros con el mismo id entrenamiento y id jugador, algún registro tiene un dato NO NULLO en id_detalle_contenido
        SELECT COUNT(*) INTO v_exists2
        FROM detalle_entrenamiento
        WHERE id_jugador = p_id_jugador AND id_entrenamiento = p_id_entrenamiento AND id_detalle_contenido IS NOT NULL;
        
        -- En caso de que no exista (v_exists2 = 0), pasará a un if, en caso contrario (v_exists2 > 0), pasará a un else
        IF v_exists2 >= 1 THEN
            -- Abrir el cursor
            OPEN cur;

            -- Bucle para recorrer los registros
            read_loop: LOOP
                FETCH cur INTO v_id;
                IF done THEN
                    LEAVE read_loop;
                END IF;

                -- Verificar si id_detalle_contenido es NULL
                IF (SELECT id_detalle_contenido FROM detalle_entrenamiento WHERE id_detalle = v_id) IS NULL THEN
                    -- Actualizar el registro
                    UPDATE detalle_entrenamiento
                    SET id_asistencia = NULL,
                        id_caracteristica_analisis = NULL,
                        id_detalle_contenido = v_id_detalle_contenido
                    WHERE id_detalle = v_id;
                    LEAVE read_loop;
                END IF;
            END LOOP;

            -- Cerrar el cursor
            CLOSE cur;
        ELSE
            -- Si existe un id_detalle_contenido no nulo, insertar un nuevo registro
            INSERT INTO detalle_entrenamiento (id_entrenamiento, id_asistencia, id_caracteristica_analisis, id_detalle_contenido, id_jugador)
            VALUES (p_id_entrenamiento, NULL, NULL, v_id_detalle_contenido, p_id_jugador);
        END IF;
    END IF;
END;
$$

DELIMITER ;

-- Procedimiento para actualizar detalle contenido
DELIMITER $$

CREATE PROCEDURE actualizarDetalleContenido(
    IN p_subContenido_id INT UNSIGNED,
    IN p_subContenido_minutos INT UNSIGNED,
    IN p_tarea_id INT UNSIGNED,
    IN p_tarea_minutos INT UNSIGNED,
    IN p_id_detalle_contenido INT UNSIGNED
)
BEGIN
    
      UPDATE detalles_contenidos
      SET id_tarea = p_tarea_id,
      id_sub_tema_contenido = p_subContenido_id,
      minutos_contenido = p_subContenido_minutos,
      minutos_tarea = p_tarea_minutos
      WHERE id_detalle_contenido = p_id_detalle_contenido;
      
END;
$$

DELIMITER ;

-- ------------------------------------------------------------------------PARTIDOS----------------------------------------------------------------
-- Vista para partidos:
CREATE VIEW vista_detalle_partidos AS
SELECT
    DATE_FORMAT(p.fecha_partido, '%e de %M del %Y') AS fecha,
    p.localidad_partido,
    p.resultado_partido,
    p.logo_rival,
    e.logo_equipo,
    e.nombre_equipo,
    p.rival_partido AS nombre_rival,
    p.id_partido,
    e.id_equipo
FROM
    partidos p
INNER JOIN
    equipos e ON p.id_equipo = e.id_equipo
ORDER BY p.fecha_partido;

SELECT * FROM vista_detalle_partidos;

-- PROCEDIMIENTO ALMACENADO DE PARTIDOS
DELIMITER $$

CREATE PROCEDURE insertarPartido(
    IN p_id_equipo INT,
    IN p_logo_rival VARCHAR(50),
    IN p_rival_partido VARCHAR(50),
    IN p_cancha_partido VARCHAR(100),
    IN p_resultado_partido VARCHAR(10),
    IN p_localidad_partido ENUM('Local', 'Visitante'),
    IN p_tipo_resultado_partido ENUM('Victoria', 'Empate', 'Derrota'),
    IN p_id_jornada INT
)
BEGIN
    DECLARE v_fecha_actual DATETIME;
    -- Obtener la fecha actual
    SET v_fecha_actual = NOW();

    -- Insertar el nuevo registro en la tabla partidos
    INSERT INTO partidos (
        id_jornada,
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
        p_id_jornada,
        p_id_equipo,
        p_logo_rival,
        p_rival_partido,
        v_fecha_actual,
        p_cancha_partido,
        p_resultado_partido,
        p_localidad_partido,
        p_tipo_resultado_partido
    );
END$$

DELIMITER ;

-- Vista para read one de partidos
CREATE VIEW vista_partidos_equipos AS
SELECT 
    e.id_equipo,
    e.nombre_equipo,
    e.logo_equipo,
    p.id_partido,
    DATE(p.fecha_partido) AS fecha_partido,
    p.cancha_partido,
    p.rival_partido AS nombre_rival,
    p.logo_rival,
    p.resultado_partido,
    p.localidad_partido,
    p.tipo_resultado_partido,
    j.nombre_jornada,
    j.id_jornada
FROM 
    partidos p
JOIN 
    equipos e ON p.id_equipo = e.id_equipo
JOIN 
    jornadas j ON p.id_jornada = j.id_jornada;


SELECT 
        e.id_estado_fisico_jugador,
        e.id_jugador,
        e.altura_jugador,
        e.peso_jugador,
        e.indice_masa_corporal,
        e.fecha_creacion,
        j.nombre_jugador,
        DATE_FORMAT(e.fecha_creacion, '%d de %M de %Y') AS fecha_creacion_format
        FROM estados_fisicos_jugadores e
        INNER JOIN
        jugadores j ON j.id_jugador = e.id_jugador
        WHERE e.id_jugador = 2;
SELECT * FROM equipos;
