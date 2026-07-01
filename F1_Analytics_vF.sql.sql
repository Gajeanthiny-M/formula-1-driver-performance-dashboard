SELECT
    d.forename,
    d.surname,
    COUNT(*) AS races,
    ROUND(AVG(s.grid), 2) AS avg_grid,
    ROUND(AVG(s.position), 2) AS avg_finish,
    ROUND(AVG(s.grid - s.position), 2) AS racecraft_score,
    ROUND(
        AVG(
            CASE
                WHEN s.grid >= 10 THEN s.grid - s.position
            END
        ), 2
    ) AS recovery_drive_index,
    SUM(CASE WHEN s.position = 1 THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN s.position <= 3 THEN 1 ELSE 0 END) AS podiums,
    ROUND(
        100.0 * SUM(CASE WHEN s.position <= 3 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS podium_rate
FROM formula_one_sessionentry s
JOIN formula_one_session sess
    ON s.session_id = sess.id
JOIN formula_one_roundentry r
    ON s.round_entry_id = r.id
JOIN formula_one_teamdriver td
    ON r.team_driver_id = td.id
JOIN formula_one_driver d
    ON td.driver_id = d.id
JOIN formula_one_round ro
    ON r.round_id = ro.id
JOIN formula_one_season se
    ON ro.season_id = se.id
WHERE s.grid IS NOT NULL
AND s.position IS NOT NULL
AND se.year >= 2018
AND sess.type = 'R'
GROUP BY
    d.forename,
    d.surname
HAVING COUNT(*) >= 75
ORDER BY recovery_drive_index DESC;