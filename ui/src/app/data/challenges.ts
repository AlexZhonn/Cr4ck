export interface Challenge {
  id: string;
  title: string;
  framework: string;
  language: string;
  difficulty: 'Easy' | 'Medium' | 'Hard';
  description: string;
  starterCode: string;
}

export const CHALLENGES: Challenge[] = [
  {
    id: 'oop_001',
    title: 'Library System',
    framework: 'Java / OOP',
    language: 'java',
    difficulty: 'Easy',
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
    title: 'Notification Service',
    framework: 'TypeScript / Design Patterns',
    language: 'typescript',
    difficulty: 'Medium',
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
    id: 'oop_003',
    title: 'E-Commerce Cart',
    framework: 'Python / OOP',
    language: 'python',
    difficulty: 'Medium',
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
    id: 'sys_001',
    title: 'Rate Limiter',
    framework: 'Java / System Design',
    language: 'java',
    difficulty: 'Hard',
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
];
