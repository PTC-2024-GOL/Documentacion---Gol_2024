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

ALTER TABLE administradores
ADD COLUMN codigo_autenticacion VARCHAR(100);

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

ALTER TABLE administradores
MODIFY dui_administrador VARCHAR(10) NOT NULL;

ALTER TABLE tecnicos
MODIFY dui_tecnico VARCHAR(10) NOT NULL;


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
  CONSTRAINT uq_nombre_equipo UNIQUE(nombre_equipo),
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

ALTER TABLE tipos_goles
ADD CONSTRAINT uq_nombre_tipo_gol UNIQUE(nombre_tipo_gol);

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

ALTER TABLE lesiones
    ADD CONSTRAINT u_sub_tipologia UNIQUE(id_sub_tipologia);

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


-- TABLAS NUEVAS DE CORRECCIONES DE REUNIÓN DEL 12/09/2024
CREATE TABLE palmares(
id_palmares INT AUTO_INCREMENT PRIMARY KEY,
id_equipo INT NOT NULL,
CONSTRAINT fk_equipo_palmares FOREIGN KEY (id_equipo) REFERENCES equipos(id_equipo),
id_temporada INT NOT NULL,
CONSTRAINT fk_temporada_palmares FOREIGN KEY (id_temporada) REFERENCES temporadas(id_temporada), 
lugar ENUM('Campeón', 'Subcampeón', 'Tercer lugar') NOT NULL
);

-- Por si no entienden porque le puse así a la tabla: La real academia española 
-- define la palabra "palmares" de las siguientes dos maneras: 
-- 1. Lista de vencedores en una competición.
-- 2. Historial, relación de méritos, especialmente de deportistas.
CREATE TABLE test(
id_test BIGINT AUTO_INCREMENT PRIMARY KEY,
id_jugador INT NOT NULL,
fecha DATE NOT NULL,
contestado BOOLEAN DEFAULT 0,
CONSTRAINT fk_jugador_test FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador),
id_partido INT NULL,
CONSTRAINT fk_partido_test FOREIGN KEY (id_partido) REFERENCES partidos(id_partido),
id_entrenamiento BIGINT NULL,
CONSTRAINT fk_entrenamientos_test FOREIGN KEY (id_entrenamiento) REFERENCES entrenamientos(id_entrenamiento)
);

CREATE TABLE respuesta_test(
id_respuesta BIGINT AUTO_INCREMENT PRIMARY KEY,
pregunta VARCHAR(2000) NOT NULL,
respuesta INT NOT NULL,
id_test BIGINT NOT NULL,
CONSTRAINT fk_test_respuesta FOREIGN KEY (id_test) REFERENCES test(id_test)
);


CREATE TABLE notificaciones (
id_notificacion BIGINT AUTO_INCREMENT PRIMARY KEY,
titulo VARCHAR(200) NOT NULL,
mensaje TEXT NOT NULL,
fecha_notificacion DATETIME NOT NULL DEFAULT NOW(),
tipo_notificacion ENUM('Registro medico', 'Test', 'Entrenamiento', 'Eventos', 'Partido'),
id_jugador INT NOT NULL,
CONSTRAINT fk_jugador_notificacion FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador),
visto BOOLEAN NULL DEFAULT 0,
evento INT NULL
);

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
	DECLARE nombre_count INT;

    -- Verificar si el nombre ya existe
    SELECT COUNT(*) INTO nombre_count
    FROM caracteristicas_jugadores
    WHERE nombre_caracteristica_jugador = p_nombre_caracteristica;
    
     -- Si existe un duplicado, generar un error
    IF nombre_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'nombre de la caraterística ya existe';
    ELSE
    INSERT INTO caracteristicas_jugadores (nombre_caracteristica_jugador, clasificacion_caracteristica_jugador)
    VALUES (p_nombre_caracteristica, p_clasificacion);
    END IF;
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
	DECLARE nombre_count INT;

    -- Verificar si el nombre ya existe
	SELECT COUNT(*) INTO nombre_count
	FROM caracteristicas_jugadores
	WHERE nombre_caracteristica_jugador = p_nuevo_nombre
	AND id_caracteristica_jugador <> p_id_caracteristica;
	IF nombre_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'nombre de la caraterística ya existe';
    ELSE
    UPDATE caracteristicas_jugadores
    SET nombre_caracteristica_jugador = p_nuevo_nombre,
        clasificacion_caracteristica_jugador = p_nueva_clasificacion
    WHERE id_caracteristica_jugador = p_id_caracteristica;
    END IF;
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
    DECLARE nombre_count INT;

    -- Verificar si el nombre ya existe
    SELECT COUNT(*) INTO nombre_count
    FROM cuerpos_tecnicos
    WHERE nombre_cuerpo_tecnico = p_nombre_cuerpo_tecnico;

    -- Si existe un duplicado, generar un error
    IF nombre_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'nombre del cuerpo técnico ya existe';
    ELSE
        INSERT INTO cuerpos_tecnicos (nombre_cuerpo_tecnico)
        VALUES (p_nombre_cuerpo_tecnico);
    END IF;
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
	DECLARE nombre_count INT;

    -- Verificar si el nombre ya existe
    SELECT COUNT(*) INTO nombre_count
	FROM cuerpos_tecnicos
	WHERE nombre_cuerpo_tecnico = p_nuevo_nombre
	AND id_cuerpo_tecnico <> p_id_cuerpo_tecnico;

    -- Si existe un duplicado, generar un error
    IF nombre_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'nombre del cuerpo técnico ya existe';
	ELSE
		UPDATE cuerpos_tecnicos
		SET nombre_cuerpo_tecnico = p_nuevo_nombre
		WHERE id_cuerpo_tecnico = p_id_cuerpo_tecnico;
	END IF;
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
DECLARE nombre_count INT;

    -- Verificar si el nombre ya existe
    SELECT COUNT(*) INTO nombre_count
    FROM sub_tipologias
    WHERE nombre_sub_tipologia = p_nombre_sub_tipologia;

    -- Si existe un duplicado, generar un error
    IF nombre_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'nombre de la sub tipología ya existe';
    ELSE
    INSERT INTO sub_tipologias (nombre_sub_tipologia, id_tipologia)
    VALUES (p_nombre_sub_tipologia, p_id_tipologia);
    END IF;
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
	DECLARE nombre_count INT;

    -- Verificar si el nombre ya existe
    SELECT COUNT(*) INTO nombre_count
	FROM sub_tipologias
	WHERE nombre_sub_tipologia = p_nombre_sub_tipologia
	AND id_sub_tipologia <> p_id_sub_tipologia;

    -- Si existe un duplicado, generar un error
    IF nombre_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'nombre de la sub tipología ya existe';
    ELSE
    UPDATE sub_tipologias
    SET nombre_sub_tipologia = p_nombre_sub_tipologia,
        id_tipologia = p_id_tipologia
    WHERE id_sub_tipologia = p_id_sub_tipologia;
    END IF;
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
	DECLARE nombre_count INT;

    -- Verificar si el nombre ya existe
    SELECT COUNT(*) INTO nombre_count
    FROM tipologias
    WHERE tipologia = p_tipologia;

    -- Si existe un duplicado, generar un error
    IF nombre_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'nombre de la tipología ya existe';
    ELSE
    INSERT INTO tipologias (tipologia)
    VALUES (p_tipologia);
    END IF;
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
	DECLARE nombre_count INT;

    -- Verificar si el nombre ya existe
	SELECT COUNT(*) INTO nombre_count
	FROM tipologias
	WHERE tipologia = p_nueva_tipologia
	AND id_tipologia <> p_id_tipologia;

    -- Si existe un duplicado, generar un error
    IF nombre_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'nombre de la tipología ya existe';
    ELSE
    UPDATE tipologias
    SET tipologia = p_nueva_tipologia
    WHERE id_tipologia = p_id_tipologia;
    END IF;
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
    DECLARE jornada_count INT;

    -- Validar que no exista una jornada con el mismo nombre o número en la misma plantilla
    SELECT COUNT(*) INTO jornada_count
    FROM jornadas
    WHERE (nombre_jornada = p_nombre_jornada OR numero_jornada = p_numero_jornada)
    AND id_plantilla = p_id_plantilla;

    IF jornada_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre o número de jornada ya existe para esta plantilla';
    END IF;

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
    DECLARE jornada_count INT;

    -- Validar que no exista otra jornada con el mismo nombre o número en la misma plantilla
    SELECT COUNT(*) INTO jornada_count
    FROM jornadas
    WHERE (nombre_jornada = p_nombre_jornada OR numero_jornada = p_numero_jornada)
    AND id_plantilla = p_id_plantilla
    AND id_jornada != p_id_jornada;

    IF jornada_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre o número de jornada ya existe para esta plantilla';
    END IF;

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

-- Procedimiento para insertar registros_medicos con verificación de duplicados
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
    DECLARE record_count INT;
 
    -- Verificar si el registro ya existe
    SELECT COUNT(*) INTO record_count
    FROM registros_medicos
    WHERE id_jugador = p_id_jugador
      AND fecha_lesion = p_fecha_lesion
      AND id_lesion = p_id_lesion;
 
    -- Si existe un duplicado, generar un error
    IF record_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El registro médico ya existe';
    ELSE
        INSERT INTO registros_medicos (id_jugador, fecha_lesion, dias_lesionado, id_lesion, retorno_entreno, retorno_partido)
        VALUES (p_id_jugador, p_fecha_lesion, p_dias_lesionado, p_id_lesion, p_retorno_entreno, p_retorno_partido);
    END IF;
END //
DELIMITER ;
 
-- Procedimiento para actualizar registros_medicos con verificación de duplicados
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
    DECLARE record_count INT;
 
    -- Verificar si el registro ya existe para otro registro médico
    SELECT COUNT(*) INTO record_count
    FROM registros_medicos
    WHERE id_jugador = p_id_jugador
      AND fecha_lesion = p_fecha_lesion
      AND id_lesion = p_id_lesion
      AND id_registro_medico <> p_id_registro_medico;
 
    -- Si existe un duplicado, generar un error
    IF record_count > 0 THEN
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'El registro médico ya existe';
    ELSE
        UPDATE registros_medicos
        SET id_jugador = p_id_jugador,
            fecha_lesion = p_fecha_lesion,
            dias_lesionado = p_dias_lesionado,
            id_lesion = p_id_lesion,
            retorno_entreno = p_retorno_entreno,
            retorno_partido = p_retorno_partido
        WHERE id_registro_medico = p_id_registro_medico;
    END IF;
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
    DECLARE v_genero_jugador ENUM('Masculino', 'Femenino');
    DECLARE v_genero_equipo ENUM('Masculino', 'Femenino');
    DECLARE v_nombre_equipo VARCHAR(50);
    DECLARE v_nombre_temporada VARCHAR(50);
    DECLARE v_equipo_actual INT;
    DECLARE v_temporada_actual INT;
    DECLARE v_error_msg VARCHAR(255); -- Variable para almacenar el mensaje de error

    -- Obtener el género del jugador
    SELECT genero_jugador INTO v_genero_jugador
    FROM jugadores
    WHERE id_jugador = p_id_jugador;

    -- Obtener el género del equipo
    SELECT genero_equipo INTO v_genero_equipo FROM equipos
    WHERE id_equipo = p_id_equipo;
    
    SELECT nombre_equipo INTO v_nombre_equipo FROM equipos
    WHERE id_equipo = p_id_equipo;

    -- Verificar si los géneros coinciden
    IF v_genero_jugador != v_genero_equipo THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El género del jugador no coincide con el género del equipo';
    ELSE
        -- Verificar si la plantilla ya tiene un equipo y temporada asignados
        SELECT id_equipo, id_temporada INTO v_equipo_actual, v_temporada_actual
        FROM plantillas_equipos
        WHERE id_plantilla = p_id_plantilla
        LIMIT 1;

        -- Si ya tiene datos, validar que el equipo y temporada coincidan
        IF v_equipo_actual IS NOT NULL AND v_temporada_actual IS NOT NULL THEN
            IF v_equipo_actual != p_id_equipo OR v_temporada_actual != p_id_temporada THEN
                -- Obtener el nombre del equipo y la temporada correctos
                SELECT nombre_equipo INTO v_nombre_equipo
                FROM equipos
                WHERE id_equipo = v_equipo_actual;

                SELECT nombre_temporada INTO v_nombre_temporada
                FROM temporadas
                WHERE id_temporada = v_temporada_actual;

                -- Concatenar el mensaje de error en la variable
                SET v_error_msg = CONCAT('La plantilla ya está asignada al equipo ', v_nombre_equipo, ' en la temporada ', v_nombre_temporada);

                -- Generar el error con el mensaje concatenado
                SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = v_error_msg;
            END IF;
        END IF;

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
    DECLARE v_genero_jugador ENUM('Masculino', 'Femenino');
    DECLARE v_genero_equipo ENUM('Masculino', 'Femenino');
    DECLARE v_nombre_equipo VARCHAR(50);
    DECLARE v_nombre_temporada VARCHAR(50);
    DECLARE v_equipo_actual INT;
    DECLARE v_temporada_actual INT;
    DECLARE v_error_msg VARCHAR(255); -- Variable para almacenar el mensaje de error

    -- Obtener el género del jugador
    SELECT genero_jugador INTO v_genero_jugador
    FROM jugadores
    WHERE id_jugador = p_id_jugador;

    -- Obtener el género del equipo y nombre
    SELECT genero_equipo, nombre_equipo INTO v_genero_equipo, v_nombre_equipo
    FROM equipos
    WHERE id_equipo = p_id_equipo;

    -- Verificar si los géneros coinciden
    IF v_genero_jugador != v_genero_equipo THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El género del jugador no coincide con el género del equipo';
    ELSE
        -- Verificar si la plantilla ya tiene un equipo y temporada asignados
        SELECT id_equipo, id_temporada INTO v_equipo_actual, v_temporada_actual
        FROM plantillas_equipos
        WHERE id_plantilla = p_id_plantilla
        LIMIT 1;

        -- Si ya tiene datos, validar que el equipo y temporada coincidan
        IF v_equipo_actual IS NOT NULL AND v_temporada_actual IS NOT NULL THEN
            IF v_equipo_actual != p_id_equipo OR v_temporada_actual != p_id_temporada THEN
                -- Obtener el nombre del equipo y la temporada correctos
                SELECT nombre_equipo INTO v_nombre_equipo
                FROM equipos
                WHERE id_equipo = v_equipo_actual;

                SELECT nombre_temporada INTO v_nombre_temporada
                FROM temporadas
                WHERE id_temporada = v_temporada_actual;

                -- Concatenar el mensaje de error en la variable
                SET v_error_msg = CONCAT('La plantilla ya está asignada al equipo ', v_nombre_equipo, ' en la temporada ', v_nombre_temporada);

                -- Generar el error con el mensaje concatenado
                SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = v_error_msg;
            END IF;
        END IF;

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
CREATE VIEW vista_cuerpos_tecnicos AS
SELECT id_cuerpo_tecnico AS 'ID',
nombre_cuerpo_tecnico AS 'NOMBRE'
FROM cuerpos_tecnicos;


SELECT id_cuerpo_tecnico AS 'ID',
nombre_cuerpo_tecnico AS 'NOMBRE'
FROM cuerpos_tecnicos;
SELECT * FROM vista_cuerpos_tecnicos;
DELIMITER ;

-- VISTA para tabla pagos
DROP VIEW IF EXISTS vista_pagos;
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
        ROUND(p.cantidad_pago + p.mora_pago, 2) AS 'TOTAL'
FROM pagos p
INNER JOIN jugadores j ON p.id_jugador = j.id_jugador;


-- VISTA para tabla sub tipología
DROP VIEW IF EXISTS vista_sub_tipologias;
DELIMITER $$
CREATE VIEW vista_sub_tipologias AS
SELECT st.id_sub_tipologia AS 'ID',
	   CONCAT(t.tipologia, " - ", st.nombre_sub_tipologia) AS 'COMPLETO', 
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
    j.dorsal_jugador,
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
    CONCAT('Dorsal ', j.dorsal_jugador) AS jugadores,
    j.id_jugador AS id,
    pe.id_plantilla_equipo,
    p.posicion,
    pDos.posicion AS posicion_secundaria
FROM
    equipos e
JOIN
    plantillas_equipos pe ON e.id_equipo = pe.id_equipo
JOIN
    jugadores j ON pe.id_jugador = j.id_jugador
JOIN 
	posiciones p ON j.id_posicion_principal = p.id_posicion
JOIN 
	posiciones pDos ON j.id_posicion_secundaria = pDos.id_posicion;

SELECT * FROM vista_equipos_jugadores;
SELECT * FROM jugadores;
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
ALTER VIEW vista_detalle_partidos AS
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
    c.nombre_categoria,
    v.autorizacion_prediccion
FROM
    partidos p
INNER JOIN
    equipos e ON p.id_equipo = e.id_equipo
INNER JOIN
	rivales i ON p.id_rival = i.id_rival
INNER JOIN
    categorias c ON e.id_categoria = c.id_categoria
INNER JOIN
	vista_autorizacion_prediccion v ON p.id_partido = v.id_partido
ORDER BY p.fecha_partido DESC;

SELECT * FROM vista_detalle_partidos WHERE id_partido = 6;

-- Vista para saber si un partido tiene los datos necesarios para ser predecido
CREATE VIEW vista_autorizacion_prediccion AS
SELECT 
    e.id_equipo,
    e.nombre_equipo,
    r.id_rival,
    r.nombre_rival,
    p.id_partido,
    COUNT(DISTINCT p.id_partido) AS partidos_jugados_equipo,
    (SELECT COUNT(*) FROM partidos p2 WHERE p2.id_rival = r.id_rival) AS partidos_jugados_rival,
    (SELECT COUNT(*) 
     FROM caracteristicas_analisis ca 
     WHERE ca.id_jugador IN (SELECT pe.id_jugador 
                             FROM plantillas_equipos pe 
                             WHERE pe.id_equipo = e.id_equipo)) AS caracteristicas_analizadas,
    (SELECT COUNT(*) 
     FROM test t 
     WHERE t.id_jugador IN (SELECT pe.id_jugador 
                            FROM plantillas_equipos pe 
                            WHERE pe.id_equipo = e.id_equipo) 
     AND t.contestado = 1) AS registros_contestados,
    CASE 
        WHEN COUNT(DISTINCT p.id_partido) >= 3 AND 
             (SELECT COUNT(*) FROM partidos p2 WHERE p2.id_rival = r.id_rival) >= 3 AND 
             (SELECT COUNT(*) FROM caracteristicas_analisis ca WHERE ca.id_jugador IN (SELECT pe.id_jugador FROM plantillas_equipos pe WHERE pe.id_equipo = e.id_equipo)) > 0 AND 
             (SELECT COUNT(*) FROM test t WHERE t.id_jugador IN (SELECT pe.id_jugador FROM plantillas_equipos pe WHERE pe.id_equipo = e.id_equipo) AND t.contestado = 1) >= 10
        THEN 'true'
        ELSE 'false'
    END AS autorizacion_prediccion
