DROP DATABASE if EXISTS db_gol_sv;

CREATE DATABASE db_gol_sv;
USE db_gol_sv;

CREATE TABLE administradores(
  id_administrador INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_administrador VARCHAR(50) NOT NULL, 
  apellido_administrador VARCHAR(50) NOT NULL, 
  alias_administrador VARCHAR(25) NOT NULL, 
  CONSTRAINT uq_alias_administrador_unico UNIQUE(alias_administrador), 
  clave_administrador VARCHAR(100) NOT NULL, 
  correo_administrador VARCHAR(50) NOT NULL, 
  CONSTRAINT uq_correo_administrador_unico UNIQUE(correo_administrador), 
  CONSTRAINT chk_correo_administrador_formato CHECK (correo_administrador REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$'), 
  telefono_administrador VARCHAR(15) NOT NULL, 
  dui_administrador VARCHAR(10) NOT NULL, 
  CONSTRAINT uq_dui_administrador_unico UNIQUE(dui_administrador), 
  fecha_nacimiento_administrador DATE NOT NULL, 
  fecha_creacion DATETIME NULL DEFAULT NOW(), 
  intentos_administrador INT DEFAULT 0, 
  fecha_clave DATETIME NULL, 
  fecha_bloqueo DATETIME NULL, 
  foto_administrador VARCHAR(50) NULL, 
  CONSTRAINT chk_url_foto_administrador CHECK (foto_administrador LIKE '%.jpg' OR foto_administrador LIKE '%.png' OR foto_administrador LIKE '%.jpeg' OR foto_administrador LIKE '%.gif')
);

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
  fecha_nacimiento_tecnico DATE NOT NULL, 
  fecha_creacion DATETIME NULL DEFAULT NOW(), 
  foto_tecnico VARCHAR(50) NULL, 
  CONSTRAINT chk_url_foto_administrador CHECK (foto_tecnico LIKE '%.jpg' OR foto_tecnico LIKE '%.png' OR foto_tecnico LIKE '%.jpeg' OR foto_tecnico LIKE '%.gif')
);

CREATE TABLE temporadas(
  id_temporada INT AUTO_INCREMENT PRIMARY KEY, 
  anio YEAR NOT NULL, 
  CONSTRAINT uq_anio_temporada_unico UNIQUE(anio)
);

CREATE TABLE horarios(
  id_horario INT AUTO_INCREMENT PRIMARY KEY, 
  dia ENUM('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo') NOT NULL, 
  hora_inicial TIME NOT NULL, 
  hora_final TIME NOT NULL, 
  CONSTRAINT chk_validacion_de_horas CHECK(hora_inicial < hora_final), 
  campo_de_entrenamiento VARCHAR(100) NOT NULL
);

CREATE TABLE categorias(
  id_categoria INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_categoria VARCHAR(80) NOT NULL, 
  CONSTRAINT uq_nombre_categoria_unico UNIQUE(nombre_categoria), 
  edad_minima_permitida DATE NOT NULL, 
  edad_maxima_permitida DATE NOT NULL, 
  CONSTRAINT chk_validacion_de_edades CHECK(edad_minima_permitida < edad_maxima_permitida), 
  id_temporada INT NOT NULL, 
  CONSTRAINT fk_temporada_de_la_categoria FOREIGN KEY (id_temporada) REFERENCES temporadas(id_temporada), 
  id_horario INT NOT NULL, 
  CONSTRAINT fk_horarios_de_la_categoria FOREIGN KEY (id_horario) REFERENCES horarios(id_horario)
);

CREATE TABLE cuerpos_tecnicos(
  id_cuerpo_tecnico INT AUTO_INCREMENT PRIMARY KEY, 
  primer_tecnico INT, 
  CONSTRAINT fk_primer_tecnico FOREIGN KEY (primer_tecnico) REFERENCES tecnicos(id_tecnico), 
  segundo_tecnico INT, 
  CONSTRAINT fk_segundo_tecnico FOREIGN KEY (segundo_tecnico) REFERENCES tecnicos(id_tecnico), 
  preparador_fisico INT, 
  CONSTRAINT fk_preparador_fisico FOREIGN KEY (preparador_fisico) REFERENCES tecnicos(id_tecnico), 
  delegado INT, 
  CONSTRAINT fk_delegado FOREIGN KEY (delegado) REFERENCES tecnicos(id_tecnico)
);

