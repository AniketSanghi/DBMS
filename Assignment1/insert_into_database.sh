#!/bin/bash

# State Code - State Table
tail -3132 age\-education.csv | cut -d ',' -f 2,3,4 | uniq > states.csv

sqlite3 population.db "CREATE TABLE states(
StateCode INTEGER,
DistrictCode INTEGER,
AreaName TEXT
);" ".mode csv" ".import states.csv states"

rm states.csv

# Multilingual-education
tail -864 multilingual-education.csv| cut -d ',' -f 1,4,5,6,7,8,9,10,11 > education.csv

sqlite3 population.db "CREATE TABLE multilingual_education(
StateCode INTEGER,
AreaType TEXT,
Education TEXT,
BilingualPersons INTEGER,
BilingualMales INTEGER,
BilingualFemales INTEGER,
TrilingualPersons INTEGER,
TrilingualMales INTEGER,
TrilingualFemales INTEGER
)" ".mode csv" ".import education.csv multilingual_education"

rm education.csv


# Multilingual-age
tail -1080 multilingual-age.csv| cut -d ',' -f 1,4,5,6,7,8,9,10,11 | tr "-" "," | sed 's/\(^[^,]*,[^,]*,\)Total/\10,1000/g' | sed 's/Age not stated/-1,-1/g' | sed 's/+/,90/g' > temp
paste -d, temp <(tail -1080 multilingual-age.csv| cut -d ',' -f 5) > mulage.csv
rm temp

sqlite3 population.db "CREATE TABLE multilingual_age(
StateCode INTEGER,
AreaType TEXT,
Agemin INTEGER,
Agemax INTEGER,
BilingualPersons INTEGER,
BilingualMales INTEGER,
BilingualFemales INTEGER,
TrilingualPersons INTEGER,
TrilingualMales INTEGER,
TrilingualFemales INTEGER,
AgeGrp TEXT
)" ".mode csv" ".import mulage.csv multilingual_age"

rm mulage.csv


# Populate with literate/Illiterate
tail -3132 age\-education.csv | cut -d ',' -f 2,5,6,7,8,9,10,11,12,13,14,15 |  sed "s/\(^[^,]*,[^,]*,\)\([^-+,a-zA-Z]*\)\(,\)/\1\2,\2\3/g" | sed "s/+/,90/g" |  tr "-" "," | sed "s/Age not stated/-1,-1/g" | sed "s/All ages/0,1000/g" > temp
paste -d, temp <(tail -3132 age\-education.csv | cut -d ',' -f 6) > pop.csv
rm temp

sqlite3 population.db "CREATE TABLE population(
StateCode INTEGER,
AreaType TEXT,
Agemin INTEGER,
Agemax INTEGER,
Population_Persons INTEGER,
Population_Males INTEGER,
Population_Females INTEGER,
Illiterate_Persons INTEGER,
Illiterate_Males INTEGER,
Illiterate_Females INTEGER,
literate_Persons INTEGER,
literate_Males INTEGER,
literate_Females INTEGER,
AgeGrp TEXT
)" ".mode csv" ".import pop.csv population"

rm pop.csv


# Literate categories
tail -3132 age\-education.csv | cut -d ',' -f 2,5,6,16- |  sed "s/\(^[^,]*,[^,]*,\)\([^-+,a-zA-Z]*\)\(,\)/\1\2,\2\3/g" | sed "s/+/,90/g" | tr "-" "," | sed "s/Age not stated/-1,-1/g" | sed "s/All ages/0,1000/g" > temp
paste -d, temp <(tail -3132 age\-education.csv | cut -d ',' -f 6) > lit.csv
rm temp

sqlite3 population.db "CREATE TABLE literates(
StateCode INTEGER,
AreaType TEXT,
Agemin INTEGER,
Agemax INTEGER,
NoEdu_Persons INTEGER,
NoEdu_Males INTEGER,
NoEdu_Females INTEGER,
BelowPrimary_Persons INTEGER,
BelowPrimary_Males INTEGER,
BelowPrimary_Females INTEGER,
Primary_Persons INTEGER,
Primary_Males INTEGER,
Primary_Females INTEGER,
Middle_Persons INTEGER,
Middle_Males INTEGER,
Middle_Females INTEGER,
Metric_Persons INTEGER,
Metric_Males INTEGER,
Metric_Females INTEGER,
Higher_Persons INTEGER,
Higher_Males INTEGER,
Higher_Females INTEGER,
NoTechnical_Persons INTEGER,
NoTechnical_Males INTEGER,
NoTechnical_Females INTEGER,
NoDegree_Persons INTEGER,
NoDegree_Males INTEGER,
NoDegree_Females INTEGER,
Graduate_Persons INTEGER,
Graduate_Males INTEGER,
Graduate_Females INTEGER,
Unclassfied_Persons INTEGER,
Unclassfied_Males INTEGER,
Unclassfied_Females INTEGER,
AgeGrp TEXT
)" ".mode csv" ".import lit.csv literates"

rm lit.csv