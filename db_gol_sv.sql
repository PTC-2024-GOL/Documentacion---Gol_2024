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
  CONSTRAINT uq_telefono_administrador_unico UNIQUE(telefono_administrador),
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
  CONSTRAINT uq_telefono_tecnico_unico UNIQUE(telefono_tecnico),
  dui_tecnico VARCHAR(10) NOT NULL,
  CONSTRAINT uq_dui_tecnico_unico UNIQUE(dui_tecnico),
  fecha_nacimiento_tecnico DATE NOT NULL,
  fecha_creacion DATETIME NULL DEFAULT NOW(),
  foto_tecnico VARCHAR(50) NULL,
  CONSTRAINT chk_url_foto_administrador CHECK (foto_tecnico LIKE '%.jpg' OR foto_tecnico LIKE '%.png' OR foto_tecnico LIKE '%.jpeg' OR foto_tecnico LIKE '%.gif')
);

CREATE TABLE temporadas(
  id_temporada INT AUTO_INCREMENT PRIMARY KEY,
  anio_temporada YEAR NOT NULL,
  CONSTRAINT uq_anio_temporada_unico UNIQUE(anio_temporada)
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
  nombre_cuerpo_tecnico VARCHAR(60),
  CONSTRAINT uq_nombre_cuerpo_tecnico_unico UNIQUE(nombre_cuerpo_tecnico),
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
  genero_equipo ENUM('Masculino ', 'Femenino') NOT NULL,
  telefono_contacto VARCHAR(14) NULL,
  CONSTRAINT uq_telefono_equipo_unico UNIQUE(telefono_contacto),
  id_cuerpo_tecnico INT NULL,
  CONSTRAINT fk_cuerpo_tecnico_del_equipo FOREIGN KEY (id_cuerpo_tecnico) REFERENCES cuerpos_tecnicos(id_cuerpo_tecnico),
  id_administrador INT NULL,
  CONSTRAINT fk_administrador_del_equipo FOREIGN KEY (id_administrador) REFERENCES administradores(id_administrador),
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
  CONSTRAINT check_dorsal_jugador CHECK (dorsal_jugador > 0),
  nombre_jugador VARCHAR(50) NOT NULL,
  apellido_jugador VARCHAR(50) NOT NULL,
  estatus_jugador ENUM('Activo', 'Baja temporal', 'Baja definitiva') DEFAULT 'Activo',
  fecha_nacimiento_jugador DATE NULL,
  genero_jugador ENUM('Masculino ', 'Femenino') NOT NULL,
  perfil_jugador ENUM('Zurdo', 'Diestro', 'Ambidiestro') NOT NULL,
  id_posicion_principal INT NOT NULL,
  CONSTRAINT fk_posicion_principal FOREIGN KEY (id_posicion_principal) REFERENCES posiciones(id_posicion),
  id_posicion_secundaria INT NULL,
  CONSTRAINT fk_posicion_secundaria FOREIGN KEY (id_posicion_secundaria) REFERENCES posiciones(id_posicion),
  altura_jugador DECIMAL(4, 2) UNSIGNED NOT NULL,
  CONSTRAINT check_altura_jugador CHECK (altura_jugador > 0),
  peso_jugador DECIMAL(5, 2) UNSIGNED NOT NULL,
  CONSTRAINT check_peso_jugador CHECK (peso_jugador > 0),
  indice_masa_corporal DECIMAL(5, 2) UNSIGNED NULL,
  alias_jugador VARCHAR(25) NOT NULL,
  CONSTRAINT uq_alias_jugador_unico UNIQUE(alias_jugador),
  clave_jugador VARCHAR(100) NOT NULL,
  foto_jugador VARCHAR(36) NULL,
  CONSTRAINT chk_url_foto_jugador CHECK (foto_jugador LIKE '%.jpg' OR foto_jugador LIKE '%.png' OR foto_jugador LIKE '%.jpeg' OR foto_jugador LIKE '%.gif')
);