CREATE TABLE equipos(
  id_equipo INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_equipo VARCHAR(50) NOT NULL, 
  CONSTRAINT uq_nombre_equipo_unico UNIQUE(nombre_equipo), 
  telefono_contacto VARCHAR(14) NULL, 
  id_cuerpo_tecnico INT NULL, 
  CONSTRAINT fk_cuerpo_tecnico_del_equipo FOREIGN KEY (id_cuerpo_tecnico) REFERENCES cuerpos_tecnicos(id_cuerpo_tecnico), 
  id_administrador INT NULL, 
  CONSTRAINT fk_administrador_del_equipo FOREIGN KEY (id_administrador) REFERENCES administradores(id_administrador), 
  id_categoria INT NOT NULL, 
  CONSTRAINT fk_categoria_del_equipo FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

CREATE TABLE posiciones(
  id_posicion INT AUTO_INCREMENT PRIMARY KEY, 
  posicion VARCHAR(60) NOT NULL, 
  CONSTRAINT uq_posicion_unico UNIQUE(posicion), 
  area_de_juego ENUM('Ofensiva', 'Defensiva', 'Ofensiva y defensiva') NOT NULL
);

CREATE TABLE jugadores(
  id_jugador INT AUTO_INCREMENT PRIMARY KEY, 
  dorsal INT NULL, 
  nombre_jugador VARCHAR(50) NOT NULL, 
  apellido_jugador VARCHAR(50) NOT NULL, 
  estatus ENUM('Activo', 'Baja temporal', 'Baja definitiva') NOT NULL, 
  fecha_nacimiento DATE NULL, 
  edad INT NULL, 
  perfil ENUM('Zurdo', 'Diestro', 'Ambidiestro') NOT NULL, 
  id_posicion_principal INT NOT NULL, 
  CONSTRAINT fk_posicion_principal FOREIGN KEY (id_posicion_principal) REFERENCES posiciones(id_posicion), 
  id_posicion_secundaria INT NULL, 
  CONSTRAINT fk_posicion_secundaria FOREIGN KEY (id_posicion_secundaria) REFERENCES posiciones(id_posicion), 
  altura DECIMAL(4, 2) NOT NULL, 
  peso DECIMAL(5, 2) NOT NULL, 
  indice_masa_corporal DECIMAL(5, 2) NULL, 
  foto_jugador VARCHAR(36) NULL, 
  CONSTRAINT chk_url_foto_jugador CHECK (foto_jugador LIKE '%.jpg' OR foto_jugador LIKE '%.png' OR foto_jugador LIKE '%.jpeg' OR foto_jugador LIKE '%.gif')
);

CREATE TABLE sub_caracteristicas(
  id_sub_caracteristica INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_sub_caracteristica VARCHAR(50) NOT NULL,
  CONSTRAINT uq_nombre_sub_caracteristica_unico UNIQUE(nombre_sub_caracteristica), 
  caracteristica ENUM('Técnicos', 'Tácticos', 'Condicionales', 'Psicologicos', 'Personales') NOT NULL
);

CREATE TABLE caracteristicas_generales(
  id_caracteristica_general INT AUTO_INCREMENT PRIMARY KEY, 
  nota_caracteristica DECIMAL(5,3) NOT NULL,
  id_jugador INT NOT NULL, 
  CONSTRAINT fk_jugador_caracteristica_general FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador), 
  id_sub_caracteristica INT NOT NULL, 
  CONSTRAINT fk_sub_caracteristica_jugador_caracteristica_general FOREIGN KEY (id_sub_caracteristica) REFERENCES sub_caracteristicas(id_sub_caracteristica)
);

CREATE TABLE asistencias(
  id_asistencia INT AUTO_INCREMENT PRIMARY KEY, 
  id_jugador INT NOT NULL, 
  CONSTRAINT fk_jugador_asistencia FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador), 
  id_horario INT NOT NULL, 
  CONSTRAINT fk_horario_asistencia FOREIGN KEY (id_horario) REFERENCES horarios(id_horario), 
  mes ENUM('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre') NOT NULL, 
  fecha DATE NULL DEFAULT NOW(), 
  asistencia ENUM('Asistencia', 'Ausencia injustificada', 'Enfermedad', 'Estudio', 'Trabajo', 'Viaje', 'Permiso', 'Falta', 'Lesion', 'Otro') NOT NULL, 
  observacion VARCHAR(2000) NULL
);

CREATE TABLE tipos_contenidos(
  id_tipo_contenido INT AUTO_INCREMENT PRIMARY KEY, 
  tipo_contenido VARCHAR(60) NOT NULL, 
  CONSTRAINT uq_tipo_contenido_unico UNIQUE(tipo_contenido)
);

