USE db_gol_sv;

-- Administradores
INSERT INTO administradores (nombre_administrador, apellido_administrador, clave_administrador, correo_administrador, telefono_administrador, dui_administrador, fecha_nacimiento_administrador, alias_administrador, foto_administrador) VALUES
('Juan', 'Perez', '$2y$10$AE/qbXQgc6Ffn21F68sjdOzAbGgoI3Y9lYyG8/nMyRYpwQEIsNQ5q', 'juan.perez@example.com', '7443-0548', '07072307-9', '1980-01-01', 'jperez', 'default.png'),
('Maria', 'Lopez', '$2y$10$BF/jhyTgk7Gfn34J78jdnHzRfGftjJ4K5yTj8/mNQRYewSEOsJQ5t', 'maria.lopez@example.com', '7443-0549', '08082308-8', '1982-02-15', 'mlopez', 'default.png'),
('Pedro', 'Gonzalez', '$2y$10$CE/kijUk8Fgn45K89kfoUzShGhtuL5K6uUk9/pOQRZyxFRFsKQ6u', 'pedro.gonzalez@example.com', '7443-0550', '09092309-7', '1979-03-20', 'pgonzalez', 'default.png'),
('Ana', 'Martinez', '$2y$10$DF/lklVm9Ggo56L90lglUzTiHvvM7L7yVzL9/qPQSZyzGTEQsM2u', 'ana.martinez@example.com', '7443-0551', '10002310-6', '1985-04-10', 'amartinez', 'default.png'),
('Luis', 'Fernandez', '$2y$10$EF/mnlWo0Hhp67M01mhmUzUjHwWQ8M9yWzM0/rRSZAzHTFUsN3u', 'luis.fernandez@example.com', '7443-0552', '11012311-5', '1981-05-25', 'lfernandez', 'default.png');

-- Técnicos
INSERT INTO tecnicos (nombre_tecnico, apellido_tecnico, alias_tecnico, clave_tecnico, correo_tecnico, telefono_tecnico, dui_tecnico, fecha_nacimiento_tecnico, foto_tecnico) VALUES
('Carlos', 'Ramirez', 'cramirez', '$2y$10$AE/qbXQgc6Ffn21F68sjdOzAbGgoI3Y9lYyG8/nMyRYpwQEIsNQ5q', 'carlos.ramirez@example.com', '7845-4525', '07072308-7', '1985-05-15', 'default.png'),
('Jose', 'Mendez', 'jmendez', '$2y$10$BF/jhyTgk7Gfn34J78jdnHzRfGftjJ4K5yTj8/mNQRYewSEOsJQ5t', 'jose.mendez@example.com', '7845-4526', '08082309-6', '1987-07-19', 'default.png'),
('Miguel', 'Hernandez', 'mhernandez', '$2y$10$CE/kijUk8Fgn45K89kfoUzShGhtuL5K6uUk9/pOQRZyxFRFsKQ6u', 'miguel.hernandez@example.com', '7845-4527', '09092310-5', '1989-09-23', 'default.png'),
('Laura', 'Garcia', 'lgarcia', '$2y$10$DF/lklVm9Ggo56L90lglUzTiHvvM7L7yVzL9/qPQSZyzGTEQsM2u', 'laura.garcia@example.com', '7845-4528', '10002311-4', '1991-11-27', 'default.png'),
('Sofia', 'Reyes', 'sreyes', '$2y$10$EF/mnlWo0Hhp67M01mhmUzUjHwWQ8M9yWzM0/rRSZAzHTFUsN3u', 'sofia.reyes@example.com', '7845-4529', '11012312-3', '1993-01-31', 'default.png');

-- Temporadas
INSERT INTO temporadas (nombre_temporada) VALUES
('Temporada 2024'),
('Temporada 2023'),
('Temporada 2022'),
('Temporada 2021'),
('Temporada 2020'),
('Temporada 2019');

