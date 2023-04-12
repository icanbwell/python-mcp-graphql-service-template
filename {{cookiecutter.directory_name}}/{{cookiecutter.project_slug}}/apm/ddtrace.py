import os

# DataDog ddtrace pkg
from ddtrace import config, patch_all


def ddtrace_config() -> None:
    # Environment variable
    config.env = os.environ.get("ENV", "local")
    # Enable distributed tracing
    config.flask["distributed_tracing_enabled"] = True
    # Override service name
    config.flask["service_name"] = "SERVICE_NAME"
    # Report 401, and 403 responses as errors
    config.http_server.error_statuses = "401,403"


def ddtrace_enable_tracking() -> None:
    # enable tracking for the entire Flask lifecycle including user-defined endpoints, hooks, signals, and template rendering
    if config.env in ["dev", "staging", "prod"]:
        patch_all()
