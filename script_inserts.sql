-- SCRIPT DE INSERTS
USE db_gol_sv;

-- 1. Admin
SET @fecha_creacion := NOW();

SET @alias := generar_alias_administrador('Juan', 'Pérez', @fecha_creacion);

INSERT INTO administradores (nombre_administrador, apellido_administrador, alias_administrador, clave_administrador, correo_administrador, telefono_administrador, dui_administrador, fecha_nacimiento_administrador, fecha_creacion) 
VALUES ('José', 'Martínez', @alias, 'onegoalsv', 'chepemart@gmail.com', '1234-5678', '07070707-7', '1979-09-30', @fecha_creacion);

-- 2. tecnicos
INSERT INTO tecnicos (nombre_tecnico, apellido_tecnico, alias_tecnico, clave_tecnico, correo_tecnico, telefono_tecnico, dui_tecnico, fecha_nacimiento_tecnico) VALUES
('Roberto', 'Martínez', 'roberto_m', 'pass123', 'roberto@gmail.com', '7771-8234', '01010101-1', '1976-02-28'),
('María', 'Gutiérrez', 'maria_g', 'password123', 'maria@gmail.com', '6664-8321', '02020202-2', '1980-09-15'),
('José', 'Dominguez', 'jose_d', 'abc123', 'jose@gmail.com', '5551-7234', '03030303-3', '1978-11-10'),
('Verónica', 'Castro', 'veronica_c', 'clave456', 'veronica@gmail.com', '4444-7321', '04040404-4', '1983-07-22'),
('Daniel', 'Fernández', 'daniel_f', 'dani123', 'daniel@gmail.com', '3335-7678', '05050505-5', '1975-05-20'),
('Carolina', 'Santos', 'carolina_s', 'password456', 'carolina@gmail.com', '2221-7234', '06060606-6', '1982-08-18'),
('Jorge', 'Ruiz', 'jorge_r', 'qwerty123', 'jorge@gmail.com', '1114-7321', '08080808-8', '1977-03-30'),
('Paula', 'Ortega', 'paula_o', 'paula123', 'paula@gmail.com', '9995-7678', '09090909-9', '1984-12-05'),
('Alberto', 'Mendoza', 'alberto_m', 'contraseña123', 'alberto@gmail.com', '8881-7234', '10101010-0', '1979-06-08'),
('Carmen', 'Vargas', 'carmen_v', 'clave789', 'carmen@gmail.com', '7774-7321', '11111111-1', '1981-01-12');

-- 3. temporadas
INSERT INTO temporadas(anio_temporada) VALUES(2020);
INSERT INTO temporadas(anio_temporada) VALUES(2021);
INSERT INTO temporadas(anio_temporada) VALUES(2022);
INSERT INTO temporadas(anio_temporada) VALUES(2023);
INSERT INTO temporadas(anio_temporada) VALUES(2024);

-- 4. horarios
INSERT INTO horarios (dia, hora_inicial, hora_final, campo_de_entrenamiento) VALUES
('Miércoles', '16:00:00', '18:00:00', 'Cancha Bayer'),
('Jueves', '16:00:00', '18:00:00', 'Cancha Bayer'),
('Viernes', '16:00:00', '18:00:00', 'Cancha Bayer'),
('Sábado', '16:00:00', '18:00:00', 'Cancha Bayer'),
('Domingo', '16:00:00', '18:00:00', 'Cancha Bayer'),
('Lunes', '16:00:00', '18:00:00', 'Cancha Bayer'),
('Martes', '16:00:00', '18:00:00', 'Cancha Bayer'),
('Miércoles', '16:00:00', '18:00:00', 'Cancha Bayer'),
('Jueves', '16:00:00', '18:00:00', 'Cancha Bayer'),
('Viernes', '16:00:00', '18:00:00', 'Cancha Bayer');

-- 5. categorias
INSERT INTO categorias (nombre_categoria, edad_minima_permitida, edad_maxima_permitida, id_temporada, id_horario) VALUES
('Nivel 1', '2020-01-01', '2017-12-31', 1, 1),
('Nivel 2', '2016-01-01', '2011-12-31', 2, 2),
('Nivel 3', '2009-01-01', '2008-12-31', 3, 1),
('Nivel 4', '2007-01-01', '2005-12-31', 4, 2);

