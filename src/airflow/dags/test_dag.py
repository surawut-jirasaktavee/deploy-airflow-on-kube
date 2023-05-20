from airflow import DAG
from airflow.operators.email import EmailOperator
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.utils import timezone

from datetime import timedelta


default_args = {
    "owner": "prem",
    "email": ["premsurawut2021@gmail.com"],
    "start_date": timezone.datetime(2022, 1, 1, 0, 0, 0),
    "retries": 3,
    "retry_delay": timedelta(minutes=3),
}
with DAG(
    "test_dag",
    default_args=default_args,
    schedule_interval="@daily",
) as dag:
    
    def hello():
        print("Hello World")
    
    start = DummyOperator(task_id="start")
    hello = PythonOperator(task_id="Hello", python_callable=hello)
    end = DummyOperator(task_id="end")
    
    start >> hello >> end