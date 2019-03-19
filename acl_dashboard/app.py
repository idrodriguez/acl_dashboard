import atexit
import json
import time

import numpy as np
import pandas as pd
import plotly
import plotly.graph_objs as go
import pusher
import requests
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.interval import IntervalTrigger
from envparse import env
from flask import Flask, render_template
from flask_bootstrap import Bootstrap

import pyodbc

# Flask and Bootstrapper initialization
app = Flask(__name__)
bootstrap = Bootstrap(app)

# Pusher client
pusher_client = pusher.Pusher(
    app_id=env('PUSHER_APP_ID'),
    key=env('PUSHER_KEY'),
    secret=env('PUSHER_SECRET'),
    cluster=env('PUSHER_CLUSTER'),
    ssl=True
)

# Routes definition
@app.route('/')
def index():
    aclJobs = getAclJobs()
    return render_template('dashboard.html', aclJobs = aclJobs)

def getAclJobs():
    # SQL Query execution
    connectionStr = 'Driver={SQL Server}; Server=' + env('DB_ADDRESS') + ';Database=' + env('DB_NAME')  + ';Integrated Security=True;Pooling=False;'
    connection = pyodbc.connect(connectionStr)
    query_acljobs = open('acljobs.sql', 'r')
    jobs_dataframe = pd.read_sql_query(query_acljobs.read(), connection)

    # Create chart data
    data = [
        go.Bar(
                x=jobs_dataframe['last_run_date'] + ' ' + jobs_dataframe['last_run_time'],
                y=jobs_dataframe.apply(changeDurationBasedOnRunStatus, axis=1)
            )
    ]

    graphJSON = json.dumps(data, cls=plotly.utils.PlotlyJSONEncoder)
    return graphJSON

def pushAclJobs():
    aclJobs = getAclJobs()

    # Trigger data
    pusher_client.trigger("acl_dashboard", "job", aclJobs)

def changeDurationBasedOnRunStatus(row):
    if row['run_status'] == 1:
        value = row['run_duration_minutes']
    elif row['run_status'] == 0:
        value = row['run_duration_minutes'] * -1
    return value

# Create schedule for retrieving acl jobs
scheduler = BackgroundScheduler()
scheduler.start()
scheduler.add_job(
    func=pushAclJobs,
    trigger=IntervalTrigger(minutes=30),
    id='acl_retrieval_job',
    name='Retrieve acl jobs every 30 minutes',
    replace_existing=True)
# Shut down the scheduler when exiting the app
atexit.register(lambda: scheduler.shutdown())

if __name__ == '__main__':
    app.run()