FROM 
    equipos e
JOIN 
    partidos p ON e.id_equipo = p.id_equipo
JOIN 
    rivales r ON p.id_rival = r.id_rival
GROUP BY 
    e.id_equipo, r.id_rival;

SELECT autorizacion_prediccion FROM vista_autorizacion_prediccion WHERE id_partido = 6;
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
DROP VIEW IF EXISTS vista_jugadores_por_equipo;
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
    
DROP VIEW IF EXISTS vista_jugadores_por_equipo2;
-- VER JUGADORES POR EQUIPO
CREATE VIEW vista_jugadores_por_equipo2 AS
    SELECT DISTINCT
        cp.id_convocatoria,
        cp.id_partido,
        cp.id_jugador,
        cp.estado_convocado,
        pt.id_equipo,
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
    posiciones p ON j.id_posicion_principal = p.id_posicion
LEFT JOIN plantillas_equipos pt ON pt.id_jugador = cp.id_jugador
GROUP BY nombre_jugador, apellido_jugador;

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
DROP PROCEDURE IF EXISTS Asistencia;
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
    DECLARE v_fecha DATE;

	-- Verificar la fecha del partido por el (id_partido)
	SELECT fecha_entrenamiento INTO v_fecha 
	FROM entrenamientos
	WHERE id_entrenamiento = p_id_entrenamiento;
	
    IF (p_asistencia_bool = 1) THEN
        -- Actualizar el registro
        UPDATE asistencias
        SET
            id_horario = p_id_horario,
            id_jugador = p_id_jugador,
            asistencia = p_asistencia,
            observacion_asistencia = p_observacion
        WHERE id_asistencia = p_id_asistencia;
        
        -- Actualizamos el test
        IF p_asistencia = 'Asistencia' THEN
            -- Insertar en test si asistió
            INSERT INTO test (id_jugador, fecha, id_entrenamiento) 
            VALUES (p_id_jugador, v_fecha, p_id_entrenamiento);
        ELSE            
				-- Eliminar de test si no asistió
            DELETE FROM test WHERE id_jugador = p_id_jugador AND id_entrenamiento = p_id_entrenamiento;
        END IF;
    ELSE
        -- Insertar un nuevo registro
        INSERT INTO asistencias (id_jugador, id_horario, asistencia, observacion_asistencia, id_entrenamiento)
        VALUES (p_id_jugador, p_id_horario, p_asistencia, p_observacion, p_id_entrenamiento);
			
			-- Actualizamos el test
        IF p_asistencia = 'Asistencia' THEN
            -- Insertar en test si asistió
            INSERT INTO test (id_jugador, fecha, id_entrenamiento) 
            VALUES (p_id_jugador, v_fecha, p_id_entrenamiento);
        END IF;
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
    DECLARE v_tipo_resultado_partido ENUM('Victoria', 'Empate', 'Derrota', 'Pendiente');
	 DECLARE v_fecha DATE;
	 
	 -- Verificar la fecha del partido por el (id_partido)
	SELECT fecha_partido INTO v_fecha 
	FROM partidos
	WHERE id_partido = p_id_partido;
    -- Verificar si el tipo de resultado del partido es 'Pendiente'
    SELECT tipo_resultado_partido INTO v_tipo_resultado_partido
    FROM partidos
    WHERE id_partido = p_id_partido;

    IF v_tipo_resultado_partido != 'Pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar la convocatoria porque el partido ya no está pendiente.';
    ELSE
        -- Verificar si ya existe una fila en convocatorias_partidos para el par (id_partido, id_jugador)
        SELECT id_convocatoria INTO v_id_convocatoria
        FROM convocatorias_partidos
        WHERE id_partido = p_id_partido AND id_jugador = p_id_jugador;

        IF v_id_convocatoria IS NOT NULL THEN
            -- Actualizar la fila existente en convocatorias_partidos
            UPDATE convocatorias_partidos
            SET id_partido = p_id_partido, id_jugador = p_id_jugador, estado_convocado = p_estado_convocado
            WHERE id_convocatoria = v_id_convocatoria;
            
            	IF p_estado_convocado = 0 THEN
            		-- Eliminar de test si no está convocado
            		DELETE FROM test WHERE id_jugador = p_id_jugador AND id_partido = p_id_partido;
        			ELSE
            		-- Insertar en test si está convocado
            		INSERT INTO test (id_jugador, fecha, id_partido) 
            		VALUES (p_id_jugador, v_fecha, p_id_partido);
        			END IF;
        ELSE
            -- Insertar una nueva fila en convocatorias_partidos
            INSERT INTO convocatorias_partidos (id_partido, id_jugador, estado_convocado)
            VALUES (p_id_partido, p_id_jugador, p_estado_convocado);
        			IF p_estado_convocado = 1 THEN
            		-- Insertar en test si está convocado
            		INSERT INTO test (id_jugador, fecha, id_partido) 
            		VALUES (p_id_jugador, v_fecha, p_id_partido);
        			END IF;
        END IF;
    END IF;
END
$$
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
    d.id_tecnico,
    v.autorizacion_prediccion
FROM
    partidos p
INNER JOIN
    equipos e ON p.id_equipo = e.id_equipo
INNER JOIN
	rivales i ON p.id_rival = i.id_rival
INNER JOIN
    detalles_cuerpos_tecnicos d ON e.id_cuerpo_tecnico = d.id_cuerpo_tecnico
INNER JOIN
	vista_autorizacion_prediccion v ON p.id_partido = v.id_partido
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
	 DATE_FORMAT(e.fecha_asistencia, '%e de %M') AS fecha,
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


DROP PROCEDURE IF EXISTS sp_insertar_palmares;
DELIMITER //

CREATE PROCEDURE sp_insertar_palmares (
    IN p_id_equipo INT,
    IN p_id_temporada INT,
    IN p_lugar ENUM('Campeón', 'Subcampeón', 'Tercer lugar')
)
BEGIN
    DECLARE record_count INT;
    DECLARE error_message VARCHAR(255);

    -- Verificar si el palmarés ya existe para el equipo y la temporada
    SELECT COUNT(*) INTO record_count
    FROM palmares
    WHERE id_equipo = p_id_equipo
      AND id_temporada = p_id_temporada;

    -- Si existe un registro, asignar el mensaje de error
    IF record_count > 0 THEN
        SET error_message = CONCAT('El reconocimiento ya existe para el equipo en esta temporada');
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = error_message;
    END IF;

    -- Verificar si el equipo ya obtuvo un lugar en la temporada
    SELECT COUNT(*) INTO record_count
    FROM palmares
    WHERE id_equipo = p_id_equipo
      AND id_temporada = p_id_temporada
      AND lugar = p_lugar;

    -- Si existe un duplicado, generar un error
    IF record_count > 0 THEN
        SET error_message = CONCAT('El equipo ya obtuvo ', p_lugar, ' en esta temporada');
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = error_message;
    ELSE
        -- Insertar el nuevo registro en palmarés
        INSERT INTO palmares (id_equipo, id_temporada, lugar)
        VALUES (p_id_equipo, p_id_temporada, p_lugar);
    END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_actualizar_palmares;
DELIMITER //

CREATE PROCEDURE sp_actualizar_palmares (
    IN p_id_palmares INT,
    IN p_id_equipo INT,
    IN p_id_temporada INT,
    IN p_lugar ENUM('Campeón', 'Subcampeón', 'Tercer lugar')
)
BEGIN
    DECLARE record_count INT;
    DECLARE error_message VARCHAR(255);

    -- Verificar si el palmarés ya existe para otro registro (diferente de p_id_palmares)
    SELECT COUNT(*) INTO record_count
    FROM palmares
    WHERE id_equipo = p_id_equipo
      AND id_temporada = p_id_temporada
      AND id_palmares <> p_id_palmares;

    -- Si existe un duplicado, generar un error
    IF record_count > 0 THEN
        SET error_message = 'El reconocimiento ya existe para el equipo en esta temporada';
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = error_message;
    END IF;

    -- Verificar si el equipo ya obtuvo un lugar en la temporada
    SELECT COUNT(*) INTO record_count
    FROM palmares
    WHERE id_equipo = p_id_equipo
      AND id_temporada = p_id_temporada
      AND lugar = p_lugar
      AND id_palmares <> p_id_palmares; -- excluyendo el registro actual

    -- Si existe un duplicado, generar un error
    IF record_count > 0 THEN
        SET error_message = CONCAT('El equipo ya obtuvo ', p_lugar, ' en esta temporada ');
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = error_message;
    ELSE
        -- Actualizar el registro en palmarés
        UPDATE palmares
        SET id_equipo = p_id_equipo,
            id_temporada = p_id_temporada,
            lugar = p_lugar
        WHERE id_palmares = p_id_palmares;
    END IF;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS sp_eliminar_palmares;
DELIMITER //

CREATE PROCEDURE sp_eliminar_palmares (
    IN p_id_palmares INT
)
BEGIN
    -- Eliminar el registro de palmarés
    DELETE FROM palmares WHERE id_palmares = p_id_palmares;
END //
DELIMITER ;

-- TRIGGER QUE VALIDA QUE NO SE INSERTEN COMBINACIONES EXISTENTES EN MOMENTOS DE JUEGO:

DELIMITER //

CREATE TRIGGER validar_unicidad_temas_contenidos
BEFORE INSERT ON temas_contenidos
FOR EACH ROW
BEGIN
  -- Verifica si ya existe la combinación de momento_juego y zona_campo
  IF EXISTS (
    SELECT 1 FROM temas_contenidos 
    WHERE momento_juego = NEW.momento_juego
    AND zona_campo = NEW.zona_campo
  ) THEN
    -- Lanza un error si ya existe la combinación
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'La combinación de momento_juego y zona_campo ya existe.';
  END IF;
END;
//

DELIMITER ;

-- TRIGGER QUE VALIDA QUE NO SE INSERTEN COMBINACIONES EXISTENTES EN MOMENTOS DE JUEGO:
DELIMITER //

CREATE TRIGGER validar_unicidad_temas_contenidos_update
BEFORE UPDATE ON temas_contenidos
FOR EACH ROW
BEGIN
  -- Verifica si ya existe la combinación de momento_juego y zona_campo
  IF EXISTS (
    SELECT 1 FROM temas_contenidos 
    WHERE momento_juego = NEW.momento_juego
    AND zona_campo = NEW.zona_campo
    AND id_tema_contenido != NEW.id_tema_contenido
  ) THEN
    -- Lanza un error si ya existe la combinación
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'La combinación de momento_juego y zona_campo ya existe.';
  END IF;
END;
//

DELIMITER ;

-- TRIGGER QUE VALIDA QUE NO SE INSERTEN COMBINACIONES EXISTENTES EN PRINCIPIOS DE JUEGO:

DELIMITER //

CREATE TRIGGER validar_unicidad_sub_temas_contenidos
BEFORE INSERT ON sub_temas_contenidos
FOR EACH ROW
BEGIN
  -- Verifica si ya existe la combinación de momento_juego y zona_campo
  IF EXISTS (
    SELECT 1 FROM sub_temas_contenidos 
    WHERE sub_tema_contenido = NEW.sub_tema_contenido
    AND id_tema_contenido = NEW.id_tema_contenido
  ) THEN
    -- Lanza un error si ya existe la combinación
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'La combinación de momento de juego y principio ya existe.';
  END IF;
END;
//

DELIMITER ;

-- TRIGGER QUE VALIDA QUE NO SE INSERTEN CCOMBINACIONES EXISTENTES EN PRINCIPIOS DE JUEGO:
DELIMITER //

CREATE TRIGGER validar_unicidad_sub_temas_contenidos_update
BEFORE UPDATE ON sub_temas_contenidos
FOR EACH ROW
BEGIN
  -- Verifica si ya existe la combinación de momento_juego y zona_campo
 IF EXISTS (
    SELECT 1 FROM sub_temas_contenidos 
    WHERE id_tema_contenido = NEW.id_tema_contenido
    AND sub_tema_contenido = NEW.sub_tema_contenido
    AND id_sub_tema_contenido != NEW.id_sub_tema_contenido
  ) THEN
    -- Lanza un error si ya existe la combinación
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'La combinación de momento de juego y principio ya existe.';
  END IF;
END;
//

DELIMITER ;
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
    
INSERT INTO palmares (id_equipo, id_temporada, lugar) VALUES
(1, 1, 'Campeón'),
(2, 2, 'Subcampeón'),
(3, 3, 'Tercer lugar'),
(1, 4, 'Subcampeón'),
(4, 5, 'Campeón');



INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (1, '2024-09-01', TRUE, 1, NULL),
       (1, '2024-09-05', TRUE, 6, NULL),
       (1, '2024-09-09', TRUE, 7, NULL),
       (1, '2024-09-13', TRUE, 8, NULL),
       (1, '2024-09-17', TRUE, 9, NULL);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (2, '2024-09-02', TRUE, 1, NULL),
       (2, '2024-09-06', TRUE, 6, NULL),
       (2, '2024-09-10', TRUE, 7, NULL),
       (2, '2024-09-14', TRUE, 8, NULL),
       (2, '2024-09-18', TRUE, 9, NULL);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (3, '2024-09-03', TRUE, 1, NULL),
       (3, '2024-09-07', TRUE, 6, NULL),
       (3, '2024-09-11', TRUE, 7, NULL),
       (3, '2024-09-15', TRUE, 8, NULL),
       (3, '2024-09-19', TRUE, 9, NULL);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (5, '2024-09-04', TRUE, 1, NULL),
       (5, '2024-09-08', TRUE, 6, NULL),
       (5, '2024-09-12', TRUE, 7, NULL),
       (5, '2024-09-16', TRUE, 8, NULL),
       (5, '2024-09-20', TRUE, 9, NULL);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (7, '2024-09-05', TRUE, 1, NULL),
       (7, '2024-09-09', TRUE, 6, NULL),
       (7, '2024-09-13', TRUE, 7, NULL),
       (7, '2024-09-17', TRUE, 8, NULL),
       (7, '2024-09-21', TRUE, 9, NULL);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (8, '2024-09-06', TRUE, 1, NULL),
       (8, '2024-09-10', TRUE, 6, NULL),
       (8, '2024-09-14', TRUE, 7, NULL),
       (8, '2024-09-18', TRUE, 8, NULL),
       (8, '2024-09-22', TRUE, 9, NULL);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (11, '2024-09-07', TRUE, 1, NULL),
       (11, '2024-09-11', TRUE, 6, NULL),
       (11, '2024-09-15', TRUE, 7, NULL),
       (11, '2024-09-19', TRUE, 8, NULL),
       (11, '2024-09-23', TRUE, 9, NULL);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (12, '2024-09-08', TRUE, 1, NULL),
       (12, '2024-09-12', TRUE, 6, NULL),
       (12, '2024-09-16', TRUE, 7, NULL),
       (12, '2024-09-20', TRUE, 8, NULL),
       (12, '2024-09-24', TRUE, 9, NULL);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (10, '2024-09-09', TRUE, 1, NULL),
       (10, '2024-09-13', TRUE, 6, NULL),
       (10, '2024-09-17', TRUE, 7, NULL),
       (10, '2024-09-21', TRUE, 8, NULL),
       (10, '2024-09-25', TRUE, 9, NULL);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (4, '2024-09-10', TRUE, 1, NULL),
       (4, '2024-09-14', TRUE, 6, NULL),
       (4, '2024-09-18', TRUE, 7, NULL),
       (4, '2024-09-22', TRUE, 8, NULL),
       (4, '2024-09-26', TRUE, 9, NULL);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (6, '2024-09-11', TRUE, 1, NULL),
       (6, '2024-09-15', TRUE, 6, NULL),
       (6, '2024-09-19', TRUE, 7, NULL),
       (6, '2024-09-23', TRUE, 8, NULL),
       (6, '2024-09-27', TRUE, 9, NULL);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (13, '2024-09-12', TRUE, 1, NULL),
       (13, '2024-09-16', TRUE, 6, NULL),
       (13, '2024-09-20', TRUE, 7, NULL),
       (13, '2024-09-24', TRUE, 8, NULL),
       (13, '2024-09-28', TRUE, 9, NULL);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (14, '2024-09-13', TRUE, 1, NULL),
       (14, '2024-09-17', TRUE, 6, NULL),
       (14, '2024-09-21', TRUE, 7, NULL),
       (14, '2024-09-25', TRUE, 8, NULL),
       (14, '2024-09-29', TRUE, 9, NULL);

