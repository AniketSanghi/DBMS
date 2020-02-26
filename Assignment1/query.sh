#!/bin/bash

if [ $# -eq 0 ]
then
	echo "Enter query number as argument"
fi

if [[ $1 = "1" ]]
then
	
	sqlite3 population.db "SELECT areaname, (100.0*TrilingualPersons/Population_Persons) as Percentage_Trilingual
	FROM (SELECT statecode, Population_Persons 
			FROM population
			WHERE AgeGrp = 'All ages' and AreaType = 'Total') 
		NATURAL JOIN (SELECT statecode, TrilingualPersons
			FROM multilingual_age
			WHERE AgeGrp = 'Total' and AreaType = 'Total')
		NATURAL JOIN states 
	WHERE statecode != 0
	ORDER BY Percentage_Trilingual"

elif [[ $1 = "2" ]]
then
	
	sqlite3 population.db " SELECT agegrp1, max(100.0*BilingualPersons/total)
	FROM (SELECT agegrp1, BilingualPersons, sum(Population_Persons) as total
		FROM (SELECT agegrp as agegrp1, agemin as agemin1, agemax as agemax1, BilingualPersons
				FROM multilingual_age
				WHERE statecode = 0 and AreaType = 'Total' and agegrp != 'Total' and agemin != -1)
			JOIN (SELECT agegrp as agegrp2, agemin as agemin2, agemax as agemax2, Population_Persons
				FROM population
				WHERE statecode = 0 and AreaType = 'Total' and agegrp != 'All ages' and agemin != -1)
		WHERE (agemin2 >= agemin1 and agemin2 <= agemax1) or (agemax2 >= agemin1 and agemax2 <= agemax1)
		GROUP BY agegrp1)"


elif [[ $1 = "3" ]]
then

	sqlite3 population.db "SELECT AgeGrp, max(skew)
	FROM (SELECT AgeGrp, (1.0*Population_Males/Population_Females) as skew
			FROM population
			WHERE statecode = 0 and AreaType = 'Total' and AgeGrp != 'All ages'
		UNION SELECT AgeGrp, (1.0*Population_Females/Population_Males) as skew
			FROM population
			WHERE statecode = 0 and AreaType = 'Total' and AgeGrp != 'All ages')"

elif [[ $1 = "4" ]]
then

	sqlite3 population.db "SELECT (Population_Persons - BilingualPersons)
	FROM (SELECT statecode, Population_Persons 
			FROM population
			WHERE AgeGrp = 'All ages' and AreaType = 'Total' and statecode = 0) 
		NATURAL JOIN (SELECT statecode, BilingualPersons
			FROM multilingual_age
			WHERE AgeGrp = 'Total' and AreaType = 'Total' and statecode = 0)"

elif [[ $1 = "5" ]]
then

	sqlite3 population.db "SELECT statecode, areaname, max(avg)
	FROM	(SELECT statecode, areaname, (1.0*sum(avgP)/sum(Population_Persons)) as avg
			FROM ( 	SELECT statecode, areaname, (((Agemin + Agemax)/2)*Population_Persons) as avgP, Population_Persons
					FROM population NATURAL JOIN states
					WHERE AreaType = 'Total' and statecode != 0 and agegrp != 'All ages' and Agemin != -1 )
			GROUP BY statecode)"

fi