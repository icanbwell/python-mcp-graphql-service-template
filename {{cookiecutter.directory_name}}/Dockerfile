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

RUN apt-get update && \
    apt-get install -y git && \
    pip install pipenv

ENV PROJECT_DIR /usr/src/{{cookiecutter.directory_name}}

ENV FLASK_APP {{cookiecutter.project_slug}}.api

# this is needed by prometheus
ENV PROMETHEUS_MULTIPROC_DIR /tmp/prometheus

RUN mkdir -p ${PROMETHEUS_MULTIPROC_DIR}

RUN mkdir -p /usr/local/lib/python3.9/site-packages/ && \
    mkdir -p /usr/local/lib/python3.9/dist-packages && \
    mkdir -p /usr/local/bin/

# copy the python packags from the above docker so we only get the necessary stuff
COPY --from=python_packages /usr/local/lib/python3.9/site-packages/ /usr/local/lib/python3.9/site-packages/
# get the shell commands for these twp packages also
COPY --from=python_packages /usr/local/bin/pytest /usr/local/bin/pytest
COPY --from=python_packages /usr/local/bin/gunicorn /usr/local/bin/gunicorn

COPY Pipfile* ${PROJECT_DIR}/
WORKDIR ${PROJECT_DIR}

COPY ./{{cookiecutter.project_slug}} ./{{cookiecutter.project_slug}}
COPY wsgi.py ${PROJECT_DIR}/
COPY gunicorn.conf.py ${PROJECT_DIR}/

EXPOSE 5000

#CMD ["pipenv", "run", "flask", "run", "-h", "0.0.0.0"]
CMD ["pipenv", "run", "gunicorn", "--workers", "4", "--bind", "0.0.0.0:5000", "wsgi:app"]