CREATE TABLE contenidos(
  id_contenido INT AUTO_INCREMENT PRIMARY KEY, 
  tema_contenido VARCHAR(60) NOT NULL, 
  id_tipo_contenido INT NOT NULL, 
  CONSTRAINT fk_tipo_contenido FOREIGN KEY (id_tipo_contenido) REFERENCES tipos_contenidos(id_tipo_contenido)
);

CREATE TABLE tipos_tareas(
  id_tipo_tarea INT AUTO_INCREMENT PRIMARY KEY, 
  tipo_tarea VARCHAR(50) NOT NULL, 
  CONSTRAINT uq_tipo_tarea_unico UNIQUE(tipo_tarea)
);

CREATE TABLE tareas(
  id_tarea INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_tarea VARCHAR(60) NOT NULL,
  id_tipo_tarea INT NOT NULL, 
  CONSTRAINT fk_tipo_de_tarea FOREIGN KEY (id_tipo_tarea) REFERENCES tipos_tareas(id_tipo_tarea)
);

CREATE TABLE detalle_contenido(
  id_detalle_contenido INT AUTO_INCREMENT PRIMARY KEY, 
  id_tarea INT NULL, 
  CONSTRAINT fk_tarea FOREIGN KEY (id_tarea) REFERENCES tareas(id_tarea), 
  id_contenido INT NOT NULL, 
  CONSTRAINT fk_contenido FOREIGN KEY (id_contenido) REFERENCES contenidos(id_contenido), 
  id_asistencia INT NOT NULL, 
  CONSTRAINT fk_asistencia_contenidos FOREIGN KEY (id_asistencia) REFERENCES asistencias(id_asistencia),
  cantidad_contenido INT NULL, 
  minutos_tarea INT NULL
);

CREATE TABLE jornadas(
  id_jornada INT AUTO_INCREMENT PRIMARY KEY, 
  numero_jornada INT NOT NULL, 
  id_temporada INT NOT NULL, 
  CONSTRAINT fk_temporada_jornada FOREIGN KEY (id_temporada) REFERENCES temporadas(id_temporada), 
  fecha_inicio DATE NOT NULL, 
  fecha_fin DATE NOT NULL, 
  CONSTRAINT chk_validacion_de_fechas_de_jornada CHECK(fecha_inicio < fecha_fin)
);

CREATE TABLE detalles_jornadas(
  id_detalle_jornada INT AUTO_INCREMENT PRIMARY KEY, 
  id_jornada INT NOT NULL, 
  CONSTRAINT fk_identificador_de_jornada FOREIGN KEY (id_jornada) REFERENCES jornadas(id_jornada),
  id_caracteristica_general INT NOT NULL, 
  CONSTRAINT fk_caracteristicas_generales_jornada FOREIGN KEY (id_caracteristica_general) REFERENCES caracteristicas_generales(id_caracteristica_general), 
  id_detalle_contenido INT NOT NULL, 
  CONSTRAINT fk_detalle_contenido_jornada FOREIGN KEY (id_detalle_contenido) REFERENCES detalle_contenido(id_detalle_contenido)
);

CREATE TABLE partidos(
  id_partido INT AUTO_INCREMENT PRIMARY KEY, 
  id_detalle_jornada INT NOT NULL, 
  CONSTRAINT fk_jornada_partido FOREIGN KEY (id_detalle_jornada) REFERENCES detalles_jornadas(id_detalle_jornada), 
  id_equipo INT NOT NULL, 
  CONSTRAINT fk_equipo FOREIGN KEY (id_equipo) REFERENCES equipos(id_equipo), 
  rival VARCHAR(50) NOT NULL, 
  fecha DATETIME NOT NULL, 
  cancha VARCHAR(100) NOT NULL, 
  resultado VARCHAR(10) NULL, 
  localidad ENUM('Local', 'Visitante') NOT NULL, 
  tipo_resultado ENUM('Victoria', 'Empate', 'Derrota') NULL
);


CREATE TABLE tipos_juegos(
  id_tipo_juego INT AUTO_INCREMENT PRIMARY KEY, 
  nombre_tipo_juego VARCHAR(50) NOT NULL, 
  CONSTRAINT uq_nombre_tipo_juego_unico UNIQUE(nombre_tipo_juego)
);

CREATE TABLE tipos_goles(
  id_tipo_gol INT AUTO_INCREMENT PRIMARY KEY, 
  id_tipo_juego INT NOT NULL, 
  CONSTRAINT fk_tipo_de_juego FOREIGN KEY (id_tipo_juego) REFERENCES tipos_juegos(id_tipo_juego), 
  nombre_tipo_gol VARCHAR(60) NOT NULL
);

