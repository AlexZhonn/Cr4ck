-- Migration 003: challenges table + seed data
-- Single source of truth for all challenges (replaces frontend-only data/challenges.ts).

CREATE TYPE challenge_difficulty AS ENUM ('Easy', 'Medium', 'Hard');
CREATE TYPE challenge_topic      AS ENUM ('OOP', 'Design Patterns', 'System Design');

CREATE TABLE IF NOT EXISTS challenges (
    id           VARCHAR(50)          PRIMARY KEY,
    title        VARCHAR(200)         NOT NULL,
    topic        challenge_topic      NOT NULL,
    difficulty   challenge_difficulty NOT NULL,
    language     VARCHAR(50)          NOT NULL,
    framework    VARCHAR(100)         NOT NULL,
    description  TEXT                 NOT NULL,
    starter_code TEXT                 NOT NULL,
    is_active    BOOLEAN              NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ          NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_challenges_topic      ON challenges (topic);
CREATE INDEX IF NOT EXISTS idx_challenges_difficulty ON challenges (difficulty);

-- ── Seed: OOP ────────────────────────────────────────────────────────────────

INSERT INTO challenges (id, title, topic, difficulty, language, framework, description, starter_code) VALUES
(
  'oop_001', 'Library System', 'OOP', 'Easy', 'java', 'Java / OOP',
  E'Design a simple library system where users can borrow and return books.\n\n**Requirements:**\n- Users can borrow books\n- Users can return books\n- Library tracks inventory\n- A book cannot be borrowed if already checked out\n\n**Constraints:**\n- Support multiple users\n- Book availability must be tracked',
  E'public class Library {\n    // TODO: implement\n}\n\npublic class Book {\n    // TODO: implement\n}\n\npublic class User {\n    // TODO: implement\n}'
),
(
  'oop_002', 'E-Commerce Cart', 'OOP', 'Medium', 'python', 'Python / OOP',
  E'Build a shopping cart system with discount strategies.\n\n**Requirements:**\n- Add/remove items from cart\n- Apply discount codes (percentage, fixed amount)\n- Calculate total with taxes\n- Support the Strategy pattern for pricing\n\n**Constraints:**\n- Discounts should be composable\n- Cart state must be consistent',
  E'class Cart:\n    # TODO: implement\n    pass\n\nclass DiscountStrategy:\n    # TODO: implement abstract base\n    pass\n\nclass PercentageDiscount(DiscountStrategy):\n    # TODO: implement\n    pass'
),
(
  'oop_003', 'University Enrollment', 'OOP', 'Medium', 'java', 'Java / OOP',
  E'Model a university enrollment system for students and courses.\n\n**Requirements:**\n- Students enroll in and drop courses\n- Courses have a maximum capacity\n- A student cannot enroll in the same course twice\n- Print a student''s transcript with enrolled courses\n\n**Constraints:**\n- Use proper encapsulation (no public fields)\n- Handle edge cases: full course, duplicate enrollment',
  E'public class Student {\n    // TODO: implement\n}\n\npublic class Course {\n    // TODO: implement\n}\n\npublic class Enrollment {\n    // TODO: implement\n}'
),
(
  'oop_004', 'Bank Account Hierarchy', 'OOP', 'Hard', 'typescript', 'TypeScript / OOP',
  E'Design a bank account hierarchy supporting multiple account types.\n\n**Requirements:**\n- Base Account with deposit, withdraw, getBalance\n- SavingsAccount: earns interest, limited withdrawals per month\n- CheckingAccount: overdraft protection up to a limit\n- InvestmentAccount: buy/sell assets, track portfolio value\n\n**Constraints:**\n- Use abstract classes and polymorphism\n- All monetary values must be precise (no floating point errors)\n- Each subclass must enforce its own business rules',
  E'abstract class Account {\n  // TODO: implement base class\n}\n\nclass SavingsAccount extends Account {\n  // TODO: implement\n}\n\nclass CheckingAccount extends Account {\n  // TODO: implement\n}\n\nclass InvestmentAccount extends Account {\n  // TODO: implement\n}'
)
ON CONFLICT (id) DO NOTHING;

-- ── Seed: Design Patterns ────────────────────────────────────────────────────

INSERT INTO challenges (id, title, topic, difficulty, language, framework, description, starter_code) VALUES
(
  'dp_001', 'Notification Service', 'Design Patterns', 'Medium', 'typescript', 'TypeScript / Design Patterns',
  E'Design a notification service that supports multiple delivery channels (Email, SMS, Push).\n\n**Requirements:**\n- Send notifications through Email, SMS, and Push channels\n- Users can subscribe to specific channels\n- Support for notification templates\n- Channels can be added without modifying core logic (Open/Closed Principle)',
  E'interface NotificationChannel {\n  // TODO: define interface\n}\n\nclass NotificationService {\n  // TODO: implement\n}\n\nclass EmailChannel implements NotificationChannel {\n  // TODO: implement\n}'
),
(
  'dp_002', 'Plugin System', 'Design Patterns', 'Medium', 'typescript', 'TypeScript / Design Patterns',
  E'Build a plugin system using the Strategy and Registry patterns.\n\n**Requirements:**\n- A PluginRegistry that registers and retrieves plugins by name\n- Plugins share a common interface with an execute() method\n- The core system should not need modification when new plugins are added\n- Include at least two example plugins (e.g., LogPlugin, MetricsPlugin)\n\n**Constraints:**\n- Plugins must be swappable at runtime\n- Registry should warn if a duplicate plugin name is registered',
  E'interface Plugin {\n  name: string;\n  execute(context: Record<string, unknown>): void;\n}\n\nclass PluginRegistry {\n  // TODO: implement\n}\n\nclass LogPlugin implements Plugin {\n  // TODO: implement\n}'
),
(
  'dp_003', 'Document Builder', 'Design Patterns', 'Easy', 'java', 'Java / Design Patterns',
  E'Implement a document builder using the Builder pattern.\n\n**Requirements:**\n- Build documents with optional title, body, header, footer, and metadata\n- The builder should enforce that body is always set before building\n- Support method chaining (fluent API)\n- A Director class should offer pre-built document templates\n\n**Constraints:**\n- Document objects should be immutable once built\n- Builder must throw if required fields are missing',
  E'public class Document {\n    // TODO: immutable document\n}\n\npublic class DocumentBuilder {\n    // TODO: fluent builder\n}\n\npublic class DocumentDirector {\n    // TODO: pre-built templates\n}'
),
(
  'dp_004', 'Event Bus', 'Design Patterns', 'Hard', 'python', 'Python / Design Patterns',
  E'Implement a typed event bus using the Observer pattern.\n\n**Requirements:**\n- Publishers emit named events with a payload\n- Subscribers register handlers for specific event types\n- Multiple handlers can listen to the same event\n- Unsubscribe support: handlers can be removed by reference\n\n**Constraints:**\n- Handlers must be called in subscription order\n- Emitting an event with no subscribers should be a no-op (no error)\n- Thread-safe emission',
  E'from typing import Callable, Any\n\nclass EventBus:\n    # TODO: implement\n    pass\n\nclass Publisher:\n    # TODO: implement\n    pass\n\nclass Subscriber:\n    # TODO: implement\n    pass'
)
ON CONFLICT (id) DO NOTHING;

-- ── Seed: System Design ──────────────────────────────────────────────────────

INSERT INTO challenges (id, title, topic, difficulty, language, framework, description, starter_code) VALUES
(
  'sys_001', 'Rate Limiter', 'System Design', 'Hard', 'java', 'Java / System Design',
  E'Implement a token bucket rate limiter that can throttle API requests per user.\n\n**Requirements:**\n- Limit requests per user per time window\n- Token bucket algorithm\n- Thread-safe implementation\n- Configurable rate and burst capacity\n\n**Constraints:**\n- Must handle concurrent requests\n- O(1) time complexity per request check',
  E'import java.util.concurrent.*;\n\npublic class RateLimiter {\n    // TODO: implement token bucket\n}\n\npublic class TokenBucket {\n    // TODO: implement\n}'
),
(
  'sys_002', 'In-Memory Cache', 'System Design', 'Medium', 'python', 'Python / System Design',
  E'Build an in-memory LRU cache with TTL support.\n\n**Requirements:**\n- get(key) and set(key, value, ttl_seconds) operations\n- Evict least-recently-used item when capacity is exceeded\n- Expired entries are not returned and are lazily evicted\n- Cache hit/miss statistics\n\n**Constraints:**\n- O(1) get and set\n- Max capacity is configurable at construction',
  E'from collections import OrderedDict\nimport time\n\nclass LRUCache:\n    # TODO: implement\n    pass\n\nclass CacheEntry:\n    # TODO: implement\n    pass'
),
(
  'sys_003', 'Job Queue', 'System Design', 'Medium', 'typescript', 'TypeScript / System Design',
  E'Design a simple job queue with worker pool.\n\n**Requirements:**\n- Enqueue jobs with a priority level (high, normal, low)\n- A worker pool processes jobs concurrently up to a max concurrency limit\n- Failed jobs retry up to a configurable max attempts\n- Track job status: queued, running, done, failed\n\n**Constraints:**\n- High-priority jobs always process before normal/low\n- Workers should not starve low-priority jobs indefinitely',
  E'type JobStatus = ''queued'' | ''running'' | ''done'' | ''failed'';\ntype Priority = ''high'' | ''normal'' | ''low'';\n\ninterface Job {\n  id: string;\n  priority: Priority;\n  status: JobStatus;\n  execute: () => Promise<void>;\n}\n\nclass JobQueue {\n  // TODO: implement\n}\n\nclass WorkerPool {\n  // TODO: implement\n}'
),
(
  'sys_004', 'URL Shortener', 'System Design', 'Easy', 'java', 'Java / System Design',
  E'Design a URL shortener service.\n\n**Requirements:**\n- shorten(url): returns a short code (6–8 chars)\n- resolve(code): returns the original URL\n- Track hit count per short URL\n- Codes must be unique and URL-safe\n\n**Constraints:**\n- In-memory storage is fine\n- Short codes should be generated deterministically or randomly (your choice — justify it)',
  E'public class UrlShortener {\n    // TODO: implement shorten and resolve\n}\n\npublic class ShortUrl {\n    // TODO: implement model\n}'
)
ON CONFLICT (id) DO NOTHING;