-- ENTRENAMIENTOS:
INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (1, '2024-09-01', TRUE, NULL, 32),
       (1, '2024-09-05', TRUE, NULL, 31),
       (1, '2024-09-09', TRUE, NULL, 26),
       (1, '2024-09-13', TRUE, NULL, 27),
       (1, '2024-09-17', TRUE, NULL, 29),
       (1, '2024-09-21', TRUE, NULL, 28),
       (1, '2024-09-25', TRUE, NULL, 25),
       (1, '2024-09-29', TRUE, NULL, 22),
       (1, '2024-10-03', TRUE, NULL, 24);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (2, '2024-09-02', TRUE, NULL, 32),
       (2, '2024-09-06', TRUE, NULL, 31),
       (2, '2024-09-10', TRUE, NULL, 26),
       (2, '2024-09-14', TRUE, NULL, 27),
       (2, '2024-09-18', TRUE, NULL, 29),
       (2, '2024-09-22', TRUE, NULL, 28),
       (2, '2024-09-26', TRUE, NULL, 25),
       (2, '2024-09-30', TRUE, NULL, 22),
       (2, '2024-10-04', TRUE, NULL, 24);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (3, '2024-09-03', TRUE, NULL, 32),
       (3, '2024-09-07', TRUE, NULL, 31),
       (3, '2024-09-11', TRUE, NULL, 26),
       (3, '2024-09-15', TRUE, NULL, 27),
       (3, '2024-09-19', TRUE, NULL, 29),
       (3, '2024-09-23', TRUE, NULL, 28),
       (3, '2024-09-27', TRUE, NULL, 25),
       (3, '2024-10-01', TRUE, NULL, 22),
       (3, '2024-10-05', TRUE, NULL, 24);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (5, '2024-09-04', TRUE, NULL, 32),
       (5, '2024-09-08', TRUE, NULL, 31),
       (5, '2024-09-12', TRUE, NULL, 26),
       (5, '2024-09-16', TRUE, NULL, 27),
       (5, '2024-09-20', TRUE, NULL, 29),
       (5, '2024-09-24', TRUE, NULL, 28),
       (5, '2024-09-28', TRUE, NULL, 25),
       (5, '2024-10-02', TRUE, NULL, 22),
       (5, '2024-10-06', TRUE, NULL, 24);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (7, '2024-09-05', TRUE, NULL, 32),
       (7, '2024-09-09', TRUE, NULL, 31),
       (7, '2024-09-13', TRUE, NULL, 26),
       (7, '2024-09-17', TRUE, NULL, 27),
       (7, '2024-09-21', TRUE, NULL, 29),
       (7, '2024-09-25', TRUE, NULL, 28),
       (7, '2024-09-29', TRUE, NULL, 25),
       (7, '2024-10-03', TRUE, NULL, 22),
       (7, '2024-10-07', TRUE, NULL, 24);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (8, '2024-09-06', TRUE, NULL, 32),
       (8, '2024-09-10', TRUE, NULL, 31),
       (8, '2024-09-14', TRUE, NULL, 26),
       (8, '2024-09-18', TRUE, NULL, 27),
       (8, '2024-09-22', TRUE, NULL, 29),
       (8, '2024-09-26', TRUE, NULL, 28),
       (8, '2024-09-30', TRUE, NULL, 25),
       (8, '2024-10-04', TRUE, NULL, 22),
       (8, '2024-10-08', TRUE, NULL, 24);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (11, '2024-09-07', TRUE, NULL, 32),
       (11, '2024-09-11', TRUE, NULL, 31),
       (11, '2024-09-15', TRUE, NULL, 26),
       (11, '2024-09-19', TRUE, NULL, 27),
       (11, '2024-09-23', TRUE, NULL, 29),
       (11, '2024-09-27', TRUE, NULL, 28),
       (11, '2024-10-01', TRUE, NULL, 25),
       (11, '2024-10-05', TRUE, NULL, 22),
       (11, '2024-10-09', TRUE, NULL, 24);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (12, '2024-09-08', TRUE, NULL, 32),
       (12, '2024-09-12', TRUE, NULL, 31),
       (12, '2024-09-16', TRUE, NULL, 26),
       (12, '2024-09-20', TRUE, NULL, 27),
       (12, '2024-09-24', TRUE, NULL, 29),
       (12, '2024-09-28', TRUE, NULL, 28),
       (12, '2024-10-02', TRUE, NULL, 25),
       (12, '2024-10-06', TRUE, NULL, 22),
       (12, '2024-10-10', TRUE, NULL, 24);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (10, '2024-09-09', TRUE, NULL, 32),
       (10, '2024-09-13', TRUE, NULL, 31),
       (10, '2024-09-17', TRUE, NULL, 26),
       (10, '2024-09-21', TRUE, NULL, 27),
       (10, '2024-09-25', TRUE, NULL, 29),
       (10, '2024-09-29', TRUE, NULL, 28),
       (10, '2024-10-03', TRUE, NULL, 25),
       (10, '2024-10-07', TRUE, NULL, 22),
       (10, '2024-10-11', TRUE, NULL, 24);

INSERT INTO test (id_jugador, fecha, contestado, id_partido, id_entrenamiento)
VALUES (4, '2024-09-10', TRUE, NULL, 32),
       (4, '2024-09-14', TRUE, NULL, 31),
       (4, '2024-09-18', TRUE, NULL, 26),
       (4, '2024-09-22', TRUE, NULL, 27),
       (4, '2024-09-26', TRUE, NULL, 29),
       (4, '2024-09-30', TRUE, NULL, 28),
       (4, '2024-10-04', TRUE, NULL, 25),
       (4, '2024-10-08', TRUE, NULL, 22),
       (4, '2024-10-12', TRUE, NULL, 24);

-- Inserts para el id_test 1
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 1),
('¿Cómo te sientes mentalmente hoy?', 8, 1),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 1),
('¿Cómo es tu nivel de energía actual?', 6, 1),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 1),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 1),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 1),
('¿Sientes alguna rigidez muscular?', 6, 1),
('¿Cómo sientes tu ánimo en general?', 9, 1);

-- Inserts para el id_test 2
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 6, 2),
('¿Cómo te sientes mentalmente hoy?', 7, 2),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 5, 2),
('¿Cómo es tu nivel de energía actual?', 8, 2),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 2),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 2),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 2),
('¿Sientes alguna rigidez muscular?', 5, 2),
('¿Cómo sientes tu ánimo en general?', 8, 2);

-- Inserts para el id_test 3
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 3),
('¿Cómo te sientes mentalmente hoy?', 7, 3),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 3),
('¿Cómo es tu nivel de energía actual?', 9, 3),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 3),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 3),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 3),
('¿Sientes alguna rigidez muscular?', 6, 3),
('¿Cómo sientes tu ánimo en general?', 9, 3);

-- Inserts para el id_test 4
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 6, 4),
('¿Cómo te sientes mentalmente hoy?', 7, 4),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 8, 4),
('¿Cómo es tu nivel de energía actual?', 9, 4),
('¿Tienes alguna molestia o dolor físico hoy?', 6, 4),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 4),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 4),
('¿Sientes alguna rigidez muscular?', 4, 4),
('¿Cómo sientes tu ánimo en general?', 7, 4);

-- Inserts para el id_test 5
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 5),
('¿Cómo te sientes mentalmente hoy?', 8, 5),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 5),
('¿Cómo es tu nivel de energía actual?', 6, 5),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 5),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 5),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 5),
('¿Sientes alguna rigidez muscular?', 6, 5),
('¿Cómo sientes tu ánimo en general?', 9, 5);

-- Inserts para el id_test 6
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 6, 6),
('¿Cómo te sientes mentalmente hoy?', 5, 6),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 6),
('¿Cómo es tu nivel de energía actual?', 8, 6),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 6),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 6),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 6),
('¿Sientes alguna rigidez muscular?', 7, 6),
('¿Cómo sientes tu ánimo en general?', 9, 6);

-- Inserts para el id_test 7
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 7),
('¿Cómo te sientes mentalmente hoy?', 9, 7),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 7),
('¿Cómo es tu nivel de energía actual?', 6, 7),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 7),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 7),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 7),
('¿Sientes alguna rigidez muscular?', 6, 7),
('¿Cómo sientes tu ánimo en general?', 9, 7);

-- Inserts para el id_test 8
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 6, 8),
('¿Cómo te sientes mentalmente hoy?', 7, 8),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 8, 8),
('¿Cómo es tu nivel de energía actual?', 7, 8),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 8),
('¿Cómo calificarías tu apetito el día de hoy?', 6, 8),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 8),
('¿Sientes alguna rigidez muscular?', 9, 8),
('¿Cómo sientes tu ánimo en general?', 6, 8);

-- Inserts para el id_test 8
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 8),
('¿Cómo te sientes mentalmente hoy?', 8, 8),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 8),
('¿Cómo es tu nivel de energía actual?', 9, 8),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 8),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 8),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 8),
('¿Sientes alguna rigidez muscular?', 6, 8),
('¿Cómo sientes tu ánimo en general?', 8, 8);

-- Inserts para el id_test 9
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 9),
('¿Cómo te sientes mentalmente hoy?', 7, 9),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 9),
('¿Cómo es tu nivel de energía actual?', 9, 9),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 9),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 9),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 9),
('¿Sientes alguna rigidez muscular?', 5, 9),
('¿Cómo sientes tu ánimo en general?', 6, 9);

-- Inserts para el id_test 10
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 10),
('¿Cómo te sientes mentalmente hoy?', 6, 10),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 10),
('¿Cómo es tu nivel de energía actual?', 8, 10),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 10),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 10),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 10),
('¿Sientes alguna rigidez muscular?', 8, 10),
('¿Cómo sientes tu ánimo en general?', 7, 10);

-- Inserts para el id_test 11
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 6, 11),
('¿Cómo te sientes mentalmente hoy?', 8, 11),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 11),
('¿Cómo es tu nivel de energía actual?', 9, 11),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 11),
('¿Cómo calificarías tu apetito el día de hoy?', 6, 11),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 11),
('¿Sientes alguna rigidez muscular?', 6, 11),
('¿Cómo sientes tu ánimo en general?', 8, 11);

-- Inserts para el id_test 12
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 12),
('¿Cómo te sientes mentalmente hoy?', 7, 12),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 12),
('¿Cómo es tu nivel de energía actual?', 8, 12),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 12),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 12),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 12),
('¿Sientes alguna rigidez muscular?', 5, 12),
('¿Cómo sientes tu ánimo en general?', 6, 12);

-- Inserts para el id_test 13
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 13),
('¿Cómo te sientes mentalmente hoy?', 8, 13),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 5, 13),
('¿Cómo es tu nivel de energía actual?', 7, 13),
('¿Tienes alguna molestia o dolor físico hoy?', 6, 13),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 13),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 13),
('¿Sientes alguna rigidez muscular?', 9, 13),
('¿Cómo sientes tu ánimo en general?', 7, 13);

-- Inserts para el id_test 14
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 14),
('¿Cómo te sientes mentalmente hoy?', 6, 14),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 14),
('¿Cómo es tu nivel de energía actual?', 7, 14),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 14),
('¿Cómo calificarías tu apetito el día de hoy?', 6, 14),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 14),
('¿Sientes alguna rigidez muscular?', 7, 14),
('¿Cómo sientes tu ánimo en general?', 6, 14);

-- Inserts para el id_test 15
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 15),
('¿Cómo te sientes mentalmente hoy?', 5, 15),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 8, 15),
('¿Cómo es tu nivel de energía actual?', 6, 15),
('¿Tienes alguna molestia o dolor físico hoy?', 7, 15),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 15),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 15),
('¿Sientes alguna rigidez muscular?', 5, 15),
('¿Cómo sientes tu ánimo en general?', 7, 15);

-- Inserts para el id_test 16
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 6, 16),
('¿Cómo te sientes mentalmente hoy?', 9, 16),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 8, 16),
('¿Cómo es tu nivel de energía actual?', 7, 16),
('¿Tienes alguna molestia o dolor físico hoy?', 6, 16),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 16),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 16),
('¿Sientes alguna rigidez muscular?', 7, 16),
('¿Cómo sientes tu ánimo en general?', 6, 16);

-- Inserts para el id_test 17
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 17),
('¿Cómo te sientes mentalmente hoy?', 6, 17),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 17),
('¿Cómo es tu nivel de energía actual?', 7, 17),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 17),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 17),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 17),
('¿Sientes alguna rigidez muscular?', 7, 17),
('¿Cómo sientes tu ánimo en general?', 9, 17);

-- Inserts para el id_test 18
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 18),
('¿Cómo te sientes mentalmente hoy?', 7, 18),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 8, 18),
('¿Cómo es tu nivel de energía actual?', 6, 18),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 18),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 18),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 18),
('¿Sientes alguna rigidez muscular?', 7, 18),
('¿Cómo sientes tu ánimo en general?', 6, 18);

-- Inserts para el id_test 19
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 19),
('¿Cómo te sientes mentalmente hoy?', 8, 19),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 19),
('¿Cómo es tu nivel de energía actual?', 7, 19),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 19),
('¿Cómo calificarías tu apetito el día de hoy?', 6, 19),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 19),
('¿Sientes alguna rigidez muscular?', 6, 19),
('¿Cómo sientes tu ánimo en general?', 9, 19);

-- Inserts para el id_test 20
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 20),
('¿Cómo te sientes mentalmente hoy?', 7, 20),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 8, 20),
('¿Cómo es tu nivel de energía actual?', 9, 20),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 20),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 20),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 20),
('¿Sientes alguna rigidez muscular?', 9, 20),
('¿Cómo sientes tu ánimo en general?', 6, 20);

-- Inserts para el id_test 21
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 21),
('¿Cómo te sientes mentalmente hoy?', 6, 21),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 21),
('¿Cómo es tu nivel de energía actual?', 5, 21),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 21),
('¿Cómo calificarías tu apetito el día de hoy?', 6, 21),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 21),
('¿Sientes alguna rigidez muscular?', 5, 21),
('¿Cómo sientes tu ánimo en general?', 7, 21);

-- Inserts para el id_test 22
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 22),
('¿Cómo te sientes mentalmente hoy?', 9, 22),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 22),
('¿Cómo es tu nivel de energía actual?', 8, 22),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 22),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 22),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 22),
('¿Sientes alguna rigidez muscular?', 8, 22),
('¿Cómo sientes tu ánimo en general?', 7, 22);

-- Inserts para el id_test 23
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 6, 23),
('¿Cómo te sientes mentalmente hoy?', 8, 23),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 23),
('¿Cómo es tu nivel de energía actual?', 7, 23),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 23),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 23),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 23),
('¿Sientes alguna rigidez muscular?', 9, 23),
('¿Cómo sientes tu ánimo en general?', 8, 23);

-- Inserts para el id_test 24
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 24),
('¿Cómo te sientes mentalmente hoy?', 9, 24),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 8, 24),
('¿Cómo es tu nivel de energía actual?', 6, 24),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 24),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 24),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 24),
('¿Sientes alguna rigidez muscular?', 6, 24),
('¿Cómo sientes tu ánimo en general?', 7, 24);

-- Inserts para el id_test 25
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 25),
('¿Cómo te sientes mentalmente hoy?', 7, 25),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 25),
('¿Cómo es tu nivel de energía actual?', 9, 25),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 25),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 25),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 25),
('¿Sientes alguna rigidez muscular?', 6, 25),
('¿Cómo sientes tu ánimo en general?', 9, 25);

-- Inserts para el id_test 26
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 26),
('¿Cómo te sientes mentalmente hoy?', 9, 26),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 8, 26),
('¿Cómo es tu nivel de energía actual?', 7, 26),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 26),
('¿Cómo calificarías tu apetito el día de hoy?', 6, 26),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 26),
('¿Sientes alguna rigidez muscular?', 8, 26),
('¿Cómo sientes tu ánimo en general?', 6, 26);

-- Inserts para el id_test 27
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 27),
('¿Cómo te sientes mentalmente hoy?', 7, 27),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 27),
('¿Cómo es tu nivel de energía actual?', 8, 27),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 27),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 27),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 27),
('¿Sientes alguna rigidez muscular?', 7, 27),
('¿Cómo sientes tu ánimo en general?', 9, 27);

-- Inserts para el id_test 28
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 28),
('¿Cómo te sientes mentalmente hoy?', 6, 28),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 28),
('¿Cómo es tu nivel de energía actual?', 7, 28),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 28),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 28),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 28),
('¿Sientes alguna rigidez muscular?', 7, 28),
('¿Cómo sientes tu ánimo en general?', 9, 28);

-- Inserts para el id_test 29
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 29),
('¿Cómo te sientes mentalmente hoy?', 9, 29),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 29),
('¿Cómo es tu nivel de energía actual?', 8, 29),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 29),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 29),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 29),
('¿Sientes alguna rigidez muscular?', 8, 29),
('¿Cómo sientes tu ánimo en general?', 9, 29);

-- Inserts para el id_test 30
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 30),
('¿Cómo te sientes mentalmente hoy?', 7, 30),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 8, 30),
('¿Cómo es tu nivel de energía actual?', 5, 30),
('¿Tienes alguna molestia o dolor físico hoy?', 6, 30),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 30),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 30),
('¿Sientes alguna rigidez muscular?', 6, 30),
('¿Cómo sientes tu ánimo en general?', 5, 30);

-- Inserts para el id_test 31
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 6, 31),
('¿Cómo te sientes mentalmente hoy?', 8, 31),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 31),
('¿Cómo es tu nivel de energía actual?', 9, 31),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 31),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 31),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 31),
('¿Sientes alguna rigidez muscular?', 9, 31),
('¿Cómo sientes tu ánimo en general?', 7, 31);

-- Inserts para el id_test 32
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 32),
('¿Cómo te sientes mentalmente hoy?', 8, 32),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 32),
('¿Cómo es tu nivel de energía actual?', 7, 32),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 32),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 32),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 32),
('¿Sientes alguna rigidez muscular?', 9, 32),
('¿Cómo sientes tu ánimo en general?', 8, 32);

-- Inserts para el id_test 33
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 33),
('¿Cómo te sientes mentalmente hoy?', 7, 33),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 33),
('¿Cómo es tu nivel de energía actual?', 6, 33),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 33),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 33),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 33),
('¿Sientes alguna rigidez muscular?', 6, 33),
('¿Cómo sientes tu ánimo en general?', 7, 33);

-- Inserts para el id_test 34
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 34),
('¿Cómo te sientes mentalmente hoy?', 8, 34),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 34),
('¿Cómo es tu nivel de energía actual?', 6, 34),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 34),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 34),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 34),
('¿Sientes alguna rigidez muscular?', 8, 34),
('¿Cómo sientes tu ánimo en general?', 9, 34);

-- Inserts para el id_test 35
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 35),
('¿Cómo te sientes mentalmente hoy?', 9, 35),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 8, 35),
('¿Cómo es tu nivel de energía actual?', 7, 35),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 35),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 35),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 35),
('¿Sientes alguna rigidez muscular?', 7, 35),
('¿Cómo sientes tu ánimo en general?', 8, 35);

