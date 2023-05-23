FROM apache/airflow:2.5.3-python3.9

ENV AIRFLOW_HOME=/opt/airflow

ENV AIRFLOW_VERSION=2.5.3

RUN pip install apache-airflow[google]==${AIRFLOW_VERSION} \
    && pip install pendulum

WORKDIR ${AIRFLOW_HOME}

RUN mkdir -p dags/ creds/