-- 6. cuerpos_tecnicos
INSERT INTO cuerpos_tecnicos (nombre_cuerpo_tecnico, primer_tecnico, segundo_tecnico, preparador_fisico, delegado) VALUES
('Cuerpo Técnico 1', 1, 2, 3, 4),
('Cuerpo Técnico 2', 2, 3, 4, 5),
('Cuerpo Técnico 3', 3, 4, 5, 6),
('Cuerpo Técnico 4', 4, 5, 6, 7),
('Cuerpo Técnico 5', 5, 6, 7, 8),
('Cuerpo Técnico 6', 6, 7, 8, 9),
('Cuerpo Técnico 7', 7, 8, 9, 10),
('Cuerpo Técnico 8', 8, 9, 10, 1),
('Cuerpo Técnico 9', 9, 10, 1, 2),
('Cuerpo Técnico 10', 10, 1, 2, 3);

-- 7. equipos
INSERT INTO equipos (nombre_equipo, genero_equipo, telefono_contacto, id_cuerpo_tecnico, id_administrador, id_categoria, logo_equipo) VALUES
('Barcelona', 'Masculino', '9865-2546', 1, 1, 1, 'default.jpg'),
('Girona', 'Masculino', '3287-6854', 1, 1, 1, 'default.jpg'),
('Real Madrid', 'Masculino', '2862-5882', 1, 1, 1, 'default.jpg'),
('Inter milan', 'Femenino', '2012-8676', 1, 1, 1, 'default.jpg'),
('Arsenal', 'Masculino', '0428-8654', 1, 1, 1, 'default.jpg'),
('Chelsea', 'Masculino', '7986-5687', 1, 1, 1, 'default.jpg'),
('Liverpool', 'Masculino', '3559-8751', 1, 1, 1, 'default.jpg'),
('Villarreal', 'Masculino', '6597-6578', 1, 1, 1, 'default.jpg'),
('Cádiz', 'Masculino', '5204-5687', 1, 1, 1, 'default.jpg'),
('Getafe', 'Masculino', '7687-6554', 1, 1, 1, 'default.jpg');

-- 8. posiciones
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

-- 9. jugadores
INSERT INTO jugadores (dorsal_jugador, nombre_jugador, apellido_jugador, estatus_jugador, fecha_nacimiento_jugador, genero_jugador, perfil_jugador, id_posicion_principal, id_posicion_secundaria, altura_jugador, peso_jugador, indice_masa_corporal, alias_jugador, clave_jugador, foto_jugador) VALUES
(10, 'Lionel', 'Messi', 'Activo', '1987-06-24', 'Masculino', 'Zurdo', 6, 4, 1.70, 72, 24.91, 'Leo', 'leomessi10', 'default.jpg'),
(7, 'Cristiano', 'Ronaldo', 'Activo', '1985-02-05', 'Masculino', 'Diestro', 5, 1, 1.87, 83, 23.77, 'CR7', 'ronaldo7', 'default.jpg'),
(10, 'Neymar', 'Jr.', 'Baja temporal', '1992-02-05', 'Masculino', 'Ambidiestro', 6, 3, 1.75, 68, 22.2, 'Ney', 'neymar10', 'default.jpg'),
(4, 'Sergio', 'Ramos', 'Activo', '1986-03-30', 'Masculino', 'Diestro', 13, 17, 1.83, 82, 24.43, 'SR4', 'ramos4', 'default.jpg'),
(17, 'Kevin', 'De Bruyne', 'Activo', '1991-06-28', 'Masculino', 'Ambidiestro', 8, 4, 1.81, 70, 21.39, 'KDB', 'debruyne17', 'default.jpg'),
(8, 'Andrés', 'Iniesta', 'Baja definitiva', '1984-05-11', 'Masculino', 'Diestro', 7, 11, 1.70, 68, 23.53, 'El Ilusionista', 'iniesta8', 'default.jpg'),
(9, 'Robert', 'Lewandowski', 'Activo', '1988-08-21', 'Masculino', 'Diestro', 1, 2, 1.84, 80, 23.62, 'Lewy', 'lewandowski9', 'foto7.jpg'),
(1, 'Manuel', 'Neuer', 'Activo', '1986-03-27', 'Masculino', 'Diestro', 18, 18, 1.93, 92, 24.69, 'Manu', 'neuer1', 'default.jpg'),
(7, 'Kylian', 'Mbappé', 'Activo', '1998-12-20', 'Masculino', 'Diestro', 1, 6, 1.78, 73, 23.05, 'Kyky', 'mbappe11', 'default.jpg'),
(6, 'Virgil', 'van Dijk', 'Baja temporal', '1991-07-08', 'Masculino', 'Diestro', 13, 14, 1.93, 92, 24.69, 'Big', 'virgil6', 'default.jpg');

