-- Migration 006: backfill test cases for all 12 hand-crafted challenges
-- oop_001 and oop_002 already seeded in 005; this fills the remaining 10.

-- oop_003: University Enrollment (Java)
UPDATE challenges SET test_cases = '[
  {"input": "enroll Alice CS101", "expected_output": "Alice enrolled in CS101", "description": "Student enrolls in a course"},
  {"input": "enroll Alice CS101", "expected_output": "Alice is already enrolled in CS101", "description": "Duplicate enrollment rejected"},
  {"input": "enroll Bob CS101 capacity=1", "expected_output": "CS101 is full", "description": "Cannot enroll when course at capacity"},
  {"input": "drop Alice CS101", "expected_output": "Alice dropped CS101", "description": "Student drops an enrolled course"},
  {"input": "transcript Alice", "expected_output": "Alice: []", "description": "Transcript shows empty after drop"}
]'::jsonb
WHERE id = 'oop_003';

-- oop_004: Bank Account Hierarchy (TypeScript)
UPDATE challenges SET test_cases = '[
  {"input": "savings deposit 500", "expected_output": "Balance: 500.00", "description": "Deposit into savings account"},
  {"input": "savings withdraw 100", "expected_output": "Balance: 400.00", "description": "Withdraw from savings account"},
  {"input": "checking withdraw 200 balance=100 overdraft=150", "expected_output": "Balance: -100.00", "description": "Checking account uses overdraft protection"},
  {"input": "checking withdraw 300 balance=100 overdraft=150", "expected_output": "Overdraft limit exceeded", "description": "Withdrawal beyond overdraft limit rejected"},
  {"input": "savings applyInterest rate=0.05 balance=1000", "expected_output": "Balance: 1050.00", "description": "Savings account earns interest"}
]'::jsonb
WHERE id = 'oop_004';

-- dp_001: Notification Service (TypeScript)
UPDATE challenges SET test_cases = '[
  {"input": "send email user=alice subject=Hello", "expected_output": "Email sent to alice: Hello", "description": "Send notification via email channel"},
  {"input": "send sms user=bob message=Test", "expected_output": "SMS sent to bob: Test", "description": "Send notification via SMS channel"},
  {"input": "subscribe alice push", "expected_output": "alice subscribed to push", "description": "User subscribes to push channel"},
  {"input": "send push user=alice message=Update", "expected_output": "Push sent to alice: Update", "description": "Send push notification to subscribed user"},
  {"input": "send sms user=charlie message=Hi unsubscribed=true", "expected_output": "charlie not subscribed to sms", "description": "Unsubscribed user does not receive notification"}
]'::jsonb
WHERE id = 'dp_001';

-- dp_002: Plugin System (TypeScript)
UPDATE challenges SET test_cases = '[
  {"input": "register LogPlugin", "expected_output": "LogPlugin registered", "description": "Register a plugin by name"},
  {"input": "register LogPlugin duplicate=true", "expected_output": "Warning: LogPlugin already registered", "description": "Duplicate registration triggers warning"},
  {"input": "execute LogPlugin context={}", "expected_output": "LogPlugin executed", "description": "Execute a registered plugin"},
  {"input": "execute UnknownPlugin", "expected_output": "Plugin not found: UnknownPlugin", "description": "Executing unregistered plugin returns error"},
  {"input": "register MetricsPlugin execute MetricsPlugin context={req:1}", "expected_output": "MetricsPlugin executed", "description": "Register and execute second plugin"}
]'::jsonb
WHERE id = 'dp_002';

-- dp_003: Document Builder (Java)
UPDATE challenges SET test_cases = '[
  {"input": "build title=Report body=Content", "expected_output": "Document{title=Report, body=Content}", "description": "Build document with title and body"},
  {"input": "build body=missing_title", "expected_output": "Document{body=missing_title}", "description": "Document without title is valid"},
  {"input": "build no_body=true", "expected_output": "IllegalStateException: body is required", "description": "Build without body throws exception"},
  {"input": "build title=Doc body=Text header=H footer=F", "expected_output": "Document{title=Doc, body=Text, header=H, footer=F}", "description": "Full document with all optional fields"},
  {"input": "director template=report", "expected_output": "Document{title=Report Template, body=...}", "description": "Director creates pre-built template"}
]'::jsonb
WHERE id = 'dp_003';