-- Inserts para el id_test 36
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 36),
('¿Cómo te sientes mentalmente hoy?', 8, 36),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 36),
('¿Cómo es tu nivel de energía actual?', 8, 36),
('¿Tienes alguna molestia o dolor físico hoy?', 6, 36),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 36),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 36),
('¿Sientes alguna rigidez muscular?', 8, 36),
('¿Cómo sientes tu ánimo en general?', 9, 36);

-- Inserts para el id_test 37
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 37),
('¿Cómo te sientes mentalmente hoy?', 6, 37),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 37),
('¿Cómo es tu nivel de energía actual?', 7, 37),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 37),
('¿Cómo calificarías tu apetito el día de hoy?', 6, 37),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 37),
('¿Sientes alguna rigidez muscular?', 7, 37),
('¿Cómo sientes tu ánimo en general?', 8, 37);

-- Inserts para el id_test 38
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 38),
('¿Cómo te sientes mentalmente hoy?', 8, 38),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 38),
('¿Cómo es tu nivel de energía actual?', 9, 38),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 38),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 38),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 38),
('¿Sientes alguna rigidez muscular?', 9, 38),
('¿Cómo sientes tu ánimo en general?', 8, 38);

-- Inserts para el id_test 39
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 39),
('¿Cómo te sientes mentalmente hoy?', 7, 39),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 39),
('¿Cómo es tu nivel de energía actual?', 6, 39),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 39),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 39),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 39),
('¿Sientes alguna rigidez muscular?', 6, 39),
('¿Cómo sientes tu ánimo en general?', 7, 39);

-- Inserts para el id_test 40
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 40),
('¿Cómo te sientes mentalmente hoy?', 8, 40),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 40),
('¿Cómo es tu nivel de energía actual?', 7, 40),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 40),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 40),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 40),
('¿Sientes alguna rigidez muscular?', 9, 40),
('¿Cómo sientes tu ánimo en general?', 8, 40);

-- Inserts para el id_test 41
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 41),
('¿Cómo te sientes mentalmente hoy?', 7, 41),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 41),
('¿Cómo es tu nivel de energía actual?', 6, 41),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 41),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 41),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 41),
('¿Sientes alguna rigidez muscular?', 6, 41),
('¿Cómo sientes tu ánimo en general?', 8, 41);

-- Inserts para el id_test 42
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 42),
('¿Cómo te sientes mentalmente hoy?', 8, 42),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 42),
('¿Cómo es tu nivel de energía actual?', 6, 42),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 42),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 42),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 42),
('¿Sientes alguna rigidez muscular?', 9, 42),
('¿Cómo sientes tu ánimo en general?', 8, 42);

-- Inserts para el id_test 43
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 43),
('¿Cómo te sientes mentalmente hoy?', 6, 43),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 43),
('¿Cómo es tu nivel de energía actual?', 7, 43),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 43),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 43),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 43),
('¿Sientes alguna rigidez muscular?', 6, 43),
('¿Cómo sientes tu ánimo en general?', 8, 43);

-- Inserts para el id_test 44
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 44),
('¿Cómo te sientes mentalmente hoy?', 8, 44),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 44),
('¿Cómo es tu nivel de energía actual?', 7, 44),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 44),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 44),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 44),
('¿Sientes alguna rigidez muscular?', 9, 44),
('¿Cómo sientes tu ánimo en general?', 8, 44);

-- Inserts para el id_test 45
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 45),
('¿Cómo te sientes mentalmente hoy?', 6, 45),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 45),
('¿Cómo es tu nivel de energía actual?', 8, 45),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 45),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 45),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 45),
('¿Sientes alguna rigidez muscular?', 9, 45),
('¿Cómo sientes tu ánimo en general?', 7, 45);

-- Inserts para el id_test 46
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 46),
('¿Cómo te sientes mentalmente hoy?', 7, 46),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 46),
('¿Cómo es tu nivel de energía actual?', 9, 46),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 46),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 46),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 46),
('¿Sientes alguna rigidez muscular?', 9, 46),
('¿Cómo sientes tu ánimo en general?', 8, 46);

-- Inserts para el id_test 47
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 47),
('¿Cómo te sientes mentalmente hoy?', 8, 47),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 47),
('¿Cómo es tu nivel de energía actual?', 6, 47),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 47),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 47),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 47),
('¿Sientes alguna rigidez muscular?', 8, 47),
('¿Cómo sientes tu ánimo en general?', 9, 47);

-- Inserts para el id_test 48
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 48),
('¿Cómo te sientes mentalmente hoy?', 7, 48),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 48),
('¿Cómo es tu nivel de energía actual?', 6, 48),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 48),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 48),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 48),
('¿Sientes alguna rigidez muscular?', 6, 48),
('¿Cómo sientes tu ánimo en general?', 8, 48);

-- Inserts para el id_test 49
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 49),
('¿Cómo te sientes mentalmente hoy?', 8, 49),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 49),
('¿Cómo es tu nivel de energía actual?', 6, 49),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 49),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 49),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 49),
('¿Sientes alguna rigidez muscular?', 9, 49),
('¿Cómo sientes tu ánimo en general?', 8, 49);

-- Inserts para el id_test 50
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 50),
('¿Cómo te sientes mentalmente hoy?', 7, 50),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 50),
('¿Cómo es tu nivel de energía actual?', 6, 50),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 50),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 50),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 50),
('¿Sientes alguna rigidez muscular?', 6, 50),
('¿Cómo sientes tu ánimo en general?', 8, 50);

-- Inserts para el id_test 51
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 51),
('¿Cómo te sientes mentalmente hoy?', 8, 51),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 51),
('¿Cómo es tu nivel de energía actual?', 6, 51),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 51),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 51),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 51),
('¿Sientes alguna rigidez muscular?', 6, 51),
('¿Cómo sientes tu ánimo en general?', 8, 51);

-- Inserts para el id_test 52
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 52),
('¿Cómo te sientes mentalmente hoy?', 7, 52),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 52),
('¿Cómo es tu nivel de energía actual?', 6, 52),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 52),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 52),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 52),
('¿Sientes alguna rigidez muscular?', 7, 52),
('¿Cómo sientes tu ánimo en general?', 6, 52);

-- Inserts para el id_test 53
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 53),
('¿Cómo te sientes mentalmente hoy?', 8, 53),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 53),
('¿Cómo es tu nivel de energía actual?', 6, 53),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 53),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 53),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 53),
('¿Sientes alguna rigidez muscular?', 6, 53),
('¿Cómo sientes tu ánimo en general?', 8, 53);

-- Inserts para el id_test 54
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 54),
('¿Cómo te sientes mentalmente hoy?', 7, 54),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 54),
('¿Cómo es tu nivel de energía actual?', 5, 54),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 54),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 54),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 54),
('¿Sientes alguna rigidez muscular?', 6, 54),
('¿Cómo sientes tu ánimo en general?', 9, 54);

-- Inserts para el id_test 55
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 7, 55),
('¿Cómo te sientes mentalmente hoy?', 8, 55),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 55),
('¿Cómo es tu nivel de energía actual?', 6, 55),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 55),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 55),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 55),
('¿Sientes alguna rigidez muscular?', 9, 55),
('¿Cómo sientes tu ánimo en general?', 8, 55);

-- Inserts para el id_test 56
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 56),
('¿Cómo te sientes mentalmente hoy?', 8, 56),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 56),
('¿Cómo es tu nivel de energía actual?', 7, 56),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 56),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 56),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 56),
('¿Sientes alguna rigidez muscular?', 8, 56),
('¿Cómo sientes tu ánimo en general?', 9, 56);

-- Inserts para el id_test 57
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 57),
('¿Cómo te sientes mentalmente hoy?', 7, 57),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 57),
('¿Cómo es tu nivel de energía actual?', 5, 57),
('¿Tienes alguna molestia o dolor físico hoy?', 6, 57),
('¿Cómo calificarías tu apetito el día de hoy?', 7, 57),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 57),
('¿Sientes alguna rigidez muscular?', 6, 57),
('¿Cómo sientes tu ánimo en general?', 8, 57);

-- Inserts para el id_test 58
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 58),
('¿Cómo te sientes mentalmente hoy?', 8, 58),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 58),
('¿Cómo es tu nivel de energía actual?', 6, 58),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 58),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 58),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 58),
('¿Sientes alguna rigidez muscular?', 7, 58),
('¿Cómo sientes tu ánimo en general?', 8, 58);

-- Inserts para el id_test 59
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 59),
('¿Cómo te sientes mentalmente hoy?', 7, 59),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 59),
('¿Cómo es tu nivel de energía actual?', 6, 59),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 59),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 59),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 59),
('¿Sientes alguna rigidez muscular?', 6, 59),
('¿Cómo sientes tu ánimo en general?', 8, 59);

-- Inserts para el id_test 60
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 60),
('¿Cómo te sientes mentalmente hoy?', 8, 60),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 60),
('¿Cómo es tu nivel de energía actual?', 6, 60),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 60),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 60),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 60),
('¿Sientes alguna rigidez muscular?', 7, 60),
('¿Cómo sientes tu ánimo en general?', 9, 60);

-- Inserts para el id_test 61
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 61),
('¿Cómo te sientes mentalmente hoy?', 7, 61),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 61),
('¿Cómo es tu nivel de energía actual?', 6, 61),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 61),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 61),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 61),
('¿Sientes alguna rigidez muscular?', 6, 61),
('¿Cómo sientes tu ánimo en general?', 8, 61);

-- Inserts para el id_test 62
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 62),
('¿Cómo te sientes mentalmente hoy?', 8, 62),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 62),
('¿Cómo es tu nivel de energía actual?', 5, 62),
('¿Tienes alguna molestia o dolor físico hoy?', 6, 62),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 62),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 62),
('¿Sientes alguna rigidez muscular?', 9, 62),
('¿Cómo sientes tu ánimo en general?', 8, 62);

-- Inserts para el id_test 63
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 63),
('¿Cómo te sientes mentalmente hoy?', 7, 63),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 63),
('¿Cómo es tu nivel de energía actual?', 6, 63),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 63),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 63),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 63),
('¿Sientes alguna rigidez muscular?', 7, 63),
('¿Cómo sientes tu ánimo en general?', 9, 63);

-- Inserts para el id_test 64
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 64),
('¿Cómo te sientes mentalmente hoy?', 8, 64),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 64),
('¿Cómo es tu nivel de energía actual?', 6, 64),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 64),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 64),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 64),
('¿Sientes alguna rigidez muscular?', 6, 64),
('¿Cómo sientes tu ánimo en general?', 8, 64);

-- Inserts para el id_test 65
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 65),
('¿Cómo te sientes mentalmente hoy?', 7, 65),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 65),
('¿Cómo es tu nivel de energía actual?', 5, 65),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 65),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 65),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 65),
('¿Sientes alguna rigidez muscular?', 9, 65),
('¿Cómo sientes tu ánimo en general?', 8, 65);

-- Inserts para el id_test 66
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 66),
('¿Cómo te sientes mentalmente hoy?', 8, 66),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 66),
('¿Cómo es tu nivel de energía actual?', 6, 66),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 66),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 66),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 66),
('¿Sientes alguna rigidez muscular?', 7, 66),
('¿Cómo sientes tu ánimo en general?', 9, 66);

-- Inserts para el id_test 67
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 67),
('¿Cómo te sientes mentalmente hoy?', 7, 67),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 67),
('¿Cómo es tu nivel de energía actual?', 5, 67),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 67),
('¿Cómo calificarías tu apetito el día de hoy?', 6, 67),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 67),
('¿Sientes alguna rigidez muscular?', 6, 67),
('¿Cómo sientes tu ánimo en general?', 8, 67);

-- Inserts para el id_test 68
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 68),
('¿Cómo te sientes mentalmente hoy?', 8, 68),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 68),
('¿Cómo es tu nivel de energía actual?', 5, 68),
('¿Tienes alguna molestia o dolor físico hoy?', 7, 68),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 68),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 68),
('¿Sientes alguna rigidez muscular?', 8, 68),
('¿Cómo sientes tu ánimo en general?', 9, 68);

-- Inserts para el id_test 69
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 69),
('¿Cómo te sientes mentalmente hoy?', 7, 69),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 69),
('¿Cómo es tu nivel de energía actual?', 6, 69),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 69),
('¿Cómo calificarías tu apetito el día de hoy?', 5, 69),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 69),
('¿Sientes alguna rigidez muscular?', 7, 69),
('¿Cómo sientes tu ánimo en general?', 8, 69);

-- Inserts para el id_test 70
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 70),
('¿Cómo te sientes mentalmente hoy?', 8, 70),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 70),
('¿Cómo es tu nivel de energía actual?', 6, 70),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 70),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 70),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 70),
('¿Sientes alguna rigidez muscular?', 7, 70),
('¿Cómo sientes tu ánimo en general?', 9, 70);

-- Inserts para el id_test 71
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 71),
('¿Cómo te sientes mentalmente hoy?', 7, 71),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 71),
('¿Cómo es tu nivel de energía actual?', 5, 71),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 71),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 71),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 71),
('¿Sientes alguna rigidez muscular?', 6, 71),
('¿Cómo sientes tu ánimo en general?', 7, 71);

-- Inserts para el id_test 72
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 72),
('¿Cómo te sientes mentalmente hoy?', 8, 72),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 72),
('¿Cómo es tu nivel de energía actual?', 6, 72),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 72),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 72),
('¿Cuánta motivación sientes para entrenar hoy?', 9, 72),
('¿Sientes alguna rigidez muscular?', 7, 72),
('¿Cómo sientes tu ánimo en general?', 8, 72);

-- Inserts para el id_test 73
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 73),
('¿Cómo te sientes mentalmente hoy?', 6, 73),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 73),
('¿Cómo es tu nivel de energía actual?', 5, 73),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 73),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 73),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 73),
('¿Sientes alguna rigidez muscular?', 8, 73),
('¿Cómo sientes tu ánimo en general?', 9, 73);

-- Inserts para el id_test 74
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 74),
('¿Cómo te sientes mentalmente hoy?', 8, 74),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 74),
('¿Cómo es tu nivel de energía actual?', 6, 74),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 74),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 74),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 74),
('¿Sientes alguna rigidez muscular?', 7, 74),
('¿Cómo sientes tu ánimo en general?', 8, 74);

-- Inserts para el id_test 75
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 75),
('¿Cómo te sientes mentalmente hoy?', 7, 75),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 75),
('¿Cómo es tu nivel de energía actual?', 5, 75),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 75),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 75),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 75),
('¿Sientes alguna rigidez muscular?', 9, 75),
('¿Cómo sientes tu ánimo en general?', 7, 75);

-- Inserts para el id_test 76
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 76),
('¿Cómo te sientes mentalmente hoy?', 8, 76),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 76),
('¿Cómo es tu nivel de energía actual?', 6, 76),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 76),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 76),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 76),
('¿Sientes alguna rigidez muscular?', 8, 76),
('¿Cómo sientes tu ánimo en general?', 9, 76);

-- Inserts para el id_test 77
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 77),
('¿Cómo te sientes mentalmente hoy?', 7, 77),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 77),
('¿Cómo es tu nivel de energía actual?', 5, 77),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 77),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 77),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 77),
('¿Sientes alguna rigidez muscular?', 7, 77),
('¿Cómo sientes tu ánimo en general?', 8, 77);

-- Inserts para el id_test 78
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 78),
('¿Cómo te sientes mentalmente hoy?', 8, 78),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 78),
('¿Cómo es tu nivel de energía actual?', 6, 78),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 78),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 78),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 78),
('¿Sientes alguna rigidez muscular?', 7, 78),
('¿Cómo sientes tu ánimo en general?', 9, 78);

-- Inserts para el id_test 79
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 79),
('¿Cómo te sientes mentalmente hoy?', 7, 79),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 79),
('¿Cómo es tu nivel de energía actual?', 5, 79),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 79),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 79),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 79),
('¿Sientes alguna rigidez muscular?', 7, 79),
('¿Cómo sientes tu ánimo en general?', 8, 79);

-- Inserts para el id_test 80
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 80),
('¿Cómo te sientes mentalmente hoy?', 8, 80),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 80),
('¿Cómo es tu nivel de energía actual?', 6, 80),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 80),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 80),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 80),
('¿Sientes alguna rigidez muscular?', 7, 80),
('¿Cómo sientes tu ánimo en general?', 9, 80);

-- Inserts para el id_test 81
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 81),
('¿Cómo te sientes mentalmente hoy?', 7, 81),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 81),
('¿Cómo es tu nivel de energía actual?', 5, 81),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 81),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 81),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 81),
('¿Sientes alguna rigidez muscular?', 9, 81),
('¿Cómo sientes tu ánimo en general?', 7, 81);

-- Inserts para el id_test 82
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 82),
('¿Cómo te sientes mentalmente hoy?', 8, 82),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 82),
('¿Cómo es tu nivel de energía actual?', 6, 82),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 82),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 82),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 82),
('¿Sientes alguna rigidez muscular?', 7, 82),
('¿Cómo sientes tu ánimo en general?', 8, 82);

-- Inserts para el id_test 83
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 83),
('¿Cómo te sientes mentalmente hoy?', 6, 83),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 9, 83),
('¿Cómo es tu nivel de energía actual?', 5, 83),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 83),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 83),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 83),
('¿Sientes alguna rigidez muscular?', 8, 83),
('¿Cómo sientes tu ánimo en general?', 9, 83);

-- Inserts para el id_test 84
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 84),
('¿Cómo te sientes mentalmente hoy?', 8, 84),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 84),
('¿Cómo es tu nivel de energía actual?', 6, 84),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 84),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 84),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 84),
('¿Sientes alguna rigidez muscular?', 7, 84),
('¿Cómo sientes tu ánimo en general?', 8, 84);

-- Inserts para el id_test 85
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 85),
('¿Cómo te sientes mentalmente hoy?', 7, 85),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 85),
('¿Cómo es tu nivel de energía actual?', 5, 85),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 85),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 85),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 85),
('¿Sientes alguna rigidez muscular?', 9, 85),
('¿Cómo sientes tu ánimo en general?', 7, 85);

