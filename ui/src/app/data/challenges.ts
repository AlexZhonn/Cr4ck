export type Topic = 'OOP' | 'Design Patterns' | 'System Design';

export interface TestCase {
  input: string;
  expected_output: string;
  description: string;
}

export interface Challenge {
  id: string;
  title: string;
  framework: string;
  language: string;
  difficulty: 'Easy' | 'Medium' | 'Hard';
  topic: Topic;
  description: string;
  starterCode: string;
  starterCodes?: Record<string, string>;
  testCases?: TestCase[];
}

export const TOPICS: { id: Topic; label: string; description: string; icon: string }[] = [
  {
    id: 'OOP',
    label: 'Object-Oriented Programming',
    description: 'Classes, inheritance, encapsulation, polymorphism, and abstraction.',
    icon: 'oop',
  },
  {
    id: 'Design Patterns',
    label: 'Design Patterns',
    description: 'GoF patterns: creational, structural, and behavioral solutions.',
    icon: 'patterns',
  },
  {
    id: 'System Design',
    label: 'System Design',
    description: 'Scalable architectures, distributed systems, and real-world components.',
    icon: 'system',
  },
];

export const CHALLENGES: Challenge[] = [
  // ── OOP ──────────────────────────────────────────────────────────────────
  {
    id: 'oop_001',
    title: 'Library System',
    framework: 'Java / OOP',
    language: 'java',
    difficulty: 'Easy',
    topic: 'OOP',
    description: `Design a simple library system where users can borrow and return books.

**Requirements:**
- Users can borrow books
- Users can return books
- Library tracks inventory
- A book cannot be borrowed if already checked out

**Constraints:**
- Support multiple users
- Book availability must be tracked`,
    starterCode: `public class Library {
    // TODO: implement
}

public class Book {
    // TODO: implement
}

public class User {
    // TODO: implement
}`,
  },
  {
    id: 'oop_002',
    title: 'E-Commerce Cart',
    framework: 'Python / OOP',
    language: 'python',
    difficulty: 'Medium',
    topic: 'OOP',
    description: `Build a shopping cart system with discount strategies.

**Requirements:**
- Add/remove items from cart
- Apply discount codes (percentage, fixed amount)
- Calculate total with taxes
- Support the Strategy pattern for pricing

**Constraints:**
- Discounts should be composable
- Cart state must be consistent`,
    starterCode: `class Cart:
    # TODO: implement
    pass

class DiscountStrategy:
    # TODO: implement abstract base
    pass

class PercentageDiscount(DiscountStrategy):
    # TODO: implement
    pass`,
  },
  {
    id: 'oop_003',
    title: 'University Enrollment',
    framework: 'Java / OOP',
    language: 'java',
    difficulty: 'Medium',
    topic: 'OOP',
    description: `Model a university enrollment system for students and courses.

**Requirements:**
- Students enroll in and drop courses
- Courses have a maximum capacity
- A student cannot enroll in the same course twice
- Print a student's transcript with enrolled courses

**Constraints:**
- Use proper encapsulation (no public fields)
- Handle edge cases: full course, duplicate enrollment`,
    starterCode: `public class Student {
    // TODO: implement
}

public class Course {
    // TODO: implement
}

public class Enrollment {
    // TODO: implement
}`,
  },
  {
    id: 'oop_004',
    title: 'Bank Account Hierarchy',
    framework: 'TypeScript / OOP',
    language: 'typescript',
    difficulty: 'Hard',
    topic: 'OOP',
    description: `Design a bank account hierarchy supporting multiple account types.

**Requirements:**
- Base Account with deposit, withdraw, getBalance
- SavingsAccount: earns interest, limited withdrawals per month
- CheckingAccount: overdraft protection up to a limit
- InvestmentAccount: buy/sell assets, track portfolio value

**Constraints:**
- Use abstract classes and polymorphism
- All monetary values must be precise (no floating point errors)
- Each subclass must enforce its own business rules`,
    starterCode: `abstract class Account {
  // TODO: implement base class
}

class SavingsAccount extends Account {
  // TODO: implement
}

class CheckingAccount extends Account {
  // TODO: implement
}

class InvestmentAccount extends Account {
  // TODO: implement
}`,
  },

  // ── Design Patterns ───────────────────────────────────────────────────────
  {
    id: 'dp_001',
    title: 'Notification Service',
    framework: 'TypeScript / Design Patterns',
    language: 'typescript',
    difficulty: 'Medium',
    topic: 'Design Patterns',
    description: `Design a notification service that supports multiple delivery channels (Email, SMS, Push).

**Requirements:**
- Send notifications through Email, SMS, and Push channels
- Users can subscribe to specific channels
- Support for notification templates
- Channels can be added without modifying core logic (Open/Closed Principle)`,
    starterCode: `interface NotificationChannel {
  // TODO: define interface
}

class NotificationService {
  // TODO: implement
}

class EmailChannel implements NotificationChannel {
  // TODO: implement
}`,
  },
  {
    id: 'dp_002',
    title: 'Plugin System',
    framework: 'TypeScript / Design Patterns',
    language: 'typescript',
    difficulty: 'Medium',
    topic: 'Design Patterns',
    description: `Build a plugin system using the Strategy and Registry patterns.

**Requirements:**
- A PluginRegistry that registers and retrieves plugins by name
- Plugins share a common interface with an execute() method
- The core system should not need modification when new plugins are added
- Include at least two example plugins (e.g., LogPlugin, MetricsPlugin)

**Constraints:**
- Plugins must be swappable at runtime
- Registry should warn if a duplicate plugin name is registered`,
    starterCode: `interface Plugin {
  name: string;
  execute(context: Record<string, unknown>): void;
}

class PluginRegistry {
  // TODO: implement
}

class LogPlugin implements Plugin {
  // TODO: implement
}`,
  },
  {
    id: 'dp_003',
    title: 'Document Builder',
    framework: 'Java / Design Patterns',
    language: 'java',
    difficulty: 'Easy',
    topic: 'Design Patterns',
    description: `Implement a document builder using the Builder pattern.

**Requirements:**
- Build documents with optional title, body, header, footer, and metadata
- The builder should enforce that body is always set before building
- Support method chaining (fluent API)
- A Director class should offer pre-built document templates

**Constraints:**
- Document objects should be immutable once built
- Builder must throw if required fields are missing`,
    starterCode: `public class Document {
    // TODO: immutable document
}

public class DocumentBuilder {
    // TODO: fluent builder
}

public class DocumentDirector {
    // TODO: pre-built templates
}`,
  },
  {
    id: 'dp_004',
    title: 'Event Bus',
    framework: 'Python / Design Patterns',
    language: 'python',
    difficulty: 'Hard',
    topic: 'Design Patterns',
    description: `Implement a typed event bus using the Observer pattern.

**Requirements:**
- Publishers emit named events with a payload
- Subscribers register handlers for specific event types
- Multiple handlers can listen to the same event
- Unsubscribe support: handlers can be removed by reference

**Constraints:**
- Handlers must be called in subscription order
- Emitting an event with no subscribers should be a no-op (no error)
- Thread-safe emission`,
    starterCode: `from typing import Callable, Any

class EventBus:
    # TODO: implement
    pass

class Publisher:
    # TODO: implement
    pass

class Subscriber:
    # TODO: implement
    pass`,
  },

  // ── System Design ─────────────────────────────────────────────────────────
  {
    id: 'sys_001',
    title: 'Rate Limiter',
    framework: 'Java / System Design',
    language: 'java',
    difficulty: 'Hard',
    topic: 'System Design',
    description: `Implement a token bucket rate limiter that can throttle API requests per user.

**Requirements:**
- Limit requests per user per time window
- Token bucket algorithm
- Thread-safe implementation
- Configurable rate and burst capacity

**Constraints:**
- Must handle concurrent requests
- O(1) time complexity per request check`,
    starterCode: `import java.util.concurrent.*;

public class RateLimiter {
    // TODO: implement token bucket
}

public class TokenBucket {
    // TODO: implement
}`,
  },
  {
    id: 'sys_002',
    title: 'In-Memory Cache',
    framework: 'Python / System Design',
    language: 'python',
    difficulty: 'Medium',
    topic: 'System Design',
    description: `Build an in-memory LRU cache with TTL support.

**Requirements:**
- get(key) and set(key, value, ttl_seconds) operations
- Evict least-recently-used item when capacity is exceeded
- Expired entries are not returned and are lazily evicted
- Cache hit/miss statistics

**Constraints:**
- O(1) get and set
- Max capacity is configurable at construction`,
    starterCode: `from collections import OrderedDict
import time

class LRUCache:
    # TODO: implement
    pass

class CacheEntry:
    # TODO: implement
    pass`,
  },
  {
    id: 'sys_003',
    title: 'Job Queue',
    framework: 'TypeScript / System Design',
    language: 'typescript',
    difficulty: 'Medium',
    topic: 'System Design',
    description: `Design a simple job queue with worker pool.

**Requirements:**
- Enqueue jobs with a priority level (high, normal, low)
- A worker pool processes jobs concurrently up to a max concurrency limit
- Failed jobs retry up to a configurable max attempts
- Track job status: queued, running, done, failed

**Constraints:**
- High-priority jobs always process before normal/low
- Workers should not starve low-priority jobs indefinitely`,
    starterCode: `type JobStatus = 'queued' | 'running' | 'done' | 'failed';
type Priority = 'high' | 'normal' | 'low';

interface Job {
  id: string;
  priority: Priority;
  status: JobStatus;
  execute: () => Promise<void>;
}

class JobQueue {
  // TODO: implement
}

class WorkerPool {
  // TODO: implement
}`,
  },
  {
    id: 'sys_004',
    title: 'URL Shortener',
    framework: 'Java / System Design',
    language: 'java',
    difficulty: 'Easy',
    topic: 'System Design',
    description: `Design a URL shortener service.

**Requirements:**
- shorten(url): returns a short code (6–8 chars)
- resolve(code): returns the original URL
- Track hit count per short URL
- Codes must be unique and URL-safe

**Constraints:**
- In-memory storage is fine
- Short codes should be generated deterministically or randomly (your choice — justify it)`,
    starterCode: `public class UrlShortener {
    // TODO: implement shorten and resolve
}

public class ShortUrl {
    // TODO: implement model
}`,
  },
];