-- 10. caracteristicas_jugadores
INSERT INTO caracteristicas_jugadores (nombre_caracteristica_jugador, clasificacion_caracteristica_jugador) VALUES
('PASE CORTO', 'Técnicos'),
('PASE MEDIO', 'Técnicos'),
('PASE LARGO', 'Técnicos'),
('CONDUCCIÓN', 'Técnicos'),
('RECEPCIÓN', 'Técnicos'),
('TOMA DE DECISIONES', 'Tácticos'),
('CONCEPTOS OFENSIVOS', 'Tácticos'),
('CONCEPTOS DEFENSIVOS', 'Tácticos'),
('CONCENTRACIÓN', 'Psicologicos'),
('SACRIFICIO', 'Psicologicos');

-- 11. plantillas_equipos
INSERT INTO plantillas_equipos (id_jugador, id_temporada, id_equipo) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5),
(6, 1, 6),
(7, 2, 7),
(8, 3, 8),
(9, 4, 9),
(10, 5, 10);

-- 12. caracteristicas_analisis
INSERT INTO caracteristicas_analisis (nota_caracteristica_analisis, id_jugador, id_caracteristica_jugador) VALUES
(9.5, 1, 1),
(5.0, 2, 2),
(6.3, 3, 3),
(5.5, 4, 4),
(8.9, 5, 5),
(2.4, 6, 6),
(6.8, 7, 7),
(3.5, 8, 8),
(7.9, 9, 9),
(5.6, 10, 10);

-- 13. asistencias


-- 14. temas_contenidos


-- 15. sub_temas_contenidos


-- 16. tareas


-- 17. detalles_contenidos


-- 18. jornadas


-- 19. entrenamientos
INSERT INTO entrenamientos(id_jornada, id_caracteristica_analisis, id_detalle_contenido) VALUES
(1,1,1),
(2,2,2),
(3,3,3),
(4,4,4),
(5,5,5),
(6,6,6),
(7,7,7),
(8,8,8),
(9,9,9),
(10,10,10);

-- 20. partidos
INSERT INTO partidos (id_entrenamiento, id_equipo, logo_rival, rival_partido, fecha_partido, cancha_partido, resultado_partido, localidad_partido, tipo_resultado_partido) VALUES
(1, 1, 'logoRival.png', 'Mocaco', 2023-05-12, 'San Benito', '3 - 4', 'Localidad', 'Victoria'),
(2, 2, 'logoTigres.png', 'Tigres', 2023-05-15, 'Mejicanos', '2 - 1', 'Visitante', 'Victoria'),
(3, 3, 'logoLeon.png', 'León', 2023-05-18, 'San Jacinto', '1 - 1', 'Localidad', 'Empate'),
(4, 4, 'logoÁguila.png', 'Águila', 2023-05-21, 'Soyapango', '0 - 2', 'Visitante', 'Derrota'),
(5, 1, 'logoAlianza.png', 'Alianza', 2023-05-24, 'San Salvador', '4 - 0', 'Localidad', 'Victoria'),
(6, 2, 'logoFAS.png', 'FAS', 2023-05-27, 'Santa Ana', '2 - 3', 'Visitante', 'Derrota'),
(7, 3, 'logoMetapán.png', 'Metapán', 2023-05-30, 'Chalatenango', '3 - 1', 'Localidad', 'Victoria'),
(8, 4, 'logoChalatenango.png', 'Chalatenango', 2023-06-02, 'San Miguel', '1 - 0', 'Visitante', 'Victoria'),
(9, 1, 'logoIsidroMetapán.png', 'Isidro Metapán', 2023-06-05, 'Usulután', '2 - 2', 'Localidad', 'Empate'),
(10, 2, 'logoOnceLobos.png', 'Once Lobos', 2023-06-08, 'Ahuachapán', '4 - 1', 'Visitante', 'Victoria');

-- 21. tipos_jugadas
INSERT INTO tipos_jugadas (id_tipo_jugada, nombre_tipo_juego) VALUES
(1, 'Tiro libre'),
(2, 'Juego directo'),
(3, 'Juego combinativo'),
(4, 'Contrataque'),
(5, 'Sack'),
(6, 'Intercepción'),
(7, 'Touchdown'),
(8, 'Field goal'),
(9, 'Safety'),
(10, 'Penalty');

