FROM python:3.9

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

#CMD ["pipenv", "run", "flask", "run", "-h", "0.0.0.0"]
CMD ["pipenv", "run", "gunicorn", "--workers", "4", "--bind", "0.0.0.0:5000", "wsgi:app"]