-- dp_004: Event Bus (Python)
UPDATE challenges SET test_cases = '[
  {"input": "subscribe user_created handler_a", "expected_output": "handler_a subscribed to user_created", "description": "Subscribe handler to event"},
  {"input": "emit user_created payload={id:1}", "expected_output": "handler_a called with {id:1}", "description": "Emit event calls subscriber"},
  {"input": "emit no_subscribers_event payload={}", "expected_output": "", "description": "Emit with no subscribers is a no-op"},
  {"input": "subscribe order_placed handler_b subscribe order_placed handler_c emit order_placed payload={}", "expected_output": "handler_b called\nhandler_c called", "description": "Multiple handlers called in subscription order"},
  {"input": "subscribe click handler_d unsubscribe click handler_d emit click payload={}", "expected_output": "", "description": "Unsubscribed handler is not called"}
]'::jsonb
WHERE id = 'dp_004';

-- sys_001: Rate Limiter (Java)
UPDATE challenges SET test_cases = '[
  {"input": "request user=alice rate=5 window=1s count=1", "expected_output": "allowed", "description": "First request within rate limit is allowed"},
  {"input": "request user=alice rate=2 window=1s count=3", "expected_output": "rate limited", "description": "Third request exceeds rate=2 limit"},
  {"input": "request user=alice rate=5 window=1s count=5", "expected_output": "allowed", "description": "Fifth request exactly at limit is allowed"},
  {"input": "request user=bob rate=5 window=1s count=1 after_alice_limited=true", "expected_output": "allowed", "description": "Different user has independent bucket"},
  {"input": "request user=alice rate=2 window=1s count=1 after_window_reset=true", "expected_output": "allowed", "description": "Request allowed after time window resets"}
]'::jsonb
WHERE id = 'sys_001';

-- sys_002: In-Memory Cache / LRU (Python)
UPDATE challenges SET test_cases = '[
  {"input": "set key=a value=1 ttl=60 get key=a", "expected_output": "1", "description": "Set and get a cache entry"},
  {"input": "get key=missing", "expected_output": "None", "description": "Get missing key returns None"},
  {"input": "set key=a value=1 ttl=0.001 sleep get key=a", "expected_output": "None", "description": "Expired entry returns None"},
  {"input": "set capacity=2 keys=[a,b,c] get key=a", "expected_output": "None", "description": "LRU eviction: oldest key evicted when capacity exceeded"},
  {"input": "set capacity=2 keys=[a,b] get key=a set key=c get key=b", "expected_output": "None", "description": "Recently accessed key stays; unused key evicted"}
]'::jsonb
WHERE id = 'sys_002';

-- sys_003: Job Queue (TypeScript)
UPDATE challenges SET test_cases = '[
  {"input": "enqueue job=j1 priority=high", "expected_output": "j1 queued", "description": "Enqueue a high-priority job"},
  {"input": "enqueue job=j1 priority=low enqueue job=j2 priority=high process", "expected_output": "j2 processed first", "description": "High-priority job processes before low-priority"},
  {"input": "enqueue job=j1 execute=fail maxAttempts=3", "expected_output": "j1 retried 3 times then failed", "description": "Failed job retries up to maxAttempts"},
  {"input": "enqueue job=j1 execute=ok status", "expected_output": "j1: done", "description": "Successful job status transitions to done"},
  {"input": "enqueue job=j1 execute=fail maxAttempts=1 status", "expected_output": "j1: failed", "description": "Job exhausting retries transitions to failed"}
]'::jsonb
WHERE id = 'sys_003';

-- sys_004: URL Shortener (Java)
UPDATE challenges SET test_cases = '[
  {"input": "shorten https://example.com/very/long/path", "expected_output": "code.length >= 6", "description": "Short code is at least 6 characters"},
  {"input": "shorten https://example.com resolve result", "expected_output": "https://example.com", "description": "Resolve returns original URL"},
  {"input": "resolve unknown_code", "expected_output": "Not found", "description": "Resolving unknown code returns not found"},
  {"input": "shorten https://example.com shorten https://example.com", "expected_output": "same_code", "description": "Same URL returns same short code"},
  {"input": "shorten https://a.com resolve hit_count=2", "expected_output": "hits: 2", "description": "Hit count increments on each resolve"}
]'::jsonb
WHERE id = 'sys_004';
