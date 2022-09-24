#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~ Number guessing game 1-1000 ~~\n"
ANS=$[ 1 + $RANDOM % 1000 ]
echo $ANS
ATTEMPTS=0

GENERATE_USER(){
echo "Enter your username:"
read USER
FIND_USER=$($PSQL "SELECT username FROM users WHERE username='$USER'")
G_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USER'") 
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USER'") 
if [[ "$(echo $USER| wc -c )" -gt "22" ]]
then
echo "Maximum 22 characters"
GENERATE_USER
else
if [[ -z $FIND_USER ]]
then
echo "Welcome, $USER! It looks like this is your first time here."
echo -e "\nGuess the secret number between 1 and 1000:"
PLAY_GAME
else
echo -e "\nWelcome back, $USER! You have played $G_PLAYED games, and your best game took $BEST_GAME guesses."
echo -e "\nGuess the secret number between 1 and 1000:"
PLAY_GAME
fi
fi
}

PLAY_GAME(){
((ATTEMPTS=$ATTEMPTS + 1))
read GUESS
if [[ ! $GUESS =~ ^[0-9]+$ ]]
then
echo "That is not an integer, guess again:"
PLAY_GAME
else
if [[ $GUESS -lt $ANS ]]
then
echo "It's higher than that, guess again:"
PLAY_GAME
elif [[ $GUESS -gt $ANS ]]
then
echo "It's lower than that, guess again:"
PLAY_GAME
else
INSERT_RESULTS
echo -e "\nYou guessed it in $ATTEMPTS tries. The secret number was $ANS. Nice job!"
fi
fi
}

INSERT_RESULTS(){
if [[ -z $FIND_USER ]]
then
INSERT_NEW=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USER', 1, $ATTEMPTS)")
else
if [[ $BEST_GAME -lt $ATTEMPTS ]]
then
UPDATE_USER=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USER'")
else
UPDATE_RECORD=$($PSQL "UPDATE users SET (games_played, best_game) = (games_played + 1, $ATTEMPTS) WHERE username = '$USER'")
fi
fi
}

GENERATE_USER