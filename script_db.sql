DROP DATABASE if EXISTS db_gol_sv;
CREATE DATABASE db_gol_sv;
USE db_gol_sv;

CREATE TABLE administradores(
id_administrador INT AUTO_INCREMENT PRIMARY KEY,
nombre_administrador VARCHAR(50) NOT NULL,
apellido_administrador VARCHAR(50) NOT NULL,
clave_administrador VARCHAR(100) NOT NULL,
correo_administrador VARCHAR(50) NOT NULL,
CONSTRAINT uq_correo_administrador_unico UNIQUE(correo_administrador),
CONSTRAINT chk_correo_administrador_formato CHECK (correo_administrador REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$'),
telefono_administrador VARCHAR(15) NOT NULL,
dui_administrador VARCHAR(10) NOT NULL,
CONSTRAINT uq_dui_administrador_unico UNIQUE(dui_administrador),
fecha_nacimiento_administrador DATE NOT NULL,
alias_administrador VARCHAR(25) NOT NULL,
CONSTRAINT uq_alias_administrador_unico UNIQUE(alias_administrador),
fecha_creacion DATETIME DEFAULT NOW(),
intentos_administrador INT DEFAULT 0,
estado_administrador BOOLEAN DEFAULT 1,
tiempo_intento DATETIME NULL,
fecha_clave DATETIME NULL DEFAULT NOW(),
fecha_bloqueo DATETIME NULL,
foto_administrador VARCHAR(50) NULL,
CONSTRAINT chk_url_foto_administrador CHECK (foto_administrador LIKE '%.jpg' OR foto_administrador LIKE '%.png' OR foto_administrador LIKE '%.jpeg' OR foto_administrador LIKE '%.gif')
);
SELECT * FROM administradores;

ALTER TABLE administradores
ADD COLUMN recovery_code VARCHAR(80) DEFAULT '0000';

CREATE TABLE tecnicos(
  id_tecnico INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_tecnico VARCHAR(50) NOT NULL, 
  apellido_tecnico VARCHAR(50) NOT NULL, 
  alias_tecnico VARCHAR(25) NOT NULL, 
  CONSTRAINT uq_alias_tecnico_unico UNIQUE(alias_tecnico), 
  clave_tecnico VARCHAR(100) NOT NULL, 
  correo_tecnico VARCHAR(50) NOT NULL, 
  CONSTRAINT uq_correo_tecnico_unico UNIQUE(correo_tecnico), 
  CONSTRAINT chk_correo_tecnico_formato CHECK (correo_tecnico REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$'), 
  telefono_tecnico VARCHAR(15) NOT NULL, 
  dui_tecnico VARCHAR(10) NOT NULL, 
  CONSTRAINT uq_dui_tecnico_unico UNIQUE(dui_tecnico),
  estado_tecnico BOOLEAN NOT NULL DEFAULT 1,
  fecha_nacimiento_tecnico DATE NOT NULL,
  fecha_creacion DATETIME NULL DEFAULT NOW(),
  fecha_clave DATETIME NULL DEFAULT NOW(),
  foto_tecnico VARCHAR(50) NULL, 
  CONSTRAINT chk_url_foto_administrador CHECK (foto_tecnico LIKE '%.jpg' OR foto_tecnico LIKE '%.png' OR foto_tecnico LIKE '%.jpeg' OR foto_tecnico LIKE '%.gif')
);

ALTER TABLE tecnicos
ADD COLUMN recovery_code VARCHAR(80) DEFAULT '0000';


CREATE TABLE documentos_tecnicos(
  id_documento INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_archivo VARCHAR(50) NOT NULL, 
  id_tecnico INT NOT NULL, 
  CONSTRAINT fk_documento_del_tecnico FOREIGN KEY (id_tecnico) REFERENCES tecnicos(id_tecnico),
  archivo_adjunto VARCHAR(50) NULL,
  fecha_registro DATE NULL DEFAULT NOW()
  );

SET @sql := IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_NAME = 'documentos_tecnicos' 
     AND COLUMN_NAME = 'fecha_registro' 
     AND TABLE_SCHEMA = DATABASE()) = 0,
    'ALTER TABLE documentos_tecnicos ADD COLUMN fecha_registro DATE NULL DEFAULT NOW();',
    'SELECT ''La columna ya existe.'';'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE TABLE temporadas(
  id_temporada INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_temporada VARCHAR(50) NOT NULL,
  CONSTRAINT uq_nombre_temporada_unico UNIQUE(nombre_temporada)
);

CREATE TABLE horarios(
  id_horario INT AUTO_INCREMENT PRIMARY KEY,
  nombre_horario VARCHAR(60) NOT NULL,
  CONSTRAINT uq_nombre_horario_unico UNIQUE(nombre_horario),
  dia ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo') NOT NULL, 
  hora_inicial TIME NOT NULL, 
  hora_final TIME NOT NULL, 
  CONSTRAINT chk_validacion_de_horas CHECK(hora_inicial < hora_final), 
  campo_de_entrenamiento VARCHAR(100) NOT NULL
);

CREATE TABLE categorias(
  id_categoria INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_categoria VARCHAR(80) NOT NULL, 
  CONSTRAINT uq_nombre_categoria_unico UNIQUE(nombre_categoria), 
  edad_minima_permitida INT NOT NULL, 
  edad_maxima_permitida INT NOT NULL, 
  CONSTRAINT chk_validacion_de_edades CHECK(edad_minima_permitida <= edad_maxima_permitida)
);

SET @fk_name := (SELECT CONSTRAINT_NAME 
                 FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
                 WHERE TABLE_NAME = 'categorias' 
                 AND COLUMN_NAME = 'id_temporada' 
                 LIMIT 1);

SET @drop_fk := IF(@fk_name IS NOT NULL, 
                   CONCAT('ALTER TABLE categorias DROP FOREIGN KEY ', @fk_name, ';'), 
                   'SELECT ''La clave foranea no existe xd'';');
                   
PREPARE stmt1 FROM @drop_fk;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

SET @drop_column := IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_NAME = 'categorias' 
     AND COLUMN_NAME = 'id_temporada' 
     AND TABLE_SCHEMA = DATABASE()) = 1,
    'ALTER TABLE categorias DROP COLUMN id_temporada;',
    'SELECT ''La columna de por si no existe jsjsjskjs'';'
);

PREPARE stmt2 FROM @drop_column;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

SELECT * FROM categorias;

CREATE TABLE horarios_categorias(
  id_horario_categoria INT AUTO_INCREMENT PRIMARY KEY,
  id_categoria INT NOT NULL, 
  CONSTRAINT fk_categoria_del_horario FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
  id_horario INT NOT NULL, 
  CONSTRAINT fk_horarios_de_la_categoria FOREIGN KEY (id_horario) REFERENCES horarios(id_horario)
);

CREATE TABLE rol_tecnico(
  id_rol_tecnico INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_rol_tecnico VARCHAR(60),
  CONSTRAINT uq_nombre_rol_tecnico_unico UNIQUE(nombre_rol_tecnico)
);

CREATE TABLE cuerpos_tecnicos(
  id_cuerpo_tecnico INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_cuerpo_tecnico VARCHAR(60),
  CONSTRAINT uq_nombre_cuerpo_tecnico_unico UNIQUE(nombre_cuerpo_tecnico)
);

CREATE TABLE detalles_cuerpos_tecnicos(
  id_detalle_cuerpo_tecnico INT AUTO_INCREMENT PRIMARY KEY, 
  id_cuerpo_tecnico INT NOT NULL, 
  CONSTRAINT fk_cuerpo_tecnico_del_equipo FOREIGN KEY (id_cuerpo_tecnico) REFERENCES cuerpos_tecnicos(id_cuerpo_tecnico), 
  id_tecnico INT NOT NULL,
  CONSTRAINT fk_tecnico_del_equipo FOREIGN KEY (id_tecnico) REFERENCES tecnicos(id_tecnico), 
  id_rol_tecnico INT NOT NULL, 
  CONSTRAINT fk_rol_tecnico_del_equipo FOREIGN KEY (id_rol_tecnico) REFERENCES rol_tecnico(id_rol_tecnico)
);

CREATE TABLE equipos(
  id_equipo INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_equipo VARCHAR(50) NOT NULL, 
  CONSTRAINT uq_nombre_equipo_unico UNIQUE(nombre_equipo), 
  genero_equipo ENUM('Masculino ', 'Femenino') NOT NULL,
  telefono_contacto VARCHAR(14) NULL, 
  id_cuerpo_tecnico INT NULL, 
  CONSTRAINT fk_id_cuerpo_tecnico_del_equipo FOREIGN KEY (id_cuerpo_tecnico) REFERENCES cuerpos_tecnicos(id_cuerpo_tecnico), 
  id_categoria INT NOT NULL, 
  CONSTRAINT fk_categoria_del_equipo FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
  logo_equipo VARCHAR(50) NULL, 
  CONSTRAINT chk_url_logo_equipo CHECK (logo_equipo LIKE '%.jpg' OR logo_equipo LIKE '%.png' OR logo_equipo LIKE '%.jpeg' OR logo_equipo LIKE '%.gif')
);

CREATE TABLE posiciones(
  id_posicion INT AUTO_INCREMENT PRIMARY KEY, 
  posicion VARCHAR(60) NOT NULL, 
  CONSTRAINT uq_posicion_unico UNIQUE(posicion), 
  area_de_juego ENUM('Ofensiva', 'Defensiva', 'Ofensiva y defensiva') NOT NULL
);

CREATE TABLE jugadores(
  id_jugador INT AUTO_INCREMENT PRIMARY KEY, 
  dorsal_jugador INT UNSIGNED NULL,
  nombre_jugador VARCHAR(50) NOT NULL, 
  apellido_jugador VARCHAR(50) NOT NULL, 
  estatus_jugador ENUM('Activo', 'Baja temporal', 'Baja definitiva') DEFAULT 'Activo',
  fecha_nacimiento_jugador DATE NULL,
  genero_jugador ENUM('Masculino ', 'Femenino') NOT NULL,
  perfil_jugador ENUM('Zurdo', 'Diestro', 'Ambidiestro') NOT NULL,
  becado ENUM('Beca completa', 'Media beca', 'Ninguna'),
  id_posicion_principal INT NOT NULL, 
  CONSTRAINT fk_posicion_principal FOREIGN KEY (id_posicion_principal) REFERENCES posiciones(id_posicion), 
  id_posicion_secundaria INT NULL, 
  CONSTRAINT fk_posicion_secundaria FOREIGN KEY (id_posicion_secundaria) REFERENCES posiciones(id_posicion), 
  alias_jugador VARCHAR(25) NOT NULL,
  CONSTRAINT uq_alias_jugador_unico UNIQUE(alias_jugador), 
  clave_jugador VARCHAR(100) NOT NULL, 
  foto_jugador VARCHAR(36) NULL,
  fecha_creacion DATETIME NULL DEFAULT NOW(),
  CONSTRAINT chk_url_foto_jugador CHECK (foto_jugador LIKE '%.jpg' OR foto_jugador LIKE '%.png' OR foto_jugador LIKE '%.jpeg' OR foto_jugador LIKE '%.gif'),
  telefono VARCHAR(15) NOT NULL DEFAULT '0000-0000',
  telefono_de_emergencia VARCHAR(15) NOT NULL DEFAULT '0000-0000',
  observacion_medica VARCHAR(2000) NULL,
  tipo_sangre ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NULL DEFAULT 'O+'
);

ALTER TABLE jugadores
MODIFY COLUMN fecha_creacion DATE NULL DEFAULT NOW();

ALTER TABLE jugadores
MODIFY COLUMN foto_jugador VARCHAR(50) DEFAULT 'default.png';

-- Agregar la columna recovery_code con valor por defecto '0000'
ALTER TABLE jugadores
ADD COLUMN recovery_code VARCHAR(80) DEFAULT '0000';

-- Agregar la columna correo_jugador con valor por defecto 'example@gmail.com'
ALTER TABLE jugadores
ADD COLUMN correo_jugador VARCHAR(50) DEFAULT 'example@gmail.com';

-- Agregar la restricción de formato para correo_jugador
ALTER TABLE jugadores
ADD CONSTRAINT chk_correo_jugador_formato CHECK (correo_jugador REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$');

SET @sql := IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_NAME = 'jugadores' 
     AND COLUMN_NAME = 'telefono' 
     AND TABLE_SCHEMA = DATABASE()) = 0,
    'ALTER TABLE jugadores ADD COLUMN telefono VARCHAR(15) NOT NULL DEFAULT ''0000-0000'';',
    'SELECT ''La columna ya existe.'';'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_NAME = 'jugadores' 
     AND COLUMN_NAME = 'telefono_de_emergencia' 
     AND TABLE_SCHEMA = DATABASE()) = 0,
    'ALTER TABLE jugadores ADD COLUMN telefono_de_emergencia VARCHAR(15) NOT NULL DEFAULT ''0000-0000'';',
    'SELECT ''La columna ya existe.'';'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_NAME = 'jugadores' 
     AND COLUMN_NAME = 'observacion_medica' 
     AND TABLE_SCHEMA = DATABASE()) = 0,
    'ALTER TABLE jugadores ADD COLUMN observacion_medica VARCHAR(2000) NULL;',
    'SELECT ''La columna ya existe.'';'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_NAME = 'jugadores' 
     AND COLUMN_NAME = 'tipo_sangre' 
     AND TABLE_SCHEMA = DATABASE()) = 0,
    'ALTER TABLE jugadores ADD COLUMN tipo_sangre ENUM(''A+'', ''A-'', ''B+'', ''B-'', ''AB+'', ''AB-'', ''O+'', ''O-'') DEFAULT ''O+'';',
    'SELECT ''La columna ya existe.'';'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT * FROM jugadores;

CREATE TABLE estados_fisicos_jugadores(
  id_estado_fisico_jugador INT AUTO_INCREMENT PRIMARY KEY,
  id_jugador INT NOT NULL, 
  CONSTRAINT fk_estado_fisico_jugador FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador),
  altura_jugador DECIMAL(5, 2) UNSIGNED NOT NULL,
  peso_jugador DECIMAL(5, 2) UNSIGNED NOT NULL,
  indice_masa_corporal DECIMAL(5, 2) UNSIGNED NULL,
  fecha_creacion DATETIME NULL DEFAULT NOW()
);

# Ejecutar en caso de que se haya creado la base antes del día domingo 25 de agosto del 2024 
#ALTER TABLE estados_fisicos_jugadores MODIFY COLUMN altura_jugador INT UNSIGNED NOT NULL;
#ALTER TABLE estados_fisicos_jugadores MODIFY COLUMN peso_jugador INT UNSIGNED NOT NULL;

CREATE TABLE plantillas(
  id_plantilla INT AUTO_INCREMENT PRIMARY KEY,
  nombre_plantilla VARCHAR(150) NOT NULL,
  CONSTRAINT uq_nombre_plantilla_unico UNIQUE(nombre_plantilla)
);