-- Inserts para el id_test 86
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 86),
('¿Cómo te sientes mentalmente hoy?', 8, 86),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 86),
('¿Cómo es tu nivel de energía actual?', 6, 86),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 86),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 86),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 86),
('¿Sientes alguna rigidez muscular?', 8, 86),
('¿Cómo sientes tu ánimo en general?', 9, 86);

-- Inserts para el id_test 87
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 87),
('¿Cómo te sientes mentalmente hoy?', 7, 87),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 87),
('¿Cómo es tu nivel de energía actual?', 5, 87),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 87),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 87),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 87),
('¿Sientes alguna rigidez muscular?', 7, 87),
('¿Cómo sientes tu ánimo en general?', 8, 87);

-- Inserts para el id_test 88
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 88),
('¿Cómo te sientes mentalmente hoy?', 8, 88),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 88),
('¿Cómo es tu nivel de energía actual?', 6, 88),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 88),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 88),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 88),
('¿Sientes alguna rigidez muscular?', 8, 88),
('¿Cómo sientes tu ánimo en general?', 9, 88);

-- Inserts para el id_test 89
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 89),
('¿Cómo te sientes mentalmente hoy?', 7, 89),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 89),
('¿Cómo es tu nivel de energía actual?', 5, 89),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 89),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 89),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 89),
('¿Sientes alguna rigidez muscular?', 7, 89),
('¿Cómo sientes tu ánimo en general?', 8, 89);

-- Inserts para el id_test 90
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 90),
('¿Cómo te sientes mentalmente hoy?', 8, 90),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 90),
('¿Cómo es tu nivel de energía actual?', 6, 90),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 90),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 90),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 90),
('¿Sientes alguna rigidez muscular?', 7, 90),
('¿Cómo sientes tu ánimo en general?', 9, 90);

-- Inserts para el id_test 91
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 91),
('¿Cómo te sientes mentalmente hoy?', 7, 91),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 91),
('¿Cómo es tu nivel de energía actual?', 5, 91),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 91),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 91),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 91),
('¿Sientes alguna rigidez muscular?', 7, 91),
('¿Cómo sientes tu ánimo en general?', 8, 91);

-- Inserts para el id_test 92
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 92),
('¿Cómo te sientes mentalmente hoy?', 8, 92),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 92),
('¿Cómo es tu nivel de energía actual?', 6, 92),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 92),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 92),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 92),
('¿Sientes alguna rigidez muscular?', 9, 92),
('¿Cómo sientes tu ánimo en general?', 6, 92);

-- Inserts para el id_test 93
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 93),
('¿Cómo te sientes mentalmente hoy?', 7, 93),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 93),
('¿Cómo es tu nivel de energía actual?', 5, 93),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 93),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 93),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 93),
('¿Sientes alguna rigidez muscular?', 7, 93),
('¿Cómo sientes tu ánimo en general?', 8, 93);

-- Inserts para el id_test 94
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 94),
('¿Cómo te sientes mentalmente hoy?', 8, 94),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 94),
('¿Cómo es tu nivel de energía actual?', 6, 94),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 94),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 94),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 94),
('¿Sientes alguna rigidez muscular?', 9, 94),
('¿Cómo sientes tu ánimo en general?', 6, 94);

-- Inserts para el id_test 95
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 95),
('¿Cómo te sientes mentalmente hoy?', 7, 95),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 95),
('¿Cómo es tu nivel de energía actual?', 5, 95),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 95),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 95),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 95),
('¿Sientes alguna rigidez muscular?', 7, 95),
('¿Cómo sientes tu ánimo en general?', 8, 95);

-- Inserts para el id_test 96
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 96),
('¿Cómo te sientes mentalmente hoy?', 8, 96),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 96),
('¿Cómo es tu nivel de energía actual?', 6, 96),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 96),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 96),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 96),
('¿Sientes alguna rigidez muscular?', 7, 96),
('¿Cómo sientes tu ánimo en general?', 9, 96);

-- Inserts para el id_test 97
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 97),
('¿Cómo te sientes mentalmente hoy?', 7, 97),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 97),
('¿Cómo es tu nivel de energía actual?', 5, 97),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 97),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 97),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 97),
('¿Sientes alguna rigidez muscular?', 7, 97),
('¿Cómo sientes tu ánimo en general?', 8, 97);

-- Inserts para el id_test 98
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 98),
('¿Cómo te sientes mentalmente hoy?', 8, 98),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 98),
('¿Cómo es tu nivel de energía actual?', 6, 98),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 98),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 98),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 98),
('¿Sientes alguna rigidez muscular?', 8, 98),
('¿Cómo sientes tu ánimo en general?', 9, 98);

-- Inserts para el id_test 99
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 99),
('¿Cómo te sientes mentalmente hoy?', 7, 99),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 99),
('¿Cómo es tu nivel de energía actual?', 5, 99),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 99),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 99),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 99),
('¿Sientes alguna rigidez muscular?', 7, 99),
('¿Cómo sientes tu ánimo en general?', 8, 99);

-- Inserts para el id_test 100
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 100),
('¿Cómo te sientes mentalmente hoy?', 8, 100),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 100),
('¿Cómo es tu nivel de energía actual?', 6, 100),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 100),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 100),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 100),
('¿Sientes alguna rigidez muscular?', 7, 100),
('¿Cómo sientes tu ánimo en general?', 9, 100);

-- Inserts para el id_test 101
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 101),
('¿Cómo te sientes mentalmente hoy?', 7, 101),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 101),
('¿Cómo es tu nivel de energía actual?', 5, 101),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 101),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 101),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 101),
('¿Sientes alguna rigidez muscular?', 6, 101),
('¿Cómo sientes tu ánimo en general?', 8, 101);

-- Inserts para el id_test 102
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 102),
('¿Cómo te sientes mentalmente hoy?', 8, 102),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 102),
('¿Cómo es tu nivel de energía actual?', 6, 102),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 102),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 102),
('¿Cuánta motivación sientes para entrenar hoy?', 8, 102),
('¿Sientes alguna rigidez muscular?', 7, 102),
('¿Cómo sientes tu ánimo en general?', 9, 102);

-- Inserts para el id_test 103
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 103),
('¿Cómo te sientes mentalmente hoy?', 7, 103),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 103),
('¿Cómo es tu nivel de energía actual?', 5, 103),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 103),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 103),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 103),
('¿Sientes alguna rigidez muscular?', 7, 103),
('¿Cómo sientes tu ánimo en general?', 8, 103);

-- Inserts para el id_test 104
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 104),
('¿Cómo te sientes mentalmente hoy?', 8, 104),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 104),
('¿Cómo es tu nivel de energía actual?', 6, 104),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 104),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 104),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 104),
('¿Sientes alguna rigidez muscular?', 7, 104),
('¿Cómo sientes tu ánimo en general?', 9, 104);

-- Inserts para el id_test 105
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 105),
('¿Cómo te sientes mentalmente hoy?', 7, 105),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 105),
('¿Cómo es tu nivel de energía actual?', 5, 105),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 105),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 105),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 105),
('¿Sientes alguna rigidez muscular?', 7, 105),
('¿Cómo sientes tu ánimo en general?', 8, 105);

-- Inserts para el id_test 106
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 106),
('¿Cómo te sientes mentalmente hoy?', 8, 106),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 106),
('¿Cómo es tu nivel de energía actual?', 6, 106),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 106),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 106),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 106),
('¿Sientes alguna rigidez muscular?', 8, 106),
('¿Cómo sientes tu ánimo en general?', 9, 106);

-- Inserts para el id_test 107
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 107),
('¿Cómo te sientes mentalmente hoy?', 7, 107),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 107),
('¿Cómo es tu nivel de energía actual?', 5, 107),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 107),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 107),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 107),
('¿Sientes alguna rigidez muscular?', 7, 107),
('¿Cómo sientes tu ánimo en general?', 8, 107);

-- Inserts para el id_test 108
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 108),
('¿Cómo te sientes mentalmente hoy?', 8, 108),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 108),
('¿Cómo es tu nivel de energía actual?', 6, 108),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 108),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 108),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 108),
('¿Sientes alguna rigidez muscular?', 8, 108),
('¿Cómo sientes tu ánimo en general?', 9, 108);

-- Inserts para el id_test 109
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 109),
('¿Cómo te sientes mentalmente hoy?', 7, 109),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 109),
('¿Cómo es tu nivel de energía actual?', 5, 109),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 109),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 109),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 109),
('¿Sientes alguna rigidez muscular?', 7, 109),
('¿Cómo sientes tu ánimo en general?', 8, 109);

-- Inserts para el id_test 110
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 110),
('¿Cómo te sientes mentalmente hoy?', 8, 110),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 110),
('¿Cómo es tu nivel de energía actual?', 6, 110),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 110),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 110),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 110),
('¿Sientes alguna rigidez muscular?', 7, 110),
('¿Cómo sientes tu ánimo en general?', 9, 110);

-- Inserts para el id_test 111
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 111),
('¿Cómo te sientes mentalmente hoy?', 7, 111),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 111),
('¿Cómo es tu nivel de energía actual?', 5, 111),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 111),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 111),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 111),
('¿Sientes alguna rigidez muscular?', 7, 111),
('¿Cómo sientes tu ánimo en general?', 8, 111);

-- Inserts para el id_test 112
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 112),
('¿Cómo te sientes mentalmente hoy?', 8, 112),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 112),
('¿Cómo es tu nivel de energía actual?', 6, 112),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 112),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 112),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 112),
('¿Sientes alguna rigidez muscular?', 8, 112),
('¿Cómo sientes tu ánimo en general?', 9, 112);

-- Inserts para el id_test 113
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 113),
('¿Cómo te sientes mentalmente hoy?', 7, 113),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 113),
('¿Cómo es tu nivel de energía actual?', 5, 113),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 113),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 113),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 113),
('¿Sientes alguna rigidez muscular?', 7, 113),
('¿Cómo sientes tu ánimo en general?', 8, 113);

-- Inserts para el id_test 114
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 114),
('¿Cómo te sientes mentalmente hoy?', 8, 114),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 114),
('¿Cómo es tu nivel de energía actual?', 6, 114),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 114),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 114),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 114),
('¿Sientes alguna rigidez muscular?', 8, 114),
('¿Cómo sientes tu ánimo en general?', 9, 114);

-- Inserts para el id_test 115
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 115),
('¿Cómo te sientes mentalmente hoy?', 7, 115),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 115),
('¿Cómo es tu nivel de energía actual?', 5, 115),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 115),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 115),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 115),
('¿Sientes alguna rigidez muscular?', 7, 115),
('¿Cómo sientes tu ánimo en general?', 8, 115);

-- Inserts para el id_test 116
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 116),
('¿Cómo te sientes mentalmente hoy?', 8, 116),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 116),
('¿Cómo es tu nivel de energía actual?', 6, 116),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 116),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 116),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 116),
('¿Sientes alguna rigidez muscular?', 8, 116),
('¿Cómo sientes tu ánimo en general?', 9, 116);

-- Inserts para el id_test 117
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 117),
('¿Cómo te sientes mentalmente hoy?', 7, 117),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 117),
('¿Cómo es tu nivel de energía actual?', 5, 117),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 117),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 117),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 117),
('¿Sientes alguna rigidez muscular?', 7, 117),
('¿Cómo sientes tu ánimo en general?', 8, 117);

-- Inserts para el id_test 118
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 118),
('¿Cómo te sientes mentalmente hoy?', 8, 118),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 118),
('¿Cómo es tu nivel de energía actual?', 6, 118),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 118),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 118),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 118),
('¿Sientes alguna rigidez muscular?', 8, 118),
('¿Cómo sientes tu ánimo en general?', 9, 118);

-- Inserts para el id_test 119
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 119),
('¿Cómo te sientes mentalmente hoy?', 7, 119),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 119),
('¿Cómo es tu nivel de energía actual?', 5, 119),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 119),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 119),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 119),
('¿Sientes alguna rigidez muscular?', 7, 119),
('¿Cómo sientes tu ánimo en general?', 8, 119);

-- Inserts para el id_test 120
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 120),
('¿Cómo te sientes mentalmente hoy?', 8, 120),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 120),
('¿Cómo es tu nivel de energía actual?', 6, 120),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 120),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 120),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 120),
('¿Sientes alguna rigidez muscular?', 8, 120),
('¿Cómo sientes tu ánimo en general?', 9, 120);

-- Inserts para el id_test 121
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 121),
('¿Cómo te sientes mentalmente hoy?', 7, 121),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 121),
('¿Cómo es tu nivel de energía actual?', 5, 121),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 121),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 121),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 121),
('¿Sientes alguna rigidez muscular?', 7, 121),
('¿Cómo sientes tu ánimo en general?', 8, 121);

-- Inserts para el id_test 122
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 122),
('¿Cómo te sientes mentalmente hoy?', 8, 122),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 122),
('¿Cómo es tu nivel de energía actual?', 6, 122),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 122),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 122),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 122),
('¿Sientes alguna rigidez muscular?', 8, 122),
('¿Cómo sientes tu ánimo en general?', 9, 122);

-- Inserts para el id_test 123
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 123),
('¿Cómo te sientes mentalmente hoy?', 7, 123),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 123),
('¿Cómo es tu nivel de energía actual?', 5, 123),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 123),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 123),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 123),
('¿Sientes alguna rigidez muscular?', 7, 123),
('¿Cómo sientes tu ánimo en general?', 8, 123);

-- Inserts para el id_test 124
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 124),
('¿Cómo te sientes mentalmente hoy?', 8, 124),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 124),
('¿Cómo es tu nivel de energía actual?', 6, 124),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 124),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 124),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 124),
('¿Sientes alguna rigidez muscular?', 8, 124),
('¿Cómo sientes tu ánimo en general?', 9, 124);

-- Inserts para el id_test 125
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 125),
('¿Cómo te sientes mentalmente hoy?', 7, 125),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 125),
('¿Cómo es tu nivel de energía actual?', 5, 125),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 125),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 125),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 125),
('¿Sientes alguna rigidez muscular?', 7, 125),
('¿Cómo sientes tu ánimo en general?', 8, 125);

-- Inserts para el id_test 126
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 126),
('¿Cómo te sientes mentalmente hoy?', 8, 126),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 126),
('¿Cómo es tu nivel de energía actual?', 6, 126),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 126),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 126),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 126),
('¿Sientes alguna rigidez muscular?', 8, 126),
('¿Cómo sientes tu ánimo en general?', 9, 126);

-- Inserts para el id_test 127
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 127),
('¿Cómo te sientes mentalmente hoy?', 7, 127),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 127),
('¿Cómo es tu nivel de energía actual?', 5, 127),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 127),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 127),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 127),
('¿Sientes alguna rigidez muscular?', 7, 127),
('¿Cómo sientes tu ánimo en general?', 8, 127);

-- Inserts para el id_test 128
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 128),
('¿Cómo te sientes mentalmente hoy?', 8, 128),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 128),
('¿Cómo es tu nivel de energía actual?', 6, 128),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 128),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 128),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 128),
('¿Sientes alguna rigidez muscular?', 8, 128),
('¿Cómo sientes tu ánimo en general?', 9, 128);

-- Inserts para el id_test 129
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 129),
('¿Cómo te sientes mentalmente hoy?', 7, 129),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 129),
('¿Cómo es tu nivel de energía actual?', 5, 129),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 129),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 129),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 129),
('¿Sientes alguna rigidez muscular?', 7, 129),
('¿Cómo sientes tu ánimo en general?', 8, 129);

-- Inserts para el id_test 130
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 130),
('¿Cómo te sientes mentalmente hoy?', 8, 130),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 130),
('¿Cómo es tu nivel de energía actual?', 6, 130),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 130),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 130),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 130),
('¿Sientes alguna rigidez muscular?', 8, 130),
('¿Cómo sientes tu ánimo en general?', 9, 130);

-- Inserts para el id_test 131
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 131),
('¿Cómo te sientes mentalmente hoy?', 7, 131),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 131),
('¿Cómo es tu nivel de energía actual?', 5, 131),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 131),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 131),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 131),
('¿Sientes alguna rigidez muscular?', 7, 131),
('¿Cómo sientes tu ánimo en general?', 8, 131);

-- Inserts para el id_test 132
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 132),
('¿Cómo te sientes mentalmente hoy?', 8, 132),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 132),
('¿Cómo es tu nivel de energía actual?', 6, 132),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 132),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 132),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 132),
('¿Sientes alguna rigidez muscular?', 8, 132),
('¿Cómo sientes tu ánimo en general?', 9, 132);

-- Inserts para el id_test 133
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 133),
('¿Cómo te sientes mentalmente hoy?', 7, 133),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 133),
('¿Cómo es tu nivel de energía actual?', 5, 133),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 133),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 133),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 133),
('¿Sientes alguna rigidez muscular?', 7, 133),
('¿Cómo sientes tu ánimo en general?', 8, 133);

-- Inserts para el id_test 134
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 134),
('¿Cómo te sientes mentalmente hoy?', 8, 134),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 134),
('¿Cómo es tu nivel de energía actual?', 6, 134),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 134),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 134),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 134),
('¿Sientes alguna rigidez muscular?', 8, 134),
('¿Cómo sientes tu ánimo en general?', 9, 134);

-- Inserts para el id_test 135
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 135),
('¿Cómo te sientes mentalmente hoy?', 7, 135),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 135),
('¿Cómo es tu nivel de energía actual?', 5, 135),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 135),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 135),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 135),
('¿Sientes alguna rigidez muscular?', 7, 135),
('¿Cómo sientes tu ánimo en general?', 8, 135);

-- Inserts para el id_test 136
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 136),
('¿Cómo te sientes mentalmente hoy?', 8, 136),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 136),
('¿Cómo es tu nivel de energía actual?', 6, 136),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 136),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 136),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 136),
('¿Sientes alguna rigidez muscular?', 8, 136),
('¿Cómo sientes tu ánimo en general?', 9, 136);

-- Inserts para el id_test 137
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 137),
('¿Cómo te sientes mentalmente hoy?', 7, 137),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 137),
('¿Cómo es tu nivel de energía actual?', 5, 137),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 137),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 137),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 137),
('¿Sientes alguna rigidez muscular?', 7, 137),
('¿Cómo sientes tu ánimo en general?', 8, 137);

