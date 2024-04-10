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


-- 10. caracteristicas_jugadores


-- 11. caracteristicas_analisis


-- 12. asistencias


-- 13. temas_contenidos


-- 14. sub_temas_contenidos


-- 15. tareas


-- 16. detalles_contenidos


-- 17. jornadas


-- 18. entrenamientos


-- 19. partidos
INSERT INTO partidos (id_entrenamiento, id_equipo, logo_rival, rival_partido, fecha_partido, cancha_partido, resultado_partido, localidad_partido, tipo_resultado_partido)


-- 20. tipos_jugadas
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

-- 21. tipos_goles
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

-- 22. participaciones_partidos
INSERT INTO participaciones_partidos (id_partido, id_jugador, titular, sustitucion, minutos_jugados, goles, asistencias, estado_animo, puntuacion)

-- 23. detalles_goles
INSERT INTO detalles_goles (id_participacion, cantidad_tipo_gol, id_tipo_gol)

-- 24. detalles_amonestaciones
INSERT INTO detalles_amonestaciones (id_participacion, amonestacion, numero_amonestacion)

-- 25. tipos_lesiones
INSERT INTO tipos_lesiones (tipo_lesion) VALUES 
('LESIONES TREN INFERIOR'),
('LESIONES TREN SUPERIOR');

-- 26. tipologias
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


-- 27. sub_tipologias
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


-- 28. lesiones
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


-- 29. registro_medico
INSERT INTO registros_medicos (id_jugador, fecha_lesion, dias_lesionado, id_lesion, retorno_entreno, retorno_partido) VALUES 
(1, '2024-03-15', 10, 1, '2024-03-25', 102),
(1, '2024-02-10', 15, 3, '2024-02-25', 101),
(1, '2024-01-20', 7, 5, '2024-01-27', 100);


-- 30. pago 
INSERT INTO pagos (fecha_pago, cantidad_pago, pago_tardio, mora_pago, mes_pago, id_jugador) VALUES 
('2024-04-01', 100.00, 0, 0.00, 'Abril', 1),
('2024-03-01', 100.00, 1, 5.00, 'Marzo', 1),
('2024-02-01', 100.00, 0, 0.00, 'Febrero', 1);