CREATE TABLE plantillas_equipos(
  id_plantilla_equipo INT AUTO_INCREMENT PRIMARY KEY,
  id_plantilla INT NOT NULL, 
  CONSTRAINT fk_plantilla FOREIGN KEY (id_plantilla) REFERENCES plantillas(id_plantilla),
  id_jugador INT NOT NULL, 
  CONSTRAINT fk_jugador_plantilla FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador),
  id_temporada INT NOT NULL, 
  CONSTRAINT fk_temporada_plantilla FOREIGN KEY (id_temporada) REFERENCES temporadas(id_temporada), 
  id_equipo INT NOT NULL, 
  CONSTRAINT fk_equipo_plantilla FOREIGN KEY (id_equipo) REFERENCES equipos(id_equipo)
);


CREATE TABLE jornadas(
  id_jornada INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_jornada VARCHAR(60) NULL,
  numero_jornada INT UNSIGNED NOT NULL, 
  id_plantilla INT NOT NULL, 
  CONSTRAINT fk_plantilla_jornada FOREIGN KEY (id_plantilla) REFERENCES plantillas(id_plantilla), 
  fecha_inicio_jornada DATE NOT NULL,
  fecha_fin_jornada DATE NOT NULL,
  CONSTRAINT chk_validacion_de_fechas_de_jornada CHECK(fecha_inicio_jornada < fecha_fin_jornada)
);

CREATE TABLE entrenamientos(
  id_entrenamiento BIGINT AUTO_INCREMENT PRIMARY KEY, 
  fecha_entrenamiento DATE,
  sesion ENUM('Sesion 1', 'Sesion 2', 'Sesion 3'),
  id_jornada INT NOT NULL, 
  CONSTRAINT fk_identificador_de_jornada_entrenamiento FOREIGN KEY (id_jornada) REFERENCES jornadas(id_jornada),
  id_equipo INT NOT NULL,
  CONSTRAINT fk_identificador_de_equipo_entrenamiento FOREIGN KEY (id_equipo) REFERENCES equipos(id_equipo),
  id_horario_categoria INT NOT NULL,
  CONSTRAINT fk_identificador_de_horario_categoria_entrenamiento FOREIGN KEY (id_horario_categoria) REFERENCES horarios_categorias(id_horario_categoria)
);
-- Si el alter les da error ejecutar lo de abajo, el error da porque cuando agregamos el campo, este permanece en 0
-- y como debemos relacionarlo con la tabla, la tabla no tiene registros con id 0, entonces debemos acutalizar entrenamientos
-- A un campo que si llo contenga la tabla horarios_categorias.
-- UPDATE entrenamientos SET id_horario_categoria = 1 WHERE id_horario_categoria = 0;

CREATE TABLE caracteristicas_jugadores(
  id_caracteristica_jugador INT AUTO_INCREMENT PRIMARY KEY,
  nombre_caracteristica_jugador VARCHAR(50) NOT NULL,
  CONSTRAINT uq_nombre_sub_caracteristica_unico UNIQUE(nombre_caracteristica_jugador),
  clasificacion_caracteristica_jugador ENUM('Técnicos', 'Tácticos', 'Psicológicos', 'Físicos') NOT NULL
);

CREATE TABLE caracteristicas_analisis(
  id_caracteristica_analisis BIGINT AUTO_INCREMENT PRIMARY KEY,
  nota_caracteristica_analisis DECIMAL(5,3) UNSIGNED NOT NULL,
  id_jugador INT NOT NULL, 
  CONSTRAINT fk_jugador_caracteristica_general FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador), 
  id_caracteristica_jugador INT NOT NULL,
  CONSTRAINT fk_sub_caracteristica_jugador_caracteristica_general FOREIGN KEY (id_caracteristica_jugador) REFERENCES caracteristicas_jugadores(id_caracteristica_jugador),
  id_entrenamiento BIGINT NOT NULL, 
  CONSTRAINT fk_entrenamiento_del_analisis_de_la_caracteristica FOREIGN KEY (id_entrenamiento) REFERENCES entrenamientos(id_entrenamiento)
);

CREATE TABLE asistencias(
  id_asistencia BIGINT AUTO_INCREMENT PRIMARY KEY, 
  id_jugador INT NOT NULL, 
  CONSTRAINT fk_jugador_asistencia FOREIGN KEY (id_jugador) REFERENCES plantillas_equipos(id_plantilla_equipo), 
  id_horario INT NOT NULL, 
  CONSTRAINT fk_horario_asistencia FOREIGN KEY (id_horario) REFERENCES horarios(id_horario), 
  fecha_asistencia DATE NULL DEFAULT NOW(),
  asistencia ENUM('Asistencia', 'Ausencia injustificada', 'Enfermedad', 'Estudio', 'Trabajo', 'Viaje', 'Permiso', 'Falta', 'Lesion', 'Otro') NOT NULL, 
  observacion_asistencia VARCHAR(2000) NULL,
  id_entrenamiento BIGINT NOT NULL, 
  CONSTRAINT fk_asistencias_del_entrenamiento FOREIGN KEY (id_entrenamiento) REFERENCES entrenamientos(id_entrenamiento)
);

ALTER TABLE asistencias DROP CONSTRAINT fk_jugador_asistencia;
ALTER TABLE asistencias ADD CONSTRAINT fk_jugador_asistencia FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador);

CREATE TABLE temas_contenidos(
  id_tema_contenido INT AUTO_INCREMENT PRIMARY KEY,
  momento_juego ENUM('Ofensivo', 'Defensivo', 'Transición defensiva', 'Transición ofensiva', 'Balón parado ofensivo', 'Balón parado defensivo') NOT NULL,
  zona_campo ENUM('Zona 1', 'Zona 2', 'Zona 3') NOT NULL
);
### Ejecutar si no se tienen los campos momento juego, zona_campo; Y también si se tiene "nombre_tema_contenido"
## ALTER TABLE temas_contenidos ADD COLUMN momento_juego ENUM('Ofensivo', 'Defensivo', 'Transición defensiva', 'Transición ofensiva', 'Balón parado ofensivo', 'Balón parado defensivo');
##UPDATE temas_contenidos SET momento_juego = 'Ofensivo';
##ALTER TABLE temas_contenidos MODIFY momento_juego ENUM('Ofensivo', 'Defensivo', 'Transición defensiva', 'Transición ofensiva', 'Balón parado ofensivo', 'Balón parado defensivo') NOT NULL;
##ALTER TABLE temas_contenidos ADD COLUMN zona_campo ENUM('Zona 1', 'Zona 2', 'Zona 3');
##UPDATE temas_contenidos SET zona_campo = 'Zona 1';
##ALTER TABLE temas_contenidos MODIFY zona_campo ENUM('Zona 1', 'Zona 2', 'Zona 3') NOT NULL;
##ALTER TABLE temas_contenidos DROP COLUMN nombre_tema_contenido;

SET @add_momento_juego := IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_NAME = 'temas_contenidos' 
     AND COLUMN_NAME = 'momento_juego' 
     AND TABLE_SCHEMA = DATABASE()) = 0,
    'ALTER TABLE temas_contenidos ADD COLUMN momento_juego ENUM(''Ofensivo'', ''Defensivo'', ''Transición defensiva'', ''Transición ofensiva'', ''Balón parado ofensivo'', ''Balón parado defensivo'') NOT NULL;',
    'SELECT ''La columan momento_juego ya existe.'';'
);

PREPARE stmt1 FROM @add_momento_juego;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

SET @add_zona_campo := IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_NAME = 'temas_contenidos' 
     AND COLUMN_NAME = 'zona_campo' 
     AND TABLE_SCHEMA = DATABASE()) = 0,
    'ALTER TABLE temas_contenidos ADD COLUMN zona_campo ENUM(''Zona 1'', ''Zona 2'', ''Zona 3'') NOT NULL;',
    'SELECT ''La columna zona_campo ya existe.'';'
);

PREPARE stmt2 FROM @add_zona_campo;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;


CREATE TABLE sub_temas_contenidos(
  id_sub_tema_contenido INT AUTO_INCREMENT PRIMARY KEY,
  sub_tema_contenido VARCHAR(60) NOT NULL,
  id_tema_contenido INT NOT NULL,
  CONSTRAINT fk_tipo_contenido FOREIGN KEY (id_tema_contenido) REFERENCES temas_contenidos(id_tema_contenido)
);
SELECT * FROM sub_temas_contenidos;
CREATE TABLE tareas(
  id_tarea INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_tarea VARCHAR(60) NOT NULL
);

ALTER TABLE tareas MODIFY COLUMN nombre_tarea VARCHAR(60) NOT NULL UNIQUE;

CREATE TABLE detalles_contenidos(
  id_detalle_contenido INT AUTO_INCREMENT PRIMARY KEY, 
  id_tarea INT NULL, 
  CONSTRAINT fk_tarea FOREIGN KEY (id_tarea) REFERENCES tareas(id_tarea), 
  id_sub_tema_contenido INT NOT NULL,
  CONSTRAINT fk_contenido FOREIGN KEY (id_sub_tema_contenido) REFERENCES sub_temas_contenidos(id_sub_tema_contenido),
  minutos_contenido INT UNSIGNED NULL, 
  minutos_tarea INT UNSIGNED NULL
);


CREATE TABLE detalle_entrenamiento(
  id_detalle BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_entrenamiento BIGINT NOT NULL,
  CONSTRAINT fk_entrenamientos_detalle_entrenamiento FOREIGN KEY (id_entrenamiento) REFERENCES entrenamientos(id_entrenamiento),
  id_detalle_contenido INT, 
  CONSTRAINT fk_detalle_contenido_detalle_entrenamiento FOREIGN KEY (id_detalle_contenido) REFERENCES detalles_contenidos(id_detalle_contenido),
  id_jugador INT NOT NULL,
  CONSTRAINT fk_jugadores_detalle_entrenamiento FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador)
);

CREATE TABLE rivales (
    id_rival INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rival VARCHAR(50) NOT NULL,
    logo_rival VARCHAR(50) NULL,
    CONSTRAINT chk_logo_rival CHECK (logo_rival LIKE '%.jpg' OR logo_rival LIKE '%.png' OR logo_rival LIKE '%.jpeg')
);

ALTER TABLE rivales MODIFY COLUMN nombre_rival VARCHAR(60) NOT NULL UNIQUE;

CREATE TABLE partidos(
  id_partido INT AUTO_INCREMENT PRIMARY KEY, 
  id_jornada INT NOT NULL, 
  CONSTRAINT fk_jornada_partido FOREIGN KEY (id_jornada) REFERENCES jornadas(id_jornada), 
  id_equipo INT NOT NULL, 
  CONSTRAINT fk_equipo_partido FOREIGN KEY (id_equipo) REFERENCES equipos(id_equipo),
  fecha_partido DATETIME NOT NULL,
  cancha_partido VARCHAR(100) NOT NULL,
  resultado_partido VARCHAR(10) NULL,
  localidad_partido ENUM('Local', 'Visitante') NOT NULL,
  tipo_resultado_partido ENUM('Victoria', 'Empate', 'Derrota', 'Pendiente') NULL,
  id_rival INT NOT NULL,
  CONSTRAINT fk_rivales_partidos FOREIGN KEY (id_rival) REFERENCES rivales(id_rival)
);

CREATE TABLE convocatorias_partidos(
  id_convocatoria BIGINT AUTO_INCREMENT PRIMARY KEY, 
  id_partido INT NOT NULL,
  CONSTRAINT fk_partido_convocatoria FOREIGN KEY (id_partido) REFERENCES partidos(id_partido), 
  id_jugador INT NOT NULL,
  CONSTRAINT fk_jugador_convocatoria FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador)
);

SET @add_zona_campo := IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_NAME = 'convocatorias_partidos' 
     AND COLUMN_NAME = 'estado_convocado' 
     AND TABLE_SCHEMA = DATABASE()) = 0,
    'ALTER TABLE convocatorias_partidos ADD COLUMN estado_convocado BOOLEAN NULL DEFAULT 0;',
    'SELECT ''La columna estado_convocado ya existe.'';'
);

PREPARE stmt2 FROM @add_zona_campo;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

CREATE TABLE tipos_jugadas(
  id_tipo_jugada INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_tipo_juego VARCHAR(50) NOT NULL, 
  CONSTRAINT uq_nombre_tipo_juego_unico UNIQUE(nombre_tipo_juego)
);

CREATE TABLE tipos_goles(
  id_tipo_gol INT AUTO_INCREMENT PRIMARY KEY, 
  id_tipo_jugada INT NOT NULL, 
  CONSTRAINT fk_tipo_de_jugada FOREIGN KEY (id_tipo_jugada) REFERENCES tipos_jugadas(id_tipo_jugada), 
  nombre_tipo_gol VARCHAR(60) NOT NULL
);

CREATE TABLE participaciones_partidos(
  id_participacion BIGINT AUTO_INCREMENT PRIMARY KEY, 
  id_partido INT NOT NULL,
  CONSTRAINT fk_partido_participacion FOREIGN KEY (id_partido) REFERENCES partidos(id_partido), 
  id_jugador INT NOT NULL,
  CONSTRAINT fk_jugador_participacion FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador),
  id_posicion INT,
  CONSTRAINT fk_partido_posiciones FOREIGN KEY(id_posicion) REFERENCES posiciones(id_posicion),
  titular BOOLEAN NULL DEFAULT 0,
  sustitucion BOOLEAN NULL DEFAULT 0, 
  minutos_jugados INT UNSIGNED NULL DEFAULT 0, 
  goles INT UNSIGNED NULL DEFAULT 0,
  asistencias INT UNSIGNED NULL DEFAULT 0, 
  estado_animo ENUM (
    'Desanimado', 'Agotado', 'Normal', 'Satisfecho', 'Energetico'
  ) NULL DEFAULT 'Normal',
  puntuacion DECIMAL(5,2) UNSIGNED NULL DEFAULT 0
);
-- ------------------------------------------

CREATE TABLE detalles_goles (
  id_detalle_gol INT AUTO_INCREMENT PRIMARY KEY,
  id_participacion BIGINT NOT NULL,
  CONSTRAINT fk_participacion_detalle_gol FOREIGN KEY (id_participacion) REFERENCES participaciones_partidos(id_participacion),
  cantidad_tipo_gol INT UNSIGNED NULL,
  id_tipo_gol INT NOT NULL,
  CONSTRAINT fk_tipo_gol_detalle_gol FOREIGN KEY (id_tipo_gol) REFERENCES tipos_goles(id_tipo_gol)
);

CREATE TABLE detalles_amonestaciones (
  id_detalle_amonestacion INT AUTO_INCREMENT PRIMARY KEY,
  id_participacion BIGINT NOT NULL,
  CONSTRAINT fk_participacion_detalle_amonestacion FOREIGN KEY (id_participacion) REFERENCES participaciones_partidos(id_participacion),
  amonestacion ENUM(
    'Tarjeta amarilla', 'Tarjeta roja',
    'Ninguna'
  ) NULL DEFAULT 'Ninguna',
  numero_amonestacion INT UNSIGNED NULL
);

CREATE TABLE tipos_lesiones(
  id_tipo_lesion INT AUTO_INCREMENT PRIMARY KEY, 
  tipo_lesion VARCHAR(50) NOT NULL, 
  CONSTRAINT uq_tipo_lesion_unico UNIQUE(tipo_lesion)
);

CREATE TABLE tipologias(
  id_tipologia INT AUTO_INCREMENT PRIMARY KEY, 
  tipologia VARCHAR(60), 
  CONSTRAINT uq_tipologia_unico UNIQUE(tipologia)
);