-- Inserts para el id_test 138
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 138),
('¿Cómo te sientes mentalmente hoy?', 8, 138),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 138),
('¿Cómo es tu nivel de energía actual?', 6, 138),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 138),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 138),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 138),
('¿Sientes alguna rigidez muscular?', 8, 138),
('¿Cómo sientes tu ánimo en general?', 9, 138);

-- Inserts para el id_test 139
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 139),
('¿Cómo te sientes mentalmente hoy?', 7, 139),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 139),
('¿Cómo es tu nivel de energía actual?', 5, 139),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 139),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 139),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 139),
('¿Sientes alguna rigidez muscular?', 7, 139),
('¿Cómo sientes tu ánimo en general?', 8, 139);

-- Inserts para el id_test 140
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 140),
('¿Cómo te sientes mentalmente hoy?', 8, 140),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 140),
('¿Cómo es tu nivel de energía actual?', 6, 140),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 140),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 140),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 140),
('¿Sientes alguna rigidez muscular?', 8, 140),
('¿Cómo sientes tu ánimo en general?', 9, 140);

-- Inserts para el id_test 141
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 141),
('¿Cómo te sientes mentalmente hoy?', 7, 141),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 141),
('¿Cómo es tu nivel de energía actual?', 5, 141),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 141),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 141),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 141),
('¿Sientes alguna rigidez muscular?', 7, 141),
('¿Cómo sientes tu ánimo en general?', 8, 141);

-- Inserts para el id_test 142
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 142),
('¿Cómo te sientes mentalmente hoy?', 8, 142),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 142),
('¿Cómo es tu nivel de energía actual?', 6, 142),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 142),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 142),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 142),
('¿Sientes alguna rigidez muscular?', 8, 142),
('¿Cómo sientes tu ánimo en general?', 9, 142);

-- Inserts para el id_test 143
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 143),
('¿Cómo te sientes mentalmente hoy?', 7, 143),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 143),
('¿Cómo es tu nivel de energía actual?', 5, 143),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 143),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 143),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 143),
('¿Sientes alguna rigidez muscular?', 7, 143),
('¿Cómo sientes tu ánimo en general?', 8, 143);

-- Inserts para el id_test 144
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 144),
('¿Cómo te sientes mentalmente hoy?', 8, 144),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 144),
('¿Cómo es tu nivel de energía actual?', 6, 144),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 144),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 144),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 144),
('¿Sientes alguna rigidez muscular?', 8, 144),
('¿Cómo sientes tu ánimo en general?', 9, 144);

-- Inserts para el id_test 145
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 145),
('¿Cómo te sientes mentalmente hoy?', 7, 145),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 145),
('¿Cómo es tu nivel de energía actual?', 5, 145),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 145),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 145),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 145),
('¿Sientes alguna rigidez muscular?', 7, 145),
('¿Cómo sientes tu ánimo en general?', 8, 145);

-- Inserts para el id_test 146
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 146),
('¿Cómo te sientes mentalmente hoy?', 8, 146),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 146),
('¿Cómo es tu nivel de energía actual?', 6, 146),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 146),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 146),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 146),
('¿Sientes alguna rigidez muscular?', 8, 146),
('¿Cómo sientes tu ánimo en general?', 9, 146);

-- Inserts para el id_test 147
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 147),
('¿Cómo te sientes mentalmente hoy?', 7, 147),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 147),
('¿Cómo es tu nivel de energía actual?', 5, 147),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 147),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 147),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 147),
('¿Sientes alguna rigidez muscular?', 7, 147),
('¿Cómo sientes tu ánimo en general?', 8, 147);

-- Inserts para el id_test 148
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 148),
('¿Cómo te sientes mentalmente hoy?', 8, 148),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 148),
('¿Cómo es tu nivel de energía actual?', 6, 148),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 148),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 148),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 148),
('¿Sientes alguna rigidez muscular?', 8, 148),
('¿Cómo sientes tu ánimo en general?', 9, 148);

-- Inserts para el id_test 149
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 149),
('¿Cómo te sientes mentalmente hoy?', 7, 149),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 149),
('¿Cómo es tu nivel de energía actual?', 5, 149),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 149),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 149),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 149),
('¿Sientes alguna rigidez muscular?', 7, 149),
('¿Cómo sientes tu ánimo en general?', 8, 149);

-- Inserts para el id_test 150
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 150),
('¿Cómo te sientes mentalmente hoy?', 8, 150),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 150),
('¿Cómo es tu nivel de energía actual?', 6, 150),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 150),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 150),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 150),
('¿Sientes alguna rigidez muscular?', 8, 150),
('¿Cómo sientes tu ánimo en general?', 9, 150);

-- Inserts para el id_test 151
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 151),
('¿Cómo te sientes mentalmente hoy?', 7, 151),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 151),
('¿Cómo es tu nivel de energía actual?', 5, 151),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 151),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 151),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 151),
('¿Sientes alguna rigidez muscular?', 7, 151),
('¿Cómo sientes tu ánimo en general?', 8, 151);

-- Inserts para el id_test 152
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 152),
('¿Cómo te sientes mentalmente hoy?', 8, 152),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 152),
('¿Cómo es tu nivel de energía actual?', 6, 152),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 152),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 152),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 152),
('¿Sientes alguna rigidez muscular?', 8, 152),
('¿Cómo sientes tu ánimo en general?', 9, 152);

-- Inserts para el id_test 153
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 153),
('¿Cómo te sientes mentalmente hoy?', 7, 153),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 153),
('¿Cómo es tu nivel de energía actual?', 5, 153),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 153),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 153),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 153),
('¿Sientes alguna rigidez muscular?', 7, 153),
('¿Cómo sientes tu ánimo en general?', 8, 153);

-- Inserts para el id_test 154
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 154),
('¿Cómo te sientes mentalmente hoy?', 8, 154),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 154),
('¿Cómo es tu nivel de energía actual?', 6, 154),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 154),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 154),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 154),
('¿Sientes alguna rigidez muscular?', 8, 154),
('¿Cómo sientes tu ánimo en general?', 9, 154);

-- Inserts para el id_test 155
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 155),
('¿Cómo te sientes mentalmente hoy?', 7, 155),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 155),
('¿Cómo es tu nivel de energía actual?', 5, 155),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 155),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 155),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 155),
('¿Sientes alguna rigidez muscular?', 7, 155),
('¿Cómo sientes tu ánimo en general?', 8, 155);

-- Inserts para el id_test 156
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 156),
('¿Cómo te sientes mentalmente hoy?', 8, 156),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 156),
('¿Cómo es tu nivel de energía actual?', 6, 156),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 156),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 156),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 156),
('¿Sientes alguna rigidez muscular?', 8, 156),
('¿Cómo sientes tu ánimo en general?', 9, 156);

-- Inserts para el id_test 157
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 157),
('¿Cómo te sientes mentalmente hoy?', 7, 157),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 157),
('¿Cómo es tu nivel de energía actual?', 5, 157),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 157),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 157),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 157),
('¿Sientes alguna rigidez muscular?', 7, 157),
('¿Cómo sientes tu ánimo en general?', 8, 157);

-- Inserts para el id_test 158
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 158),
('¿Cómo te sientes mentalmente hoy?', 8, 158),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 158),
('¿Cómo es tu nivel de energía actual?', 6, 158),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 158),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 158),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 158),
('¿Sientes alguna rigidez muscular?', 8, 158),
('¿Cómo sientes tu ánimo en general?', 9, 158);

-- Inserts para el id_test 159
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 159),
('¿Cómo te sientes mentalmente hoy?', 7, 159),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 159),
('¿Cómo es tu nivel de energía actual?', 5, 159),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 159),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 159),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 159),
('¿Sientes alguna rigidez muscular?', 7, 159),
('¿Cómo sientes tu ánimo en general?', 8, 159);

-- Inserts para el id_test 160
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 160),
('¿Cómo te sientes mentalmente hoy?', 8, 160),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 160),
('¿Cómo es tu nivel de energía actual?', 6, 160),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 160),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 160),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 160),
('¿Sientes alguna rigidez muscular?', 8, 160),
('¿Cómo sientes tu ánimo en general?', 9, 160);

-- Inserts para el id_test 161
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 161),
('¿Cómo te sientes mentalmente hoy?', 7, 161),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 161),
('¿Cómo es tu nivel de energía actual?', 5, 161),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 161),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 161),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 161),
('¿Sientes alguna rigidez muscular?', 7, 161),
('¿Cómo sientes tu ánimo en general?', 8, 161);

-- Inserts para el id_test 162
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 162),
('¿Cómo te sientes mentalmente hoy?', 8, 162),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 162),
('¿Cómo es tu nivel de energía actual?', 6, 162),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 162),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 162),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 162),
('¿Sientes alguna rigidez muscular?', 8, 162),
('¿Cómo sientes tu ánimo en general?', 9, 162);

-- Inserts para el id_test 163
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 163),
('¿Cómo te sientes mentalmente hoy?', 7, 163),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 163),
('¿Cómo es tu nivel de energía actual?', 5, 163),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 163),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 163),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 163),
('¿Sientes alguna rigidez muscular?', 7, 163),
('¿Cómo sientes tu ánimo en general?', 8, 163);

-- Inserts para el id_test 164
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 164),
('¿Cómo te sientes mentalmente hoy?', 8, 164),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 164),
('¿Cómo es tu nivel de energía actual?', 6, 164),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 164),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 164),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 164),
('¿Sientes alguna rigidez muscular?', 8, 164),
('¿Cómo sientes tu ánimo en general?', 9, 164);

-- Inserts para el id_test 165
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 165),
('¿Cómo te sientes mentalmente hoy?', 7, 165),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 165),
('¿Cómo es tu nivel de energía actual?', 5, 165),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 165),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 165),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 165),
('¿Sientes alguna rigidez muscular?', 7, 165),
('¿Cómo sientes tu ánimo en general?', 8, 165);

-- Inserts para el id_test 166
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 166),
('¿Cómo te sientes mentalmente hoy?', 8, 166),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 166),
('¿Cómo es tu nivel de energía actual?', 6, 166),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 166),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 166),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 166),
('¿Sientes alguna rigidez muscular?', 8, 166),
('¿Cómo sientes tu ánimo en general?', 9, 166);

-- Inserts para el id_test 167
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 167),
('¿Cómo te sientes mentalmente hoy?', 7, 167),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 167),
('¿Cómo es tu nivel de energía actual?', 5, 167),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 167),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 167),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 167),
('¿Sientes alguna rigidez muscular?', 7, 167),
('¿Cómo sientes tu ánimo en general?', 8, 167);

-- Inserts para el id_test 168
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 168),
('¿Cómo te sientes mentalmente hoy?', 8, 168),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 168),
('¿Cómo es tu nivel de energía actual?', 6, 168),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 168),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 168),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 168),
('¿Sientes alguna rigidez muscular?', 8, 168),
('¿Cómo sientes tu ánimo en general?', 9, 168);

-- Inserts para el id_test 169
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 169),
('¿Cómo te sientes mentalmente hoy?', 7, 169),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 169),
('¿Cómo es tu nivel de energía actual?', 5, 169),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 169),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 169),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 169),
('¿Sientes alguna rigidez muscular?', 7, 169),
('¿Cómo sientes tu ánimo en general?', 8, 169);

-- Inserts para el id_test 170
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 170),
('¿Cómo te sientes mentalmente hoy?', 8, 170),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 170),
('¿Cómo es tu nivel de energía actual?', 6, 170),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 170),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 170),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 170),
('¿Sientes alguna rigidez muscular?', 8, 170),
('¿Cómo sientes tu ánimo en general?', 9, 170);

-- Inserts para el id_test 171
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 171),
('¿Cómo te sientes mentalmente hoy?', 7, 171),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 171),
('¿Cómo es tu nivel de energía actual?', 5, 171),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 171),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 171),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 171),
('¿Sientes alguna rigidez muscular?', 7, 171),
('¿Cómo sientes tu ánimo en general?', 8, 171);

-- Inserts para el id_test 172
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 172),
('¿Cómo te sientes mentalmente hoy?', 8, 172),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 172),
('¿Cómo es tu nivel de energía actual?', 6, 172),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 172),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 172),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 172),
('¿Sientes alguna rigidez muscular?', 8, 172),
('¿Cómo sientes tu ánimo en general?', 9, 172);

-- Inserts para el id_test 173
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 173),
('¿Cómo te sientes mentalmente hoy?', 7, 173),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 173),
('¿Cómo es tu nivel de energía actual?', 5, 173),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 173),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 173),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 173),
('¿Sientes alguna rigidez muscular?', 7, 173),
('¿Cómo sientes tu ánimo en general?', 8, 173);

-- Inserts para el id_test 174
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 174),
('¿Cómo te sientes mentalmente hoy?', 8, 174),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 174),
('¿Cómo es tu nivel de energía actual?', 6, 174),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 174),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 174),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 174),
('¿Sientes alguna rigidez muscular?', 8, 174),
('¿Cómo sientes tu ánimo en general?', 9, 174);

-- Inserts para el id_test 175
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 175),
('¿Cómo te sientes mentalmente hoy?', 7, 175),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 175),
('¿Cómo es tu nivel de energía actual?', 5, 175),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 175),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 175),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 175),
('¿Sientes alguna rigidez muscular?', 7, 175),
('¿Cómo sientes tu ánimo en general?', 8, 175);

-- Inserts para el id_test 176
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 176),
('¿Cómo te sientes mentalmente hoy?', 8, 176),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 176),
('¿Cómo es tu nivel de energía actual?', 6, 176),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 176),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 176),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 176),
('¿Sientes alguna rigidez muscular?', 8, 176),
('¿Cómo sientes tu ánimo en general?', 9, 176);

-- Inserts para el id_test 177
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 177),
('¿Cómo te sientes mentalmente hoy?', 7, 177),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 177),
('¿Cómo es tu nivel de energía actual?', 5, 177),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 177),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 177),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 177),
('¿Sientes alguna rigidez muscular?', 7, 177),
('¿Cómo sientes tu ánimo en general?', 8, 177);

-- Inserts para el id_test 178
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 178),
('¿Cómo te sientes mentalmente hoy?', 8, 178),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 178),
('¿Cómo es tu nivel de energía actual?', 6, 178),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 178),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 178),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 178),
('¿Sientes alguna rigidez muscular?', 8, 178),
('¿Cómo sientes tu ánimo en general?', 9, 178);

-- Inserts para el id_test 179
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 179),
('¿Cómo te sientes mentalmente hoy?', 7, 179),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 179),
('¿Cómo es tu nivel de energía actual?', 5, 179),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 179),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 179),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 179),
('¿Sientes alguna rigidez muscular?', 7, 179),
('¿Cómo sientes tu ánimo en general?', 8, 179);

-- Inserts para el id_test 180
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 180),
('¿Cómo te sientes mentalmente hoy?', 8, 180),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 180),
('¿Cómo es tu nivel de energía actual?', 6, 180),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 180),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 180),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 180),
('¿Sientes alguna rigidez muscular?', 8, 180),
('¿Cómo sientes tu ánimo en general?', 9, 180);

-- Inserts para el id_test 181
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 181),
('¿Cómo te sientes mentalmente hoy?', 7, 181),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 181),
('¿Cómo es tu nivel de energía actual?', 5, 181),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 181),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 181),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 181),
('¿Sientes alguna rigidez muscular?', 7, 181),
('¿Cómo sientes tu ánimo en general?', 8, 181);

-- Inserts para el id_test 182
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 182),
('¿Cómo te sientes mentalmente hoy?', 8, 182),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 182),
('¿Cómo es tu nivel de energía actual?', 6, 182),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 182),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 182),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 182),
('¿Sientes alguna rigidez muscular?', 8, 182),
('¿Cómo sientes tu ánimo en general?', 9, 182);

-- Inserts para el id_test 183
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 183),
('¿Cómo te sientes mentalmente hoy?', 7, 183),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 183),
('¿Cómo es tu nivel de energía actual?', 5, 183),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 183),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 183),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 183),
('¿Sientes alguna rigidez muscular?', 7, 183),
('¿Cómo sientes tu ánimo en general?', 8, 183);

-- Inserts para el id_test 184
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 184),
('¿Cómo te sientes mentalmente hoy?', 8, 184),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 184),
('¿Cómo es tu nivel de energía actual?', 6, 184),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 184),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 184),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 184),
('¿Sientes alguna rigidez muscular?', 8, 184),
('¿Cómo sientes tu ánimo en general?', 9, 184);

-- Inserts para el id_test 185
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 185),
('¿Cómo te sientes mentalmente hoy?', 7, 185),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 185),
('¿Cómo es tu nivel de energía actual?', 5, 185),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 185),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 185),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 185),
('¿Sientes alguna rigidez muscular?', 7, 185),
('¿Cómo sientes tu ánimo en general?', 8, 185);

-- Inserts para el id_test 186
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 186),
('¿Cómo te sientes mentalmente hoy?', 8, 186),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 186),
('¿Cómo es tu nivel de energía actual?', 6, 186),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 186),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 186),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 186),
('¿Sientes alguna rigidez muscular?', 8, 186),
('¿Cómo sientes tu ánimo en general?', 9, 186);

-- Inserts para el id_test 187
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 187),
('¿Cómo te sientes mentalmente hoy?', 7, 187),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 187),
('¿Cómo es tu nivel de energía actual?', 5, 187),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 187),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 187),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 187),
('¿Sientes alguna rigidez muscular?', 7, 187),
('¿Cómo sientes tu ánimo en general?', 8, 187);

-- Inserts para el id_test 188
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 188),
('¿Cómo te sientes mentalmente hoy?', 8, 188),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 188),
('¿Cómo es tu nivel de energía actual?', 6, 188),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 188),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 188),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 188),
('¿Sientes alguna rigidez muscular?', 8, 188),
('¿Cómo sientes tu ánimo en general?', 9, 188);

-- Inserts para el id_test 189
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 189),
('¿Cómo te sientes mentalmente hoy?', 7, 189),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 189),
('¿Cómo es tu nivel de energía actual?', 5, 189),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 189),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 189),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 189),
('¿Sientes alguna rigidez muscular?', 7, 189),
('¿Cómo sientes tu ánimo en general?', 8, 189);