-- Horarios
INSERT INTO horarios (nombre_horario, dia, hora_inicial, hora_final, campo_de_entrenamiento) VALUES
('Entrenamiento Lunes', 'Lunes', '08:00:00', '10:00:00', 'Campo A'),
('Entrenamiento Martes', 'Martes', '10:00:00', '12:00:00', 'Campo B'),
('Entrenamiento Miercoles', 'Miercoles', '12:00:00', '14:00:00', 'Campo C'),
('Entrenamiento Jueves', 'Jueves', '14:00:00', '16:00:00', 'Campo D'),
('Entrenamiento Viernes', 'Viernes', '16:00:00', '18:00:00', 'Campo E'),
('Entrenamiento Sabado', 'Sabado', '18:00:00', '20:00:00', 'Campo F');

-- Categorías
INSERT INTO categorias (nombre_categoria, edad_minima_permitida, edad_maxima_permitida, id_temporada) VALUES
('Sub-18', 15, 18, 1),
('Sub-16', 13, 16, 2),
('Sub-14', 11, 14, 3),
('Sub-12', 9, 12, 4),
('Sub-10', 7, 10, 5),
('Sub-8', 5, 8, 6);


-- Horarios_Categorias
INSERT INTO horarios_categorias (id_categoria, id_horario) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6);

-- Rol_Tecnico
INSERT INTO rol_tecnico (nombre_rol_tecnico) VALUES
('Entrenador Principal'),
('Asistente Técnico'),
('Preparador Físico'),
('Entrenador de Porteros'),
('Analista de Video'),
('Médico Deportivo');

-- Cuerpos_Tecnicos
INSERT INTO cuerpos_tecnicos (nombre_cuerpo_tecnico) VALUES
('Cuerpo Técnico A'),
('Cuerpo Técnico B'),
('Cuerpo Técnico C'),
('Cuerpo Técnico D'),
('Cuerpo Técnico E'),
('Cuerpo Técnico F');

-- Detalles_Cuerpos_Tecnicos
INSERT INTO detalles_cuerpos_tecnicos (id_cuerpo_tecnico, id_tecnico, id_rol_tecnico) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5);

-- Equipos
INSERT INTO equipos (nombre_equipo, genero_equipo, telefono_contacto, id_cuerpo_tecnico, id_categoria, logo_equipo) VALUES
('Equipo A', 'Masculino', '123123123', 1, 1, 'default.png'),
('Equipo B', 'Femenino', '234234234', 2, 2, 'default.png'),
('Equipo C', 'Masculino', '345345345', 3, 3, 'default.png'),
('Equipo D', 'Femenino', '456456456', 4, 4, 'default.png'),
('Equipo E', 'Masculino', '567567567', 5, 5, 'default.png'),
('Equipo F', 'Femenino', '678678678', 6, 6, 'default.png');

-- Posiciones
INSERT INTO posiciones (posicion, area_de_juego) VALUES
('Central', 'Ofensiva'),
('Delantero', 'Ofensiva'),
('Portero', 'Defensiva'),
('Defensa', 'Defensiva'),
('Mediocampista', 'Medio'),
('Extremo', 'Ofensiva');