CREATE TABLE sub_tipologias(
  id_sub_tipologia INT AUTO_INCREMENT PRIMARY KEY,
  nombre_sub_tipologia VARCHAR(60) NOT NULL,
  CONSTRAINT uq_sub_tipologia_unico UNIQUE(nombre_sub_tipologia),
  id_tipologia INT NOT NULL, 
  CONSTRAINT fk_tipologias_de_la_subtipologia FOREIGN KEY (id_tipologia) REFERENCES tipologias(id_tipologia)
);

CREATE TABLE lesiones(
  id_lesion INT AUTO_INCREMENT PRIMARY KEY, 
  id_tipo_lesion INT NOT NULL, 
  CONSTRAINT fk_registro_medico_del_tipo_de_lesion FOREIGN KEY (id_tipo_lesion) REFERENCES tipos_lesiones(id_tipo_lesion), 
  id_sub_tipologia INT NOT NULL,
  CONSTRAINT fk_id_subtipologia_lesiones FOREIGN KEY (id_sub_tipologia) REFERENCES sub_tipologias(id_sub_tipologia),
  total_por_lesion INT UNSIGNED NOT NULL DEFAULT 0,
  porcentaje_por_lesion INT UNSIGNED NULL DEFAULT 0
);

CREATE TABLE registros_medicos(
  id_registro_medico INT AUTO_INCREMENT PRIMARY KEY, 
  id_jugador INT NOT NULL, 
  CONSTRAINT fk_registro_medico_jugador FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador), 
  fecha_lesion DATE NULL, 
  fecha_registro DATE NULL DEFAULT NOW(), 
  dias_lesionado INT UNSIGNED NULL, 
  id_lesion INT NOT NULL, 
  CONSTRAINT fk_lesion_jugador FOREIGN KEY (id_lesion) REFERENCES lesiones(id_lesion), 
  retorno_entreno DATE NULL, 
  retorno_partido INT NULL, 
  CONSTRAINT fk_retorno_partido FOREIGN KEY (retorno_partido) REFERENCES partidos(id_partido)
);

ALTER TABLE registros_medicos MODIFY COLUMN retorno_partido INT DEFAULT NULL;

CREATE TABLE pagos(
  id_pago INT AUTO_INCREMENT PRIMARY KEY, 
  fecha_pago DATE NOT NULL,
  cantidad_pago DECIMAL(5, 2)UNSIGNED NOT NULL,
  pago_tardio BOOLEAN NULL DEFAULT 0, 
  mora_pago DECIMAL(5, 2) UNSIGNED NULL DEFAULT 0,
  mes_pago ENUM('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre') NOT NULL,
  id_jugador INT NOT NULL, 
  CONSTRAINT fk_jugador_pago FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador)
);

CREATE TABLE calendario(
    id_calendario INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(50) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_final DATETIME NOT NULL ,
    color VARCHAR(50)
);


-- TRIGGERS, FUNCIONES Y PROCEDIMIENTOS ALMACENADOS WEB

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

# DELIMITER //
#
# CREATE PROCEDURE insertar_o_actualizar_partido(
#     IN insertorUpdate INT,
#     IN id_jornada_param INT,
#     IN id_equipo_param INT,
#     IN logo_rival_param VARCHAR(50),
#     IN rival_partido_param VARCHAR(50),
#     IN fecha_partido_param DATETIME,
#     IN cancha_partido_param VARCHAR(100),
#     IN resultado_partido_param VARCHAR(10),
#     IN localidad_partido_param ENUM('Local', 'Visitante'),
#     IN tipo_resultado_partido_param ENUM('Victoria', 'Empate', 'Derrota')
# )
# BEGIN
#     DECLARE fecha_inicio_jornada DATE;
#     DECLARE fecha_fin_jornada DATE;
#
#     -- Verificar que la fecha del partido esté dentro de las fechas de la jornada
#     SELECT fecha_inicio_jornada, fecha_fin_jornada INTO fecha_inicio_jornada, fecha_fin_jornada
#     FROM jornadas
#     WHERE id_jornada = id_jornada_param;
#
#     IF fecha_partido_param < fecha_inicio_jornada OR fecha_partido_param > fecha_fin_jornada THEN
#         SIGNAL SQLSTATE '45000'
#         SET MESSAGE_TEXT = 'La fecha del partido está fuera del rango de fechas de la jornada';
#     END IF;
#
#     IF insertorUpdate = 0 THEN
#         INSERT INTO partidos (
#             id_jornada,
#             id_equipo,
#             logo_rival,
#             rival_partido,
#             fecha_partido,
#             cancha_partido,
#             resultado_partido,
#             localidad_partido,
#             tipo_resultado_partido
#         )
#         VALUES (
#             id_jornada_param,
#             id_equipo_param,
#             logo_rival_param,
#             rival_partido_param,
#             fecha_partido_param,
#             cancha_partido_param,
#             resultado_partido_param,
#             localidad_partido_param,
#             tipo_resultado_partido_param
#         );
#     ELSE
#         UPDATE partidos
#         SET id_jornada = id_jornada_param,
#             id_equipo = id_equipo_param,
#             logo_rival = logo_rival_param,
#             rival_partido = rival_partido_param,
#             fecha_partido = fecha_partido_param,
#             cancha_partido = cancha_partido_param,
#             resultado_partido = resultado_partido_param,
#             localidad_partido = localidad_partido_param,
#             tipo_resultado_partido = tipo_resultado_partido_param
#         WHERE id_partido = insertorUpdate;
#     END IF;
# END //
#
# DELIMITER $$

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
    DECLARE email_count INT;
    DECLARE dui_count INT;

    -- Validar formato de correo
    IF p_correo_administrador REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN

        -- Verificar si el correo ya existe
        SELECT COUNT(*) INTO email_count
        FROM administradores
        WHERE correo_administrador = p_correo_administrador;

        -- Verificar si el DUI ya existe
        SELECT COUNT(*) INTO dui_count
        FROM administradores
        WHERE dui_administrador = p_dui_administrador;

        -- Si existe un duplicado de correo o DUI, generar un error
        IF email_count > 0 THEN
            SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Correo electrónico ya existe';
        ELSEIF dui_count > 0 THEN
            SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'DUI ya existe';
        ELSE
            -- Generar el alias utilizando la función
            SET p_alias_administrador = generar_alias_administrador(p_nombre_administrador, p_apellido_administrador, NOW());
            INSERT INTO administradores (nombre_administrador, apellido_administrador, clave_administrador, correo_administrador, telefono_administrador, dui_administrador, fecha_nacimiento_administrador, alias_administrador, foto_administrador)
            VALUES(p_nombre_administrador, p_apellido_administrador, p_clave_administrador, p_correo_administrador, p_telefono_administrador, p_dui_administrador, p_fecha_nacimiento_administrador, p_alias_administrador, p_foto_administrador);
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato de correo electrónico no válido';
    END IF;
END;
$$
DELIMITER ;

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
    DECLARE email_count INT;
    DECLARE dui_count INT;

    -- Validar formato de correo
    IF p_correo_administrador REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN

        -- Verificar si el correo ya existe para otro administrador
        SELECT COUNT(*) INTO email_count
        FROM administradores
        WHERE correo_administrador = p_correo_administrador
        AND id_administrador <> p_id_administrador;

        -- Verificar si el DUI ya existe para otro administrador
        SELECT COUNT(*) INTO dui_count
        FROM administradores
        WHERE dui_administrador = p_dui_administrador
        AND id_administrador <> p_id_administrador;

        -- Si existe un duplicado de correo o DUI, generar un error
        IF email_count > 0 THEN
            SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Correo electrónico ya existe';
        ELSEIF dui_count > 0 THEN
            SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'DUI ya existe';
        ELSE
            -- Actualizar el registro del administrador
            UPDATE administradores SET
                nombre_administrador = p_nombre_administrador,
                apellido_administrador = p_apellido_administrador,
                correo_administrador = p_correo_administrador,
                telefono_administrador = p_telefono_administrador,
                dui_administrador = p_dui_administrador,
                fecha_nacimiento_administrador = p_fecha_nacimiento_administrador,
                foto_administrador = p_foto_administrador
            WHERE id_administrador = p_id_administrador;
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Formato de correo electrónico no válido';
    END IF;
END;
$$
DELIMITER ;

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
    DECLARE email_count INT;
    DECLARE dui_count INT;

    -- Validar formato de correo
    IF p_correo_tecnico REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN

        -- Verificar si el correo ya existe
        SELECT COUNT(*) INTO email_count
        FROM tecnicos
        WHERE correo_tecnico = p_correo_tecnico;

        -- Verificar si el DUI ya existe
        SELECT COUNT(*) INTO dui_count
        FROM tecnicos
        WHERE dui_tecnico = p_dui_tecnico;

        -- Si existe un duplicado de correo o DUI, generar un error
        IF email_count > 0 THEN
            SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Correo electrónico ya existe';
        ELSEIF dui_count > 0 THEN
            SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'DUI ya existe';
        ELSE
            -- Generar el alias utilizando la función
            SET p_alias_tecnico = generar_alias_tecnico(p_nombre_tecnico, p_apellido_tecnico, NOW());
            INSERT INTO tecnicos (nombre_tecnico, apellido_tecnico, clave_tecnico, correo_tecnico, telefono_tecnico, dui_tecnico, fecha_nacimiento_tecnico, alias_tecnico, foto_tecnico)
            VALUES(p_nombre_tecnico, p_apellido_tecnico, p_clave_tecnico, p_correo_tecnico, p_telefono_tecnico, p_dui_tecnico, p_fecha_nacimiento_tecnico, p_alias_tecnico, p_foto_tecnico);
        END IF;
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
    DECLARE email_count INT;
    DECLARE dui_count INT;

    -- Validar formato de correo
    IF p_correo_tecnico REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN

        -- Verificar si el correo ya existe para otro técnico
        SELECT COUNT(*) INTO email_count
        FROM tecnicos
        WHERE correo_tecnico = p_correo_tecnico
        AND id_tecnico <> p_id_tecnico;

        -- Verificar si el DUI ya existe para otro técnico
        SELECT COUNT(*) INTO dui_count
        FROM tecnicos
        WHERE dui_tecnico = p_dui_tecnico
        AND id_tecnico <> p_id_tecnico;

        -- Si existe un duplicado de correo o DUI, generar un error
        IF email_count > 0 THEN
            SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Correo electrónico ya existe';
        ELSEIF dui_count > 0 THEN
            SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'DUI ya existe';
        ELSE
            -- Actualizar el registro del técnico
            UPDATE tecnicos SET
                nombre_tecnico = p_nombre_tecnico,
                apellido_tecnico = p_apellido_tecnico,
                correo_tecnico = p_correo_tecnico,
                telefono_tecnico = p_telefono_tecnico,
                dui_tecnico = p_dui_tecnico,
                fecha_nacimiento_tecnico = p_fecha_nacimiento_tecnico,
                foto_tecnico = p_foto_tecnico
            WHERE id_tecnico = p_id_tecnico;
        END IF;
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
    IN p_clasificacion ENUM('Técnicos', 'Tácticos', 'Psicológicos', 'Físicos')
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
    IN p_nueva_clasificacion ENUM('Técnicos', 'Tácticos', 'Psicológicos', 'Físicos')
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
    DECLARE task_count INT;

    -- Verificar si el nombre de la tarea ya existe
    SELECT COUNT(*) INTO task_count
    FROM tareas
    WHERE nombre_tarea = p_nombre_tarea;

    -- Si existe un duplicado de nombre de tarea, generar un error
    IF task_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la tarea ya existe';
    ELSE
        INSERT INTO tareas (nombre_tarea)
        VALUES (p_nombre_tarea);
    END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS actualizar_tarea;
DELIMITER //
CREATE PROCEDURE actualizar_tarea(IN p_id_tarea INT, IN p_nombre_tarea VARCHAR(60))
BEGIN
    DECLARE task_count INT;

    -- Verificar si el nombre de la tarea ya existe para otra tarea
    SELECT COUNT(*) INTO task_count
    FROM tareas
    WHERE nombre_tarea = p_nombre_tarea
    AND id_tarea != p_id_tarea;

    -- Si existe un duplicado de nombre de tarea, generar un error
    IF task_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la tarea ya existe';
    ELSE
        UPDATE tareas
        SET nombre_tarea = p_nombre_tarea
        WHERE id_tarea = p_id_tarea;
    END IF;
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
DROP PROCEDURE IF EXISTS insertar_tipo_lesion;
DELIMITER //

CREATE PROCEDURE insertar_tipo_lesion(IN p_tipo_lesion VARCHAR(50))
BEGIN
    DECLARE lesion_count INT;

    -- Verificar si el tipo de lesión ya existe
    SELECT COUNT(*) INTO lesion_count
    FROM tipos_lesiones
    WHERE tipo_lesion = p_tipo_lesion;

    -- Si existe un duplicado de tipo de lesión, generar un error
    IF lesion_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de lesión ya existe';
    ELSE
        INSERT INTO tipos_lesiones (tipo_lesion)
        VALUES (p_tipo_lesion);
    END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS actualizar_tipo_lesion;
DELIMITER //

CREATE PROCEDURE actualizar_tipo_lesion(IN p_id_tipo_lesion INT, IN p_tipo_lesion VARCHAR(50))
BEGIN
    DECLARE lesion_count INT;

    -- Verificar si el tipo de lesión ya existe para otro registro
    SELECT COUNT(*) INTO lesion_count
    FROM tipos_lesiones
    WHERE tipo_lesion = p_tipo_lesion
    AND id_tipo_lesion != p_id_tipo_lesion;

    -- Si existe un duplicado de tipo de lesión, generar un error
    IF lesion_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de lesión ya existe';
    ELSE
        UPDATE tipos_lesiones
        SET tipo_lesion = p_tipo_lesion
        WHERE id_tipo_lesion = p_id_tipo_lesion;
    END IF;
END //
DELIMITER ;

DELIMITER //

CREATE PROCEDURE eliminar_tipo_lesion(IN p_id_tipo_lesion INT)
BEGIN
    DELETE FROM tipos_lesiones
    WHERE id_tipo_lesion = p_id_tipo_lesion;
END //

DELIMITER ;

-- Tabla rol_tecnico

DROP PROCEDURE IF EXISTS insertar_rol_tecnico;
DELIMITER //

CREATE PROCEDURE insertar_rol_tecnico(IN p_nombre_rol_tecnico VARCHAR(60))
BEGIN
    DECLARE rol_count INT;

    -- Verificar si el nombre del rol técnico ya existe
    SELECT COUNT(*) INTO rol_count
    FROM rol_tecnico
    WHERE nombre_rol_tecnico = p_nombre_rol_tecnico;

    -- Si existe un duplicado de nombre de rol técnico, generar un error
    IF rol_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del rol técnico ya existe';
    ELSE
        INSERT INTO rol_tecnico (nombre_rol_tecnico)
        VALUES (p_nombre_rol_tecnico);
    END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS actualizar_rol_tecnico;
DELIMITER //

