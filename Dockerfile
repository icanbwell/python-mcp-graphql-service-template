FROM python:3.8

RUN pip3 install pipenv

ENV PROJECT_DIR /usr/src/helix.providersearch

ENV FLASK_APP providersearch.api

# this is needed by prometheus
ENV PROMETHEUS_MULTIPROC_DIR /tmp/prometheus

RUN mkdir -p ${PROMETHEUS_MULTIPROC_DIR}

WORKDIR ${PROJECT_DIR}

COPY Pipfile .
COPY Pipfile.lock .
COPY ./providersearch ./providersearch
COPY ./wsgi.py ./
COPY ./gunicorn.conf.py ./

#RUN pipenv install --deploy --ignore-pipfile
RUN pipenv sync --dev --system

EXPOSE 5000

#CMD ["pipenv", "run", "flask", "run", "-h", "0.0.0.0"]
CMD ["pipenv", "run", "gunicorn", "--workers", "4", "--bind", "0.0.0.0:5000", "wsgi:app"]
