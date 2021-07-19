FROM python:3.8-slim

COPY ${project_root}/Pipfile* ./
RUN apt-get update && \
    apt-get install -y git && \
    pip install pipenv autoflake flake8 black mypy && \
    pip install pre-commit && \
    pipenv sync --dev --system
WORKDIR /sourcecode
CMD pre-commit run --all-files
