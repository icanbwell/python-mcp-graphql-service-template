# Build stage for pip packages
FROM python:3.9-bullseye as python_packages

RUN apt-get update && \
    apt-get install -y git && \
    pip install pipenv

# Essential updates for build to succeed on arm64:
RUN apt update && \
    apt install -y build-essential

RUN python --version && \
    python -m pip install --upgrade --no-cache-dir pip && \
    python -m pip install --no-cache-dir wheel && \
    python -m pip install --no-cache-dir pre-commit && \
    python -m pip install --no-cache-dir pipenv

ENV PYTHONPATH=/{{cookiecutter.directory_name}}
ENV PYTHONPATH "/opt/{{cookiecutter.directory_name}}:${PYTHONPATH}"

COPY Pipfile* /{{cookiecutter.directory_name}}/
WORKDIR /{{cookiecutter.directory_name}}

#RUN pipenv sync --system --verbose # This should not be needed because the line below covers system also
RUN pipenv sync --dev --system --verbose

RUN pip list -v


FROM python:3.9-slim-bullseye

# Update everything on the OS
RUN apt-get -y update && apt-get -y install curl && apt-get clean && rm -rf /var/cache/apt/*

RUN pip3 install pipenv

ENV PROJECT_DIR /usr/src/{{cookiecutter.directory_name}}

ENV FLASK_APP {{cookiecutter.project_slug}}.api

# this is needed by prometheus
ENV PROMETHEUS_MULTIPROC_DIR /tmp/prometheus

RUN mkdir -p ${PROMETHEUS_MULTIPROC_DIR}

WORKDIR ${PROJECT_DIR}

COPY Pipfile .
COPY Pipfile.lock .

#RUN pipenv install --deploy --ignore-pipfile
RUN pipenv sync --dev --system

COPY ./{{cookiecutter.project_slug}} ./{{cookiecutter.project_slug}}
COPY wsgi.py ./
COPY gunicorn.conf.py ./

EXPOSE 5000

# CMD ["pipenv", "run", "flask", "run", "-h", "0.0.0.0"]
CMD ["pipenv", "run", "ddtrace-run", "gunicorn", "--workers", "4", "--bind", "0.0.0.0:5000", "wsgi:app"]
