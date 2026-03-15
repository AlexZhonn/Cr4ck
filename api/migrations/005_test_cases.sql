-- Migration 005: add test_cases JSONB column to challenges
-- Each entry: { "input": "...", "expected_output": "...", "description": "..." }

ALTER TABLE challenges
    ADD COLUMN IF NOT EXISTS test_cases JSONB NOT NULL DEFAULT '[]'::jsonb;

-- Seed test cases for the first few OOP challenges as examples
UPDATE challenges SET test_cases = '[
  {"input": "borrow Book1 User1", "expected_output": "Book1 borrowed by User1", "description": "User borrows an available book"},
  {"input": "borrow Book1 User2", "expected_output": "Book1 is not available", "description": "Cannot borrow already-checked-out book"},
  {"input": "return Book1 User1", "expected_output": "Book1 returned by User1", "description": "User returns a borrowed book"}
]'::jsonb
WHERE id = 'oop_001';

UPDATE challenges SET test_cases = '[
  {"input": "add item price=10.00 qty=2", "expected_output": "Subtotal: 20.00", "description": "Basic cart total calculation"},
  {"input": "apply discount STUDENT10", "expected_output": "Discount applied: 10%", "description": "Student discount applied"},
  {"input": "checkout", "expected_output": "Order total: 18.00", "description": "Final total after discount"}
]'::jsonb
WHERE id = 'oop_002';
