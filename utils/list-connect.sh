#!/bin/bash

# récupérer l'argument passé au script et le mettre dans une variable
# et si pas d'argument, alors mettre "*" dans la variable
if [ $# -eq 0 ]
  then
    sudo salt '*' test.ping > utils/list-connect.txt
  else
    sudo salt -N $1 test.ping > utils/list-connect.txt
fi



echo "" > utils/list-connect-true.txt
echo "Connecté " >> utils/list-connect-true.txt

grep -B 1 True utils/list-connect.txt >> utils/list-connect-true.txt

sed -i '/True/d' utils/list-connect-true.txt

echo "" >> utils/list-connect-true.txt
echo "Non connecté " >> utils/list-connect-true.txt

grep -B 1 "Minion did not return." utils/list-connect.txt >> utils/list-connect-true.txt

sed -i '/Minion did not return./d' utils/list-connect-true.txt

sed -i 's/:/ /g' utils/list-connect-true.txt

sed -i '/--/d' utils/list-connect-true.txt

echo "" >> utils/list-connect-true.txt
echo "Total " >> utils/list-connect-true.txt

int=0
int=$(sed -n '/Connecté/,/Non connecté/p' utils/list-connect-true.txt | wc -l)
int=$(($int-3))

int2=0
int2=$(sed -n '/Non connecté/,/Total/p' utils/list-connect-true.txt | wc -l)
int2=$(($int2-3+$int))

echo "$int/$int2" >> utils/list-connect-true.txt
echo "" >> utils/list-connect-true.txt

sed -i 's/Connecté /Connecté :/g' utils/list-connect-true.txt

sed -i 's/Non connecté /Non connecté :/g' utils/list-connect-true.txt

sed -i 's/Total /Total :/g' utils/list-connect-true.txt

cat utils/list-connect-true.txt
rm utils/list-connect.txt
rm utils/list-connect-true.txt