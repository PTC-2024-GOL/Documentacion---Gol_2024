-- SCRIPT DE INSERTS
USE db_gol_sv;

-- 1. Admin


-- 2. tecnicos


-- 3. temporadas
INSERT INTO temporadas(anio_temporada) VALUES(2020);
INSERT INTO temporadas(anio_temporada) VALUES(2021);
INSERT INTO temporadas(anio_temporada) VALUES(2022);
INSERT INTO temporadas(anio_temporada) VALUES(2023);
INSERT INTO temporadas(anio_temporada) VALUES(2024);

-- 4. horarios


-- 5. categorias


-- 6. cuerpos_tecnicos


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
