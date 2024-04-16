# file_service
This repo contains all the contents that we need in our current file.cise.
Note: Please refer to https://confluence.amd.com/display/SCPI/Info+regarding+file+cache+server for more details.

**Steps to setup the file.cise**:
1. Make sure you have installed **docker**, **keyutils** and **cifs-utils** in the file.cise VM.
2. Make sure that you've cloned the share drive into your windows laptop.
3. After that, copy the .env file to become .env.local by running the command **cp .env .env.local**.
4. Next, proceed to change the content in the .env.local by adding in the **username & password** for the **faceless account** and the **root password** for the service.
5. Finally, run the command **make setup** and **make up** to up the container.

**Steps to restart the container**:
1. Run the command **make down up**.