CREATE TABLE plantillas_equipos(
  id_plantilla INT AUTO_INCREMENT PRIMARY KEY,
  id_jugador INT NOT NULL,
  CONSTRAINT fk_jugador_plantilla FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador),
  id_equipo INT NOT NULL,
  CONSTRAINT fk_equipo_plantilla FOREIGN KEY (id_equipo) REFERENCES equipos(id_equipo)
);

CREATE TABLE caracteristicas_jugadores(
  id_caracteristica_jugador INT AUTO_INCREMENT PRIMARY KEY,
  nombre_caracteristica_jugador VARCHAR(50) NOT NULL,
  CONSTRAINT uq_nombre_sub_caracteristica_unico UNIQUE(nombre_caracteristica_jugador),
  clasificacion_caracteristica_jugador ENUM('Técnicos', 'Tácticos', 'Condicionales', 'Psicologicos', 'Personales') NOT NULL
);

CREATE TABLE caracteristicas_analisis(
  id_caracteristica_analisis INT AUTO_INCREMENT PRIMARY KEY,
  nota_caracteristica_analisis DECIMAL(5,3) UNSIGNED NOT NULL,
  CONSTRAINT check_nota CHECK (nota_caracteristica_analisis >=0 ),
  id_jugador INT NOT NULL,
  CONSTRAINT fk_jugador_caracteristica_general FOREIGN KEY (id_jugador) REFERENCES plantillas_equipos(id_plantilla),
  id_caracteristica_jugador INT NOT NULL,
  CONSTRAINT fk_sub_caracteristica_jugador_caracteristica_general FOREIGN KEY (id_caracteristica_jugador) REFERENCES caracteristicas_jugadores(id_caracteristica_jugador)
);

CREATE TABLE asistencias(
  id_asistencia INT AUTO_INCREMENT PRIMARY KEY,
  id_jugador INT NOT NULL,
  CONSTRAINT fk_jugador_asistencia FOREIGN KEY (id_jugador) REFERENCES plantillas_equipos(id_plantilla),
  id_horario INT NOT NULL,
  CONSTRAINT fk_horario_asistencia FOREIGN KEY (id_horario) REFERENCES horarios(id_horario),
  fecha_asistencia DATE NULL DEFAULT NOW(),
  asistencia ENUM('Asistencia', 'Ausencia injustificada', 'Enfermedad', 'Estudio', 'Trabajo', 'Viaje', 'Permiso', 'Falta', 'Lesion', 'Otro') NOT NULL,
  observacion_asistencia VARCHAR(2000) NULL
);

CREATE TABLE temas_contenidos(
  id_tema_contenido INT AUTO_INCREMENT PRIMARY KEY,
  nombre_tema_contenido VARCHAR(60) NOT NULL,
  CONSTRAINT uq_tema_contenido_unico UNIQUE(nombre_tema_contenido)
);

CREATE TABLE sub_temas_contenidos(
  id_sub_tema_contenido INT AUTO_INCREMENT PRIMARY KEY,
  sub_tema_contenido VARCHAR(60) NOT NULL,
  id_tema_contenido INT NOT NULL,
  CONSTRAINT fk_tipo_contenido FOREIGN KEY (id_tema_contenido) REFERENCES temas_contenidos(id_tema_contenido)
);

CREATE TABLE tareas(
  id_tarea INT AUTO_INCREMENT PRIMARY KEY,
  nombre_tarea VARCHAR(60) NOT NULL
);