-- Jugadores
INSERT INTO jugadores (nombre_jugador, apellido_jugador, estatus_jugador, fecha_nacimiento_jugador, genero_jugador, perfil_jugador, becado, id_posicion_principal, id_posicion_secundaria, alias_jugador, clave_jugador, foto_jugador) VALUES
('Luis', 'Gomez', 'Activo', '2005-02-20', 'Masculino', 'Diestro', 'Ninguna', 1, NULL, 'lgomez', '$2y$10$AE/qbXQgc6Ffn21F68sjdOzAbGgoI3Y9lYyG8/nMyRYpwQEIsNQ5q', 'default.png'),
('Juan', 'Lopez', 'Inactivo', '2004-03-15', 'Masculino', 'Zurdo', 'Media', 2, 3, 'jlopez', '$2y$10$BF/jhyTgk7Gfn34J78jdnHzRfGftjJ4K5yTj8/mNQRYewSEOsJQ5t', 'default.png'),
('Pedro', 'Martinez', 'Activo', '2006-05-10', 'Masculino', 'Diestro', 'Completa', 3, 4, 'pmartinez', '$2y$10$CE/kijUk8Fgn45K89kfoUzShGhtuL5K6uUk9/pOQRZyxFRFsKQ6u', 'default.png'),
('Ana', 'Hernandez', 'Inactivo', '2005-07-25', 'Femenino', 'Zurdo', 'Parcial', 4, 5, 'ahernandez', '$2y$10$DF/lklVm9Ggo56L90lglUzTiHvvM7L7yVzL9/qPQSZyzGTEQsM2u', 'default.png'),
('Maria', 'Garcia', 'Activo', '2003-09-05', 'Femenino', 'Diestro', 'Ninguna', 5, 6, 'mgarcia', '$2y$10$EF/mnlWo0Hhp67M01mhmUzUjHwWQ8M9yWzM0/rRSZAzHTFUsN3u', 'default.png'),
('Sofia', 'Reyes', 'Inactivo', '2004-11-30', 'Femenino', 'Zurdo', 'Completa', 6, 1, 'sreyes', '$2y$10$FF/nopXq1Iip78N12npoVzVjIvvL8N8yUzN1/sSUXBzzHTGVTN4v', 'default.png');

-- Estados_Fisicos_Jugadores
INSERT INTO estados_fisicos_jugadores (id_jugador, altura_jugador, peso_jugador, indice_masa_corporal) VALUES
(1, 180.00, 75.00, 23.15),
(2, 175.00, 70.00, 22.86),
(3, 185.00, 80.00, 23.37),
(4, 170.00, 65.00, 22.49),
(5, 160.00, 55.00, 21.48),
(6, 165.00, 60.00, 22.04);

-- Plantillas
INSERT INTO plantillas (nombre_plantilla) VALUES
('Plantilla 2024'),
('Plantilla 2023'),
('Plantilla 2022'),
('Plantilla 2021'),
('Plantilla 2020'),
('Plantilla 2019');

-- Plantillas_Equipos
INSERT INTO plantillas_equipos (id_plantilla, id_jugador, id_temporada, id_equipo) VALUES
(1, 1, 1, 1),
(2, 2, 2, 2),
(3, 3, 3, 3),
(4, 4, 4, 4),
(5, 5, 5, 5),
(6, 6, 6, 6);

-- Jornadas
INSERT INTO jornadas (nombre_jornada, numero_jornada, id_plantilla, fecha_inicio_jornada, fecha_fin_jornada) VALUES
('Jornada 1', 1, 1, '2024-01-01', '2024-01-07'),
('Jornada 2', 2, 2, '2024-01-08', '2024-01-14'),
('Jornada 3', 3, 3, '2024-01-15', '2024-01-21'),
('Jornada 4', 4, 4, '2024-01-22', '2024-01-28'),
('Jornada 5', 5, 5, '2024-01-29', '2024-02-04'),
('Jornada 6', 6, 6, '2024-02-05', '2024-02-11');

-- Entrenamientos
INSERT INTO entrenamientos (fecha_entrenamiento, sesion, id_jornada, id_equipo, id_horario_categoria) VALUES
('2024-01-02', 'Sesion 1', 1, 1, 1),
('2024-01-09', 'Sesion 2', 2, 2, 2),
('2024-01-16', 'Sesion 3', 3, 3, 3),
('2024-01-23', 'Sesion 4', 4, 4, 4),
('2024-01-30', 'Sesion 5', 5, 5, 5),
('2024-02-06', 'Sesion 6', 6, 6, 6);

-- Características_Jugadores
INSERT INTO caracteristicas_jugadores (nombre_caracteristica_jugador, clasificacion_caracteristica_jugador) VALUES
('Resistencia', 'Físicos'),
('Velocidad', 'Físicos'),
('Fuerza', 'Físicos'),
('Técnica', 'Técnicos'),
('Táctica', 'Técnicos'),
('Visión de juego', 'Mentales');