CREATE TABLE participaciones_partidos(
  id_participacion INT AUTO_INCREMENT PRIMARY KEY, 
  id_partido INT NOT NULL, 
  CONSTRAINT fk_partido_participacion FOREIGN KEY (id_partido) REFERENCES partidos(id_partido), 
  id_jugador INT NOT NULL, 
  CONSTRAINT fk_jugador_participacion FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador), 
  titular BOOLEAN NOT NULL, 
  sustitucion BOOLEAN NOT NULL, 
  minutos_jugados INT NOT NULL, 
  goles INT NULL DEFAULT 0, 
  id_tipo_gol INT NULL, 
  CONSTRAINT fk_tipo_gol_partido FOREIGN KEY (id_tipo_gol) REFERENCES tipos_goles(id_tipo_gol), 
  cantidad_tipo_gol INT NULL, 
  asistencias INT NULL DEFAULT 0, 
  amonestacion ENUM(
    'Tarjeta amarilla', 'Tarjeta roja', 
    'Ninguna'
  ) NULL DEFAULT 'Ninguna', 
  numero_amonestacion INT NULL DEFAULT 0, 
  puntuacion INT NULL
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

CREATE TABLE subtipologias(
  id_subtipologia INT AUTO_INCREMENT PRIMARY KEY, 
  subtipologia VARCHAR(60) NOT NULL, 
  CONSTRAINT uq_sub_tipologia_unico UNIQUE(subtipologia), 
  id_tipologia INT NOT NULL, 
  CONSTRAINT fk_tipologias_de_la_subtipologia FOREIGN KEY (id_tipologia) REFERENCES tipologias(id_tipologia)
);

CREATE TABLE lesiones(
  id_lesion INT AUTO_INCREMENT PRIMARY KEY, 
  id_tipo_lesion INT NOT NULL, 
  CONSTRAINT fk_registro_medico_del_tipo_de_lesion FOREIGN KEY (id_tipo_lesion) REFERENCES tipos_lesiones(id_tipo_lesion), 
  id_subtipologia INT NOT NULL, 
  CONSTRAINT fk_id_subtipologia_lesiones FOREIGN KEY (id_subtipologia) REFERENCES subtipologias(id_subtipologia), 
  nombre_lesion VARCHAR(50) NOT NULL, 
  numero_lesiones INT NOT NULL, 
  promedio_lesiones INT NULL DEFAULT 0
);

CREATE TABLE registro_medico(
  id_registro_medico INT AUTO_INCREMENT PRIMARY KEY, 
  id_jugador INT NOT NULL, 
  CONSTRAINT fk_registro_medico_jugador FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador), 
  fecha_lesion DATE NULL, 
  fecha_registro DATE DEFAULT NOW(), 
  dias_lesionado INT NULL, 
  id_lesion INT NOT NULL, 
  CONSTRAINT fk_lesion_jugador FOREIGN KEY (id_lesion) REFERENCES lesiones(id_lesion), 
  retorno_entreno DATE NOT NULL, 
  retorno_partido INT NOT NULL, 
  CONSTRAINT fk_retorno_partido FOREIGN KEY (retorno_partido) REFERENCES partidos(id_partido)
);

CREATE TABLE pagos(
  id_pago INT AUTO_INCREMENT PRIMARY KEY, 
  fecha DATE NOT NULL, 
  cantidad DECIMAL(5, 2) NOT NULL, 
  pago_tardio BOOLEAN NULL DEFAULT 0, 
  mora DECIMAL(5, 2) NULL, 
  mes ENUM('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre') NOT NULL, 
  id_jugador INT NOT NULL, 
  CONSTRAINT fk_jugador_pago FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador)
);

DELIMITER // 

CREATE TRIGGER calcular_edad BEFORE INSERT ON jugadores FOR EACH ROW BEGIN 
SET 
  NEW.edad = YEAR(CURRENT_DATE) - YEAR(NEW.fecha_nacimiento) - (
    DATE_FORMAT(CURRENT_DATE, '%m%d') < DATE_FORMAT(NEW.fecha_nacimiento, '%m%d')
  );
END;

// 
DELIMITER ;

DELIMITER //
CREATE VIEW vista_promedio_subcaracteristicas_por_jugador AS
SELECT id_jugador, AVG(nota_caracteristica) AS promedio_subcaracteristicas
FROM caracteristicas_generales
GROUP BY id_jugador;
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