CREATE PROCEDURE actualizar_rol_tecnico(IN p_id_rol_tecnico INT, IN p_nombre_rol_tecnico VARCHAR(60))
BEGIN
    DECLARE rol_count INT;

    -- Verificar si el nombre del rol técnico ya existe para otro registro
    SELECT COUNT(*) INTO rol_count
    FROM rol_tecnico
    WHERE nombre_rol_tecnico = p_nombre_rol_tecnico
    AND id_rol_tecnico != p_id_rol_tecnico;

    -- Si existe un duplicado de nombre de rol técnico, generar un error
    IF rol_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del rol técnico ya existe';
    ELSE
        UPDATE rol_tecnico
        SET nombre_rol_tecnico = p_nombre_rol_tecnico
        WHERE id_rol_tecnico = p_id_rol_tecnico;
    END IF;
END //
DELIMITER ;

DELIMITER //

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

-- Procedimiento para insertar un nuevo horario con validación de duplicados
DROP PROCEDURE IF EXISTS sp_insertar_horario;
DELIMITER //

CREATE PROCEDURE sp_insertar_horario (
    IN p_nombre_horario VARCHAR(60),
    IN p_dia ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'),
    IN p_hora_inicial TIME,
    IN p_hora_final TIME,
    IN p_campo_de_entrenamiento VARCHAR(100)
)
BEGIN
    DECLARE record_count INT;

    -- Verificar si el registro ya existe
    SELECT COUNT(*) INTO record_count
    FROM horarios
    WHERE nombre_horario = p_nombre_horario
      AND dia = p_dia
      AND hora_inicial = p_hora_inicial
      AND hora_final = p_hora_final
      AND campo_de_entrenamiento = p_campo_de_entrenamiento;

    -- Si existe un duplicado, generar un error
    IF record_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'El registro ya existe';
    ELSE
        INSERT INTO horarios (nombre_horario, dia, hora_inicial, hora_final, campo_de_entrenamiento)
        VALUES (p_nombre_horario, p_dia, p_hora_inicial, p_hora_final, p_campo_de_entrenamiento);
    END IF;
END //
DELIMITER ;

-- Procedimiento para actualizar un horario existente con validación de duplicados
DROP PROCEDURE IF EXISTS sp_actualizar_horario;
DELIMITER //

CREATE PROCEDURE sp_actualizar_horario (
    IN p_id_horario INT,
    IN p_nombre_horario VARCHAR(60),
    IN p_dia ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'),
    IN p_hora_inicial TIME,
    IN p_hora_final TIME,
    IN p_campo_de_entrenamiento VARCHAR(100)
)
BEGIN
    DECLARE record_count INT;

    -- Verificar si el registro ya existe para otro horario
    SELECT COUNT(*) INTO record_count
    FROM horarios
    WHERE nombre_horario = p_nombre_horario
      AND dia = p_dia
      AND hora_inicial = p_hora_inicial
      AND hora_final = p_hora_final
      AND campo_de_entrenamiento = p_campo_de_entrenamiento
      AND id_horario <> p_id_horario;

    -- Si existe un duplicado, generar un error
    IF record_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'El registro ya existe';
    ELSE
        UPDATE horarios
        SET nombre_horario = p_nombre_horario,
            dia = p_dia,
            hora_inicial = p_hora_inicial,
            hora_final = p_hora_final,
            campo_de_entrenamiento = p_campo_de_entrenamiento
        WHERE id_horario = p_id_horario;
    END IF;
END //
DELIMITER ;

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
    IN p_edad_maxima_permitida INT
)
BEGIN
    INSERT INTO categorias(nombre_categoria, edad_minima_permitida, edad_maxima_permitida)
    VALUES (p_nombre_categoria, p_edad_minima_permitida, p_edad_maxima_permitida);
END //
DELIMITER ;

-- Procedimiento para actualizar una categoría
DELIMITER //
CREATE PROCEDURE sp_actualizar_categoria (
    IN p_id_categoria INT,
    IN p_nombre_categoria VARCHAR(80),
    IN p_edad_minima_permitida INT,
    IN p_edad_maxima_permitida INT
)
BEGIN
    UPDATE categorias
    SET nombre_categoria = p_nombre_categoria, edad_minima_permitida = p_edad_minima_permitida, edad_maxima_permitida = p_edad_maxima_permitida
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
    IN p_dias_lesionado INT,
    IN p_id_lesion INT,
    IN p_retorno_entreno DATE,
    IN p_retorno_partido INT
)
BEGIN
    INSERT INTO registros_medicos(id_jugador, fecha_lesion, dias_lesionado, id_lesion, retorno_entreno, retorno_partido)
    VALUES (p_id_jugador, p_fecha_lesion, p_dias_lesionado, p_id_lesion, p_retorno_entreno, p_retorno_partido);
END //
DELIMITER ;

-- Procedimiento para actualizar registros_medicos
DELIMITER //
CREATE PROCEDURE sp_actualizar_registro_medico (
    IN p_id_registro_medico INT,
    IN p_id_jugador INT,
    IN p_fecha_lesion DATE,
    IN p_dias_lesionado INT,
    IN p_id_lesion INT,
    IN p_retorno_entreno DATE,
    IN p_retorno_partido INT
)
BEGIN
    UPDATE registros_medicos
    SET id_jugador = p_id_jugador, fecha_lesion = p_fecha_lesion, dias_lesionado = p_dias_lesionado, id_lesion = p_id_lesion, retorno_entreno = p_retorno_entreno, retorno_partido = p_retorno_partido
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

DROP PROCEDURE IF EXISTS sp_insertar_plantilla_equipo;
DELIMITER //

CREATE PROCEDURE sp_insertar_plantilla_equipo (
    IN p_id_plantilla INT,
    IN p_id_jugador INT,
    IN p_id_temporada INT,
    IN p_id_equipo INT
)
BEGIN
    DECLARE record_count INT;

    -- Verificar si el registro ya existe
    SELECT COUNT(*) INTO record_count
    FROM plantillas_equipos
    WHERE id_plantilla = p_id_plantilla
      AND id_jugador = p_id_jugador
      AND id_temporada = p_id_temporada
      AND id_equipo = p_id_equipo;

    -- Si existe un duplicado, generar un error
    IF record_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'El registro ya existe';
    ELSE
        INSERT INTO plantillas_equipos (id_plantilla, id_jugador, id_temporada, id_equipo)
        VALUES (p_id_plantilla, p_id_jugador, p_id_temporada, p_id_equipo);
    END IF;
END //
DELIMITER ;

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
    DECLARE record_count INT;

    -- Verificar si el registro ya existe para otro plantilla equipo
    SELECT COUNT(*) INTO record_count
    FROM plantillas_equipos
    WHERE id_plantilla = p_id_plantilla
      AND id_jugador = p_id_jugador
      AND id_temporada = p_id_temporada
      AND id_equipo = p_id_equipo
      AND id_plantilla_equipo <> p_id_plantilla_equipo;

    -- Si existe un duplicado, generar un error
    IF record_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'El registro ya existe';
    ELSE
        UPDATE plantillas_equipos
        SET id_plantilla = p_id_plantilla,
            id_jugador = p_id_jugador,
            id_temporada = p_id_temporada,
            id_equipo = p_id_equipo
        WHERE id_plantilla_equipo = p_id_plantilla_equipo;
    END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_plantilla_equipo;
DELIMITER //
CREATE PROCEDURE sp_eliminar_plantilla_equipo (IN p_id_plantilla_equipo INT)
BEGIN
    DELETE FROM plantillas_equipos WHERE id_plantilla_equipo = p_id_plantilla_equipo;
END //
DELIMITER ;

-- Procedimientos para la tabla detalles_cuerpos_tecnicos
DROP PROCEDURE IF EXISTS sp_insertar_detalle_cuerpo_tecnico;
DELIMITER //

CREATE PROCEDURE sp_insertar_detalle_cuerpo_tecnico (
    IN p_id_cuerpo_tecnico INT,
    IN p_id_tecnico INT,
    IN p_id_rol_tecnico INT
)
BEGIN
    DECLARE record_count INT;

    -- Verificar si el registro ya existe
    SELECT COUNT(*) INTO record_count
    FROM detalles_cuerpos_tecnicos
    WHERE id_cuerpo_tecnico = p_id_cuerpo_tecnico
      AND (id_tecnico = p_id_tecnico
      OR id_rol_tecnico = p_id_rol_tecnico);

    -- Si existe un duplicado, generar un error
    IF record_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El registro ya existe';
    ELSE
        INSERT INTO detalles_cuerpos_tecnicos (id_cuerpo_tecnico, id_tecnico, id_rol_tecnico)
        VALUES (p_id_cuerpo_tecnico, p_id_tecnico, p_id_rol_tecnico);
    END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_actualizar_detalle_cuerpo_tecnico;
DELIMITER //

CREATE PROCEDURE sp_actualizar_detalle_cuerpo_tecnico (
    IN p_id_detalle_cuerpo_tecnico INT,
    IN p_id_cuerpo_tecnico INT,
    IN p_id_tecnico INT,
    IN p_id_rol_tecnico INT
)
BEGIN
    DECLARE record_count INT;

    -- Verificar si el registro ya existe para otro detalle
    SELECT COUNT(*) INTO record_count
    FROM detalles_cuerpos_tecnicos
    WHERE id_cuerpo_tecnico = p_id_cuerpo_tecnico
      AND (id_tecnico = p_id_tecnico
      OR id_rol_tecnico = p_id_rol_tecnico)
      AND id_detalle_cuerpo_tecnico <> p_id_detalle_cuerpo_tecnico;

    -- Si existe un duplicado, generar un error
    IF record_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'El registro ya existe';
    ELSE
        UPDATE detalles_cuerpos_tecnicos
        SET id_cuerpo_tecnico = p_id_cuerpo_tecnico,
            id_tecnico = p_id_tecnico,
            id_rol_tecnico = p_id_rol_tecnico
        WHERE id_detalle_cuerpo_tecnico = p_id_detalle_cuerpo_tecnico;
    END IF;
END //
DELIMITER ;

DELIMITER //
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
alias_administrador AS 'ALIAS',
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
alias_tecnico AS 'ALIAS',
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
       p.mora_pago AS 'MORA',
       p.mes_pago AS 'MES',
       CONCAT(j.nombre_jugador,' ',j.apellido_jugador) AS 'NOMBRE',
		CASE
			WHEN p.pago_tardio = 1 THEN 'Si'
           		WHEN p.pago_tardio = 0 THEN 'No'
		END AS 'TARDIO',
        ROUND(P.cantidad_pago + P.mora_pago, 2) AS 'TOTAL'
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
    t.foto_tecnico AS IMAGEN,
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
DROP VIEW IF EXISTS vista_jugadores;
CREATE VIEW vista_jugadores AS
    SELECT
        j.id_jugador,
        CONCAT(j.nombre_jugador, ' ', j.apellido_jugador) AS NOMBRE_COMPLETO,
        j.dorsal_jugador,
        j.nombre_jugador,
        j.apellido_jugador,
        j.estatus_jugador,
        j.fecha_nacimiento_jugador,
        DATE_FORMAT(j.fecha_nacimiento_jugador, '%e de %M del %Y') AS nacimiento,
        j.genero_jugador,
        j.perfil_jugador,
        j.becado,
        j.id_posicion_principal,
        j.id_posicion_secundaria,
        j.alias_jugador,
        j.clave_jugador,
        j.foto_jugador,
        j.fecha_creacion,
        DATE_FORMAT(j.fecha_creacion, '%e de %M del %Y') AS registoJugador,
        p1.posicion AS posicionPrincipal,
        p2.posicion AS posicionSecundaria,
        j.observacion_medica,
        j.tipo_sangre,
        j.telefono,
        j.telefono_de_emergencia,
        j.correo_jugador
FROM jugadores j
INNER JOIN
    posiciones p1 ON j.id_posicion_principal = p1.id_posicion
INNER JOIN
    posiciones p2 ON j.id_posicion_secundaria = p2.id_posicion;

SELECT * FROM vista_jugadores;

-- Procedimiento para insertar un jugador
DROP PROCEDURE IF EXISTS insertar_jugador;
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
   IN p_foto_jugador VARCHAR(50),
   IN telefonoJ VARCHAR(15),
   IN telefono_emergenciaJ VARCHAR(15),
   IN correoJ VARCHAR(50),
   IN tipo_sangreJ VARCHAR(10),
   IN observacion_medicaJ VARCHAR(200)
)
BEGIN
    DECLARE p_alias_jugador VARCHAR(25);
        -- Generar el alias utilizando la función, suponiendo que la función generar_alias_tecnico existe
        SET p_alias_jugador = generar_alias_jugador(p_nombre_jugador, p_apellido_jugador, p_perfil_jugador, NOW());
        INSERT INTO jugadores (dorsal_jugador, nombre_jugador, apellido_jugador, estatus_jugador, fecha_nacimiento_jugador, genero_jugador, perfil_jugador, becado, id_posicion_principal, id_posicion_secundaria, clave_jugador, foto_jugador, alias_jugador, telefono, telefono_de_emergencia, correo_jugador, tipo_sangre, observacion_medica)
        VALUES(p_dorsal_jugador, p_nombre_jugador, p_apellido_jugador, p_estatus_jugador, p_fecha_nacimiento_jugador, p_genero_jugador, p_perfil_jugador, p_becado, p_id_posicion_principal, p_id_posicion_secundaria, p_clave_jugador, p_foto_jugador, p_alias_jugador, telefonoJ, telefono_emergenciaJ, correoJ, tipo_sangreJ, observacion_medicaJ);
END;
$$
DELIMITER ;

-- Procedimiento para actualizar jugador
DROP PROCEDURE IF EXISTS actualizar_jugador;
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
    IN foto VARCHAR(36),
    IN telefonoJ VARCHAR(15),
    IN telefono_emergenciaJ VARCHAR(15),
    IN correoJ VARCHAR(50),
    IN tipo_sangreJ VARCHAR(10),
    IN observacion_medicaJ VARCHAR(200)
)
BEGIN
    UPDATE jugadores
    SET id_jugador = id, dorsal_jugador = dorsal, nombre_jugador = nombre, apellido_jugador = apellido,
        estatus_jugador = estatus, fecha_nacimiento_jugador = nacimiento, genero_jugador = genero, perfil_jugador = perfil,
        becado = beca, id_posicion_principal = posicionPrincipal, id_posicion_secundaria = posicionSecundaria, foto_jugador = foto, telefono = telefonoJ, telefono_de_emergencia = telefono_emergenciaJ, correo_jugador = correoJ, tipo_sangre = tipo_sangreJ, observacion_medica = observacion_medicaJ
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
	    st.nombre_sub_tipologia,
        l.id_tipo_lesion,
        l.id_sub_tipologia,
        l.total_por_lesion,
        l.porcentaje_por_lesion,
        tl.tipo_lesion
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
DROP VIEW IF EXISTS vista_tecnicos_equipos;
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
        t.correo_tecnico,
        t.telefono_tecnico
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
SELECT * FROM entrenamientos;
SELECT * FROM horarios;
CREATE VIEW vista_horarios_equipos AS
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
JOIN
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
    j.nombre_jugador AS jugadores,
    j.id_jugador AS id,
    pe.id_plantilla_equipo,
    p.posicion
FROM
    equipos e
JOIN
    plantillas_equipos pe ON e.id_equipo = pe.id_equipo
JOIN
    jugadores j ON pe.id_jugador = j.id_jugador
JOIN 
	posiciones p ON j.id_posicion_principal = p.id_posicion;

