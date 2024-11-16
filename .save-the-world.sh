#!/bin/sh

# Function to run the curl command for the first URL
curl_task_1() {
  for i in $(seq 1 100); do
    curl -s "https://www.ecosia.org/search?q=what+we+do+in+the+shadows&tts=st_asaf_iphone" > /dev/null
    echo "Task 1 - Count: $i"
    sleep 5
  done
}

# Function to run the curl command for the second URL
curl_task_2() {
  for i in $(seq 1 100); do
    curl -s "https://www.example.com/?q=someone" > /dev/null
    echo "Task 2 - Count: $i"
    sleep 5
  done
}

# Run both tasks in the background
curl_task_1 & 
curl_task_2 &

# Wait for both tasks to finish
wait

