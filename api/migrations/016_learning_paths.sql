-- Migration 016: learning paths + path_challenges join table
-- Curated sequences of challenges forming guided learning curricula.

CREATE TABLE IF NOT EXISTS paths (
    id          SERIAL                  PRIMARY KEY,
    slug        VARCHAR(100)            NOT NULL UNIQUE,
    title       VARCHAR(200)            NOT NULL,
    description TEXT                    NOT NULL,
    topic       challenge_topic,                    -- NULL = multi-topic path
    icon        VARCHAR(50),
    order_index INT                     NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS path_challenges (
    path_id      INT         NOT NULL REFERENCES paths(id) ON DELETE CASCADE,
    challenge_id VARCHAR(50) NOT NULL REFERENCES challenges(id),
    step_order   INT         NOT NULL,
    PRIMARY KEY (path_id, challenge_id)
);

CREATE INDEX IF NOT EXISTS idx_path_challenges_path_id ON path_challenges (path_id);

-- ── Seed: 8 curated learning paths ───────────────────────────────────────────

INSERT INTO paths (slug, title, description, topic, icon, order_index) VALUES
(
  'oop-foundations',
  'OOP Foundations',
  'Start here. Master the core pillars of OOP — encapsulation, abstraction, state, and object relationships through progressively richer real-world systems. Every challenge is Easy difficulty.',
  'OOP', 'oop', 1
),
(
  'oop-in-practice',
  'OOP in Practice',
  'Level up to medium-complexity systems. Model real business domains, enforce invariants, and apply inheritance and polymorphism correctly across a range of industry-relevant problems.',
  'OOP', 'oop', 2
),
(
  'advanced-oop',
  'Advanced OOP Systems',
  'Master OOP at full scale. Tackle multi-entity systems with complex state, deep class hierarchies, and strict business invariants — the kind of problems asked in senior-level interviews.',
  'OOP', 'oop', 3
),
(
  'creational-patterns',
  'Creational Design Patterns',
  'Master the 5 GoF creational patterns — Factory Method, Abstract Factory, Builder, Prototype, and Singleton. Learn when each applies and how they eliminate fragile object-construction code.',
  'Design Patterns', 'patterns', 4
),
(
  'structural-patterns',
  'Structural Design Patterns',
  'Master the 7 GoF structural patterns — Adapter, Bridge, Composite, Decorator, Facade, Flyweight, and Proxy. Learn how to compose objects into flexible, reusable larger structures.',
  'Design Patterns', 'patterns', 5
),
(
  'behavioral-patterns',
  'Behavioral Design Patterns',
  'Master 9 GoF behavioral patterns — Observer, Strategy, Command, State, Chain of Responsibility, Iterator, Mediator, Memento, and Visitor. Learn how objects collaborate and distribute responsibility.',
  'Design Patterns', 'patterns', 6
),
(
  'system-design-foundations',
  'System Design Foundations',
  'Build fluency with the essential patterns every backend engineer needs — caching, queues, service discovery, event-driven architecture, and resilience fundamentals.',
  'System Design', 'system', 7
),
(
  'distributed-systems',
  'Distributed Systems Deep Dive',
  'Tackle the hard problems of distributed computing — consensus algorithms, distributed locks, consistent hashing, CQRS, Saga orchestration, and leader election. Preparation for senior system design interviews.',
  'System Design', 'system', 8
);

-- ── Path 1: OOP Foundations (Easy OOP) ───────────────────────────────────────
-- Theme: classes → encapsulation → state → relationships → polymorphism

INSERT INTO path_challenges (path_id, challenge_id, step_order)
SELECT p.id, c.challenge_id, c.step_order
FROM paths p
CROSS JOIN (VALUES
  ('oop_001',  1),   -- Library System — basic classes and object relationships
  ('oop_009',  2),   -- Hotel Room Booking Platform — encapsulation + availability state
  ('oop_012',  3),   -- Gym Membership Portal — membership lifecycle tracking
  ('oop_015',  4),   -- School Grade Book System — aggregation and computation
  ('oop_024',  5),   -- Event Ticketing Platform — capacity constraints
  ('oop_033',  6),   -- Recipe Management System — composition and collections
  ('oop_042',  7),   -- Library Fine Calculator — layered business rules
  ('oop_057',  8),   -- E-Learning Quiz Engine — polymorphic question types
  ('oop_078',  9)    -- Game Character Leveling System — state evolution over time
) AS c(challenge_id, step_order)
WHERE p.slug = 'oop-foundations';

-- ── Path 2: OOP in Practice (Medium OOP) ─────────────────────────────────────
-- Theme: real business domains, inheritance, polymorphism, invariant enforcement

INSERT INTO path_challenges (path_id, challenge_id, step_order)
SELECT p.id, c.challenge_id, c.step_order
FROM paths p
CROSS JOIN (VALUES
  ('oop_002',  1),   -- E-Commerce Cart — discount strategy via polymorphism
  ('oop_003',  2),   -- University Enrollment — capacity constraints + deduplication
  ('oop_007',  3),   -- Warehouse Inventory Tracker — stock management
  ('oop_010',  4),   -- Online Auction Bidding Engine — event-driven state transitions
  ('oop_013',  5),   -- Restaurant Order Management — order lifecycle state machine
  ('oop_025',  6),   -- Digital Wallet Transaction Ledger — financial domain modeling
  ('oop_031',  7),   -- Classroom Seating Planner — constraint-aware allocation
  ('oop_040',  8),   -- Supply Chain Shipment Tracker — multi-step lifecycle
  ('oop_052',  9)    -- Bus Route Scheduler — scheduling + routing domain
) AS c(challenge_id, step_order)
WHERE p.slug = 'oop-in-practice';

-- ── Path 3: Advanced OOP Systems (Hard OOP) ───────────────────────────────────
-- Theme: abstract class hierarchies, cross-entity invariants, complex state

INSERT INTO path_challenges (path_id, challenge_id, step_order)
SELECT p.id, c.challenge_id, c.step_order
FROM paths p
CROSS JOIN (VALUES
  ('oop_004',  1),   -- Bank Account Hierarchy — abstract classes + monetary precision
  ('oop_005',  2),   -- Hospital Patient Management — multi-role class hierarchy
  ('oop_008',  3),   -- Airline Reservation System — seat allocation + cancellation logic
  ('oop_020',  4),   -- Parking Lot Management System — real-time spot tracking at scale
  ('oop_023',  5),   -- Package Delivery Tracking — multi-stage parcel lifecycle
  ('oop_029',  6),   -- Subscription Billing Manager — billing periods + proration
  ('oop_044',  7),   -- Theater Seat Reservation — constraint-heavy venue booking
  ('oop_047',  8)    -- Project Task Management Board — dependency graph orchestration
) AS c(challenge_id, step_order)
WHERE p.slug = 'advanced-oop';

-- ── Path 4: Creational Design Patterns ────────────────────────────────────────
-- Sequence: introduce each pattern at Easy → apply at Medium → master at Hard
-- Patterns covered: Builder, Singleton, Prototype, Factory Method, Abstract Factory

INSERT INTO path_challenges (path_id, challenge_id, step_order)
SELECT p.id, c.challenge_id, c.step_order
FROM paths p
CROSS JOIN (VALUES
  ('dp_003',  1),    -- Document Builder            (Easy   — Builder intro)
  ('dp_033',  2),    -- Theme Manager Singleton      (Easy   — Singleton intro)
  ('dp_048',  3),    -- Network Packet Prototype     (Easy   — Prototype intro)
  ('dp_051',  4),    -- Pizza Topping Factory        (Easy   — Factory Method intro)
  ('dp_069',  5),    -- OS-Specific Dialog           (Easy   — Abstract Factory intro)
  ('dp_007',  6),    -- Vehicle Factory Assembly     (Medium — Factory Method applied)
  ('dp_052',  7),    -- Character Sheet Builder RPG  (Medium — Builder fluent API)
  ('dp_070',  8),    -- Configuration Snapshot       (Medium — Prototype deep copy)
  ('dp_029',  9),    -- Cloud Storage Provider       (Hard   — Abstract Factory + DI)
  ('dp_011', 10)     -- Config Singleton Registry    (Hard   — Singleton + thread safety)
) AS c(challenge_id, step_order)
WHERE p.slug = 'creational-patterns';

-- ── Path 5: Structural Design Patterns ────────────────────────────────────────
-- All 7 structural patterns introduced at Easy, then key ones deepened at Medium/Hard
-- Patterns: Decorator, Facade, Bridge, Composite, Flyweight, Proxy, Adapter

INSERT INTO path_challenges (path_id, challenge_id, step_order)
SELECT p.id, c.challenge_id, c.step_order
FROM paths p
CROSS JOIN (VALUES
  ('dp_009',  1),    -- Logging Decorator Pipeline   (Easy   — Decorator intro)
  ('dp_015',  2),    -- Database Facade Adapter      (Easy   — Facade intro)
  ('dp_024',  3),    -- Cross-Platform UI Bridge     (Easy   — Bridge intro)
  ('dp_036',  4),    -- UI Component Composite       (Easy   — Composite intro)
  ('dp_045',  5),    -- Particle System Flyweight    (Easy   — Flyweight intro)
  ('dp_054',  6),    -- Firewall Rule Proxy Guard    (Easy   — Proxy intro)
  ('dp_060',  7),    -- Third-Party Payment Adapter  (Easy   — Adapter intro)
  ('dp_031',  8),    -- HTTP Request Decorator Chain (Medium — Decorator middleware)
  ('dp_058',  9),    -- Organization Chart Composite (Medium — Composite tree ops)
  ('dp_032', 10)     -- Virtual DOM Proxy Cache      (Hard   — Proxy + lazy loading)
) AS c(challenge_id, step_order)
WHERE p.slug = 'structural-patterns';

-- ── Path 6: Behavioral Design Patterns ────────────────────────────────────────
-- 9 behavioral patterns introduced at Easy, 3 deepened at Medium/Hard
-- Patterns: Observer, Command, Chain of Resp, State, Strategy, Memento, Iterator, Mediator, Visitor

INSERT INTO path_challenges (path_id, challenge_id, step_order)
SELECT p.id, c.challenge_id, c.step_order
FROM paths p
CROSS JOIN (VALUES
  ('dp_006',  1),    -- Chat Observer System         (Easy   — Observer intro)
  ('dp_012',  2),    -- Text Editor Command History  (Easy   — Command intro)
  ('dp_018',  3),    -- Support Ticket Chain Handler (Easy   — Chain of Resp intro)
  ('dp_021',  4),    -- Traffic Light State Machine  (Easy   — State intro)
  ('dp_027',  5),    -- Shipping Cost Strategy       (Easy   — Strategy intro)
  ('dp_042',  6),    -- Browser History Memento      (Easy   — Memento intro)
  ('dp_057',  7),    -- Pagination Cursor Iterator   (Easy   — Iterator intro)
  ('dp_063',  8),    -- Auction House Mediator       (Easy   — Mediator intro)
  ('dp_066',  9),    -- Insurance Premium Visitor    (Easy   — Visitor intro)
  ('dp_043', 10),    -- Vending Machine State        (Medium — State: multi-transition)
  ('dp_049', 11),    -- Compression Algorithm        (Medium — Strategy: runtime swap)
  ('dp_056', 12)     -- Undo Redo Command Processor  (Hard   — Command: history + replay)
) AS c(challenge_id, step_order)
WHERE p.slug = 'behavioral-patterns';

-- ── Path 7: System Design Foundations (Easy + Medium) ─────────────────────────
-- Theme: core patterns every backend engineer must know cold

INSERT INTO path_challenges (path_id, challenge_id, step_order)
SELECT p.id, c.challenge_id, c.step_order
FROM paths p
CROSS JOIN (VALUES
  ('sys_004',  1),   -- URL Shortener                (Easy   — hashing + redirect)
  ('sys_006',  2),   -- Message Queue Broker         (Easy   — async decoupling)
  ('sys_009',  3),   -- Write-Ahead Log Engine       (Easy   — durability guarantee)
  ('sys_012',  4),   -- Service Discovery Registry   (Easy   — microservice mesh)
  ('sys_002',  5),   -- In-Memory LRU Cache          (Medium — eviction + TTL)
  ('sys_003',  6),   -- Job Queue + Worker Pool      (Medium — priority + concurrency)
  ('sys_007',  7),   -- Circuit Breaker Middleware   (Medium — fault tolerance)
  ('sys_010',  8),   -- Read Replica Sync            (Medium — replication lag)
  ('sys_013',  9)    -- Event Sourcing Store         (Medium — immutable event log)
) AS c(challenge_id, step_order)
WHERE p.slug = 'system-design-foundations';

-- ── Path 8: Distributed Systems Deep Dive (Hard) ──────────────────────────────
-- Theme: consensus, coordination, partitioning, distributed transactions

INSERT INTO path_challenges (path_id, challenge_id, step_order)
SELECT p.id, c.challenge_id, c.step_order
FROM paths p
CROSS JOIN (VALUES
  ('sys_001',  1),   -- Rate Limiter (token bucket) — concurrency + O(1) check
  ('sys_005',  2),   -- Distributed Lock Manager   — mutual exclusion across nodes
  ('sys_008',  3),   -- Consistent Hash Ring       — partition-aware routing
  ('sys_014',  4),   -- CQRS Command Dispatcher    — read/write segregation
  ('sys_017',  5),   -- Saga Orchestration         — distributed transaction rollback
  ('sys_020',  6),   -- Leader Election Protocol   — consensus + split-brain prevention
  ('sys_023',  7),   -- WebSocket Connection Hub   — real-time fan-out at scale
  ('sys_026',  8)    -- Idempotency Key            — exactly-once semantics
) AS c(challenge_id, step_order)
WHERE p.slug = 'distributed-systems';
