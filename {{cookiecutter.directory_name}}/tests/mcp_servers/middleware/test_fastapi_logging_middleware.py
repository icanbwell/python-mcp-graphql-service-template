from typing import AsyncIterator, List, cast

from starlette.requests import Request
from starlette.responses import Response, StreamingResponse

from {{cookiecutter.project_slug}}.mcp_servers.middleware.fastapi_logging_middleware import (
    FastApiLoggingMiddleware,
)


def _make_get_request(path: str = "/stream") -> Request:
    scope = {
        "type": "http",
        "method": "GET",
        "path": path,
        "headers": [],
        "query_string": b"",
        "client": ("test", 123),
    }
    return Request(scope)


async def test_streaming_response_is_not_fully_buffered_before_dispatch_returns() -> (
    None
):
    """
    Regression test for a bug where FastApiLoggingMiddleware.dispatch() eagerly
    drained the entire body_iterator of a StreamingResponse (e.g. SSE / LLM token
    streams) into memory before returning. That fully defeats streaming: the client
    would receive nothing until the whole response had been produced and buffered,
    then get it all at once.

    The fix only peeks at the first chunk (needed for the log line) and lazily
    rechains the remainder, so dispatch() must not pull more than one item from the
    generator before it returns, and the rest of the stream must still be available
    to the client afterward via the rechained iterator.
    """
    pulled_items: List[str] = []

    async def event_stream() -> AsyncIterator[str]:
        for i in range(5):
            item = f"event-{i}\n"
            pulled_items.append(item)
            yield item

    streaming_response = StreamingResponse(
        event_stream(), media_type="text/event-stream"
    )

    async def call_next(_request: Request) -> Response:
        return streaming_response

    middleware = FastApiLoggingMiddleware(app=None)  # type: ignore[arg-type]

    result = await middleware.dispatch(_make_get_request(), call_next)

    # dispatch() must only have pulled the first chunk (needed for the log line)
    # rather than eagerly draining the whole generator into memory.
    assert pulled_items == [
        "event-0\n"
    ], f"dispatch() pulled more than the first chunk: {pulled_items!r}"

    # The rest of the stream must still be reachable via the rechained iterator.
    result_stream = cast(StreamingResponse, result)
    remaining = [section async for section in result_stream.body_iterator]
    assert remaining == [f"event-{i}\n" for i in range(5)]
    assert pulled_items == [f"event-{i}\n" for i in range(5)]


async def test_streaming_response_with_empty_body_iterator_logs_no_body() -> None:
    """
    An empty stream should not raise and dispatch() should leave the rechained
    iterator empty for the client.
    """

    async def empty_stream() -> AsyncIterator[str]:
        return
        yield  # pragma: no cover - makes this an async generator

    streaming_response = StreamingResponse(
        empty_stream(), media_type="text/event-stream"
    )

    async def call_next(_request: Request) -> Response:
        return streaming_response

    middleware = FastApiLoggingMiddleware(app=None)  # type: ignore[arg-type]

    result = await middleware.dispatch(_make_get_request(), call_next)

    result_stream = cast(StreamingResponse, result)
    remaining = [section async for section in result_stream.body_iterator]
    assert remaining == []