SELECT * FROM vista_equipos_jugadores;
SELECT * FROM plantillas_equipos;
-- Procedimiento para insertar detalle contenido
-- DROP PROCEDURE insertarDetalleContenido;
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
    -- Insertar en detalles_contenidos
    INSERT INTO detalles_contenidos (id_tarea, id_sub_tema_contenido, minutos_contenido, minutos_tarea)
    VALUES (p_tarea_id, p_subContenido_id, p_subContenido_minutos, p_tarea_minutos);

    SET v_id_detalle_contenido = LAST_INSERT_ID();

    INSERT INTO detalle_entrenamiento (id_entrenamiento, id_detalle_contenido, id_jugador)
    VALUES (p_id_entrenamiento, v_id_detalle_contenido, p_id_jugador);
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

-- ------------------------------------------------------------------------RIVALES----------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_insertar_rival;
DELIMITER //

CREATE PROCEDURE sp_insertar_rival (
    IN p_nombre_rival VARCHAR(50),
    IN p_logo_rival VARCHAR(50)
)
BEGIN
    DECLARE rival_count INT;

    -- Verificar si el nombre del rival ya existe
    SELECT COUNT(*) INTO rival_count
    FROM rivales
    WHERE nombre_rival = p_nombre_rival;

    -- Si existe un duplicado de nombre de rival, generar un error
    IF rival_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del rival ya existe';
    ELSE
        INSERT INTO rivales (nombre_rival, logo_rival)
        VALUES (p_nombre_rival, p_logo_rival);
    END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_actualizar_rival;
DELIMITER //

CREATE PROCEDURE sp_actualizar_rival (
    IN p_id_rival INT,
    IN p_nombre_rival VARCHAR(50),
    IN p_logo_rival VARCHAR(50)
)
BEGIN
    DECLARE rival_count INT;

    -- Verificar si el nombre del rival ya existe para otro registro
    SELECT COUNT(*) INTO rival_count
    FROM rivales
    WHERE nombre_rival = p_nombre_rival
    AND id_rival != p_id_rival;

    -- Si existe un duplicado de nombre de rival, generar un error
    IF rival_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del rival ya existe';
    ELSE
        UPDATE rivales
        SET nombre_rival = p_nombre_rival,
            logo_rival = p_logo_rival
        WHERE id_rival = p_id_rival;
    END IF;
END //
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_eliminar_rival (
    IN p_id_rival INT
)
BEGIN
    DECLARE contador_partidos INT;
    -- Contar cuántos registros en la tabla partidos están asociados con el id_rival
    SELECT COUNT(*)
    INTO contador_partidos
    FROM partidos
    WHERE id_rival = p_id_rival;
    -- Verificar si hay registros asociados
    IF contador_partidos > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar el rival, porque está asociado con registros en la tabla partidos';
    ELSE
        DELETE FROM rivales
        WHERE id_rival = p_id_rival;
    END IF;
END $$

DELIMITER ;

DELIMITER $$
CREATE VIEW vista_rivales AS
SELECT
    id_rival AS 'ID',
    nombre_rival AS 'Nombre',
    logo_rival AS 'Logo'
FROM rivales;
$$
DELIMITER ;

-- ------------------------------------------------------------------------PARTIDOS----------------------------------------------------------------
-- Vista para partidos:
DROP VIEW IF EXISTS vista_detalle_partidos;
CREATE VIEW vista_detalle_partidos AS
SELECT
    p.id_partido,
    DATE_FORMAT(p.fecha_partido, '%e de %M del %Y') AS fecha,
    p.fecha_partido,
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
    c.nombre_categoria
FROM
    partidos p
INNER JOIN
    equipos e ON p.id_equipo = e.id_equipo
INNER JOIN
	rivales i ON p.id_rival = i.id_rival
INNER JOIN
    categorias c ON e.id_categoria = c.id_categoria
ORDER BY p.fecha_partido DESC;

SELECT * FROM vista_detalle_partidos;

-- PROCEDIMIENTO ALMACENADO DE PARTIDOS

DELIMITER $$
CREATE PROCEDURE insertarPartido(
    IN p_id_equipo INT,
    IN p_id_rival INT,
    IN p_cancha_partido VARCHAR(100),
    IN p_resultado_partido VARCHAR(10),
    IN p_localidad_partido ENUM('Local', 'Visitante'),
    IN p_tipo_resultado_partido ENUM('Victoria', 'Empate', 'Derrota', 'Pendiente'),
    IN p_id_jornada INT,
    IN p_fecha_partido DATETIME
)
BEGIN
    INSERT INTO partidos (
        id_jornada,
        id_equipo,
        fecha_partido,
        cancha_partido,
        resultado_partido,
        localidad_partido,
        tipo_resultado_partido,
        id_rival
    )
    VALUES (
        p_id_jornada,
        p_id_equipo,
        p_fecha_partido,
        p_cancha_partido,
        p_resultado_partido,
        p_localidad_partido,
        p_tipo_resultado_partido,
        p_id_rival
    );
END$$

DELIMITER ;

-- Vista para read one de partidos
DROP VIEW IF EXISTS vista_partidos_equipos;
CREATE VIEW vista_partidos_equipos AS
SELECT
    e.id_equipo,
    e.nombre_equipo,
    e.logo_equipo,
    p.id_partido,
    p.fecha_partido,
    p.cancha_partido,
    i.nombre_rival AS nombre_rival,
    i.logo_rival,
    i.id_rival,
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
	rivales i ON p.id_rival = i.id_rival
JOIN
    jornadas j ON p.id_jornada = j.id_jornada;


-- ----------------------------------------------- PARTICIPACIONES  --------------------------------------------------------------------------
-- DROP VIEW vista_jugadores_por_equipo;
-- VER JUGADORES POR EQUIPO
CREATE VIEW vista_jugadores_por_equipo AS
    SELECT
        cp.id_convocatoria,
        cp.id_partido,
        cp.id_jugador,
        cp.estado_convocado,
        j.nombre_jugador,
        j.apellido_jugador,
        j.dorsal_jugador,
        j.foto_jugador,
        j.id_posicion_principal,
        p.posicion,
        p.area_de_juego,
        j.estatus_jugador
FROM convocatorias_partidos cp
INNER JOIN
    jugadores j ON cp.id_jugador = j.id_jugador
INNER JOIN
    posiciones p ON j.id_posicion_principal = p.id_posicion;

-- Vista para ver los tipos de goles de un jugador
CREATE VIEW vista_detalles_goles AS
    SELECT
        dt.id_detalle_gol,
        dt.id_participacion,
        dt.cantidad_tipo_gol,
        dt.id_tipo_gol,
        tg.nombre_tipo_gol
FROM detalles_goles dt
INNER JOIN
    tipos_goles tg ON dt.id_tipo_gol = tg.id_tipo_gol;

-- TRIGGER PARA INSERTAR, ACTUALIZAR O ELIMINAR GOLES EN PARTICIPACIONES PARTIDO.

-- Si ya habia creado estos trigger ejecuten estas lineas y vuelvan a crearlo. att. Con cariño su coordi :3
-- DROP TRIGGER trigger_insertar_participacion;
-- DROP TRIGGER trigger_actualizar_participacion;
-- DROP TRIGGER trigger_eliminar_participacion;

DELIMITER //
CREATE TRIGGER trigger_insertar_participacion
AFTER INSERT ON detalles_goles
FOR EACH ROW
BEGIN
    DECLARE p_goles INT;
    SET p_goles = COALESCE((SELECT SUM(cantidad_tipo_gol)
                            FROM detalles_goles
                            WHERE id_participacion = NEW.id_participacion), 0);

    UPDATE participaciones_partidos
    SET goles = p_goles
    WHERE id_participacion = NEW.id_participacion;
END //

DELIMITER ;

DELIMITER //
CREATE TRIGGER trigger_actualizar_participacion
AFTER UPDATE ON detalles_goles
FOR EACH ROW
BEGIN
    DECLARE p_goles INT;
    SET p_goles = COALESCE((SELECT SUM(cantidad_tipo_gol)
                            FROM detalles_goles
                            WHERE id_participacion = NEW.id_participacion), 0);

    UPDATE participaciones_partidos
    SET goles = p_goles
    WHERE id_participacion = NEW.id_participacion;
END //

DELIMITER ;

DELIMITER //
CREATE TRIGGER trigger_eliminar_participacion
AFTER DELETE ON detalles_goles
FOR EACH ROW
BEGIN
    DECLARE p_goles INT;
    SET p_goles = COALESCE((SELECT SUM(cantidad_tipo_gol)
                            FROM detalles_goles
                            WHERE id_participacion = OLD.id_participacion), 0);

    UPDATE participaciones_partidos
    SET goles = p_goles
    WHERE id_participacion = OLD.id_participacion;
END //

DELIMITER ;

-- Vista de registros medicos
CREATE VIEW vista_registros_medicos AS
SELECT
    rm.id_registro_medico,
    rm.id_jugador,
    CONCAT(j.nombre_jugador, ' ', j.apellido_jugador) AS nombre_completo_jugador,
    rm.fecha_lesion,
    rm.fecha_registro,
    rm.dias_lesionado,
    rm.id_lesion,
    l.id_tipo_lesion,
    l.id_sub_tipologia,
    st.nombre_sub_tipologia,
    rm.retorno_entreno,
    rm.retorno_partido,
    p.fecha_partido
FROM
    registros_medicos rm
INNER JOIN
    jugadores j ON rm.id_jugador = j.id_jugador
INNER JOIN
    lesiones l ON rm.id_lesion = l.id_lesion
INNER JOIN
    sub_tipologias st ON l.id_sub_tipologia = st.id_sub_tipologia
LEFT JOIN
    partidos p ON rm.retorno_partido = p.id_partido;

-- Vista de categorias
CREATE VIEW vista_categorias AS
SELECT
    c.id_categoria,
    c.nombre_categoria,
    c.edad_minima_permitida,
    c.edad_maxima_permitida
FROM
    categorias c;

-- Vista de horarios_categorias
DROP VIEW IF EXISTS vista_horarios_categorias;
CREATE VIEW vista_horarios_categorias AS
SELECT
    hc.id_horario_categoria,
    hc.id_horario,
    h.nombre_horario,
    hc.id_categoria,
    c.nombre_categoria,
    h.dia,
    h.hora_inicial,
    h.hora_final
FROM
    horarios_categorias hc
INNER JOIN
    horarios h ON hc.id_horario = h.id_horario
INNER JOIN
    categorias c ON hc.id_categoria = c.id_categoria;


-- ---------------------------------------VISTA PARA INGRESOS----------------------------------------------------
DROP VIEW IF EXISTS vista_ingresos;
CREATE VIEW vista_ingresos AS
    SELECT
        YEAR(fecha_pago) as anio,
        mes_pago AS mes,
        SUM(cantidad_pago) AS cantidad
FROM pagos
WHERE YEAR(fecha_pago) = YEAR(CURDATE())
GROUP BY mes_pago ;

-- ------------------------------------------------------------------------ENTRENAMIENTOS----------------------------------------------------------------
-- -Vista para el read all
CREATE VIEW vista_jornadas_entrenamientos AS
SELECT
    j.id_jornada,
    e.id_entrenamiento,
    e.fecha_entrenamiento,
    CONCAT(DATE_FORMAT(e.fecha_entrenamiento, '%e de %M del %Y'), ' - ', e.sesion) AS detalle_entrenamiento
FROM
    jornadas j
JOIN
    entrenamientos e ON j.id_jornada = e.id_jornada;
SELECT * FROM vista_jornadas_entrenamientos WHERE id_jornada = 1;

-- -Agregar un entrenamiento
/*
INSERT INTO entrenamientos (fecha_entrenamiento, sesion, id_jornada, id_equipo, id_categoria, id_horario)
VALUES (?,?,?,?,?,?);
*/

-- -Update
/*
UPDATE entrenameientos SET fecha_entrenamiento = ?, sesion = ?, id_jornada ?, id_categoria = ?, id_horario = ? WHERE id_entrenamiento = ?
*/
-- Vista para ver los contenidos de un entrenamientos
CREATE VIEW vista_entrenamientos_contenidos AS
SELECT
    e.id_entrenamiento,
    e.id_equipo,
    e.fecha_entrenamiento,
    stc.sub_tema_contenido,
    CONCAT(tc.momento_juego, ' - ', stc.sub_tema_contenido) AS contenidos
FROM
    entrenamientos e
JOIN
    detalle_entrenamiento de ON e.id_entrenamiento = de.id_entrenamiento
JOIN
    detalles_contenidos dc ON de.id_detalle_contenido = dc.id_detalle_contenido
JOIN
    sub_temas_contenidos stc ON dc.id_sub_tema_contenido = stc.id_sub_tema_contenido
JOIN
    temas_contenidos tc ON stc.id_tema_contenido = tc.id_tema_contenido
GROUP BY
    e.id_entrenamiento, contenidos;

SELECT * FROM vista_entrenamientos_contenidos;
SELECT * FROM vista_entrenamientos_contenidos WHERE id_entrenamiento = 1;

-- vista para el titulo de entrenamientos
CREATE VIEW vista_jornadas AS
SELECT
    id_jornada,
    CONCAT(
        'Jornada del ',
        DATE_FORMAT(fecha_inicio_jornada, '%e de %M'),
        ' - ',
        DATE_FORMAT(fecha_fin_jornada, '%e de %M')
    ) AS titulo
FROM
    jornadas;

-- Vista para ver las categorias y los horarios de la tabla horarios_categorias
CREATE VIEW vista_entrenamientos_horario_categorias AS
SELECT
    e.id_horario_categoria AS id_categoria,
    CONCAT(dc.nombre_categoria, ' - ', de.nombre_horario) AS nombre_categoria
FROM
    horarios_categorias e
JOIN
    horarios de ON e.id_horario = de.id_horario
JOIN
    categorias dc ON e.id_categoria = dc.id_categoria;

-- -----------------------------------VISTA PARA CARACTERISTICAS ANALISIS -------------------------------------------------------------------------
DROP VIEW IF EXISTS vista_caracteristicas_analisis;

CREATE VIEW vista_caracteristicas_analisis AS
SELECT
    j.id_jugador AS IDJ,
    CONCAT(j.nombre_jugador, ' ', j.apellido_jugador) AS JUGADOR,
    CASE
        WHEN ca.nota_caracteristica_analisis IS NULL THEN 0
        ELSE ca.nota_caracteristica_analisis
    END AS NOTA,
    cj.id_caracteristica_jugador AS IDC,
    cj.nombre_caracteristica_jugador AS CARACTERISTICA,
    cj.clasificacion_caracteristica_jugador AS TIPO,
    COALESCE(ca.id_entrenamiento, a.id_entrenamiento) AS IDE,
    a.asistencia AS ASISTENCIA
FROM
    jugadores j
LEFT JOIN
    asistencias a ON j.id_jugador = a.id_jugador
LEFT JOIN
    caracteristicas_analisis ca ON j.id_jugador = ca.id_jugador AND a.id_entrenamiento = ca.id_entrenamiento
LEFT JOIN
    caracteristicas_jugadores cj ON ca.id_caracteristica_jugador = cj.id_caracteristica_jugador
WHERE
    a.asistencia = 'Asistencia';