-- 22. tipos_goles
INSERT INTO tipos_goles (id_tipo_gol, id_tipo_jugada, nombre_tipo_gol) VALUES
(1, 1, 'Tiro de esquina'),
(2, 2, 'Dentro del area'),
(3, 3, 'Pase corto'),
(4, 4, 'Pase largo'),
(5, 5, 'Carrera'),
(6, 6, 'Touchdown'),
(7, 7, 'Field goal'),
(8, 8, 'Safety'),
(9, 9, 'Penalty'),
(10, 10, 'Fumble');

-- 23. participaciones_partidos
INSERT INTO participaciones_partidos (id_partido, id_jugador, titular, sustitucion, minutos_jugados, goles, asistencias, estado_animo, puntuacion) VALUES
(1, 1, true, false, 20, 5, 2, 'Agotado', 8),
(2, 2, false, true, 15, 1, 0, 'Desanimado', 7),
(3, 3, true, false, 90, 0, 1, 'Normal', 9),
(4, 4, false, true, 30, 2, 0, 'Agotado', 8),
(5, 1, true, false, 60, 0, 1, 'Satisfecho', 7),
(6, 2, false, true, 45, 0, 0, 'Energético', 6),
(7, 3, true, false, 90, 3, 2, 'Agotado', 10),
(8, 4, false, true, 20, 1, 0, 'Normal', 7),
(9, 1, true, false, 75, 1, 1, 'Normal', 8),
(10, 2, false, true, 15, 0, 0, 'Normal', 6);

-- 24. detalles_goles
INSERT INTO detalles_goles (id_participacion, cantidad_tipo_gol, id_tipo_gol) VALUES
(1, 2, 2),
(1, 1, 4),
(1, 1, 2),
(1, 3, 3),
(1, 1, 5),
(1, 2, 2),
(1, 1, 4),
(1, 2, 5),
(1, 3, 5),
(1, 2, 2);

-- 25. detalles_amonestaciones
INSERT INTO detalles_amonestaciones (id_participacion, amonestacion, numero_amonestacion) VALUES








-- 26. tipos_lesiones
INSERT INTO tipos_lesiones (tipo_lesion) VALUES 
('LESIONES TREN INFERIOR'),
('LESIONES TREN SUPERIOR');

-- 27. tipologias
INSERT INTO tipologias (tipologia) VALUES 
('ISQUIOS'),
('CUÁDRICEPS'),
('SÓLEO'),
('GEMELO'),
('ROTURA DE LIGAMENTO CRUZADO'),
('ROTURA FIBRILAR'),
('ESGUINCE TOBILLO'),
('ROTURA LIG.RODILLA'),
('ESGUINCE RODILLA'),
('TENDÓN AQUILES');


-- 28. sub_tipologias
INSERT INTO sub_tipologias (nombre_sub_tipologia, id_tipologia) VALUES 
('Rotura de fibras', 1),
('Fractura de brazo', 2),
('Hematoma', 3),
('Tirón muscular', 1),
('Luxación de hombro', 5),
('ROTURA ESCAFOIDES', 1),
('TENDINITIS CODO', 2),
('FRACTURA', 3),
('FISURA', 1),
('INTERNO', 5);


-- 29. lesiones
INSERT INTO lesiones (id_tipo_lesion, id_sub_tipologia, numero_lesiones, promedio_lesiones) VALUES 
(1, 1, 5, 3),
(2, 3, 2, 2),
(2, 4, 3, 2),
(2, 5, 1, 1),
(1, 2, 4, 3),
(1, 1, 5, 3),
(2, 3, 2, 2),
(2, 4, 3, 2),
(2, 5, 1, 1),
(1, 2, 4, 3);


-- 30. registro_medico
INSERT INTO registros_medicos (id_jugador, fecha_lesion, dias_lesionado, id_lesion, retorno_entreno, retorno_partido) VALUES 
(1, '2024-03-15', 10, 1, '2024-03-25', 102),
(1, '2024-02-10', 15, 3, '2024-02-25', 101),
(1, '2024-01-20', 7, 5, '2024-01-27', 100);


-- 31. pago 
INSERT INTO pagos (fecha_pago, cantidad_pago, pago_tardio, mora_pago, mes_pago, id_jugador) VALUES 
('2024-04-01', 100.00, 0, 0.00, 'Abril', 1),
('2024-03-01', 100.00, 1, 5.00, 'Marzo', 1),
('2024-02-01', 100.00, 0, 0.00, 'Febrero', 1);