CREATE TABLE detalles_contenidos(
  id_detalle_contenido INT AUTO_INCREMENT PRIMARY KEY,
  id_tarea INT NULL,
  CONSTRAINT fk_tarea FOREIGN KEY (id_tarea) REFERENCES tareas(id_tarea),
  id_sub_tema_contenido INT NOT NULL,
  CONSTRAINT fk_contenido FOREIGN KEY (id_sub_tema_contenido) REFERENCES sub_temas_contenidos(id_sub_tema_contenido),
  id_asistencia INT NOT NULL,
  CONSTRAINT fk_asistencia_contenidos FOREIGN KEY (id_asistencia) REFERENCES asistencias(id_asistencia),
  minutos_contenido INT UNSIGNED NULL,
  CONSTRAINT check_minutos_contenido CHECK (minutos_contenido >= 0),
  minutos_tarea INT UNSIGNED NULL,
  CONSTRAINT check_minutos_tarea CHECK (minutos_tarea >= 0)
);

CREATE TABLE jornadas(
  id_jornada INT AUTO_INCREMENT PRIMARY KEY,
  nombre_jornada VARCHAR(60) NULL,
  numero_jornada INT UNSIGNED NOT NULL,
  CONSTRAINT check_numero_jornada CHECK (numero_jornada >= 0),
  id_temporada INT NOT NULL,
  CONSTRAINT fk_temporada_jornada FOREIGN KEY (id_temporada) REFERENCES temporadas(id_temporada),
  fecha_inicio_jornada DATE NOT NULL,
  fecha_fin_jornada DATE NOT NULL,
  CONSTRAINT chk_validacion_de_fechas_de_jornada CHECK(fecha_inicio_jornada < fecha_fin_jornada)
);

CREATE TABLE entrenamientos(
  id_entrenamiento INT AUTO_INCREMENT PRIMARY KEY,
  id_jornada INT NOT NULL,
  CONSTRAINT fk_identificador_de_jornada FOREIGN KEY (id_jornada) REFERENCES jornadas(id_jornada),
  id_caracteristica_analisis INT NOT NULL,
  CONSTRAINT fk_caracteristicas_analisis_jornada FOREIGN KEY (id_caracteristica_analisis) REFERENCES caracteristicas_analisis(id_caracteristica_analisis),
  id_detalle_contenido INT NOT NULL,
  CONSTRAINT fk_detalle_contenido_jornada FOREIGN KEY (id_detalle_contenido) REFERENCES detalles_contenidos(id_detalle_contenido)
);

CREATE TABLE partidos(
  id_partido INT AUTO_INCREMENT PRIMARY KEY,
  id_entrenamiento INT NOT NULL,
  CONSTRAINT fk_jornada_partido FOREIGN KEY (id_entrenamiento) REFERENCES entrenamientos(id_entrenamiento),
  id_equipo INT NOT NULL,
  CONSTRAINT fk_equipo_partido FOREIGN KEY (id_equipo) REFERENCES plantillas_equipos(id_plantilla),
  logo_rival VARCHAR(50) NULL,
  CONSTRAINT chk_url_logo_equipo_rival CHECK (logo_rival LIKE '%.jpg' OR logo_rival LIKE '%.png' OR logo_rival LIKE '%.jpeg' OR logo_rival LIKE '%.gif'),
  rival_partido VARCHAR(50) NOT NULL,
  fecha_partido DATETIME NOT NULL,
  cancha_partido VARCHAR(100) NOT NULL,
  resultado_partido VARCHAR(10) NULL,
  localidad_partido ENUM('Local', 'Visitante') NOT NULL,
  tipo_resultado_partido ENUM('Victoria', 'Empate', 'Derrota') NULL
);


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
  id_participacion INT AUTO_INCREMENT PRIMARY KEY,
  id_partido INT NOT NULL,
  CONSTRAINT fk_partido_participacion FOREIGN KEY (id_partido) REFERENCES partidos(id_partido),
  id_jugador INT NOT NULL,
  CONSTRAINT fk_jugador_participacion FOREIGN KEY (id_jugador) REFERENCES plantillas_equipos(id_plantilla),
  titular BOOLEAN NULL DEFAULT 0,
  sustitucion BOOLEAN NULL DEFAULT 0,
  minutos_jugados INT UNSIGNED NULL DEFAULT 0,
  CONSTRAINT check_minutos_jugados CHECK (minutos_jugados >= 0),
  goles INT UNSIGNED NULL DEFAULT 0,
  CONSTRAINT check_goles CHECK (goles >= 0),
  asistencias INT UNSIGNED NULL DEFAULT 0,
  CONSTRAINT check_asistencias CHECK (asistencias >= 0),
  estado_animo ENUM (
    'Desanimado', 'Agotado', 'Normal', 'Satisfecho', 'Energético'
  ) NULL DEFAULT 'Normal',
  puntuacion INT UNSIGNED NULL DEFAULT 0,
  CONSTRAINT check_puntuacion CHECK (puntuacion > 0)
);

