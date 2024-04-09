-- SCRIPT DE INSERTS
USE db_gol_sv;

-- 1. Admin


-- 2. tecnicos


-- 3. temporadas


-- 4. horarios


-- 5. categorias


-- 6. cuerpos_tecnicos


-- 7. equipos


-- 8. posiciones


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


-- 26. tipologias


-- 27. sub_tipologias


-- 28. lesiones


-- 29. registro_medico


-- 30. pago 