SELECT * FROM asistencias WHERE id_entrenamiento = 23;
SELECT * FROM caracteristicas_analisis;
SELECT * FROM caracteristicas_jugadores;
SELECT IDJ ,JUGADOR, IDE,
        ROUND(AVG(NOTA), 2) AS PROMEDIO
        FROM vista_caracteristicas_analisis
        WHERE IDE = 23 GROUP BY IDJ, JUGADOR;

DROP PROCEDURE IF EXISTS insertarCaracteristicasYDetallesRemodelado;
DELIMITER $$

CREATE PROCEDURE insertarCaracteristicasYDetallesRemodelado(
    IN p_id_jugador INT UNSIGNED,
    IN p_id_entrenamiento INT UNSIGNED,
    IN p_id_caracteristica_jugador INT UNSIGNED,
    IN p_nota_caracteristica_analisis DECIMAL(5,3)
)
BEGIN
    DECLARE v_id_caracteristica_analisis BIGINT;

    -- Verificar si ya existe una fila en caracteristicas_analisis para el par (id_jugador, id_caracteristica_jugador, id_entrenamiento)
    SELECT id_caracteristica_analisis INTO v_id_caracteristica_analisis
    FROM caracteristicas_analisis
    WHERE id_jugador = p_id_jugador AND id_caracteristica_jugador = p_id_caracteristica_jugador AND id_entrenamiento = p_id_entrenamiento;

    IF v_id_caracteristica_analisis IS NOT NULL THEN
        -- Actualizar la fila existente en caracteristicas_analisis
        UPDATE caracteristicas_analisis
        SET nota_caracteristica_analisis = p_nota_caracteristica_analisis
        WHERE id_caracteristica_analisis = v_id_caracteristica_analisis;
    ELSE
        -- Insertar una nueva fila en caracteristicas_analisis
        INSERT INTO caracteristicas_analisis (nota_caracteristica_analisis, id_jugador, id_caracteristica_jugador, id_entrenamiento)
        VALUES (p_nota_caracteristica_analisis, p_id_jugador, p_id_caracteristica_jugador, p_id_entrenamiento);
    END IF;
END$$

DELIMITER ;

-- --------------------------------PROCEDIMIENTOS PARA EL DASHBOARD ----------------------------------------------------------------------------

-- PROCEDIMIENTO PARA SABER LOS RESULTADOS ESTADISTICOS DE UN EQUIPO
DELIMITER $$
CREATE PROCEDURE resultadosPartido(
    IN p_id_equipo INT
)
BEGIN
    SELECT
        SUM(CASE WHEN tipo_resultado_partido = 'Victoria' THEN 1 ELSE 0 END) AS victorias,
        SUM(CASE WHEN tipo_resultado_partido = 'Empate' THEN 1 ELSE 0 END) AS empates,
        SUM(CASE WHEN tipo_resultado_partido = 'Derrota' THEN 1 ELSE 0 END) AS derrotas,
        SUM(SUBSTRING_INDEX(resultado_partido, '-', 1)) AS golesAFavor,
        SUM(SUBSTRING_INDEX(resultado_partido, '-', -1)) AS golesEnContra,
        (SUM(SUBSTRING_INDEX(resultado_partido, '-', 1)) - SUM(SUBSTRING_INDEX(resultado_partido, '-', -1))) AS diferencia
    FROM partidos WHERE id_equipo = p_id_equipo;

END$$
DELIMITER ;


-- PROCEDIMIENTO PARA SACAR EL PROMEDIO PARA CADA AREA DE ENTRENAMIENTO DE UN EQUIPO
	DELIMITER $$
	CREATE PROCEDURE analisisEntrenamientos(
	    IN p_id_equipo INT
	)
	BEGIN
	    SELECT
	        pj.id_jugador,
	        pj.id_equipo,
	        cj.clasificacion_caracteristica_jugador AS caracteristica,
	        ROUND(AVG(C.nota_caracteristica_analisis), 2) AS promedio
	    FROM plantillas_equipos pj
	        INNER JOIN caracteristicas_analisis c ON pj.id_plantilla_equipo = c.id_jugador
	        INNER JOIN caracteristicas_jugadores cj ON c.id_caracteristica_jugador = cj.id_caracteristica_jugador
	    WHERE id_equipo = p_id_equipo GROUP BY cj.clasificacion_caracteristica_jugador;

	END$$
	DELIMITER ;

-- ----------------------------------------------------ASISTENCIAS PROCEDIMIENTOS Y VISTAS--------------------------------------------------------------------------

-- -Vista para saber si un regisro de id entrenamiento tiene asistencias o no, tambien entrega datos generales que la asistencia necesitará, como el id_horario
CREATE VIEW vista_asistencias_entrenamiento AS
SELECT
    e.id_entrenamiento,
    e.fecha_entrenamiento,
    h.id_horario,
    DATE_FORMAT(e.fecha_entrenamiento, '%e de %M del %Y') AS fecha_transformada,
    e.sesion,
    CASE
        WHEN COUNT(de.id_entrenamiento > 0) > 0 THEN 1
        ELSE 0
    END AS asistencia
FROM
    entrenamientos e
LEFT JOIN
    asistencias de ON e.id_entrenamiento = de.id_entrenamiento
INNER JOIN
	horarios_categorias h ON e.id_horario_categoria = h.id_horario_categoria
GROUP BY
    e.id_entrenamiento;

-- -Procedimiento para agregar o actualizar una asistencia
DELIMITER $$

CREATE PROCEDURE Asistencia(
    IN p_id_entrenamiento INT,
    IN p_id_jugador INT,
    IN p_id_horario INT,
    IN p_asistencia ENUM('Asistencia', 'Ausencia injustificada', 'Enfermedad', 'Estudio', 'Trabajo', 'Viaje', 'Permiso', 'Falta', 'Lesion', 'Otro'),
    IN p_observacion VARCHAR(2000),
    IN p_id_asistencia INT,
    IN p_asistencia_bool BOOL
)
BEGIN
    DECLARE v_id INT;
    DECLARE done INT DEFAULT 0;
    DECLARE v_id_asistencia INT;
    DECLARE v_exists INT;
    DECLARE v_exists2 INT;

    IF (p_asistencia_bool = 1) THEN
        -- Actualizar el registro
        UPDATE asistencias
        SET
            id_horario = p_id_horario,
            id_jugador = p_id_jugador,
            asistencia = p_asistencia,
            observacion_asistencia = p_observacion
        WHERE id_asistencia = p_id_asistencia;
    ELSE
        -- Insertar un nuevo registro
        INSERT INTO asistencias (id_jugador, id_horario, asistencia, observacion_asistencia, id_entrenamiento)
        VALUES (p_id_jugador, p_id_horario, p_asistencia, p_observacion, p_id_entrenamiento);

    END IF;
END$$

DELIMITER ;


-- ---Vista para ver las asistecias y los jugadores
-- -Vista cuando se sabe que existen registros en asistencias
-- Vista principal de asistencias
DROP VIEW IF EXISTS vista_asistencias;
CREATE VIEW vista_asistencias AS
SELECT DISTINCT
    CONCAT(j.nombre_jugador, ' ', j.apellido_jugador) AS jugador,
    pe.id_jugador AS id,
    a.id_entrenamiento,
    a.asistencia AS asistencia,
    a.observacion_asistencia AS observacion,
    a.id_asistencia AS id_asistencia
FROM
    asistencias a
JOIN
    plantillas_equipos pe ON a.id_jugador = pe.id_jugador
JOIN
    jugadores j ON pe.id_jugador = j.id_jugador;


-- Vista cuando se sabe que no hay registros
DROP VIEW IF EXISTS vista_asistencias_default;
CREATE VIEW vista_asistencias_default AS
SELECT DISTINCT
    CONCAT(j.nombre_jugador, ' ', j.apellido_jugador) AS jugador,
    j.id_jugador AS id,
    e.id_entrenamiento,
    'Asistencia' AS asistencia,
    NULL AS observacion,
    0 AS id_asistencia
FROM
    entrenamientos e
JOIN
    equipos eq ON e.id_equipo = eq.id_equipo
JOIN
    plantillas_equipos pe ON eq.id_equipo = pe.id_equipo
JOIN
    jugadores j ON pe.id_jugador = j.id_jugador
WHERE
    pe.id_equipo = e.id_equipo;



CREATE VIEW notas_por_jugador AS
    SELECT
        c.id_jugador,
        cj.clasificacion_caracteristica_jugador,
        ROUND(AVG(c.nota_caracteristica_analisis), 1) AS nota_por_area,
        c.id_caracteristica_jugador
FROM caracteristicas_analisis c
INNER JOIN caracteristicas_jugadores cj ON c.id_caracteristica_jugador = cj.id_caracteristica_jugador
GROUP BY c.id_jugador, cj.clasificacion_caracteristica_jugador;

CREATE VIEW vista_ultimos_entrenamientos AS
SELECT DISTINCT
    SUM(CASE WHEN a.asistencia = 'Asistencia' THEN 1 ELSE 0 END) AS asistencia,
    DATE_FORMAT(a.fecha_asistencia, '%e de %M') AS fecha,
    e.id_equipo
FROM asistencias a
INNER JOIN entrenamientos e ON a.id_entrenamiento = e.id_entrenamiento
GROUP BY a.fecha_asistencia, e.id_equipo;
SELECT asistencia, fecha FROM vista_ultimos_entrenamientos WHERE id_equipo = 1;


-- --------------------- Documentos técnicos -------------------------------------

DROP PROCEDURE IF EXISTS sp_insertar_documento_tecnico;
DELIMITER $$

CREATE PROCEDURE sp_insertar_documento_tecnico (
    IN p_nombre_archivo VARCHAR(50),
    IN p_id_tecnico INT,
    IN p_archivo_adjunto VARCHAR(50)
)
BEGIN
    DECLARE doc_count INT;

    -- Verificar si el nombre del archivo ya existe para el mismo técnico
    SELECT COUNT(*) INTO doc_count
    FROM documentos_tecnicos
    WHERE nombre_archivo = p_nombre_archivo
    AND id_tecnico = p_id_tecnico;

    -- Si existe un duplicado de nombre de archivo para el técnico, generar un error
    IF doc_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del archivo ya existe para este técnico';
    ELSE
        INSERT INTO documentos_tecnicos (nombre_archivo, id_tecnico, archivo_adjunto, fecha_registro)
        VALUES (p_nombre_archivo, p_id_tecnico, p_archivo_adjunto, NOW());
    END IF;
END $$

DELIMITER ;

DROP PROCEDURE IF EXISTS sp_actualizar_documento_tecnico;
DELIMITER $$

CREATE PROCEDURE sp_actualizar_documento_tecnico (
    IN p_id_documento INT,
    IN p_nombre_archivo VARCHAR(50),
    IN p_id_tecnico INT,
    IN p_archivo_adjunto VARCHAR(50)
)
BEGIN
    DECLARE doc_count INT;

    -- Verificar si el nombre del archivo ya existe para otro registro del mismo técnico
    SELECT COUNT(*) INTO doc_count
    FROM documentos_tecnicos
    WHERE nombre_archivo = p_nombre_archivo
    AND id_tecnico = p_id_tecnico
    AND id_documento != p_id_documento;

    -- Si existe un duplicado de nombre de archivo para el técnico, generar un error
    IF doc_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del archivo ya existe para este técnico';
    ELSE
        UPDATE documentos_tecnicos
        SET nombre_archivo = p_nombre_archivo,
            id_tecnico = p_id_tecnico,
            archivo_adjunto = p_archivo_adjunto,
            fecha_registro = NOW()
        WHERE id_documento = p_id_documento;
    END IF;
END $$

DELIMITER ;


DROP PROCEDURE IF EXISTS sp_eliminar_documento_tecnico;
DELIMITER $$

CREATE PROCEDURE sp_eliminar_documento_tecnico (
    IN p_id_documento INT
)
BEGIN
    DELETE FROM documentos_tecnicos
    WHERE id_documento = p_id_documento;
END $$

DELIMITER ;



DELIMITER $$

CREATE VIEW vista_documentos_tecnicos AS
SELECT
    id_documento AS 'ID',
    nombre_archivo AS 'NOMBRE',
    id_tecnico AS 'IDT',
    archivo_adjunto AS 'ARCHIVO',
    fecha_registro AS 'FECHA'
FROM documentos_tecnicos;
$$

DELIMITER ;

-- ------ Vista gráficos detalles contenidos ----------------
CREATE VIEW vista_grafico_contenidos_entrenamiento AS
SELECT
    id_entrenamiento,
    sub_tema_contenido,
    minutos_maximos_subtema
FROM (
    SELECT
        de.id_entrenamiento,
        stc.sub_tema_contenido,
        MAX(dc.minutos_contenido) OVER (PARTITION BY de.id_entrenamiento, dc.id_sub_tema_contenido) AS minutos_maximos_subtema,
        ROW_NUMBER() OVER (PARTITION BY de.id_entrenamiento, dc.id_sub_tema_contenido ORDER BY dc.minutos_contenido DESC) AS rn_subtema
    FROM
        detalle_entrenamiento de
    JOIN
        detalles_contenidos dc ON de.id_detalle_contenido = dc.id_detalle_contenido
    LEFT JOIN
        sub_temas_contenidos stc ON dc.id_sub_tema_contenido = stc.id_sub_tema_contenido
) AS subquery
WHERE rn_subtema = 1;


CREATE VIEW vista_grafico_tareas_entrenamiento AS
SELECT
    id_entrenamiento,
    nombre_tarea,
    minutos_maximos_tarea
FROM (
    SELECT
        de.id_entrenamiento,
        t.nombre_tarea,
        MAX(dc.minutos_tarea) OVER (PARTITION BY de.id_entrenamiento, dc.id_tarea) AS minutos_maximos_tarea,
        ROW_NUMBER() OVER (PARTITION BY de.id_entrenamiento, dc.id_tarea ORDER BY dc.minutos_tarea DESC) AS rn_tarea
    FROM
        detalle_entrenamiento de
    JOIN
        detalles_contenidos dc ON de.id_detalle_contenido = dc.id_detalle_contenido
    LEFT JOIN
        tareas t ON dc.id_tarea = t.id_tarea
) AS subquery
WHERE rn_tarea = 1;

-- Vista para reportes en participaciones partido
CREATE VIEW vista_reporte_participacion_partido AS
    SELECT
        p.id_participacion,
        j.nombre_jugador,
        j.apellido_jugador,
        p.id_partido,
        p.titular,
        p.sustitucion,
        p.minutos_jugados,
        p.goles,
        p.asistencias,
        p.estado_animo,
        p.puntuacion,
        po.posicion
FROM participaciones_partidos p
INNER JOIN jugadores j on p.id_jugador = j.id_jugador
INNER JOIN posiciones po on p.id_posicion = po.id_posicion;

CREATE VIEW proyectiva_registro_medico AS
    SELECT
    rm.dias_lesionado,
    rm.id_lesion,
    rm.fecha_lesion,
    DATEDIFF(rm.retorno_entreno, rm.fecha_lesion) AS dias_recuperacion,
    l.id_tipo_lesion,
    tl.tipo_lesion
    FROM registros_medicos rm
    INNER JOIN lesiones l on rm.id_lesion = l.id_lesion
    INNER JOIN tipos_lesiones tl on l.id_tipo_lesion = tl.id_tipo_lesion
    WHERE fecha_lesion IS NOT NULL;