CREATE TABLE detalles_goles (
  id_detalle_gol INT AUTO_INCREMENT PRIMARY KEY,
  id_participacion INT NOT NULL,
  CONSTRAINT fk_participacion_detalle_gol FOREIGN KEY (id_participacion) REFERENCES participaciones_partidos(id_participacion),
  cantidad_tipo_gol INT UNSIGNED NULL,
  CONSTRAINT check_cantidad_tipo_gol CHECK (cantidad_tipo_gol >= 0),
  id_tipo_gol INT NOT NULL,
  CONSTRAINT fk_tipo_gol_detalle_gol FOREIGN KEY (id_tipo_gol) REFERENCES tipos_goles(id_tipo_gol)
);

CREATE TABLE detalles_amonestaciones (
  id_detalle_amonestacion INT AUTO_INCREMENT PRIMARY KEY,
  id_participacion INT NOT NULL,
  amonestacion ENUM(
    'Tarjeta amarilla', 'Tarjeta roja',
    'Ninguna'
  ) NULL DEFAULT 'Ninguna',
  numero_amonestacion INT UNSIGNED NULL,
  CONSTRAINT check_numero_amonestacion CHECK (numero_amonestacion >= 0)
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
  numero_lesiones INT UNSIGNED NOT NULL,
  CONSTRAINT check_numero_lesiones CHECK (numero_lesiones >= 0),
  promedio_lesiones INT UNSIGNED NULL DEFAULT 0,
  CONSTRAINT check_promedio_lesiones CHECK (promedio_lesiones >= 0)
);

CREATE TABLE registros_medicos(
  id_registro_medico INT AUTO_INCREMENT PRIMARY KEY,
  id_jugador INT NOT NULL,
  CONSTRAINT fk_registro_medico_jugador FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador),
  fecha_lesion DATE NULL,
  fecha_registro DATE NULL DEFAULT NOW(),
  dias_lesionado INT UNSIGNED NULL,
  CONSTRAINT check_dias_lesionado CHECK (dias_lesionado > 0),
  id_lesion INT NOT NULL,
  CONSTRAINT fk_lesion_jugador FOREIGN KEY (id_lesion) REFERENCES lesiones(id_lesion),
  retorno_entreno DATE NOT NULL,
  retorno_partido INT NOT NULL,
  CONSTRAINT fk_retorno_partido FOREIGN KEY (retorno_partido) REFERENCES partidos(id_partido)
);

CREATE TABLE pagos(
  id_pago INT AUTO_INCREMENT PRIMARY KEY,
  fecha_pago DATE NOT NULL,
  cantidad_pago DECIMAL(5, 2)UNSIGNED NOT NULL,
  CONSTRAINT check_cantidad_pago CHECK (cantidad_pago >= 0),
  pago_tardio BOOLEAN NULL DEFAULT 0,
  mora_pago DECIMAL(5, 2) UNSIGNED NULL DEFAULT 0,
  CONSTRAINT check_mora_pago CHECK (mora_pago >= 0),
  mes_pago ENUM('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre') NOT NULL,
  id_jugador INT NOT NULL,
  CONSTRAINT fk_jugador_pago FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador)
);