-- Características_Analisis
INSERT INTO caracteristicas_analisis (nota_caracteristica_analisis, id_jugador, id_caracteristica_jugador, id_entrenamiento) VALUES
(9.5, 1, 1, 1),
(8.0, 2, 2, 2),
(7.5, 3, 3, 3),
(8.5, 4, 4, 4),
(9.0, 5, 5, 5),
(7.0, 6, 6, 6);

-- Asistencias
INSERT INTO asistencias (id_jugador, id_horario, fecha_asistencia, asistencia, observacion_asistencia, id_entrenamiento) VALUES
(1, 1, '2024-01-02', 'Asistencia', NULL, 1),
(2, 2, '2024-01-09', 'Asistencia', 'Llegó tarde', 2),
(3, 3, '2024-01-16', 'Falta', 'Motivo personal', 3),
(4, 4, '2024-01-23', 'Asistencia', NULL, 4),
(5, 5, '2024-01-30', 'Asistencia', 'Lesión', 5),
(6, 6, '2024-02-06', 'Asistencia', NULL, 6);

-- Temas_Contenidos
INSERT INTO temas_contenidos (nombre_tema_contenido) VALUES
('Estrategias de juego'),
('Técnicas de pase'),
('Defensa en zona'),
('Ataque rápido'),
('Tácticas de equipo'),
('Preparación física');

-- Sub_Temas_Contenidos
INSERT INTO sub_temas_contenidos (sub_tema_contenido, id_tema_contenido) VALUES
('Ataque en bloque', 1),
('Pase corto', 2),
('Defensa alta', 3),
('Contraataque', 4),
('Presión alta', 5),
('Entrenamiento de fuerza', 6);

-- Tareas
INSERT INTO tareas (nombre_tarea) VALUES
('Ejercicio de tiro'),
('Ejercicio de pase'),
('Ejercicio de defensa'),
('Ejercicio de resistencia'),
('Ejercicio de táctica'),
('Ejercicio de técnica');

-- Detalles_Contenidos
INSERT INTO detalles_contenidos (id_tarea, id_sub_tema_contenido, minutos_contenido, minutos_tarea) VALUES
(1, 1, 30, 15),
(2, 2, 45, 20),
(3, 3, 60, 25),
(4, 4, 75, 30),
(5, 5, 90, 35),
(6, 6, 105, 40);

-- Detalle_Entrenamiento
INSERT INTO detalle_entrenamiento (id_entrenamiento, id_detalle_contenido, id_jugador) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5),
(6, 6, 6);

-- Rivales
INSERT INTO rivales (nombre_rival, logo_rival) VALUES
('Rival A', 'default.png'),
('Rival B', 'default.png'),
('Rival C', 'default.png'),
('Rival D', 'default.png'),
('Rival E', 'default.png'),
('Rival F', 'default.png');

-- Partidos
INSERT INTO partidos (id_jornada, id_equipo, fecha_partido, cancha_partido, resultado_partido, localidad_partido, tipo_resultado_partido, id_rival) VALUES
(1, 1, '2024-01-15 15:00:00', 'Cancha A', '2-1', 'Local', 'Victoria', 1),
(2, 2, '2024-01-22 17:00:00', 'Cancha B', '0-2', 'Visitante', 'Derrota', 2),
(3, 3, '2024-01-29 19:00:00', 'Cancha C', '1-1', 'Local', 'Empate', 3),
(4, 4, '2024-02-05 16:00:00', 'Cancha D', '3-0', 'Visitante', 'Victoria', 4),
(5, 5, '2024-02-12 18:00:00', 'Cancha E', '2-2', 'Local', 'Empate', 5),
(6, 6, '2024-02-19 20:00:00', 'Cancha F', '1-3', 'Visitante', 'Derrota', 6);

-- Participaciones_Partidos
INSERT INTO participaciones_partidos (id_partido, id_jugador, titular, sustitucion, minutos_jugados, goles, asistencias, estado_animo, puntuacion) VALUES
(1, 1, TRUE, FALSE, 90, 1, 0, 'Energético', 8.5),
(2, 2, TRUE, FALSE, 90, 0, 1, 'Concentrado', 7.0),
(3, 3, TRUE, FALSE, 90, 1, 1, 'Motivado', 8.0),
(4, 4, TRUE, FALSE, 90, 2, 0, 'Entusiasmado', 9.0),
(5, 5, TRUE, FALSE, 90, 0, 2, 'Optimista', 7.5),
(6, 6, TRUE, FALSE, 90, 1, 0, 'Calmado', 8.0);

