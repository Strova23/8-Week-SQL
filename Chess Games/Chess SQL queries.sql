# all data
select *
from chess_games;

# Total amount of games
select count(distinct game_id) as games
from chess_games;

# Games won by Side
select winner, count(game_id) as Games_Won
from chess_games
group by winner;

# Total amount of players
select count(distinct id) as player_count
from 
	(
    select white_id as id
    from chess_games
    UNION ALL 
    select black_id as id
    from chess_games
    ) users;

# Temporary table to store the game with the least turns 
with CTE as (
	select min(turns) as shortest_game
    from chess_games
    )
# shortest games
select game_id, rated, turns, winner, victory_status, white_id, white_rating, black_id, black_rating, opening_shortname
from CTE, chess_games
where chess_games.turns = CTE.shortest_game;

# Temporary table to store the game with the most turns 
with CTE as (
	select max(turns) as longest_game
    from chess_games
    )
# longest game
select game_id, rated, turns, winner, victory_status, white_id, white_rating, black_id, black_rating, opening_shortname
from CTE, chess_games
where chess_games.turns = CTE.longest_game;

# What percentage of games were won by White? Black? Draw?
select round((select count(winner) from chess_games where winner = "White" ) / count(winner) * 100, 2) as White_win
	, round((select count(winner) from chess_games where winner = "Black" ) / count(winner) * 100, 2) as Black_win
    , round((select count(winner) from chess_games where winner = "Draw" ) / count(winner) * 100, 2) as Draw
from chess_games;

# Which opening move was most frequently used in games in which black won? 
select opening_shortname as first_move, count(opening_fullname) as frequency
from chess_games
where winner = "Black"
group by first_move
order by frequency desc;

# Which opening move was most frequently used in games in which white won?
select opening_shortname as first_move, count(opening_fullname) as frequency
from chess_games
where winner = "White"
group by first_move
order by frequency desc;

# What percentage of games are won by the player with the higher rating?
# Games won by White
select round((select count(winner) from chess_games where winner = "White" and white_rating > black_rating) / count(game_id) * 100, 2) as White_Percentage_Win
from chess_games;

# Games won by Black
select round((select count(winner) from chess_games where winner = "Black" and black_rating > white_rating) / count(game_id) * 100, 2) as Black_Percentage_Win
from chess_games;

# Games won by Higher Rated Player
select winner, count(game_id) as Games_Won
from chess_games
where winner = "White" and 
	white_rating > black_rating
UNION
select winner, count(game_id) as Games_Won
from chess_games
where winner = "Black" and 
	white_rating < black_rating;

# Which user won the most amount of games? -- id: taranga
select id, count(id) as games_won
from 
	(
    select rated, white_id as id
    from chess_games
    where winner = "White"
    UNION ALL
    select rated, black_id as id
    from chess_games
    where winner = "Black"
    ) temp
group by id
order by games_won desc;

# Games Won
# replace id with any specific username
select id, count(id) as games_won
from 
	(
    select white_id as id
    from chess_games
    where winner = "White"
    UNION ALL
    select black_id as id
    from chess_games
    where winner = "Black"
    ) temp
where id = "taranga"
group by id;

# Games Played
# replace id with any specific username
select id, count(id) as games_played
from 
	(
    select white_id as id
    from chess_games
    UNION ALL
    select black_id as id
    from chess_games
    ) temp
where id = "taranga"
group by id;

# Games played by each user
select id, count(played.id) as games_played
from 
	(
    select white_id as id
    from chess_games
    UNION ALL
    select black_id as id
    from chess_games
    ) played
group by id
order by games_played desc;