DROP VIEW IF EXISTS vista_caracteristicas_analisis_2;
CREATE VIEW vista_caracteristicas_analisis_2 AS
SELECT 
    j.id_jugador AS IDJ,
    CONCAT(j.nombre_jugador, ' ', j.apellido_jugador) AS JUGADOR,
    CASE 
        WHEN ca.nota_caracteristica_analisis IS NULL THEN 0
        ELSE ca.nota_caracteristica_analisis
    END AS NOTA,
    cj.id_caracteristica_jugador AS IDC,
    cj.nombre_caracteristica_jugador AS CARACTERISTICA,
    cj.clasificacion_caracteristica_jugador AS TIPO,
    COALESCE(ca.id_entrenamiento, a.id_entrenamiento) AS IDE,
    a.asistencia AS ASISTENCIA,
    en.fecha_entrenamiento,
    en.id_equipo
FROM 
    jugadores j
LEFT JOIN 
    asistencias a ON j.id_jugador = a.id_jugador
LEFT JOIN
	entrenamientos en ON a.id_entrenamiento = en.id_entrenamiento
LEFT JOIN 
    caracteristicas_analisis ca ON j.id_jugador = ca.id_jugador AND a.id_entrenamiento = ca.id_entrenamiento
LEFT JOIN 
    caracteristicas_jugadores cj ON ca.id_caracteristica_jugador = cj.id_caracteristica_jugador
WHERE
    a.asistencia = 'Asistencia';
SELECT * FROM proyectiva_registro_medico;

CREATE VIEW delantero_asistencias_evaluaciones AS
SELECT
    p.id_partido,
    p.id_equipo,
    j.id_jugador,
    j.nombre_jugador,
    COUNT(DISTINCT a.id_asistencia) AS frecuencia,
    MAX(a.fecha_asistencia) AS fecha,
    ROUND(AVG(
        CASE
            WHEN ca.nota_caracteristica_analisis IS NULL THEN 0
            ELSE ca.nota_caracteristica_analisis
        END
    ), 2) AS promedio
FROM
    partidos p
JOIN
    equipos eq ON eq.id_equipo = p.id_equipo
JOIN
    plantillas_equipos pq ON pq.id_equipo = eq.id_equipo
JOIN
    jugadores j ON j.id_jugador = pq.id_jugador
JOIN
    posiciones ps ON ps.id_posicion = j.id_posicion_principal
    AND ps.area_de_juego = 'Ofensiva'
JOIN
    asistencias a ON a.id_jugador = j.id_jugador
LEFT JOIN
    caracteristicas_analisis ca ON j.id_jugador = ca.id_jugador
    AND a.id_entrenamiento = ca.id_entrenamiento
WHERE
    a.fecha_asistencia >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
GROUP BY
    p.id_partido, p.id_equipo, j.id_jugador
HAVING
    promedio > 0;

DROP VIEW IF EXISTS vista_caracteristicas_analisis_2;
CREATE VIEW vista_caracteristicas_analisis_2 AS
SELECT
    j.id_jugador AS IDJ,
    CONCAT(j.nombre_jugador, ' ', j.apellido_jugador) AS JUGADOR,
    CASE
        WHEN ca.nota_caracteristica_analisis IS NULL THEN 0
        ELSE ca.nota_caracteristica_analisis
    END AS NOTA,
    cj.id_caracteristica_jugador AS IDC,
    cj.nombre_caracteristica_jugador AS CARACTERISTICA,
    cj.clasificacion_caracteristica_jugador AS TIPO,
    COALESCE(ca.id_entrenamiento, a.id_entrenamiento) AS IDE,
    a.asistencia AS ASISTENCIA,
    en.fecha_entrenamiento
FROM
    jugadores j
LEFT JOIN
    asistencias a ON j.id_jugador = a.id_jugador
LEFT JOIN
	entrenamientos en ON a.id_entrenamiento = en.id_entrenamiento
LEFT JOIN
    caracteristicas_analisis ca ON j.id_jugador = ca.id_jugador AND a.id_entrenamiento = ca.id_entrenamiento
LEFT JOIN
    caracteristicas_jugadores cj ON ca.id_caracteristica_jugador = cj.id_caracteristica_jugador
WHERE
    a.asistencia = 'Asistencia';

-- --------------------------------------Vistas para reporte predictivo "PROXIMO PARTIDO"--------------------------------------
-- 1. Marcador de los últimos partidos del rival en este estilo: [1-0]
SELECT resultado_partido FROM partidos WHERE id_rival = 1 AND tipo_resultado_partido <> 'Pendiente';
-- 2. Marcador de victorias o derrotas {[victoria, local], [empate, visitante], [derrota, local]} y si eran local o visitante
SELECT CONCAT(localidad_partido, ', ', tipo_resultado_partido) AS resultado FROM partidos WHERE id_rival = 1;
-- 3. Marcador de los últimos partidos del equipo gol en este estilo [1,0]
SELECT resultado_partido FROM partidos WHERE id_equipo = 1 AND tipo_resultado_partido <> 'Pendiente';
-- 4. Marcador de victorias o derrotas {[victoria, local], [empate, visitante], [derrota, local]} y si eran local o visitante
SELECT CONCAT(localidad_partido, ', ', tipo_resultado_partido) AS resultado FROM partidos WHERE id_equipo = 1;
-- 5. Contenidos vistos en el último 2 mes, nombre del contenido y frecuencia
SELECT sub_tema_contenido, id_equipo, COUNT(sub_tema_contenido) AS frecuencia FROM vista_entrenamientos_contenidos
WHERE id_equipo = 1 AND fecha_entrenamiento >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH) GROUP BY sub_tema_contenido;
-- 6. Cantidad de entrenamientos en el 2 mes
SELECT COUNT(id_entrenamiento) AS frecuencia_entrenamientos FROM entrenamientos WHERE id_equipo = 1 AND fecha_entrenamiento >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH);
-- 7. Logo, nombre del equipo y lo mismo del rival
SELECT logo_rival, nombre_rival, logo_equipo, logo_rival, id_rival, id_equipo, localidad_partido FROM vista_detalle_partidos WHERE id_partido = 1;
-- 8. Nota pruebas promedio en cada area en el 2 último mes
-- SELECT IDJ, JUGADOR, ROUND(AVG(NOTA), 2) AS PROMEDIO, fecha_entrenamiento FROM vista_caracteristicas_analisis_2
-- WHERE fecha_entrenamiento >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH) AND id_equipo = 2 GROUP BY IDJ, JUGADOR
-- HAVING PROMEDIO > 0;
-- 9. Nota de la última evaluación de los delanteros (sum), cantidad de asistencias de los últimos 2 meses (count)

-- ------ Vista para gráfica predictiva de progresión
DROP VIEW IF EXISTS vista_predictiva_progresion;
CREATE VIEW vista_predictiva_progresion AS
SELECT DISTINCT
    j.id_jugador AS IDJ,
    CONCAT(j.nombre_jugador, ' ', j.apellido_jugador) AS JUGADOR,
    ca.nota_caracteristica_analisis AS NOTA,
    cj.id_caracteristica_jugador AS IDC,
    cj.nombre_caracteristica_jugador AS CARACTERISTICA,
    cj.clasificacion_caracteristica_jugador AS TIPO,
    COALESCE(ca.id_entrenamiento, a.id_entrenamiento) AS IDE,
    e.fecha_entrenamiento AS FECHA,
    a.asistencia AS ASISTENCIA
FROM 
    jugadores j
LEFT JOIN 
    asistencias a ON j.id_jugador = a.id_jugador
LEFT JOIN 
    entrenamientos e ON e.id_entrenamiento = a.id_entrenamiento
LEFT JOIN 
    caracteristicas_analisis ca ON j.id_jugador = ca.id_jugador AND a.id_entrenamiento = ca.id_entrenamiento
LEFT JOIN 
    caracteristicas_jugadores cj ON ca.id_caracteristica_jugador = cj.id_caracteristica_jugador
WHERE
    a.asistencia = 'Asistencia'
    AND ca.nota_caracteristica_analisis IS NOT NULL;
    
    
SELECT id_asistencia, observacion, asistencia, id, jugador, id_entrenamiento 
        FROM vista_asistencias WHERE id_entrenamiento = 25;
SELECT id_sub_tema_contenido, sub_tema_contenido
                    FROM sub_temas_contenidos;

-- Vista para elegir contenidos por el tipo de cancha
DROP VIEW IF EXISTS subcontenidos_por_cancha;
CREATE VIEW subcontenidos_por_cancha AS
SELECT 
	sbc.id_sub_tema_contenido, 
	CONCAT(sbc.sub_tema_contenido, ' - ', tc.momento_juego) AS sub_tema_contenido,
	tc.zona_campo
FROM sub_temas_contenidos sbc
INNER JOIN
	temas_contenidos tc ON sbc.id_tema_contenido = tc.id_tema_contenido;
	
SELECT id_sub_tema_contenido, sub_tema_contenido FROM	subcontenidos_por_cancha WHERE zona_campo = 'Zona 3';
SELECT stc.*, tc.momento_juego
                FROM sub_temas_contenidos stc
                INNER JOIN temas_contenidos tc ON stc.id_tema_contenido = tc.id_tema_contenido;


-- ----------- CONVOCATORIAS ---------------------
DROP PROCEDURE IF EXISTS guardar_convocatoria;
DELIMITER $$

CREATE PROCEDURE guardar_convocatoria(
    IN p_id_partido INT UNSIGNED,
    IN p_id_jugador INT UNSIGNED,
    IN p_estado_convocado BOOLEAN
)
BEGIN
    DECLARE v_id_convocatoria BIGINT;

    -- Verificar si ya existe una fila en convocatorias_partidos para el par (id_partido, id_jugador)
    SELECT id_convocatoria INTO v_id_convocatoria
    FROM convocatorias_partidos
    WHERE id_partido = p_id_partido AND id_jugador = p_id_jugador;

    IF v_id_convocatoria IS NOT NULL THEN
        -- Actualizar la fila existente en convocatorias_partidos
        UPDATE convocatorias_partidos
        SET id_partido = p_id_partido, id_jugador = p_id_jugador, estado_convocado = p_estado_convocado
        WHERE id_convocatoria = v_id_convocatoria;
    ELSE
        -- Insertar una nueva fila en convocatorias_partidos
        INSERT INTO convocatorias_partidos (id_partido, id_jugador, estado_convocado)
        VALUES (p_id_partido, p_id_jugador, p_estado_convocado);
    END IF;
END$$

DELIMITER ;


DROP VIEW IF EXISTS vista_maximos_goleadores;
CREATE VIEW vista_maximos_goleadores AS
SELECT pj.id_jugador AS IDJ, pj.id_equipo AS IDE,
CONCAT(j.nombre_jugador, " ", j.apellido_jugador) AS JUGADOR,
po.posicion AS POSICION, j.foto_jugador AS FOTO,
COALESCE(SUM(goles), 0) AS TOTAL_GOLES
FROM plantillas_equipos pj
INNER JOIN participaciones_partidos p ON p.id_jugador = pj.id_jugador
INNER JOIN jugadores j ON p.id_jugador = j.id_jugador
INNER JOIN posiciones po ON j.id_posicion_principal = po.id_posicion
GROUP BY JUGADOR ORDER BY TOTAL_GOLES DESC;

DROP VIEW IF EXISTS vista_maximos_asistentes;
CREATE VIEW vista_maximos_asistentes AS
SELECT pj.id_jugador AS IDJ, pj.id_equipo AS IDE,
CONCAT(j.nombre_jugador, " ", j.apellido_jugador) AS JUGADOR,
po.posicion AS POSICION, j.foto_jugador AS FOTO,
COALESCE(SUM(asistencias), 0) AS TOTAL_ASISTENCIAS
FROM plantillas_equipos pj
INNER JOIN participaciones_partidos p ON p.id_jugador = pj.id_jugador
INNER JOIN jugadores j ON p.id_jugador = j.id_jugador
INNER JOIN posiciones po ON j.id_posicion_principal = po.id_posicion
GROUP BY JUGADOR ORDER BY TOTAL_ASISTENCIAS DESC;

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

-- INSERT

INSERT INTO administradores (nombre_administrador, apellido_administrador, clave_administrador, correo_administrador, telefono_administrador, dui_administrador, fecha_nacimiento_administrador, alias_administrador, foto_administrador)
	VALUES 
	('Joel', 'Mena', '$2y$10$Lq7h.aAUL.UMVBB1BE7dB.GBYm5EfF1v2TOLcxBBU0e83CRPV68aC', 'carlos.martinez@example.com', '12345678', '12345678-9', '1980-05-15', 'JoMe20241', 'default.png'),
	('María', 'Gómez', '$2y$10$Lq7h.aAUL.UMVBB1BE7dB.GBYm5EfF1v2TOLcxBBU0e83CRPV68aC', 'maria.gomez@example.com', '87654321', '98765432-1', '1985-07-20', 'MGomez', 'default.png'),
	('Juan', 'Pérez', '$2y$10$Lq7h.aAUL.UMVBB1BE7dB.GBYm5EfF1v2TOLcxBBU0e83CRPV68aC', 'juan.perez@example.com', '12344321', '12349876-5', '1990-09-25', 'JPerez', 'default.png'),
	('Ana', 'Hernández', '$2y$10$Lq7h.aAUL.UMVBB1BE7dB.GBYm5EfF1v2TOLcxBBU0e83CRPV68aC', 'ana.hernandez@example.com', '87651234', '54321234-7', '1992-11-30', 'AHernandez', 'default.png'),
	('Luis', 'Fernández', '$2y$10$Lq7h.aAUL.UMVBB1BE7dB.GBYm5EfF1v2TOLcxBBU0e83CRPV68aC', 'luis.fernandez@example.com', '43211234', '65432123-8', '1988-02-14', 'LFernandez', 'default.png');
    
INSERT INTO tecnicos (nombre_tecnico, apellido_tecnico, alias_tecnico, clave_tecnico, correo_tecnico, telefono_tecnico, dui_tecnico, fecha_nacimiento_tecnico, foto_tecnico)
	VALUES
	('Pedro', 'López', 'PLopez', 'tecnico123', 'pedro.lopez@example.com', '22334455', '12345678-0', '1982-03-10', 'default.png'),
	('Laura', 'Ramírez', 'LRamirez', 'tecnico456', 'laura.ramirez@example.com', '55443322', '98765432-1', '1986-08-05', 'default.png'),
	('Santiago', 'Morales', 'SMorales', 'tecnico789', 'santiago.morales@example.com', '66778899', '23456789-0', '1990-12-12', 'default.png'),
	('Claudia', 'Vargas', 'CVargas', 'tecnico321', 'claudia.vargas@example.com', '11223344', '54321234-5', '1994-05-28', 'default.png'),
	('Miguel', 'Méndez', 'MMendez', 'tecnico654', 'miguel.mendez@example.com', '44332211', '65432123-6', '1987-09-16', 'default.png');
    
INSERT INTO documentos_tecnicos (nombre_archivo, id_tecnico, archivo_adjunto)
	VALUES 
    ('Informe de mantenimiento', 1, 'default.png'),
	('Manual de operaciones', 2, 'default.png'),
	('Informe de instalación', 3, 'default.png'),
	('Checklist de seguridad', 4, 'default.png'),
	('Reporte de fallas', 5, 'default.png');

