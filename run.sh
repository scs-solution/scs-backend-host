kill $(ps aux | grep scs-host:app | awk '{print $2; exit}')
export PATH=$PATH:/usr/local/bin
gunicorn --bind 0.0.0.0:3001 scs-host:app