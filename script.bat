@ECHO OFF

mysql --local-infile=1 -u "bases1" "-pbases1" "proy2" < "[BD1]CargaMasiva_201403767.sql"

pause;
exit;