-- Inserts para el id_test 190
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 190),
('¿Cómo te sientes mentalmente hoy?', 8, 190),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 190),
('¿Cómo es tu nivel de energía actual?', 6, 190),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 190),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 190),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 190),
('¿Sientes alguna rigidez muscular?', 8, 190),
('¿Cómo sientes tu ánimo en general?', 9, 190);

-- Inserts para el id_test 191
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 191),
('¿Cómo te sientes mentalmente hoy?', 7, 191),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 191),
('¿Cómo es tu nivel de energía actual?', 5, 191),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 191),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 191),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 191),
('¿Sientes alguna rigidez muscular?', 7, 191),
('¿Cómo sientes tu ánimo en general?', 8, 191);

-- Inserts para el id_test 192
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 192),
('¿Cómo te sientes mentalmente hoy?', 8, 192),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 192),
('¿Cómo es tu nivel de energía actual?', 6, 192),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 192),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 192),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 192),
('¿Sientes alguna rigidez muscular?', 8, 192),
('¿Cómo sientes tu ánimo en general?', 9, 192);

-- Inserts para el id_test 193
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 193),
('¿Cómo te sientes mentalmente hoy?', 7, 193),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 193),
('¿Cómo es tu nivel de energía actual?', 5, 193),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 193),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 193),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 193),
('¿Sientes alguna rigidez muscular?', 7, 193),
('¿Cómo sientes tu ánimo en general?', 8, 193);

-- Inserts para el id_test 194
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 194),
('¿Cómo te sientes mentalmente hoy?', 8, 194),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 194),
('¿Cómo es tu nivel de energía actual?', 6, 194),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 194),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 194),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 194),
('¿Sientes alguna rigidez muscular?', 8, 194),
('¿Cómo sientes tu ánimo en general?', 9, 194);

-- Inserts para el id_test 195
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 195),
('¿Cómo te sientes mentalmente hoy?', 7, 195),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 195),
('¿Cómo es tu nivel de energía actual?', 5, 195),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 195),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 195),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 195),
('¿Sientes alguna rigidez muscular?', 7, 195),
('¿Cómo sientes tu ánimo en general?', 8, 195);

-- Inserts para el id_test 196
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 196),
('¿Cómo te sientes mentalmente hoy?', 8, 196),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 196),
('¿Cómo es tu nivel de energía actual?', 6, 196),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 196),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 196),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 196),
('¿Sientes alguna rigidez muscular?', 8, 196),
('¿Cómo sientes tu ánimo en general?', 9, 196);

-- Inserts para el id_test 197
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 197),
('¿Cómo te sientes mentalmente hoy?', 7, 197),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 197),
('¿Cómo es tu nivel de energía actual?', 5, 197),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 197),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 197),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 197),
('¿Sientes alguna rigidez muscular?', 7, 197),
('¿Cómo sientes tu ánimo en general?', 8, 197);

-- Inserts para el id_test 198
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 198),
('¿Cómo te sientes mentalmente hoy?', 8, 198),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 198),
('¿Cómo es tu nivel de energía actual?', 6, 198),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 198),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 198),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 198),
('¿Sientes alguna rigidez muscular?', 8, 198),
('¿Cómo sientes tu ánimo en general?', 9, 198);

-- Inserts para el id_test 199
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 199),
('¿Cómo te sientes mentalmente hoy?', 7, 199),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 199),
('¿Cómo es tu nivel de energía actual?', 5, 199),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 199),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 199),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 199),
('¿Sientes alguna rigidez muscular?', 7, 199),
('¿Cómo sientes tu ánimo en general?', 8, 199);

-- Inserts para el id_test 200
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 200),
('¿Cómo te sientes mentalmente hoy?', 8, 200),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 200),
('¿Cómo es tu nivel de energía actual?', 6, 200),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 200),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 200),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 200),
('¿Sientes alguna rigidez muscular?', 8, 200),
('¿Cómo sientes tu ánimo en general?', 9, 200);

-- Inserts para el id_test 201
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 201),
('¿Cómo te sientes mentalmente hoy?', 7, 201),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 201),
('¿Cómo es tu nivel de energía actual?', 5, 201),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 201),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 201),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 201),
('¿Sientes alguna rigidez muscular?', 7, 201),
('¿Cómo sientes tu ánimo en general?', 8, 201);

-- Inserts para el id_test 202
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 202),
('¿Cómo te sientes mentalmente hoy?', 8, 202),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 202),
('¿Cómo es tu nivel de energía actual?', 6, 202),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 202),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 202),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 202),
('¿Sientes alguna rigidez muscular?', 8, 202),
('¿Cómo sientes tu ánimo en general?', 9, 202);

-- Inserts para el id_test 203
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 203),
('¿Cómo te sientes mentalmente hoy?', 7, 203),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 203),
('¿Cómo es tu nivel de energía actual?', 5, 203),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 203),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 203),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 203),
('¿Sientes alguna rigidez muscular?', 7, 203),
('¿Cómo sientes tu ánimo en general?', 8, 203);

-- Inserts para el id_test 204
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 204),
('¿Cómo te sientes mentalmente hoy?', 8, 204),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 204),
('¿Cómo es tu nivel de energía actual?', 6, 204),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 204),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 204),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 204),
('¿Sientes alguna rigidez muscular?', 8, 204),
('¿Cómo sientes tu ánimo en general?', 9, 204);

-- Inserts para el id_test 205
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 205),
('¿Cómo te sientes mentalmente hoy?', 7, 205),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 205),
('¿Cómo es tu nivel de energía actual?', 5, 205),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 205),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 205),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 205),
('¿Sientes alguna rigidez muscular?', 7, 205),
('¿Cómo sientes tu ánimo en general?', 8, 205);

-- Inserts para el id_test 206
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 206),
('¿Cómo te sientes mentalmente hoy?', 8, 206),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 206),
('¿Cómo es tu nivel de energía actual?', 6, 206),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 206),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 206),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 206),
('¿Sientes alguna rigidez muscular?', 8, 206),
('¿Cómo sientes tu ánimo en general?', 9, 206);

-- Inserts para el id_test 207
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 207),
('¿Cómo te sientes mentalmente hoy?', 7, 207),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 207),
('¿Cómo es tu nivel de energía actual?', 5, 207),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 207),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 207),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 207),
('¿Sientes alguna rigidez muscular?', 7, 207),
('¿Cómo sientes tu ánimo en general?', 8, 207);

-- Inserts para el id_test 208
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 208),
('¿Cómo te sientes mentalmente hoy?', 8, 208),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 208),
('¿Cómo es tu nivel de energía actual?', 6, 208),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 208),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 208),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 208),
('¿Sientes alguna rigidez muscular?', 8, 208),
('¿Cómo sientes tu ánimo en general?', 9, 208);

-- Inserts para el id_test 209
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 209),
('¿Cómo te sientes mentalmente hoy?', 7, 209),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 209),
('¿Cómo es tu nivel de energía actual?', 5, 209),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 209),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 209),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 209),
('¿Sientes alguna rigidez muscular?', 7, 209),
('¿Cómo sientes tu ánimo en general?', 8, 209);

-- Inserts para el id_test 210
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 210),
('¿Cómo te sientes mentalmente hoy?', 8, 210),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 210),
('¿Cómo es tu nivel de energía actual?', 6, 210),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 210),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 210),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 210),
('¿Sientes alguna rigidez muscular?', 8, 210),
('¿Cómo sientes tu ánimo en general?', 9, 210);

-- Inserts para el id_test 211
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 211),
('¿Cómo te sientes mentalmente hoy?', 7, 211),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 211),
('¿Cómo es tu nivel de energía actual?', 5, 211),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 211),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 211),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 211),
('¿Sientes alguna rigidez muscular?', 7, 211),
('¿Cómo sientes tu ánimo en general?', 8, 211);

-- Inserts para el id_test 212
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 212),
('¿Cómo te sientes mentalmente hoy?', 8, 212),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 212),
('¿Cómo es tu nivel de energía actual?', 6, 212),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 212),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 212),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 212),
('¿Sientes alguna rigidez muscular?', 8, 212),
('¿Cómo sientes tu ánimo en general?', 9, 212);

-- Inserts para el id_test 213
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 213),
('¿Cómo te sientes mentalmente hoy?', 7, 213),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 213),
('¿Cómo es tu nivel de energía actual?', 5, 213),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 213),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 213),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 213),
('¿Sientes alguna rigidez muscular?', 7, 213),
('¿Cómo sientes tu ánimo en general?', 8, 213);

-- Inserts para el id_test 214
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 214),
('¿Cómo te sientes mentalmente hoy?', 8, 214),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 214),
('¿Cómo es tu nivel de energía actual?', 6, 214),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 214),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 214),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 214),
('¿Sientes alguna rigidez muscular?', 8, 214),
('¿Cómo sientes tu ánimo en general?', 9, 214);

-- Inserts para el id_test 215
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 215),
('¿Cómo te sientes mentalmente hoy?', 7, 215),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 215),
('¿Cómo es tu nivel de energía actual?', 5, 215),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 215),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 215),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 215),
('¿Sientes alguna rigidez muscular?', 7, 215),
('¿Cómo sientes tu ánimo en general?', 8, 215);

-- Inserts para el id_test 216
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 216),
('¿Cómo te sientes mentalmente hoy?', 8, 216),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 216),
('¿Cómo es tu nivel de energía actual?', 6, 216),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 216),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 216),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 216),
('¿Sientes alguna rigidez muscular?', 8, 216),
('¿Cómo sientes tu ánimo en general?', 9, 216);

-- Inserts para el id_test 217
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 217),
('¿Cómo te sientes mentalmente hoy?', 7, 217),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 217),
('¿Cómo es tu nivel de energía actual?', 5, 217),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 217),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 217),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 217),
('¿Sientes alguna rigidez muscular?', 7, 217),
('¿Cómo sientes tu ánimo en general?', 8, 217);

-- Inserts para el id_test 218
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 218),
('¿Cómo te sientes mentalmente hoy?', 8, 218),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 218),
('¿Cómo es tu nivel de energía actual?', 6, 218),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 218),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 218),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 218),
('¿Sientes alguna rigidez muscular?', 8, 218),
('¿Cómo sientes tu ánimo en general?', 9, 218);

-- Inserts para el id_test 219
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 219),
('¿Cómo te sientes mentalmente hoy?', 7, 219),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 219),
('¿Cómo es tu nivel de energía actual?', 5, 219),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 219),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 219),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 219),
('¿Sientes alguna rigidez muscular?', 7, 219),
('¿Cómo sientes tu ánimo en general?', 8, 219);

-- Inserts para el id_test 220
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 220),
('¿Cómo te sientes mentalmente hoy?', 8, 220),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 220),
('¿Cómo es tu nivel de energía actual?', 6, 220),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 220),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 220),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 220),
('¿Sientes alguna rigidez muscular?', 8, 220),
('¿Cómo sientes tu ánimo en general?', 9, 220);

-- Inserts para el id_test 221
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 221),
('¿Cómo te sientes mentalmente hoy?', 7, 221),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 221),
('¿Cómo es tu nivel de energía actual?', 5, 221),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 221),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 221),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 221),
('¿Sientes alguna rigidez muscular?', 7, 221),
('¿Cómo sientes tu ánimo en general?', 8, 221);

-- Inserts para el id_test 222
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 222),
('¿Cómo te sientes mentalmente hoy?', 8, 222),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 222),
('¿Cómo es tu nivel de energía actual?', 6, 222),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 222),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 222),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 222),
('¿Sientes alguna rigidez muscular?', 8, 222),
('¿Cómo sientes tu ánimo en general?', 9, 222);

-- Inserts para el id_test 223
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 223),
('¿Cómo te sientes mentalmente hoy?', 7, 223),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 223),
('¿Cómo es tu nivel de energía actual?', 5, 223),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 223),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 223),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 223),
('¿Sientes alguna rigidez muscular?', 7, 223),
('¿Cómo sientes tu ánimo en general?', 8, 223);

-- Inserts para el id_test 224
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 224),
('¿Cómo te sientes mentalmente hoy?', 8, 224),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 224),
('¿Cómo es tu nivel de energía actual?', 6, 224),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 224),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 224),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 224),
('¿Sientes alguna rigidez muscular?', 8, 224),
('¿Cómo sientes tu ánimo en general?', 9, 224);

-- Inserts para el id_test 225
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 225),
('¿Cómo te sientes mentalmente hoy?', 7, 225),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 225),
('¿Cómo es tu nivel de energía actual?', 5, 225),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 225),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 225),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 225),
('¿Sientes alguna rigidez muscular?', 7, 225),
('¿Cómo sientes tu ánimo en general?', 8, 225);

-- Inserts para el id_test 226
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 226),
('¿Cómo te sientes mentalmente hoy?', 8, 226),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 226),
('¿Cómo es tu nivel de energía actual?', 6, 226),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 226),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 226),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 226),
('¿Sientes alguna rigidez muscular?', 8, 226),
('¿Cómo sientes tu ánimo en general?', 9, 226);

-- Inserts para el id_test 227
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 227),
('¿Cómo te sientes mentalmente hoy?', 7, 227),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 227),
('¿Cómo es tu nivel de energía actual?', 5, 227),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 227),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 227),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 227),
('¿Sientes alguna rigidez muscular?', 7, 227),
('¿Cómo sientes tu ánimo en general?', 8, 227);

-- Inserts para el id_test 228
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 228),
('¿Cómo te sientes mentalmente hoy?', 8, 228),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 228),
('¿Cómo es tu nivel de energía actual?', 6, 228),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 228),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 228),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 228),
('¿Sientes alguna rigidez muscular?', 8, 228),
('¿Cómo sientes tu ánimo en general?', 9, 228);

-- Inserts para el id_test 229
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 229),
('¿Cómo te sientes mentalmente hoy?', 7, 229),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 229),
('¿Cómo es tu nivel de energía actual?', 5, 229),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 229),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 229),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 229),
('¿Sientes alguna rigidez muscular?', 7, 229),
('¿Cómo sientes tu ánimo en general?', 8, 229);

-- Inserts para el id_test 230
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 230),
('¿Cómo te sientes mentalmente hoy?', 8, 230),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 230),
('¿Cómo es tu nivel de energía actual?', 6, 230),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 230),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 230),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 230),
('¿Sientes alguna rigidez muscular?', 8, 230),
('¿Cómo sientes tu ánimo en general?', 9, 230);

-- Inserts para el id_test 231
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 231),
('¿Cómo te sientes mentalmente hoy?', 7, 231),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 231),
('¿Cómo es tu nivel de energía actual?', 5, 231),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 231),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 231),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 231),
('¿Sientes alguna rigidez muscular?', 7, 231),
('¿Cómo sientes tu ánimo en general?', 8, 231);

-- Inserts para el id_test 232
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 232),
('¿Cómo te sientes mentalmente hoy?', 8, 232),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 232),
('¿Cómo es tu nivel de energía actual?', 6, 232),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 232),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 232),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 232),
('¿Sientes alguna rigidez muscular?', 8, 232),
('¿Cómo sientes tu ánimo en general?', 9, 232);

-- Inserts para el id_test 233
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 233),
('¿Cómo te sientes mentalmente hoy?', 7, 233),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 233),
('¿Cómo es tu nivel de energía actual?', 5, 233),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 233),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 233),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 233),
('¿Sientes alguna rigidez muscular?', 7, 233),
('¿Cómo sientes tu ánimo en general?', 8, 233);

-- Inserts para el id_test 234
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 234),
('¿Cómo te sientes mentalmente hoy?', 8, 234),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 234),
('¿Cómo es tu nivel de energía actual?', 6, 234),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 234),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 234),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 234),
('¿Sientes alguna rigidez muscular?', 8, 234),
('¿Cómo sientes tu ánimo en general?', 9, 234);

-- Inserts para el id_test 235
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 235),
('¿Cómo te sientes mentalmente hoy?', 7, 235),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 235),
('¿Cómo es tu nivel de energía actual?', 5, 235),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 235),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 235),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 235),
('¿Sientes alguna rigidez muscular?', 7, 235),
('¿Cómo sientes tu ánimo en general?', 8, 235);

-- Inserts para el id_test 236
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 236),
('¿Cómo te sientes mentalmente hoy?', 8, 236),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 236),
('¿Cómo es tu nivel de energía actual?', 6, 236),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 236),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 236),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 236),
('¿Sientes alguna rigidez muscular?', 8, 236),
('¿Cómo sientes tu ánimo en general?', 9, 236);

-- Inserts para el id_test 237
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 237),
('¿Cómo te sientes mentalmente hoy?', 7, 237),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 237),
('¿Cómo es tu nivel de energía actual?', 5, 237),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 237),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 237),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 237),
('¿Sientes alguna rigidez muscular?', 7, 237),
('¿Cómo sientes tu ánimo en general?', 8, 237);

-- Inserts para el id_test 238
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 238),
('¿Cómo te sientes mentalmente hoy?', 8, 238),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 238),
('¿Cómo es tu nivel de energía actual?', 6, 238),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 238),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 238),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 238),
('¿Sientes alguna rigidez muscular?', 8, 238),
('¿Cómo sientes tu ánimo en general?', 9, 238);

-- Inserts para el id_test 239
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 239),
('¿Cómo te sientes mentalmente hoy?', 7, 239),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 239),
('¿Cómo es tu nivel de energía actual?', 5, 239),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 239),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 239),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 239),
('¿Sientes alguna rigidez muscular?', 7, 239),
('¿Cómo sientes tu ánimo en general?', 8, 239);

-- Inserts para el id_test 240
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 240),
('¿Cómo te sientes mentalmente hoy?', 8, 240),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 240),
('¿Cómo es tu nivel de energía actual?', 6, 240),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 240),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 240),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 240),
('¿Sientes alguna rigidez muscular?', 8, 240),
('¿Cómo sientes tu ánimo en general?', 9, 240);

-- Inserts para el id_test 241
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 241),
('¿Cómo te sientes mentalmente hoy?', 7, 241),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 241),
('¿Cómo es tu nivel de energía actual?', 5, 241),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 241),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 241),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 241),
('¿Sientes alguna rigidez muscular?', 7, 241),
('¿Cómo sientes tu ánimo en general?', 8, 241);

