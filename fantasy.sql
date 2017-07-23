CREATE schema fantasy

CREATE VIEW fantasy.individual_dk AS (
select
player_id,
gsis_id,
team,
sum(passing_Tds)*4 as passing_tds,
SUM(passing_yds)/25 as passing_yds,
SUM(receiving_rec) as receiving_rec,
SUM(passing_int)*-1 as passing_int,
SUM(rushing_yds)/10 as rushing_yds,
SUM(rushing_tds)*6 as rushing_tds,
SUM(receiving_yds)/10 as receiving_yds,
SUM(receiving_tds)*6 as receiving_tds,
SUM(puntret_tds)*6 as puntret_tds,
SUM(fumbles_lost)*-1 as fumbles_lost,
(SUM(passing_twoptm)+SUM(rushing_twoptm)+SUM(receiving_twoptm))*2 as twoptm,
SUM(fumbles_rec_tds)*6 as fumbles_rec_tds,
SUM(defense_sk) as defense_sk,
SUM(defense_int)*2 as defense_int,
SUM(defense_frec)*2 as defense_frec,
SUM(defense_int_tds)*6 as defense_int_tds,
SUM(defense_frec_tds)*6 as defense_frec_tds,
SUM(defense_puntblk)*6 as defense_puntblk,
SUM(defense_safe)*2 as defense_safe,
(SUM(defense_fgblk)+ SUM(punting_blk))*2 as defense_fgblk
from play_player
GROUP BY 1, 2, 3)

CREATE VIEW fantasy.game_score AS (
SELECT
a.team,
a.gsis_id,
CASE WHEN a.team=b.home_team THEN home_score WHEN a.team=away_team THEN away_score ELSE NULL end as team_score,
CASE WHEN a.team=b.away_team THEN home_score WHEN a.team=home_team THEN away_score ELSE NULL end as oppo_score
FROM fantasy.individual_dk a
LEFT JOIN game b ON (b.home_team=a.team OR b.away_team=a.team) and a.gsis_id=b.gsis_id
GROUP BY 1,2,3,4)

CREATE VIEW fantasy.def_score AS (
SELECT team, gsis_id,
CASE WHEN oppo_score = 0 THEN 10
WHEN oppo_score<7 THEN 7
WHEN oppo_score<14 THEN 4
WHEN oppo_score<=20 THEN 1
WHEN oppo_score<=27 THEN 0
WHEN oppo_score<=34 THEN -1
WHEN oppo_score>=35 THEN -4
ELSE NULL END as def_points
FROM fantasy.game_score)