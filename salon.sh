#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo "~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
	if [[ $1 ]]
	then
		echo "$1"
	fi

	# Display services
	SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
	echo "$SERVICES" | while IFS='|' read SERVICE_ID NAME
	do
		echo "$SERVICE_ID) $NAME"
	done

	# Read service selection
	read SERVICE_ID_SELECTED

	# Validate service selection
	SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
	if [[ -z $SERVICE_NAME ]]
	then
		# Invalid service, show menu again
		MAIN_MENU "I could not find that service. What would you like today?"
	else
		# Get customer phone number
		echo -e "\nWhat's your phone number?"
		read CUSTOMER_PHONE

		# Check if customer exists
		CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

		# If customer doesn't exist, get name
		if [[ -z $CUSTOMER_ID ]]
		then
			echo "I don't have a record for that phone number, what's your name?"
			read CUSTOMER_NAME

			# Insert new customer
			INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
			CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
		else
			# Get existing customer name
			CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
		fi

		# Get appointment time
		echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

		# Insert new appointment
		INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
		# Confirmation message
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
	fi
}

MAIN_MENU