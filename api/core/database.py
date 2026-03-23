import logging
import os
import time
from contextlib import contextmanager

import psycopg2
import psycopg2.pool
from dotenv import load_dotenv
from psycopg2.extras import RealDictCursor

load_dotenv()

logger = logging.getLogger(__name__)

_pool: psycopg2.pool.ThreadedConnectionPool | None = None

# Per-statement hard limit: avoids runaway queries holding connections indefinitely
_SLOW_QUERY_WARN_MS = 500
_CONNECT_OPTIONS = "-c client_encoding=UTF8 -c statement_timeout=5000"


def _get_pool() -> psycopg2.pool.ThreadedConnectionPool:
    global _pool
    if _pool is None:
        min_conn = int(os.getenv("DB_POOL_MIN", "2"))
        max_conn = int(os.getenv("DB_POOL_MAX", "20"))
        _pool = psycopg2.pool.ThreadedConnectionPool(
            min_conn,
            max_conn,
            os.getenv("DATABASE_URL"),
            cursor_factory=RealDictCursor,
            options=_CONNECT_OPTIONS,
        )
        logger.info("DB pool created (min=%d max=%d)", min_conn, max_conn)
    return _pool


def get_db():
    """FastAPI dependency — acquires a connection from the pool, releases on completion."""
    pool = _get_pool()
    conn = pool.getconn()
    start = time.monotonic()
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        elapsed_ms = (time.monotonic() - start) * 1000
        if elapsed_ms > _SLOW_QUERY_WARN_MS:
            logger.warning("Slow DB request: %.1f ms", elapsed_ms)
        pool.putconn(conn)


@contextmanager
def get_db_context():
    """Context manager for manual usage outside FastAPI dependency injection."""
    pool = _get_pool()
    conn = pool.getconn()
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        pool.putconn(conn)