INSERT INTO temporadas (nombre_temporada)
	VALUES
	('Temporada 2023'),
	('Temporada 2024'),
	('Temporada 2022'),
	('Temporada 2020'),
	('Temporada 2021');
    
INSERT INTO horarios (nombre_horario, dia, hora_inicial, hora_final, campo_de_entrenamiento)
	VALUES 
	('Horario Matutino', 'Lunes', '08:00:00', '12:00:00', 'Campo A'),
	('Horario Vespertino', 'Martes', '13:00:00', '17:00:00', 'Campo B'),
	('Horario Nocturno', 'Miércoles', '18:00:00', '22:00:00', 'Campo C'),
	('Horario Especial', 'Jueves', '10:00:00', '14:00:00', 'Campo D'),
	('Horario de Fin de Semana', 'Sábado', '09:00:00', '13:00:00', 'Campo E');
    
INSERT INTO categorias (nombre_categoria, edad_minima_permitida, edad_maxima_permitida)
	VALUES
	('Infantil', 5, 12),
	('Juvenil', 13, 17),
	('Adulto', 18, 35),
	('Senior', 36, 50),
	('Veterano', 51, 65);
    
INSERT INTO horarios_categorias (id_categoria, id_horario)
	VALUES 
	(1, 1),
	(2, 2),
	(3, 3),
	(4, 4),
	(5, 5);


INSERT INTO rol_tecnico (nombre_rol_tecnico)
	VALUES
	('Entrenador Principal'),
	('Asistente Técnico'),
	('Fisioterapeuta'),
	('Preparador Físico'),
	('Médico del Equipo');
    
INSERT INTO cuerpos_tecnicos (nombre_cuerpo_tecnico)
	VALUES 
    ('Cuerpo Técnico Sub-18'),
	('Cuerpo Técnico Femenino'),
	('Cuerpo Técnico Senior'),
	('Cuerpo Técnico Juvenil'),
	('Cuerpo Técnico Veteranos');
    
INSERT INTO detalles_cuerpos_tecnicos (id_cuerpo_tecnico, id_tecnico, id_rol_tecnico)
	VALUES 
	(1, 1, 1),
	(2, 2, 2),
	(3, 3, 3),
	(4, 4, 4),
	(5, 5, 5);
    
INSERT INTO equipos (nombre_equipo, genero_equipo, telefono_contacto, id_cuerpo_tecnico, id_categoria, logo_equipo)
	VALUES 
	('Tiburones', 'Masculino', '1234567890', 1, 1, 'default.png'),
	('Águilas', 'Femenino', '0987654321', 2, 2, 'default.png'),
	('Leones', 'Masculino', '1122334455', 3, 3, 'default.png'),
	('Panteras', 'Femenino', '5544332211', 4, 4, 'default.png'),
	('Dragones', 'Masculino', '6677889900', 5, 5, 'default.png');
    
INSERT INTO posiciones (posicion, area_de_juego)
	VALUES 
	('Delantero', 'Ofensiva'),
	('Defensa Central', 'Defensiva'),
	('Lateral Derecho', 'Defensiva'),
	('Centrocampista', 'Ofensiva y defensiva'),
	('Portero', 'Defensiva');
    
INSERT INTO jugadores (dorsal_jugador, nombre_jugador, apellido_jugador, estatus_jugador, fecha_nacimiento_jugador, genero_jugador, perfil_jugador, becado, id_posicion_principal,id_posicion_secundaria, alias_jugador, clave_jugador, foto_jugador, telefono, telefono_de_emergencia, observacion_medica, tipo_sangre, correo_jugador)
	VALUES 
	(10, 'Juan', 'Pérez', 'Activo', '1998-05-12', 'Masculino', 'Diestro', 'Beca completa', 1, 2, 'Juampi', 'clave123', 'default.png', '1234-5678', '8765-4321', 'Ninguna', 'O+', 'juan.perez@gmail.com'),
	(7, 'Carlos', 'Martínez', 'Baja temporal', '1995-03-22', 'Masculino', 'Zurdo', 'Media beca', 2, 1, 'Carlitos', 'clave456', 'default.png', '1234-8765', '4321-5678', 'Asma', 'A+', 'carlos.martinez@gmail.com'),
	(15, 'Luis', 'Gómez', 'Activo', '2001-12-30', 'Masculino', 'Ambidiestro', 'Ninguna', 3, 2,'Luigi', 'clave789', 'default.png', '5678-1234', '8765-4321', 'Diabetes tipo 2', 'B+', 'luis.gomez@gmail.com'),
	(23, 'Ana', 'López', 'Baja definitiva', '1997-08-15', 'Femenino', 'Zurdo', 'Beca completa', 4, 3, 'Anita', 'clave012', 'default.png', '8765-1234', '1234-8765', 'Ninguna', 'AB+', 'ana.lopez@gmail.com'),
	(18, 'María', 'Ramírez', 'Activo', '2000-04-25', 'Femenino', 'Diestro', 'Ninguna', 5, 4, 'Mari', 'clave345', 'default.png', '2345-6789', '6789-2345', 'Fractura reciente', 'O-', 'maria.ramirez@gmail.com');
    
INSERT INTO estados_fisicos_jugadores (id_jugador, altura_jugador, peso_jugador, indice_masa_corporal)
	VALUES 
	(1, 1.75, 70.5, 23.1),
	(2, 1.80, 78.0, 24.1),
	(3, 1.67, 60.0, 21.5),
	(4, 1.62, 55.5, 21.1),
	(5, 1.70, 65.0, 22.5);
    
INSERT INTO plantillas (nombre_plantilla)
	VALUES 
	('Plantilla Sub-18'),
	('Plantilla Femenina'),
	('Plantilla Senior'),
	('Plantilla Juvenil'),
	('Plantilla Veteranos');
    
INSERT INTO plantillas_equipos (id_plantilla, id_jugador, id_temporada, id_equipo)
	VALUES 
	(1, 1, 1, 1),
	(2, 2, 2, 2),
	(3, 3, 3, 3),
	(4, 4, 4, 4),
	(5, 5, 5, 5);

INSERT INTO jornadas (nombre_jornada, numero_jornada, id_plantilla, fecha_inicio_jornada, fecha_fin_jornada)
	VALUES 
	('Jornada 1', 1, 1, '2024-09-01', '2024-09-02'),
	('Jornada 2', 2, 2, '2024-09-03', '2024-09-04'),
	('Jornada 3', 3, 3, '2024-09-05', '2024-09-06'),
	('Jornada 4', 4, 4, '2024-09-07', '2024-09-08'),
	('Jornada 5', 5, 5, '2024-09-09', '2024-09-10');
    
INSERT INTO entrenamientos (fecha_entrenamiento, sesion, id_jornada, id_equipo, id_horario_categoria)
	VALUES 
	('2024-09-01', 'Sesion 1', 1, 1, 1),
	('2024-09-02', 'Sesion 2', 2, 2, 2),
	('2024-09-03', 'Sesion 3', 3, 3, 3),
	('2024-09-04', 'Sesion 1', 4, 4, 4),
	('2024-09-05', 'Sesion 2', 5, 5, 5);
    
INSERT INTO caracteristicas_jugadores (nombre_caracteristica_jugador, clasificacion_caracteristica_jugador)
	VALUES 
	('Habilidad en regate', 'Técnicos'),
	('Visión de juego', 'Tácticos'),
	('Resiliencia mental', 'Psicológicos'),
	('Velocidad', 'Físicos'),
	('Precisión en el pase', 'Técnicos');

INSERT INTO caracteristicas_analisis (nota_caracteristica_analisis, id_jugador, id_caracteristica_jugador, id_entrenamiento)
	VALUES 
	(8.500, 1, 1, 1),
	(7.250, 2, 2, 2),
	(9.000, 3, 3, 3),
	(6.750, 4, 4, 4),
	(8.000, 5, 5, 5);
    
INSERT INTO asistencias (id_jugador, id_horario, asistencia, id_entrenamiento)
	VALUES 
	(1, 1, 'Asistencia', 1),
	(2, 2, 'Ausencia injustificada', 2),
	(3, 3, 'Enfermedad', 3),
	(4, 4, 'Estudio', 4),
	(5, 5, 'Trabajo', 5);
    
INSERT INTO temas_contenidos (momento_juego, zona_campo)
	VALUES 
	('Ofensivo', 'Zona 1'),
	('Defensivo', 'Zona 2'),
	('Transición defensiva', 'Zona 3'),
	('Balón parado ofensivo', 'Zona 1'),
	('Balón parado defensivo', 'Zona 2');
    
INSERT INTO sub_temas_contenidos (sub_tema_contenido, id_tema_contenido)
	VALUES 
	('Control del balón', 1),
	('Marcaje en zona', 2),
	('Presión alta', 3),
	('Juego de pases', 4),
	('Cobertura defensiva', 5);

INSERT INTO tareas (nombre_tarea)
	VALUES 
	('Preparación física'),
	('Análisis táctico'),
	('Revisión de técnica'),
	('Entrenamiento de resistencia'),
	('Estudio de videos');
    
INSERT INTO detalles_contenidos (id_tarea, id_sub_tema_contenido, minutos_contenido, minutos_tarea)
	VALUES 
	(1, 1, 30, 60),
	(2, 2, 45, 90),
	(3, 3, 60, 120),
	(4, 4, 40, 80),
	(5, 5, 25, 50);

INSERT INTO detalle_entrenamiento (id_entrenamiento, id_detalle_contenido, id_jugador)
	VALUES 
	(1, 1, 1),
	(2, 2, 2),
	(3, 3, 3),
	(4, 4, 4),
	(5, 5, 5);
    
INSERT INTO rivales (nombre_rival, logo_rival)
	VALUES 
	('Rival 1', 'default.png'),
	('Rival 2', 'default.png'),
	('Rival 3', 'default.png'),
	('Rival 4', 'default.png'),
	('Rival 5', 'default.png');
    
INSERT INTO partidos (id_jornada, id_equipo, fecha_partido, cancha_partido, resultado_partido, localidad_partido, tipo_resultado_partido, id_rival)
	VALUES 
	(1, 1, '2024-09-15 18:00:00', 'Estadio Principal', '2-1', 'Local', 'Victoria', 1),
	(2, 2, '2024-09-20 20:00:00', 'Estadio Secundario', '1-1', 'Visitante', 'Empate', 2),
	(3, 3, '2024-09-25 17:00:00', 'Estadio Tercero', '0-3', 'Local', 'Derrota', 3),
	(4, 4, '2024-09-30 19:00:00', 'Estadio Principal', '4-0', 'Local', 'Victoria', 4),
	(5, 5, '2024-10-05 16:00:00', 'Estadio Secundario', '2-2', 'Visitante', 'Empate', 5);
    
INSERT INTO convocatorias_partidos (id_partido, id_jugador, estado_convocado)
	VALUES
	(1, 1, 1),
	(2, 2, 0),
	(3, 3, 1),
	(4, 4, 1),
	(5, 5, 0);
    
INSERT INTO tipos_jugadas (nombre_tipo_juego)
	VALUES 
	('Tiro libre'),
	('Corner'),
	('Penal'),
	('Falta'),
	('Saque de banda');

INSERT INTO tipos_goles (id_tipo_jugada, nombre_tipo_gol)
	VALUES 
	(1, 'Tiro libre directo'),
	(2, 'Gol de corner'),
	(3, 'Penal'),
	(4, 'Remate de cabeza'),
	(5, 'Autogol');
    
INSERT INTO participaciones_partidos (id_partido, id_jugador, id_posicion, titular, sustitucion, minutos_jugados, goles, asistencias, estado_animo, puntuacion)
	VALUES 
	(1, 1, 1, 1, 0, 90, 2, 1, 'Energetico', 8.5),
	(2, 2, 2, 0, 1, 45, 1, 0, 'Normal', 7.0),
	(3, 3, 3, 1, 0, 80, 0, 2, 'Satisfecho', 7.5),
	(4, 4, 4, 1, 0, 90, 0, 0, 'Agotado', 6.0),
	(5, 5, 5, 0, 1, 30, 1, 1, 'Normal', 7.8);

INSERT INTO detalles_goles (id_participacion, cantidad_tipo_gol, id_tipo_gol)
	VALUES 
	(1, 2, 1),
	(2, 1, 3),
	(3, 0, 4),
	(4, 0, 2),
	(5, 1, 5);
    
INSERT INTO detalles_amonestaciones (id_participacion, amonestacion, numero_amonestacion)
	VALUES 
	(1, 'Tarjeta amarilla', 1),
	(2, 'Tarjeta roja', 1),
	(3, 'Ninguna', 0),
	(4, 'Tarjeta amarilla', 2),
	(5, 'Ninguna', 0);

INSERT INTO tipos_lesiones (tipo_lesion)
	VALUES 
	('Distensión muscular'),
	('Fractura ósea'),
	('Desgarro ligamentoso'),
	('Luxación articular'),
	('Contusión');
    
INSERT INTO tipologias (tipologia)
	VALUES 
	('Defensor central'),
	('Delantero centro'),
	('Mediocampista ofensivo'),
	('Lateral derecho'),
	('Portero');

INSERT INTO sub_tipologias (nombre_sub_tipologia, id_tipologia)
	VALUES 
	('Defensa central derecho', 1),
	('Defensa central izquierdo', 1),
	('Delantero por derecha', 2),
	('Delantero por izquierda', 2),
	('Portero suplente', 5);
    
INSERT INTO lesiones (id_tipo_lesion, id_sub_tipologia, total_por_lesion, porcentaje_por_lesion)
	VALUES 
	(1, 1, 3, 20),
	(2, 2, 1, 5),
	(3, 3, 2, 10),
	(4, 4, 1, 8),
	(5, 5, 0, 0);

INSERT INTO registros_medicos (id_jugador, fecha_lesion, dias_lesionado, id_lesion, retorno_entreno, retorno_partido)
	VALUES 
	(1, '2024-07-01', 15, 1, '2024-07-16', NULL),
	(2, '2024-07-05', 30, 2, '2024-08-05', NULL),
	(3, '2024-06-15', 10, 3, '2024-06-25', 1),
	(4, '2024-08-01', 20, 4, '2024-08-21', 2),
	(5, '2024-07-10', 5, 5, '2024-07-15', NULL);
    
INSERT INTO pagos (fecha_pago, cantidad_pago, pago_tardio, mora_pago, mes_pago, id_jugador)
	VALUES 
	('2024-07-01', 100.00, 0, 0, 'Julio', 1),
	('2024-07-05', 90.00, 1, 10.00, 'Julio', 2),
	('2024-06-15', 100.00, 0, 0, 'Junio', 3),
	('2024-08-01', 85.00, 1, 15.00, 'Agosto', 4),
	('2024-07-10', 100.00, 0, 0, 'Julio', 5);

INSERT INTO calendario (titulo, fecha_inicio, fecha_final, color)
	VALUES 
	('Entrenamiento físico', '2024-09-01 08:00:00', '2024-09-01 10:00:00', 'blue'),
	('Partido amistoso', '2024-09-05 16:00:00', '2024-09-05 18:00:00', 'red'),
	('Reunión técnica', '2024-09-03 14:00:00', '2024-09-03 15:00:00', 'green'),
	('Entrenamiento táctico', '2024-09-07 08:00:00', '2024-09-07 10:00:00', 'yellow'),
	('Partido oficial', '2024-09-10 18:00:00', '2024-09-10 20:00:00', 'red');



