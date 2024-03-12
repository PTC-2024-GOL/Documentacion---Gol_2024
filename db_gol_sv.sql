DROP DATABASE if EXISTS prototipo_base_gol_el_salvador;

CREATE DATABASE prototipo_base_gol_el_salvador;

USE prototipo_base_gol_el_salvador;

CREATE TABLE administradores(
id_administrador INT AUTO_INCREMENT PRIMARY KEY,
nombre_administrador VARCHAR(50) NOT NULL,
apellido_administrador VARCHAR(50) NOT NULL,
alias_administrador VARCHAR(25) NOT NULL,
CONSTRAINT uq_alias_administrador_unico 
UNIQUE(alias_administrador),
clave_administrador VARCHAR(100) NOT NULL,
correo_administrador VARCHAR(50) NOT NULL,
CONSTRAINT uq_correo_administrador_unico 
UNIQUE(correo_administrador),
CONSTRAINT chk_correo_administrador_formato 
CHECK (correo_administrador REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$'),
telefono_administrador VARCHAR(15) NOT NULL,
dui_administrador VARCHAR(10) NOT NULL,
CONSTRAINT uq_dui_administrador_unico 
UNIQUE(dui_administrador),
fecha_nacimiento_administrador DATE NOT NULL,
fecha_creacion DATETIME NULL DEFAULT NOW(),
intentos_administrador INT DEFAULT 0,
fecha_clave DATETIME NULL,
fecha_bloqueo DATETIME NULL,
foto_administrador VARCHAR(50) NULL,
CONSTRAINT chk_url_foto_administrador 
CHECK (foto_administrador LIKE '%.jpg' OR foto_administrador LIKE '%.png' OR foto_administrador LIKE '%.jpeg' OR foto_administrador LIKE '%.gif')
);

CREATE TABLE tecnicos(
id_tecnico INT AUTO_INCREMENT PRIMARY KEY,
nombre_tecnico VARCHAR(50) NOT NULL,
apellido_tecnico VARCHAR(50) NOT NULL,
alias_tecnico VARCHAR(25) NOT NULL,
CONSTRAINT uq_alias_tecnico_unico 
UNIQUE(alias_tecnico),
clave_tecnico VARCHAR(100) NOT NULL,
correo_tecnico VARCHAR(50) NOT NULL,
CONSTRAINT uq_correo_tecnico_unico 
UNIQUE(correo_tecnico),
CONSTRAINT chk_correo_tecnico_formato 
CHECK (correo_tecnico REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$'),
telefono_tecnico VARCHAR(15) NOT NULL,
dui_tecnico VARCHAR(10) NOT NULL,
CONSTRAINT uq_dui_tecnico_unico 
UNIQUE(dui_tecnico),
fecha_nacimiento_tecnico DATE NOT NULL,
fecha_creacion DATETIME NULL DEFAULT NOW(),
foto_tecnico VARCHAR(50) NULL,
CONSTRAINT chk_url_foto_administrador 
CHECK (foto_tecnico LIKE '%.jpg' OR foto_tecnico LIKE '%.png' OR foto_tecnico LIKE '%.jpeg' OR foto_tecnico LIKE '%.gif')
);

CREATE TABLE temporadas(
id_temporada INT AUTO_INCREMENT PRIMARY KEY,
anio YEAR NOT NULL,
CONSTRAINT uq_anio_temporada_unico 
UNIQUE(anio)
);

CREATE TABLE horarios(
id_horario INT AUTO_INCREMENT PRIMARY KEY,
dia ENUM('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo') NOT NULL,
hora_inicial TIME NOT NULL,
hora_final TIME NOT NULL,
CONSTRAINT chk_validacion_de_horas 
CHECK(hora_inicial < hora_final),
campo_de_entrenamiento VARCHAR(100) NOT NULL
);

CREATE TABLE categorias(
id_categoria INT AUTO_INCREMENT PRIMARY KEY,
nombre_categoria VARCHAR(80) NOT NULL,
edad_minima_permitida DATE NOT NULL,
edad_maxima_permitida DATE NOT NULL,
CONSTRAINT chk_validacion_de_edades 
CHECK(edad_minima_permitida < edad_maxima_permitida),
id_temporada INT NOT NULL,
CONSTRAINT fk_temporada_de_la_categoria 
FOREIGN KEY (id_temporada)
REFERENCES temporadas(id_temporada),
id_horario INT NOT NULL,
CONSTRAINT fk_horarios_de_la_categoria 
FOREIGN KEY (id_horario)
REFERENCES horarios(id_horario)
);

CREATE TABLE cuerpos_tecnicos(
    id_cuerpo_tecnico INT AUTO_INCREMENT PRIMARY KEY,
    primer_tecnico INT,
    CONSTRAINT fk_primer_tecnico
    FOREIGN KEY (primer_tecnico)
    REFERENCES tecnicos(id_tecnico),
    segundo_tecnico INT,
    CONSTRAINT fk_segundo_tecnico
    FOREIGN KEY (segundo_tecnico)
    REFERENCES tecnicos(id_tecnico),
    preparador_fisico INT,
    CONSTRAINT fk_preparador_fisico
    FOREIGN KEY (preparador_fisico)
    REFERENCES tecnicos(id_tecnico),
    delegado INT,
    CONSTRAINT fk_delegado
    FOREIGN KEY (delegado)
    REFERENCES tecnicos(id_tecnico)
);

CREATE TABLE equipos(
id_equipo INT AUTO_INCREMENT PRIMARY KEY,
nombre_equipo VARCHAR(50) NOT NULL,
telefono_contacto VARCHAR(14) NULL,
id_cuerpo_tecnico INT NULL,
CONSTRAINT fk_cuerpo_tecnico_del_equipo 
FOREIGN KEY (id_cuerpo_tecnico)
REFERENCES cuerpos_tecnicos(id_cuerpo_tecnico),
id_administrador INT NULL,
CONSTRAINT fk_administrador_del_equipo 
FOREIGN KEY (id_administrador)
REFERENCES administradores(id_administrador),
id_categoria INT NOT NULL,
CONSTRAINT fk_categoria_del_equipo 
FOREIGN KEY (id_categoria)
REFERENCES categorias(id_categoria)
);

CREATE TABLE posiciones(
id_posicion INT AUTO_INCREMENT PRIMARY KEY,
posicion VARCHAR(60) NOT NULL,
CONSTRAINT uq_posicion_unico 
UNIQUE(posicion),
area_de_juego ENUM('Ofensiva','Defensiva', 'Ofensiva y defensiva') NOT NULL
);

CREATE TABLE jugadores(
id_jugador INT AUTO_INCREMENT PRIMARY KEY,
playera INT NULL,
nombre_jugador VARCHAR(50) NOT NULL,
apellido_jugador VARCHAR(50) NOT NULL,
estatus ENUM('Activo', 'Baja temporal', 'Baja definitiva') NOT NULL,
fecha_nacimiento DATE NULL,
edad INT NULL,
perfil ENUM('Zurdo', 'Diestro', 'Ambidiestro') NOT NULL,
id_posicion_principal INT NOT NULL,
CONSTRAINT fk_posicion_principal 
FOREIGN KEY (id_posicion_principal)
REFERENCES posiciones(id_posicion),
id_posicion_secundaria INT NULL,
CONSTRAINT fk_posicion_secundaria 
FOREIGN KEY (id_posicion_secundaria)
REFERENCES posiciones(id_posicion),
altura DECIMAL(4,2) NOT NULL,
peso DECIMAL(5,2) NOT NULL,
indice_masa_corporal DECIMAL(5,2) NULL,
foto_jugador VARCHAR(36) NULL,
CONSTRAINT chk_url_foto_jugador 
CHECK (foto_jugador LIKE '%.jpg' OR foto_jugador LIKE '%.png' OR foto_jugador LIKE '%.jpeg' OR foto_jugador LIKE '%.gif')
);

CREATE TABLE caracteristicas_fisicas(
id_caracteristica_fisica INT AUTO_INCREMENT PRIMARY KEY,
fuerza INT NULL DEFAULT 0,
CONSTRAINT chk_fuerza
CHECK(fuerza >= 0 AND fuerza <= 10),
resistencia INT NULL DEFAULT 0,
CONSTRAINT chk_resistencia
CHECK(resistencia >= 0 AND resistencia <= 10),
velocidad INT NULL DEFAULT 0,
CONSTRAINT chk_velocidad
CHECK(velocidad >= 0 AND velocidad <= 10),
agilidad INT NULL DEFAULT 0,
CONSTRAINT chk_agilidad
CHECK(agilidad >= 0 AND agilidad <= 10)
);

CREATE TABLE caracteristicas_tecnicas(
id_caracteristica_tecnica INT AUTO_INCREMENT PRIMARY KEY,
pase_corto INT NULL DEFAULT 0,
CONSTRAINT chk_pase_corto
CHECK(pase_corto >= 0 AND pase_corto <= 10),
pase_medio INT NULL DEFAULT 0,
CONSTRAINT chk_pase_medio
CHECK(pase_medio >= 0 AND pase_medio <= 10),
pase_largo INT NULL DEFAULT 0,
CONSTRAINT chk_pase_largo
CHECK(pase_largo >= 0 AND pase_largo <= 10),
conduccion INT NULL DEFAULT 0,
CONSTRAINT chk_conduccion
CHECK(conduccion >= 0 AND conduccion <= 10),
recepcion INT NULL DEFAULT 0,
CONSTRAINT chk_recepcion
CHECK(recepcion >= 0 AND recepcion <= 10),
cabeceo INT NULL DEFAULT 0,
CONSTRAINT chk_cabeceo
CHECK(cabeceo >= 0 AND cabeceo <= 10),
regate INT NULL DEFAULT 0,
CONSTRAINT chk_regate
CHECK(regate >= 0 AND regate <= 10),
definicion_a_gol INT NULL DEFAULT 0,
CONSTRAINT chk_definicion_a_gol
CHECK(definicion_a_gol >= 0 AND definicion_a_gol <= 10)
);

CREATE TABLE caracteristicas_tacticas(
id_caracteristica_tactica INT AUTO_INCREMENT PRIMARY KEY,
toma_de_decisiones INT NULL DEFAULT 0,
CONSTRAINT chk_toma_de_decisiones
CHECK(toma_de_decisiones >= 0 AND toma_de_decisiones <= 10),
conceptos_ofensivos INT NULL DEFAULT 0,
CONSTRAINT chk_conceptos_ofensivos
CHECK(conceptos_ofensivos >= 0 AND conceptos_ofensivos <= 10),
conceptos_defensivos INT NULL DEFAULT 0,
CONSTRAINT chk_conceptos_defensivos
CHECK(conceptos_defensivos >= 0 AND conceptos_defensivos <= 10),
interpretacion_del_juego INT NULL DEFAULT 0,
CONSTRAINT chk_interpretacion_del_juego
CHECK(interpretacion_del_juego >= 0 AND interpretacion_del_juego <= 10)
);

CREATE TABLE caracteristicas_psicologicas(
id_caracteristica_psicologica INT AUTO_INCREMENT PRIMARY KEY,
concentracion INT NULL DEFAULT 0,
CONSTRAINT chk_concentracion
CHECK(concentracion >= 0 AND concentracion <= 10),
autoconfianza INT NULL DEFAULT 0,
CONSTRAINT chk_autoconfianza
CHECK(autoconfianza >= 0 AND autoconfianza <= 10),
sacrificio INT NULL DEFAULT 0,
CONSTRAINT chk_sacrificio
CHECK(sacrificio >= 0 AND sacrificio <= 10),
autocontrol INT NULL DEFAULT 0,
CONSTRAINT chk_autocontrol
CHECK(autocontrol >= 0 AND autocontrol <= 10)
);

CREATE TABLE caracteristicas_generales(
id_caracteristica_general INT AUTO_INCREMENT PRIMARY KEY,
id_jugador INT NOT NULL,
CONSTRAINT fk_caracteristica_jugador 
FOREIGN KEY (id_jugador)
REFERENCES jugadores(id_jugador),
id_caracteristica_fisica INT NULL,
CONSTRAINT fk_caracteristicas_fisicas_jugador 
FOREIGN KEY (id_caracteristica_fisica)
REFERENCES caracteristicas_fisicas(id_caracteristica_fisica),
id_caracteristica_tecnica INT NULL,
CONSTRAINT fk_caracteristicas_tecnicas_jugador 
FOREIGN KEY (id_caracteristica_tecnica)
REFERENCES caracteristicas_tecnicas(id_caracteristica_tecnica),
id_caracteristica_tactica INT NULL,
CONSTRAINT fk_caracteristicas_tacticas_jugador 
FOREIGN KEY (id_caracteristica_tactica)
REFERENCES caracteristicas_tacticas(id_caracteristica_tactica),
id_caracteristica_psicologica INT NULL,
CONSTRAINT fk_caracteristicas_jugador 
FOREIGN KEY (id_caracteristica_psicologica)
REFERENCES caracteristicas_psicologicas(id_caracteristica_psicologica),
promedio DECIMAL(5,3) NULL
);

CREATE TABLE control_asistencias(
id_asistencia INT AUTO_INCREMENT PRIMARY KEY,
id_jugador INT NOT NULL,
CONSTRAINT fk_jugador_asistencia 
FOREIGN KEY (id_jugador) 
REFERENCES jugadores(id_jugador),
id_horario INT NOT NULL,
CONSTRAINT fk_horario_asistencia 
FOREIGN KEY (id_horario) 
REFERENCES horarios(id_horario),
mes ENUM('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre') NOT NULL,
fecha DATE NULL DEFAULT NOW(),
asistencia ENUM('Asistencia', 'Permiso', 'Falta', 'Lesion') NOT NULL
);

CREATE TABLE tipos_contenidos(
id_tipo_contenido INT AUTO_INCREMENT PRIMARY KEY,
tipo_contenido VARCHAR(60) NOT NULL,
CONSTRAINT uq_tipo_contenido_unico
UNIQUE(tipo_contenido)
);

CREATE TABLE tipos_tareas(
id_tipo_tarea INT AUTO_INCREMENT PRIMARY KEY,
tipo_tarea VARCHAR(50) NOT NULL,
CONSTRAINT uq_tipo_tarea_unico
UNIQUE(tipo_tarea)
);

CREATE TABLE tareas(
id_tarea INT AUTO_INCREMENT PRIMARY KEY,
id_tipo_tarea INT NOT NULL,
CONSTRAINT fk_tipo_de_tarea 
FOREIGN KEY (id_tipo_tarea) 
REFERENCES tipos_tareas(id_tipo_tarea),
minutos INT NOT NULL
);

CREATE TABLE contenidos(
id_contenido INT AUTO_INCREMENT PRIMARY KEY,
tema_contenido VARCHAR(60) NOT NULL,
subtema_contenido VARCHAR(60) NULL,
id_tipo_contenido INT NOT NULL,
CONSTRAINT fk_tipo_contenido 
FOREIGN KEY (id_tipo_contenido) 
REFERENCES tipos_contenidos(id_tipo_contenido),
cantidad INT NULL
);

CREATE TABLE detalle_contenido(
id_detalle_contenido INT AUTO_INCREMENT PRIMARY KEY,
id_tarea INT NULL,
CONSTRAINT fk_tarea 
FOREIGN KEY (id_tarea) 
REFERENCES tareas(id_tarea),
id_contenido INT NOT NULL,
CONSTRAINT fk_contenido 
FOREIGN KEY (id_contenido) 
REFERENCES contenidos(id_contenido),
id_asistencia INT NOT NULL,
CONSTRAINT fk_asistencia_contenidos 
FOREIGN KEY (id_asistencia)
REFERENCES control_asistencias(id_asistencia)
);

CREATE TABLE jornadas(
id_jornada INT AUTO_INCREMENT PRIMARY KEY,
numero_jornada INT NOT NULL,
id_temporada INT NOT NULL,
CONSTRAINT fk_temporada_jornada 
FOREIGN KEY (id_temporada) 
REFERENCES temporadas(id_temporada),
fecha_inicio DATE NOT NULL,
fecha_fin DATE NOT NULL, 
CONSTRAINT chk_validacion_de_fechas_de_jornada
CHECK(fecha_inicio < fecha_fin),
id_caracteristica_general INT NOT NULL,
CONSTRAINT fk_caracteristicas_generales_jornada 
FOREIGN KEY (id_caracteristica_general)
REFERENCES caracteristicas_generales(id_caracteristica_general),
id_detalle_contenido INT NOT NULL,
CONSTRAINT fk_detalle_contenido_jornada 
FOREIGN KEY (id_detalle_contenido)
REFERENCES detalle_contenido(id_detalle_contenido)
);

CREATE TABLE partidos(
id_partido INT AUTO_INCREMENT PRIMARY KEY,
id_jornada INT NOT NULL,
CONSTRAINT fk_jornada_partido 
FOREIGN KEY (id_jornada) 
REFERENCES jornadas(id_jornada),
id_equipo INT NOT NULL,
CONSTRAINT fk_equipo 
FOREIGN KEY (id_equipo) 
REFERENCES equipos(id_equipo),
rival VARCHAR(50) NOT NULL,
fecha DATE NOT NULL,
hora TIME NOT NULL,
cancha VARCHAR(100) NOT NULL,
resultado VARCHAR(10) NULL,
localidad ENUM('Local', 'Visitante') NOT NULL,
tipo_resultado ENUM('Victoria', 'Empate', 'Derrota') NULL
);

CREATE TABLE tipos_lesiones(
id_tipo_lesion INT AUTO_INCREMENT PRIMARY KEY,
tipo_lesion VARCHAR(50) NOT NULL,
CONSTRAINT uq_tipo_lesion_unico
UNIQUE(tipo_lesion)
);

CREATE TABLE subtipologias(
id_subtipologia INT AUTO_INCREMENT PRIMARY KEY,
subtipologia VARCHAR(60) NOT NULL,
CONSTRAINT uq_sub_tipologia_unico
UNIQUE(subtipologia)
);

CREATE TABLE tipologias(
id_tipologia INT AUTO_INCREMENT PRIMARY KEY,
tipologia VARCHAR(60), 
CONSTRAINT uq_tipologia_unico
UNIQUE(tipologia),
id_subtipologia INT NOT NULL,
CONSTRAINT fk_subtipologias_de_la_tipologia
FOREIGN KEY (id_subtipologia)
REFERENCES subtipologias(id_subtipologia)
);

CREATE TABLE lesiones(
id_lesion INT AUTO_INCREMENT PRIMARY KEY,
id_tipo_lesion INT NOT NULL,
CONSTRAINT fk_registro_medico_del_tipo_de_lesion 
FOREIGN KEY (id_tipo_lesion)
REFERENCES tipos_lesiones(id_tipo_lesion),
id_tipologia INT NOT NULL,
CONSTRAINT fk_tipologia_lesiones
FOREIGN KEY (id_tipologia)
REFERENCES tipologias(id_tipologia),
nombre_lesion VARCHAR(50) NOT NULL,
numero_lesiones INT NOT NULL,
promedio_lesiones INT NULL DEFAULT 0
);

CREATE TABLE registro_medico(
id_registro_medico INT AUTO_INCREMENT PRIMARY KEY,
id_jugador INT NOT NULL,
CONSTRAINT fk_registro_medico_jugador 
FOREIGN KEY (id_jugador) 
REFERENCES jugadores(id_jugador),
fecha_lesion DATE NULL,
fecha_registro DATE DEFAULT NOW(),
dias_lesionado INT NULL,
retorno_entreno DATE NOT NULL,
retorno_partido INT NOT NULL, 
CONSTRAINT fk_retorno_partido 
FOREIGN KEY (retorno_partido) 
REFERENCES partidos(id_partido)
);

CREATE TABLE tipos_juegos(
id_tipo_juego INT AUTO_INCREMENT PRIMARY KEY,
nombre_tipo_juego VARCHAR(50) NOT NULL,
CONSTRAINT uq_nombre_tipo_juego_unico
UNIQUE(nombre_tipo_juego)
);

CREATE TABLE tipos_goles(
id_tipo_gol INT AUTO_INCREMENT PRIMARY KEY,
id_tipo_juego INT NOT NULL,
CONSTRAINT fk_tipo_de_juego 
FOREIGN KEY (id_tipo_juego) 
REFERENCES tipos_juegos(id_tipo_juego),
nombre_tipo_gol VARCHAR(60) NOT NULL,
cantidad INT NULL
);

CREATE TABLE participaciones_partidos(
id_participacion INT AUTO_INCREMENT PRIMARY KEY,
id_partido INT NOT NULL,
CONSTRAINT fk_partido_participacion 
FOREIGN KEY (id_partido) 
REFERENCES partidos(id_partido),
id_jugador INT NOT NULL,
CONSTRAINT fk_jugador_participacion 
FOREIGN KEY (id_jugador) 
REFERENCES jugadores(id_jugador),
titular BOOLEAN NOT NULL,
sustitucion BOOLEAN NOT NULL,
minutos_jugados INT NOT NULL,
goles INT NULL DEFAULT 0,
id_tipo_gol INT NULL,
CONSTRAINT fk_tipo_gol_partido 
FOREIGN KEY (id_tipo_gol) 
REFERENCES tipos_goles(id_tipo_gol),
asistencias INT NULL DEFAULT 0,
amonestacion ENUM('Tarjeta amarilla', 'Tarjeta roja', 'Ninguna') NULL DEFAULT 'Ninguna',
numero_amonestacion INT NULL DEFAULT 0,
puntuacion INT NULL
);

CREATE TABLE pagos(
id_pago INT AUTO_INCREMENT PRIMARY KEY,
fecha DATE NOT NULL,
cantidad DECIMAL(5,2) NOT NULL,
pago_tardio BOOLEAN NULL DEFAULT 0,
mora DECIMAL(5,2) NULL,
mes ENUM('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre') NOT NULL,
id_jugador INT NOT NULL,
CONSTRAINT fk_jugador_pago 
FOREIGN KEY (id_jugador) 
REFERENCES jugadores(id_jugador)
);

USE prototipo_base_gol_el_salvador;

DELIMITER //
CREATE TRIGGER calcular_edad BEFORE INSERT ON jugadores
FOR EACH ROW
BEGIN
SET NEW.edad = YEAR(CURRENT_DATE) - YEAR(NEW.fecha_nacimiento) -
(DATE_FORMAT(CURRENT_DATE, '%m%d') < DATE_FORMAT(NEW.fecha_nacimiento, '%m%d'));
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER calcular_promedio_caracteristicas BEFORE INSERT ON caracteristicas_generales
FOR EACH ROW
BEGIN
DECLARE promedio_fisica DECIMAL(5,3);
DECLARE promedio_tecnica DECIMAL(5,3);
DECLARE promedio_tactica DECIMAL(5,3);
DECLARE promedio_psicologica DECIMAL(5,3);

-- Calcula el promedio de las características físicas
SELECT AVG(fuerza + resistencia + velocidad + agilidad) INTO promedio_fisica
FROM caracteristicas_fisicas
WHERE id_caracteristica_fisica = NEW.id_caracteristica_fisica;

-- Calcula el promedio de las características técnicas
SELECT AVG(pase_corto + pase_medio + pase_largo + conduccion + recepcion + cabeceo + regate + definicion_a_gol) INTO promedio_tecnica
FROM caracteristicas_tecnicas
WHERE id_caracteristica_tecnica = NEW.id_caracteristica_tecnica;

-- Calcula el promedio de las características tácticas
SELECT AVG(toma_de_decisiones + conceptos_ofensivos + conceptos_defensivos + interpretacion_del_juego) INTO promedio_tactica
FROM caracteristicas_tacticas
WHERE id_caracteristica_tactica = NEW.id_caracteristica_tactica;

-- Calcula el promedio de las características psicológicas
SELECT AVG(concentracion + autoconfianza + sacrificio + autocontrol) INTO promedio_psicologica
FROM caracteristicas_psicologicas
WHERE id_caracteristica_psicologica = NEW.id_caracteristica_psicologica;

-- Calcula el promedio general
SET NEW.promedio = (promedio_fisica + promedio_tecnica + promedio_tactica + promedio_psicologica) / 4;
END;
//
DELIMITER ;

DELIMITER //

CREATE TRIGGER calcular_dias_lesionado
BEFORE INSERT ON registro_medico
FOR EACH ROW
BEGIN
    DECLARE dias_estimados INT;

    -- Calcula los días estimados lesionados
    SET dias_estimados = DATEDIFF(NEW.retorno_entreno, NEW.fecha_lesion);

    -- Asigna el valor calculado a la columna dias_lesionado
    SET NEW.dias_lesionado = dias_estimados;
END;
//
DELIMITER ;


INSERT INTO temporadas(anio) VALUES(2024);
-- Inserción de posiciones de ataque
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Delantero centro', 'Ofensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Segundo delantero', 'Ofensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Mediapunta', 'Ofensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Falso nueve', 'Ofensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Extremo izquierdo', 'Ofensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Extremo derecho', 'Ofensiva');
-- Inserción de posiciones de mediocampista
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Mediocentro', 'Ofensiva y defensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Mediocentro ofensivo', 'Ofensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Mediocentro defensivo', 'Defensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Pivote', 'Defensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Interior izquierdo', 'Ofensiva y defensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Interior derecho', 'Ofensiva y defensiva');
-- Inserción de posiciones de defensa
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Defensa central', 'Defensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Defensa izquierdo', 'Defensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Defensa derecho', 'Defensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Lateral izquierdo', 'Defensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Lateral derecho', 'Defensiva');
INSERT INTO posiciones (posicion, area_de_juego) VALUES ('Portero', 'Defensiva');
