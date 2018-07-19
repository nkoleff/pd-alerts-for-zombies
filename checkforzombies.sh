#!/bin/bash

#check for zobie processes
zombies=`ps -aux | awk '{ if ($8 ~ /Z/) { print } }'`

#add current date to variable
date=$(date +"%Y-%m-%d %H:%M")

if [ -z "$zombies" ]; then 
	echo "there are no zombie processes"
	#if there are no zombie processes resolve current in state

	while read k; do

		curl -H "Content-type: application/json" -X POST \
	    -d '{    
			"service_key": "YOUR-KEY-HERE",
			"incident_key": "Zombie-'$k'",
			"event_type": "resolve",
			"description": "Nikolay fixed the Zombie-'$k'.",
			"details": {
			"fixed at": "'"$date"'"
			}
	    }' \
	    "https://events.pagerduty.com/generic/2010-04-15/create_event.json"

	done < <(comm -23 <( awk '{print $2}' /home/kolev/Documents/zombie_state.txt | sort)  <(ps -aux | awk '{ if ($8 ~ /Z/) { print $2} }' | sort))

else

	if [ ! -f /home/kolev/Documents/zombie_state.txt ]; then
		echo "file is not found"

    	#create alerts when file is not found as there are some zombie processes

    	while read p; do
  			
    		curl -H "Content-Type: application/json" -X POST \
	    	-d '{
	    		"service_key": "YOUR-KEY-HERE", 
	    		"incident_key": "Zombie-'$p'",
	    		"event_type": "trigger", 
	    		"description": "Zombie processes found Zombie-'$p'.", 
	    		"client": "Sample Monitoring Service",
	    		"client_url": "https://monitoring.service.com",
	    		"details": { 
	    			"device": "Nikolay laptop" 
	    		}
	    	}' \
	    	https://events.pagerduty.com/generic/2010-04-15/create_event.json

		done < <(ps -aux | awk '{ if ($8 ~ /Z/) { print $2} }')
    	
    else
		echo "file is found"    	
    	#when file exist first resolve old zombie alerts

    	while read d; do

    		curl -v -H "Content-type: application/json" -X POST \
		    -d '{    
				"service_key": "YOUR-KEY-HERE",
				"incident_key": "Zombie-'$d'",
				"event_type": "resolve",
				"description": "Nikolay fixed the Zombie-'$d'.",
				"details": {
				"fixed at": "'"$date"'"
				}
		    }' \
		    "https://events.pagerduty.com/generic/2010-04-15/create_event.json"

    	done < <(comm -23 <( awk '{print $2}' /home/kolev/Documents/zombie_state.txt | sort)  <(ps -aux | awk '{ if ($8 ~ /Z/) { print $2} }' | sort))

    	#now create new alerts for the new zombies

    	while read w; do

    		curl -H "Content-Type: application/json" -X POST \
	    	-d '{
	    		"service_key": "YOUR-KEY-HERE", 
	    		"incident_key": "Zombie-'$w'",
	    		"event_type": "trigger", 
	    		"description": "Zombie processes found Zombie-'$w'.", 
	    		"client": "Sample Monitoring Service",
	    		"client_url": "https://monitoring.service.com",
	    		"details": { 
	    			"device": "Nikolay laptop" 
	    		}
	    	}' \
	    	https://events.pagerduty.com/generic/2010-04-15/create_event.json

    	done < <(comm -13 <( awk '{print $2}' /home/kolev/Documents/zombie_state.txt | sort)  <(ps -aux | awk '{ if ($8 ~ /Z/) { print $2} }' | sort))

	fi

fi

#create state file
zombies_state=`ps -aux | awk '{ if ($8 ~ /Z/) { print } }' > /home/kolev/Documents/zombie_state.txt`
