from __future__ import annotations

import logging
import time
import uuid
from typing import Callable

from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response

from core.request_context import reset_request_id, set_request_id

logger = logging.getLogger(__name__)

REQUEST_ID_HEADER = "X-Request-ID"


class RequestIdMiddleware(BaseHTTPMiddleware):
    async def dispatch(
        self,
        request: Request,
        call_next: Callable[[Request], Response],
    ) -> Response:
        incoming = (request.headers.get(REQUEST_ID_HEADER) or "").strip()
        request_id = incoming[:128] if incoming else str(uuid.uuid4())

        token = set_request_id(request_id)
        request.state.request_id = request_id
        started_at = time.perf_counter()
        try:
            response = await call_next(request)
        except Exception:
            duration_ms = int((time.perf_counter() - started_at) * 1000)
            logger.exception(
                "http_request_failed method=%s path=%s duration_ms=%s client_ip=%s",
                request.method,
                request.url.path,
                duration_ms,
                request.client.host if request.client else "unknown",
            )
            reset_request_id(token)
            raise

        duration_ms = int((time.perf_counter() - started_at) * 1000)
        logger.info(
            "http_request_completed method=%s path=%s status_code=%s duration_ms=%s client_ip=%s",
            request.method,
            request.url.path,
            response.status_code,
            duration_ms,
            request.client.host if request.client else "unknown",
        )
        response.headers[REQUEST_ID_HEADER] = request_id
        reset_request_id(token)
        return response
