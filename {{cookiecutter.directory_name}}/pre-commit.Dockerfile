FROM python:3.11-slim

RUN apt-get update && \
    apt-get install -y git && \
    pip install pipenv

COPY ${project_root}/Pipfile* ./

RUN pipenv sync --dev --system

WORKDIR /sourcecode
RUN apt-get clean
RUN git config --global --add safe.directory /sourcecode
CMD if [ "$PRE_COMMIT_ALL_FILES" = true ] ; then pre-commit run --all-files ; \
    else pre-commit run ; fi
