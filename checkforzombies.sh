#!/bin/bash

#enter your service key
echo "Enter your Pagerduty service key:"
read -s service_key

#create the state file
path=/home/kolev/Documents/zombie_state.txt
touch $path

#check for zombie processes and add them to variable
zombies=`ps -aux | awk '{ if ($8 ~ /Z/) { print } }'`

#add current date and time to variable
date=$(date +"%Y-%m-%d %H:%M")


#functions for Pagerduty alerts resolve and trigger

trigger () {

	#create alerts for zombies

	while read p; do
  			
		curl -H "Content-Type: application/json" -X POST \
    	-d '{
    		"service_key": "'$service_key'", 
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

	done < <(comm -13 <( awk '{print $2}' $path | sort)  <(ps -aux | awk '{ if ($8 ~ /Z/) { print $2} }' | sort))


}

resolve () {

	#resolve alerts for zombies

	while read k; do

		curl -H "Content-type: application/json" -X POST \
	    -d '{    
			"service_key": "'$service_key'",
			"incident_key": "Zombie-'$k'",
			"event_type": "resolve",
			"description": "Nikolay fixed the Zombie-'$k'.",
			"details": {
			"fixed at": "'"$date"'"
			}
	    }' \
	    "https://events.pagerduty.com/generic/2010-04-15/create_event.json"

	done < <(comm -23 <( awk '{print $2}' $path | sort)  <(ps -aux | awk '{ if ($8 ~ /Z/) { print $2} }' | sort))

}

#run

if [ -z "$zombies" ]; then 
	#if there are no zombie processes resolve current in state

	resolve

else

	#if there are zombies first resolve after it create alerts

	resolve

	trigger

fi

zombies_state=`ps -aux | awk '{ if ($8 ~ /Z/) { print } }' > $path`