FROM public.ecr.aws/docker/library/python:3.12-alpine3.20 AS python_packages

# Set terminal width (COLUMNS) and height (LINES)
ENV COLUMNS=300

ARG GITHUB_TOKEN

# Install git, build-essential, and pipenv
RUN apk add --no-cache git build-base && \
    pip install pipenv

# Copy Pipfile and Pipfile.lock
COPY Pipfile* ./

# Install dependencies using pipenv
RUN pipenv sync --dev --system

# Set the working directory
WORKDIR /sourcecode

# Clean up unnecessary files
RUN git config --global --add safe.directory /sourcecode

CMD ["pre-commit", "run", "--all-files"]