-- Inserts para el id_test 242
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 242),
('¿Cómo te sientes mentalmente hoy?', 8, 242),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 242),
('¿Cómo es tu nivel de energía actual?', 6, 242),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 242),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 242),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 242),
('¿Sientes alguna rigidez muscular?', 8, 242),
('¿Cómo sientes tu ánimo en general?', 9, 242);

-- Inserts para el id_test 243
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 8, 243),
('¿Cómo te sientes mentalmente hoy?', 7, 243),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 6, 243),
('¿Cómo es tu nivel de energía actual?', 5, 243),
('¿Tienes alguna molestia o dolor físico hoy?', 4, 243),
('¿Cómo calificarías tu apetito el día de hoy?', 8, 243),
('¿Cuánta motivación sientes para entrenar hoy?', 6, 243),
('¿Sientes alguna rigidez muscular?', 7, 243),
('¿Cómo sientes tu ánimo en general?', 8, 243);

-- Inserts para el id_test 244
INSERT INTO respuesta_test (pregunta, respuesta, id_test)
VALUES 
('¿Cómo te sientes físicamente hoy?', 9, 244),
('¿Cómo te sientes mentalmente hoy?', 8, 244),
('¿Cómo calificas la calidad de tu sueño la noche pasada?', 7, 244),
('¿Cómo es tu nivel de energía actual?', 6, 244),
('¿Tienes alguna molestia o dolor físico hoy?', 5, 244),
('¿Cómo calificarías tu apetito el día de hoy?', 9, 244),
('¿Cuánta motivación sientes para entrenar hoy?', 7, 244),
('¿Sientes alguna rigidez muscular?', 8, 244),
('¿Cómo sientes tu ánimo en general?', 9, 244);


SET GLOBAL event_scheduler = ON;

SELECT * FROM notificaciones;

DROP EVENT IF EXISTS generar_recap_mensual;
CREATE EVENT IF NOT EXISTS generar_recap_mensual
ON SCHEDULE EVERY 1 MONTH
STARTS (CURRENT_DATE + INTERVAL (1 - DAY(CURRENT_DATE)) DAY + INTERVAL 1 DAY)
DO
  INSERT INTO notificaciones (titulo, mensaje, tipo_notificacion, id_jugador)
  SELECT 
    'Tu recap mensual está listo', 
    'Puedes ver tu RECAP de este mes presionando aquí', 
    'Eventos', 
    pp.id_jugador
  FROM participaciones_partidos pp
  INNER JOIN partidos p ON pp.id_partido = p.id_partido
  WHERE p.fecha_partido BETWEEN DATE_SUB(LAST_DAY(CURRENT_DATE - INTERVAL 1 MONTH), INTERVAL DAY(LAST_DAY(CURRENT_DATE - INTERVAL 1 MONTH)) - 1 DAY)
    AND LAST_DAY(CURRENT_DATE - INTERVAL 1 MONTH)
  GROUP BY pp.id_jugador
  HAVING COUNT(pp.id_partido) > 0;
  
DELIMITER //
DROP TRIGGER IF EXISTS insertar_notificacion_registro_medico;
CREATE TRIGGER insertar_notificacion_registro_medico
AFTER INSERT ON registros_medicos
FOR EACH ROW
BEGIN
  INSERT INTO notificaciones (titulo, mensaje, tipo_notificacion, id_jugador)
  VALUES (
    'Nuevo registro médico', 
    CONCAT('Se ha registrado un nuevo reporte médico para ti. Fecha del reporte: ', NEW.fecha_registro),
    'Registro medico', 
    NEW.id_jugador
  );
END//

DELIMITER;

DELIMITER //
DROP TRIGGER IF EXISTS notificacion_nuevo_entrenamiento;
CREATE TRIGGER notificacion_nuevo_entrenamiento
AFTER INSERT ON entrenamientos
FOR EACH ROW
BEGIN
  -- Insertar notificación para cada jugador del equipo relacionado con el entrenamiento
  INSERT INTO notificaciones (titulo, mensaje, tipo_notificacion, id_jugador, evento)
  SELECT 
    'Nuevo entrenamiento programado', 
    CONCAT('Se ha programado un nuevo entrenamiento para el ', NEW.fecha_entrenamiento, '. Sesión: ', NEW.sesion), 
    'Entrenamiento', 
    pe.id_jugador,
    NEW.id_jornada
  FROM plantillas_equipos pe
  WHERE pe.id_equipo = NEW.id_equipo;
END//
DELIMITER;

DELIMITER //
DROP TRIGGER IF EXISTS notificacion_gol_jugador;
CREATE TRIGGER notificacion_gol_jugador
AFTER INSERT ON detalles_goles
FOR EACH ROW
BEGIN
  DECLARE id_jugador INT;
  DECLARE id_partido INT;

  -- Obtener id_jugador y id_partido desde participaciones_partidos
  SELECT pp.id_jugador, pp.id_partido 
  INTO id_jugador, id_partido
  FROM participaciones_partidos pp
  WHERE pp.id_participacion = NEW.id_participacion;

  -- Insertar notificación para el jugador que marcó el gol
  INSERT INTO notificaciones (titulo, mensaje, tipo_notificacion, id_jugador, evento)
  VALUES (
    '¡Gol anotado!', 
    'Felicidades, has anotado un gol en tu último partido.', 
    'Partido', 
    id_jugador, 
    id_partido
  );
END//

DELIMITER ;

DELIMITER //
DROP TRIGGER IF EXISTS notificacion_amonestacion_jugador;
CREATE TRIGGER notificacion_amonestacion_jugador
AFTER INSERT ON detalles_amonestaciones
FOR EACH ROW
BEGIN
  DECLARE id_jugador INT;
  DECLARE id_partido INT;

  -- Obtener id_jugador y id_partido desde participaciones_partidos
  SELECT pp.id_jugador, pp.id_partido 
  INTO id_jugador, id_partido
  FROM participaciones_partidos pp
  WHERE pp.id_participacion = NEW.id_participacion;

  -- Insertar notificación para el jugador que recibió la amonestación
  INSERT INTO notificaciones (titulo, mensaje, tipo_notificacion, id_jugador, evento)
  VALUES (
    'Amonestación recibida', 
    CONCAT('Has recibido una ', NEW.amonestacion, ' en tu último partido.'), 
    'Partido', 
    id_jugador, 
    id_partido
  );
END//
DELIMITER ;
DROP TRIGGER IF EXISTS notificacion_estado_convocatoria;
DELIMITER //
CREATE TRIGGER notificacion_estado_convocatoria
AFTER INSERT ON convocatorias_partidos
FOR EACH ROW
BEGIN
  -- Si el jugador está convocado
  IF NEW.estado_convocado = 1 THEN
    INSERT INTO notificaciones (titulo, mensaje, tipo_notificacion, id_jugador, evento)
    VALUES (
      'Convocatoria para el partido', 
      'Has sido convocado para el próximo partido.', 
      'Partido', 
      NEW.id_jugador, 
      NEW.id_partido
    );
  -- Si el jugador no está convocado
  ELSE
    INSERT INTO notificaciones (titulo, mensaje, tipo_notificacion, id_jugador, evento)
    VALUES (
      'No convocado para el partido', 
      'No has sido convocado para el próximo partido.', 
      'Partido', 
      NEW.id_jugador, 
      NEW.id_partido
    );
  END IF;
END//

DELIMITER ;
DROP EVENT IF EXISTS enviar_test_post_partido;
DELIMITER //
CREATE EVENT enviar_test_post_partido
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY + INTERVAL '07:30' HOUR_MINUTE
DO
BEGIN
  INSERT INTO notificaciones (titulo, mensaje, tipo_notificacion, id_jugador, evento)
  SELECT 
    'Test post-partido disponible', 
    'Tienes disponible un test post-partido.', 
    'Test', 
    p.id_jugador, 
    p.id_partido
  FROM participaciones_partidos p
  WHERE p.id_partido IN (
    SELECT id_partido FROM partidos WHERE DATE(fecha_partido) = CURDATE() - INTERVAL 1 DAY
  );
END //

DELIMITER ;

DROP EVENT IF EXISTS enviar_test_post_entrenamiento;
DELIMITER //
CREATE EVENT enviar_test_post_entrenamiento
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY + INTERVAL '07:30' HOUR_MINUTE
DO
BEGIN
  INSERT INTO notificaciones (titulo, mensaje, tipo_notificacion, id_jugador, evento)
  SELECT 
    'Test post-entrenamiento disponible', 
    'Tienes disponible un test post-entrenamiento.', 
    'Test', 
    a.id_jugador, 
    a.id_entrenamiento
  FROM asistencias a
  WHERE DATE(a.fecha_asistencia) = CURDATE() - INTERVAL 1 DAY;
END //

DELIMITER ;

DROP EVENT IF EXISTS enviar_notificacion_cumpleanios;
DELIMITER //
CREATE EVENT enviar_notificacion_cumpleanios
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL '07:30' HOUR_MINUTE
DO
BEGIN
    INSERT INTO notificaciones (titulo, mensaje, tipo_notificacion, id_jugador)
    SELECT 
        'Feliz Cumpleaños', 
        CONCAT('¡Feliz cumpleaños, ', j.nombre_jugador, ' ', j.apellido_jugador, '!'),
        'Eventos', 
        j.id_jugador
    FROM jugadores j
    WHERE DATE_FORMAT(j.fecha_nacimiento_jugador, '%m-%d') = DATE_FORMAT(CURDATE(), '%m-%d');
END//
DELIMITER ;

DROP EVENT IF EXISTS enviar_notificacion_entrenamiento;
DELIMITER //
CREATE EVENT enviar_notificacion_entrenamiento
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL '07:30' HOUR_MINUTE
DO
BEGIN
    INSERT INTO notificaciones (titulo, mensaje, tipo_notificacion, id_jugador, evento)
    SELECT 
        'Entrenamiento programado', 
        CONCAT('Tienes un entrenamiento programado hoy, ', e.sesion, '.'),
        'Eventos', 
        j.id_jugador,
        e.id_entrenamiento
    FROM entrenamientos e
    JOIN jugadores j ON j.id_jugador = e.id_jugador -- Asegúrate de tener un campo para relacionar jugadores con entrenamientos
    WHERE e.fecha_entrenamiento = CURDATE();
END//

DELIMITER ;

SELECT * FROM notificaciones;

DELIMITER //
DROP TRIGGER IF EXISTS after_asistencia_insert;
CREATE TRIGGER after_asistencia_insert
AFTER INSERT ON asistencias
FOR EACH ROW
BEGIN
  -- Validar si la asistencia es "Asistencia"
  IF NEW.asistencia = 'Asistencia' THEN
    INSERT INTO test (id_jugador, fecha, id_entrenamiento)
    VALUES (NEW.id_jugador, NEW.fecha_asistencia, NEW.id_entrenamiento);
  END IF;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_asistencia_update
AFTER UPDATE ON asistencias
FOR EACH ROW
BEGIN
  IF NEW.asistencia = 'Asistencia' THEN
    IF NOT EXISTS (
      SELECT 1 
      FROM test 
      WHERE id_jugador = NEW.id_jugador
      AND id_entrenamiento = NEW.id_entrenamiento
      AND fecha = NEW.fecha_asistencia
    ) THEN
    INSERT INTO test (id_jugador, fecha, id_entrenamiento)
      VALUES (NEW.id_jugador, NEW.fecha_asistencia, NEW.id_entrenamiento);
    END IF;
  ELSEIF OLD.asistencia = 'Asistencia' AND NEW.asistencia != 'Asistencia' THEN
    IF EXISTS (
      SELECT 1 
      FROM test 
      WHERE id_jugador = OLD.id_jugador
      AND id_entrenamiento = OLD.id_entrenamiento
      AND fecha = OLD.fecha_asistencia
    ) THEN
      DELETE FROM test 
      WHERE id_jugador = OLD.id_jugador
      AND id_entrenamiento = OLD.id_entrenamiento
      AND fecha = OLD.fecha_asistencia;
    END IF;
  END IF;
END//

DELIMITER ;

DELIMITER //
CREATE TRIGGER after_participacion_insert
AFTER INSERT ON participaciones_partidos
FOR EACH ROW
BEGIN
  INSERT INTO test (id_jugador, fecha, id_partido)
  VALUES (NEW.id_jugador, (SELECT fecha_partido FROM partidos WHERE id_partido = NEW.id_partido), NEW.id_partido);
END//
DELIMITER ;

CREATE VIEW delantero_test_wellnes AS
SELECT
    eq.id_equipo,
    j.id_jugador,
    -- Usamos CONCAT y SUBSTRING_INDEX para obtener el primer nombre y primer apellido
    CONCAT(SUBSTRING_INDEX(j.nombre_jugador, ' ', 1), ' ', SUBSTRING_INDEX(j.apellido_jugador, ' ', 1)) AS nombre_jugador,
    ROUND(AVG(ca.respuesta), 2) AS promedio
FROM
    equipos eq
JOIN
    plantillas_equipos pq ON pq.id_equipo = eq.id_equipo
JOIN
    jugadores j ON j.id_jugador = pq.id_jugador AND j.estatus_jugador = 'Activo'
JOIN
    posiciones ps ON ps.id_posicion = j.id_posicion_principal
    AND ps.area_de_juego = 'Ofensiva'
JOIN
    test a ON j.id_jugador = a.id_jugador
JOIN
    respuesta_test ca ON a.id_test = ca.id_test
WHERE
    a.fecha >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
GROUP BY
    eq.id_equipo, j.id_jugador;

CREATE VIEW asistencias_evaluaciones AS
SELECT
    p.id_partido,
    p.id_equipo,
    j.id_jugador,
    -- Usamos CONCAT y SUBSTRING_INDEX para obtener el primer nombre y primer apellido
    CONCAT(SUBSTRING_INDEX(j.nombre_jugador, ' ', 1), ' ', SUBSTRING_INDEX(j.apellido_jugador, ' ', 1)) AS nombre_jugador,
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
    jugadores j ON j.id_jugador = pq.id_jugador AND j.estatus_jugador = 'Activo'
JOIN
    posiciones ps ON ps.id_posicion = j.id_posicion_principal
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
    
CREATE VIEW test_wellnes AS
SELECT
    eq.id_equipo,
    j.id_jugador,
    -- Usamos CONCAT y SUBSTRING_INDEX para obtener el primer nombre y primer apellido
    CONCAT(SUBSTRING_INDEX(j.nombre_jugador, ' ', 1), ' ', SUBSTRING_INDEX(j.apellido_jugador, ' ', 1)) AS nombre_jugador,
    ROUND(AVG(ca.respuesta), 2) AS promedio
FROM
    equipos eq
JOIN
    plantillas_equipos pq ON pq.id_equipo = eq.id_equipo
JOIN
    jugadores j ON j.id_jugador = pq.id_jugador AND j.estatus_jugador = 'Activo'
JOIN
    posiciones ps ON ps.id_posicion = j.id_posicion_principal
JOIN
    test a ON j.id_jugador = a.id_jugador
JOIN
    respuesta_test ca ON a.id_test = ca.id_test AND ca.pregunta = '¿Cuánta motivación sientes para entrenar hoy?'
WHERE
    a.fecha >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
GROUP BY
    eq.id_equipo, j.id_jugador;

CREATE VIEW delantero_asistencias_evaluaciones AS
SELECT
    p.id_partido,
    p.id_equipo,
    j.id_jugador,
    -- Usamos CONCAT y SUBSTRING_INDEX para obtener el primer nombre y primer apellido
    CONCAT(SUBSTRING_INDEX(j.nombre_jugador, ' ', 1), ' ', SUBSTRING_INDEX(j.apellido_jugador, ' ', 1)) AS nombre_jugador,
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
    jugadores j ON j.id_jugador = pq.id_jugador AND j.estatus_jugador = 'Activo'
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

-- Vista para saber si un partido tiene los datos necesarios para ser predecido
CREATE VIEW vista_autorizacion_prediccion AS
SELECT 
    e.id_equipo,
    e.nombre_equipo,
    r.id_rival,
    r.nombre_rival,
    p.id_partido,
    COUNT(DISTINCT p.id_partido) AS partidos_jugados_equipo,
    (SELECT COUNT(*) FROM partidos p2 WHERE p2.id_rival = r.id_rival) AS partidos_jugados_rival,
    (SELECT COUNT(*) 
     FROM caracteristicas_analisis ca 
     WHERE ca.id_jugador IN (SELECT pe.id_jugador 
                             FROM plantillas_equipos pe 
                             WHERE pe.id_equipo = e.id_equipo)) AS caracteristicas_analizadas,
    (SELECT COUNT(*) 
     FROM test t 
     WHERE t.id_jugador IN (SELECT pe.id_jugador 
                            FROM plantillas_equipos pe 
                            WHERE pe.id_equipo = e.id_equipo) 
     AND t.contestado = 1) AS registros_contestados,
    CASE 
        WHEN COUNT(DISTINCT p.id_partido) >= 3 AND 
             (SELECT COUNT(*) FROM partidos p2 WHERE p2.id_rival = r.id_rival) >= 3 AND 
             (SELECT COUNT(*) FROM caracteristicas_analisis ca WHERE ca.id_jugador IN (SELECT pe.id_jugador FROM plantillas_equipos pe WHERE pe.id_equipo = e.id_equipo)) > 0 AND 
             (SELECT COUNT(*) FROM test t WHERE t.id_jugador IN (SELECT pe.id_jugador FROM plantillas_equipos pe WHERE pe.id_equipo = e.id_equipo) AND t.contestado = 1) >= 10
        THEN 'true'
        ELSE 'false'
    END AS autorizacion_prediccion
FROM 
    equipos e
JOIN 
    partidos p ON e.id_equipo = p.id_equipo
JOIN 
    rivales r ON p.id_rival = r.id_rival
GROUP BY 
    e.id_equipo, r.id_rival;

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
    c.nombre_categoria,
    v.autorizacion_prediccion
FROM
    partidos p
INNER JOIN
    equipos e ON p.id_equipo = e.id_equipo
INNER JOIN
	rivales i ON p.id_rival = i.id_rival
INNER JOIN
    categorias c ON e.id_categoria = c.id_categoria
INNER JOIN
	vista_autorizacion_prediccion v ON p.id_partido = v.id_partido
ORDER BY p.fecha_partido DESC;