-- Tipos_Jugadas
INSERT INTO tipos_jugadas (nombre_tipo_juego) VALUES
('Contraataque'),
('Presión defensiva'),
('Transición rápida'),
('Remate desde fuera del área'),
('Jugada elaborada');

-- Tipos_Goles
INSERT INTO tipos_goles (id_tipo_jugada, nombre_tipo_gol) VALUES
(1, 'Gol de cabeza'),
(2, 'Gol de volea'),
(3, 'Gol de penal'),
(4, 'Gol olímpico'),
(5, 'Gol de tiro libre');

-- Detalles_Goles
INSERT INTO detalles_goles (id_participacion, cantidad_tipo_gol, id_tipo_gol) VALUES
(1, 1, 1),
(2, 1, 3),
(3, 1, 1),
(4, 2, 1),
(5, 1, 5),
(6, 1, 2);

-- Detalles_Amonestaciones
INSERT INTO detalles_amonestaciones (id_participacion, amonestacion, numero_amonestacion) VALUES
(1, 'Tarjeta amarilla', 1),
(2, 'Tarjeta amarilla', 2),
(3, 'Tarjeta roja', 1),
(5, 'Tarjeta amarilla', 1),
(6, 'Tarjeta amarilla', 1);

-- Tipos_Lesiones
INSERT INTO tipos_lesiones (tipo_lesion) VALUES
('Desgarro muscular'),
('Fractura ósea'),
('Luxación articular'),
('Lesión de ligamentos'),
('Esguince');

-- Tipologias
INSERT INTO tipologias (tipologia) VALUES
('Tipologia A'),
('Tipologia B'),
('Tipologia C'),
('Tipologia D'),
('Tipologia E'),
('Tipologia F');

-- Sub_Tipologias
INSERT INTO sub_tipologias (nombre_sub_tipologia, id_tipologia) VALUES
('Sub Tipologia A1', 1),
('Sub Tipologia A2', 1),
('Sub Tipologia B1', 2),
('Sub Tipologia C1', 3),
('Sub Tipologia D1', 4);

-- Lesiones
INSERT INTO lesiones (id_tipo_lesion, id_sub_tipologia, total_por_lesion, porcentaje_por_lesion) VALUES
(1, 1, 1, 100),
(2, 1, 2, 80),
(3, 2, 1, 50),
(4, 3, 3, 70),
(5, 4, 2, 60),
(1, 1, 1, 100);

-- Registros_Medicos
INSERT INTO registros_medicos (id_jugador, fecha_lesion, dias_lesionado, id_lesion, retorno_entreno, retorno_partido) VALUES
(1, '2024-01-10', 10, 1, '2024-01-20', 1),
(2, '2024-02-10', 15, 2, '2024-02-25', 2),
(3, '2024-03-15', 20, 3, '2024-04-04', 3),
(4, '2024-04-20', 25, 4, '2024-05-15', 4),
(5, '2024-05-25', 30, 5, '2024-06-24', 5),
(6, '2024-06-30', 35, 1, '2024-07-25', 6);

-- Pagos
INSERT INTO pagos (fecha_pago, cantidad_pago, pago_tardio, mora_pago, mes_pago, id_jugador) VALUES
('2024-01-05', 50.00, FALSE, 0.00, 'Enero', 1),
('2024-01-10', 50.00, TRUE, 5.00, 'Enero', 2),
('2024-01-15', 50.00, FALSE, 0.00, 'Enero', 3),
('2024-01-20', 50.00, TRUE, 10.00, 'Enero', 4),
('2024-01-25', 50.00, FALSE, 0.00, 'Enero', 5),
('2024-01-30', 50.00, TRUE, 15.00, 'Enero', 6);
