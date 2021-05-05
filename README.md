# Overview
This repository contains a React frontend, and an Express backend that the frontend connects to.

# Objective
Deploy the frontend and backend in 2 environments - Dev and Prod. Both environments must be accessible over the public internet.

The Prod environment must have some kind of mechanism to scale the backend.

Fork this repo as a base. You may change any code in this repository to suit the infrastructure you build in this code challenge.

If you have any questions or concerns about this challenge, you may contact daniel@lightfeather.io

# Submission
1. A github repo that has been forked from this repo with all your code.
2. Modify this README file with instructions for:
a. Any tools needed to deploy your infrastructure
b. All the steps to deploy a replica of your Dev and Prod infrastructure
c. Steps to scale the production backend up or down, if scaling requires manual intervention. If its auto-scaled, describe the auto-scaling mechanism.
d. URLs to the deployed Dev and Prod frontends
4. Submit your github and contact information via https://forms.gle/DNaQn2S9VGueSACdA

# Evaluation
You will be evaluated on the ease to replicate your infrastructure. This is a combination of quality of the instructions, as well as any scripts to automate the overall setup process.

# Setup your environment
Install nodejs. Binaries and installers can be found on nodejs.org.
https://nodejs.org/en/download/

For macOS or Linux, Nodejs can usually be found in your preferred package manager.
https://nodejs.org/en/download/package-manager/

Depending on the Linux distribution, the Node Package Manager `npm` may need to be installed separately.

# Running the project
The backend and the frontend will need to run on separate processes. The backend should be started first.
```
cd backend
npm ci
npm start
```
The backend should response to a GET request on `localhost:8080`.

With the backend started, the frontend can be started.
```
cd frontend
npm ci
npm start
```
The frontend can be accessed at `localhost:3000`. If the frontend successfully connects to the backend, a message saying "SUCCESS" followed by a guid should be displayed on the screen.  If the connection failed, an error message will be displayed on the screen.

# Configuration
The frontend has a configuration file at `frontend/src/config.js` that defines the URL to call the backend. This URL is used on `frontend/src/App.js#12`, where the front end will make the GET call during the initial load of the page.

The backend has a configuration file at `backend/config.js` that defines the host that the frontend will be calling from. This URL is used in the `Access-Control-Allow-Origin` CORS header, read in `backend/index.js#14`
