-- Migration 017: New curated challenges — OOP, Design Patterns, System Design
-- All challenges support Python, Java, TypeScript, and C++.

-- ============================================================
-- WIPE old seeded data (idempotent reset)
-- ============================================================
DELETE FROM path_challenges;
DELETE FROM paths;
DELETE FROM user_badges;
DELETE FROM user_challenges  WHERE challenge_id IN (SELECT id FROM challenges WHERE is_ai_generated = FALSE);
DELETE FROM daily_challenges;
DELETE FROM challenges       WHERE is_ai_generated = FALSE;

-- ============================================================
-- OOP CHALLENGES
-- ============================================================

INSERT INTO challenges (id, title, topic, difficulty, language, framework,
    description, starter_code, test_cases, test_harness, starter_codes, test_harnesses) VALUES (

'oop_n01',
'Bank Account Manager',
'OOP', 'Easy', 'python', 'Python / OOP',
$$Design a bank account system that supports basic financial operations.

**Requirements:**
- `BankAccount(owner, balance)` — create an account with an owner name and initial balance
- `deposit(amount) -> str` — add funds; return `"Deposited {amount:.2f}. Balance: {balance:.2f}"`
- `withdraw(amount) -> str` — deduct funds; return `"Withdrew {amount:.2f}. Balance: {balance:.2f}"` or `"Insufficient funds."` if balance would go negative
- `get_balance() -> str` — return `"Balance: {balance:.2f}"`
- `get_owner() -> str` — return the owner's name

**Constraints:**
- Balance must never go below 0
- All monetary values formatted to 2 decimal places$$,

$$class BankAccount:
    def __init__(self, owner: str, balance: float):
        pass

    def deposit(self, amount: float) -> str:
        pass

    def withdraw(self, amount: float) -> str:
        pass

    def get_balance(self) -> str:
        pass

    def get_owner(self) -> str:
        pass$$,

$TC$[
  {"input": "create Alice 100.00\ndeposit 50.00\nbalance", "expected_output": "Deposited 50.00. Balance: 150.00\nBalance: 150.00", "description": "Deposit increases balance"},
  {"input": "create Bob 200.00\nwithdraw 80.00\nbalance", "expected_output": "Withdrew 80.00. Balance: 120.00\nBalance: 120.00", "description": "Withdraw decreases balance"},
  {"input": "create Carol 50.00\nwithdraw 100.00\nbalance", "expected_output": "Insufficient funds.\nBalance: 50.00", "description": "Withdraw more than balance is rejected"},
  {"input": "create Dave 0.00\ndeposit 25.50\nwithdraw 25.50\nbalance", "expected_output": "Deposited 25.50. Balance: 25.50\nWithdrew 25.50. Balance: 0.00\nBalance: 0.00", "description": "Withdraw exact balance leaves zero"},
  {"input": "create Eve 1000.00\nowner", "expected_output": "Eve", "description": "Owner name is returned correctly"},
  {"input": "create Frank 500.00\ndeposit 100.00\nwithdraw 300.00\nwithdraw 400.00\nbalance", "expected_output": "Deposited 100.00. Balance: 600.00\nWithdrew 300.00. Balance: 300.00\nInsufficient funds.\nBalance: 300.00", "description": "Multiple operations in sequence"}
]$TC$::jsonb,

NULL,

$SC${"python": "class BankAccount:\n    def __init__(self, owner: str, balance: float):\n        pass\n\n    def deposit(self, amount: float) -> str:\n        pass\n\n    def withdraw(self, amount: float) -> str:\n        pass\n\n    def get_balance(self) -> str:\n        pass\n\n    def get_owner(self) -> str:\n        pass",
  "java": "public class BankAccount {\n    private String owner;\n    private double balance;\n\n    public BankAccount(String owner, double balance) {\n        // TODO\n    }\n\n    public String deposit(double amount) {\n        // TODO\n        return \"\";\n    }\n\n    public String withdraw(double amount) {\n        // TODO\n        return \"\";\n    }\n\n    public String getBalance() {\n        // TODO\n        return \"\";\n    }\n\n    public String getOwner() {\n        // TODO\n        return \"\";\n    }\n}",
  "typescript": "class BankAccount {\n    private owner: string;\n    private balance: number;\n\n    constructor(owner: string, balance: number) {\n        // TODO\n    }\n\n    deposit(amount: number): string {\n        // TODO\n        return \"\";\n    }\n\n    withdraw(amount: number): string {\n        // TODO\n        return \"\";\n    }\n\n    getBalance(): string {\n        // TODO\n        return \"\";\n    }\n\n    getOwner(): string {\n        // TODO\n        return \"\";\n    }\n}",
  "cpp": "#include <string>\n#include <sstream>\n#include <iomanip>\nusing namespace std;\n\nclass BankAccount {\nprivate:\n    string owner;\n    double balance;\npublic:\n    BankAccount(string owner, double balance) {\n        // TODO\n    }\n\n    string deposit(double amount) {\n        // TODO\n        return \"\";\n    }\n\n    string withdraw(double amount) {\n        // TODO\n        return \"\";\n    }\n\n    string get_balance() {\n        // TODO\n        return \"\";\n    }\n\n    string get_owner() {\n        // TODO\n        return \"\";\n    }\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\naccount = None\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"create\":\n        account = BankAccount(parts[1], float(parts[2]))\n    elif cmd == \"deposit\":\n        print(account.deposit(float(parts[1])))\n    elif cmd == \"withdraw\":\n        print(account.withdraw(float(parts[1])))\n    elif cmd == \"balance\":\n        print(account.get_balance())\n    elif cmd == \"owner\":\n        print(account.get_owner())",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        BankAccount account = null;\n        while (sc.hasNextLine()) {\n            String line = sc.nextLine().trim();\n            if (line.isEmpty()) continue;\n            String[] parts = line.split(\" \");\n            String cmd = parts[0];\n            if (cmd.equals(\"create\")) {\n                account = new BankAccount(parts[1], Double.parseDouble(parts[2]));\n            } else if (cmd.equals(\"deposit\")) {\n                System.out.println(account.deposit(Double.parseDouble(parts[1])));\n            } else if (cmd.equals(\"withdraw\")) {\n                System.out.println(account.withdraw(Double.parseDouble(parts[1])));\n            } else if (cmd.equals(\"balance\")) {\n                System.out.println(account.getBalance());\n            } else if (cmd.equals(\"owner\")) {\n                System.out.println(account.getOwner());\n            }\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl = readline.createInterface({ input: process.stdin });\nlet account: BankAccount | null = null;\nrl.on('line', (line) => {\n    line = line.trim();\n    if (!line) return;\n    const parts = line.split(' ');\n    const cmd = parts[0];\n    if (cmd === 'create') {\n        account = new BankAccount(parts[1], parseFloat(parts[2]));\n    } else if (cmd === 'deposit') {\n        console.log(account!.deposit(parseFloat(parts[1])));\n    } else if (cmd === 'withdraw') {\n        console.log(account!.withdraw(parseFloat(parts[1])));\n    } else if (cmd === 'balance') {\n        console.log(account!.getBalance());\n    } else if (cmd === 'owner') {\n        console.log(account!.getOwner());\n    }\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main() {\n    string line;\n    BankAccount* account = nullptr;\n    while (getline(cin, line)) {\n        if (line.empty()) continue;\n        istringstream ss(line);\n        string cmd; ss >> cmd;\n        if (cmd == \"create\") {\n            string owner; double bal;\n            ss >> owner >> bal;\n            account = new BankAccount(owner, bal);\n        } else if (cmd == \"deposit\") {\n            double amt; ss >> amt;\n            cout << account->deposit(amt) << \"\\n\";\n        } else if (cmd == \"withdraw\") {\n            double amt; ss >> amt;\n            cout << account->withdraw(amt) << \"\\n\";\n        } else if (cmd == \"balance\") {\n            cout << account->get_balance() << \"\\n\";\n        } else if (cmd == \"owner\") {\n            cout << account->get_owner() << \"\\n\";\n        }\n    }\n    return 0;\n}"
}$TH$::jsonb

),

-- oop_n02 -------------------------------------------------------
(
'oop_n02',
'Animal Zoo',
'OOP', 'Easy', 'python', 'Python / OOP',
$$Model a zoo with a class hierarchy using inheritance and polymorphism.

**Requirements:**
- `Animal(name, sound)` — base class; `speak() -> str` returns `"{name} says {sound}!"`
- `Dog(name)` — sound is `"Woof"`; adds `fetch(item) -> str` returning `"{name} fetches the {item}!"`
- `Cat(name)` — sound is `"Meow"`; adds `purr() -> str` returning `"{name} purrs..."`
- `Bird(name, can_fly)` — sound is `"Tweet"`; adds `fly() -> str` returning `"{name} soars through the sky!"` or `"{name} cannot fly."`

**Constraints:**
- `speak()` is defined only on `Animal`; subclasses must call `super().__init__`$$,

$$class Animal:
    def __init__(self, name: str, sound: str):
        pass

    def speak(self) -> str:
        pass

class Dog(Animal):
    def __init__(self, name: str):
        pass

    def fetch(self, item: str) -> str:
        pass

class Cat(Animal):
    def __init__(self, name: str):
        pass

    def purr(self) -> str:
        pass

class Bird(Animal):
    def __init__(self, name: str, can_fly: bool):
        pass

    def fly(self) -> str:
        pass$$,

$TC$[
  {"input": "dog Rex\nspeak Rex", "expected_output": "Rex says Woof!", "description": "Dog speak uses inherited method"},
  {"input": "cat Whiskers\nspeak Whiskers", "expected_output": "Whiskers says Meow!", "description": "Cat speak uses inherited method"},
  {"input": "dog Rex\nfetch Rex ball", "expected_output": "Rex fetches the ball!", "description": "Dog fetch works"},
  {"input": "cat Luna\npurr Luna", "expected_output": "Luna purrs...", "description": "Cat purr works"},
  {"input": "bird Tweety true\nfly Tweety", "expected_output": "Tweety soars through the sky!", "description": "Flying bird can fly"},
  {"input": "bird Penny false\nfly Penny", "expected_output": "Penny cannot fly.", "description": "Non-flying bird cannot fly"},
  {"input": "bird Eagle true\nspeak Eagle", "expected_output": "Eagle says Tweet!", "description": "Bird speak is inherited"}
]$TC$::jsonb,

NULL,

$SC${"python": "class Animal:\n    def __init__(self, name: str, sound: str):\n        pass\n\n    def speak(self) -> str:\n        pass\n\nclass Dog(Animal):\n    def __init__(self, name: str):\n        pass\n\n    def fetch(self, item: str) -> str:\n        pass\n\nclass Cat(Animal):\n    def __init__(self, name: str):\n        pass\n\n    def purr(self) -> str:\n        pass\n\nclass Bird(Animal):\n    def __init__(self, name: str, can_fly: bool):\n        pass\n\n    def fly(self) -> str:\n        pass",
  "java": "class Animal {\n    protected String name;\n    protected String sound;\n    public Animal(String name, String sound) {\n        // TODO\n    }\n    public String speak() {\n        // TODO\n        return \"\";\n    }\n}\nclass Dog extends Animal {\n    public Dog(String name) {\n        // TODO: super(...)\n    }\n    public String fetch(String item) {\n        // TODO\n        return \"\";\n    }\n}\nclass Cat extends Animal {\n    public Cat(String name) {\n        // TODO\n    }\n    public String purr() {\n        // TODO\n        return \"\";\n    }\n}\nclass Bird extends Animal {\n    private boolean canFly;\n    public Bird(String name, boolean canFly) {\n        // TODO\n    }\n    public String fly() {\n        // TODO\n        return \"\";\n    }\n}",
  "typescript": "class Animal {\n    protected name: string;\n    protected sound: string;\n    constructor(name: string, sound: string) {\n        // TODO\n    }\n    speak(): string {\n        // TODO\n        return \"\";\n    }\n}\nclass Dog extends Animal {\n    constructor(name: string) {\n        // TODO: super(...)\n    }\n    fetch(item: string): string {\n        // TODO\n        return \"\";\n    }\n}\nclass Cat extends Animal {\n    constructor(name: string) {\n        // TODO\n    }\n    purr(): string {\n        // TODO\n        return \"\";\n    }\n}\nclass Bird extends Animal {\n    private canFly: boolean;\n    constructor(name: string, canFly: boolean) {\n        // TODO\n    }\n    fly(): string {\n        // TODO\n        return \"\";\n    }\n}",
  "cpp": "#include <string>\nusing namespace std;\nclass Animal {\nprotected:\n    string name, sound;\npublic:\n    Animal(string name, string sound) {\n        // TODO\n    }\n    virtual string speak() {\n        // TODO\n        return \"\";\n    }\n};\nclass Dog : public Animal {\npublic:\n    Dog(string name) : Animal(name, \"Woof\") {}\n    string fetch(string item) {\n        // TODO\n        return \"\";\n    }\n};\nclass Cat : public Animal {\npublic:\n    Cat(string name) : Animal(name, \"Meow\") {}\n    string purr() {\n        // TODO\n        return \"\";\n    }\n};\nclass Bird : public Animal {\n    bool canFly;\npublic:\n    Bird(string name, bool canFly) : Animal(name, \"Tweet\"), canFly(canFly) {}\n    string fly() {\n        // TODO\n        return \"\";\n    }\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\nanimals = {}\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"dog\":\n        animals[parts[1]] = Dog(parts[1])\n    elif cmd == \"cat\":\n        animals[parts[1]] = Cat(parts[1])\n    elif cmd == \"bird\":\n        animals[parts[1]] = Bird(parts[1], parts[2].lower() == \"true\")\n    elif cmd == \"speak\":\n        print(animals[parts[1]].speak())\n    elif cmd == \"fetch\":\n        print(animals[parts[1]].fetch(parts[2]))\n    elif cmd == \"purr\":\n        print(animals[parts[1]].purr())\n    elif cmd == \"fly\":\n        print(animals[parts[1]].fly())",
  "java": "import java.util.Scanner;\nimport java.util.HashMap;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        HashMap<String,Animal> animals = new HashMap<>();\n        while (sc.hasNextLine()) {\n            String line = sc.nextLine().trim();\n            if (line.isEmpty()) continue;\n            String[] p = line.split(\" \");\n            String cmd = p[0];\n            if (cmd.equals(\"dog\")) animals.put(p[1], new Dog(p[1]));\n            else if (cmd.equals(\"cat\")) animals.put(p[1], new Cat(p[1]));\n            else if (cmd.equals(\"bird\")) animals.put(p[1], new Bird(p[1], p[2].equals(\"true\")));\n            else if (cmd.equals(\"speak\")) System.out.println(animals.get(p[1]).speak());\n            else if (cmd.equals(\"fetch\")) System.out.println(((Dog)animals.get(p[1])).fetch(p[2]));\n            else if (cmd.equals(\"purr\")) System.out.println(((Cat)animals.get(p[1])).purr());\n            else if (cmd.equals(\"fly\")) System.out.println(((Bird)animals.get(p[1])).fly());\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl = readline.createInterface({ input: process.stdin });\nconst animals: Record<string, any> = {};\nrl.on('line', (line) => {\n    line = line.trim();\n    if (!line) return;\n    const p = line.split(' ');\n    const cmd = p[0];\n    if (cmd === 'dog') animals[p[1]] = new Dog(p[1]);\n    else if (cmd === 'cat') animals[p[1]] = new Cat(p[1]);\n    else if (cmd === 'bird') animals[p[1]] = new Bird(p[1], p[2] === 'true');\n    else if (cmd === 'speak') console.log(animals[p[1]].speak());\n    else if (cmd === 'fetch') console.log(animals[p[1]].fetch(p[2]));\n    else if (cmd === 'purr') console.log(animals[p[1]].purr());\n    else if (cmd === 'fly') console.log(animals[p[1]].fly());\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\n#include <map>\nusing namespace std;\nint main() {\n    string line;\n    map<string,Animal*> animals;\n    while (getline(cin, line)) {\n        if (line.empty()) continue;\n        istringstream ss(line);\n        string cmd; ss >> cmd;\n        if (cmd == \"dog\") { string n; ss>>n; animals[n]=new Dog(n); }\n        else if (cmd == \"cat\") { string n; ss>>n; animals[n]=new Cat(n); }\n        else if (cmd == \"bird\") { string n,cf; ss>>n>>cf; animals[n]=new Bird(n,cf==\"true\"); }\n        else if (cmd == \"speak\") { string n; ss>>n; cout<<animals[n]->speak()<<\"\\n\"; }\n        else if (cmd == \"fetch\") { string n,item; ss>>n>>item; cout<<((Dog*)animals[n])->fetch(item)<<\"\\n\"; }\n        else if (cmd == \"purr\") { string n; ss>>n; cout<<((Cat*)animals[n])->purr()<<\"\\n\"; }\n        else if (cmd == \"fly\") { string n; ss>>n; cout<<((Bird*)animals[n])->fly()<<\"\\n\"; }\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- oop_n03 -------------------------------------------------------
(
'oop_n03',
'Task Manager',
'OOP', 'Medium', 'python', 'Python / OOP',
$$Build a task manager that tracks tasks with priorities and statuses.

**Requirements:**
- `Task(task_id, title, priority)` — priority is `"low"`, `"medium"`, or `"high"`; default status is `"pending"`
- `TaskManager`:
  - `add_task(task_id, title, priority) -> str` — `"Task {id} added."` or `"Task {id} already exists."`
  - `complete_task(task_id) -> str` — `"Task {id} completed."` or `"Task {id} not found."`
  - `delete_task(task_id) -> str` — `"Task {id} deleted."` or `"Task {id} not found."`
  - `list_tasks(filter) -> str` — filter is `"all"`, `"pending"`, or `"done"`; one line per task `"[{status}] ({priority}) {title}"` sorted by id ascending; `"No tasks."` if empty

**Constraints:**
- Tasks stored by integer ID; list output sorted ascending by task_id$$,

$$class Task:
    def __init__(self, task_id: int, title: str, priority: str):
        pass

class TaskManager:
    def __init__(self):
        pass

    def add_task(self, task_id: int, title: str, priority: str) -> str:
        pass

    def complete_task(self, task_id: int) -> str:
        pass

    def delete_task(self, task_id: int) -> str:
        pass

    def list_tasks(self, filter: str = "all") -> str:
        pass$$,

$TC$[
  {"input": "add 1 WriteTests high\nadd 2 ReadDocs low\nlist all", "expected_output": "Task 1 added.\nTask 2 added.\n[pending] (high) WriteTests\n[pending] (low) ReadDocs", "description": "Add tasks and list all"},
  {"input": "add 1 Deploy medium\ncomplete 1\nlist all", "expected_output": "Task 1 added.\nTask 1 completed.\n[done] (medium) Deploy", "description": "Complete a task changes status"},
  {"input": "complete 99", "expected_output": "Task 99 not found.", "description": "Completing nonexistent task returns error"},
  {"input": "add 1 Alpha high\nadd 2 Beta low\ncomplete 1\nlist pending", "expected_output": "Task 1 added.\nTask 2 added.\nTask 1 completed.\n[pending] (low) Beta", "description": "Filter pending only"},
  {"input": "add 1 Alpha high\nadd 2 Beta low\ncomplete 1\nlist done", "expected_output": "Task 1 added.\nTask 2 added.\nTask 1 completed.\n[done] (high) Alpha", "description": "Filter done only"},
  {"input": "add 1 Alpha high\nadd 1 Duplicate medium", "expected_output": "Task 1 added.\nTask 1 already exists.", "description": "Duplicate task ID rejected"},
  {"input": "add 1 Alpha high\ndelete 1\nlist all", "expected_output": "Task 1 added.\nTask 1 deleted.\nNo tasks.", "description": "Deleted task no longer listed"},
  {"input": "list all", "expected_output": "No tasks.", "description": "Empty manager shows no tasks"}
]$TC$::jsonb,

NULL,

$SC${"python": "class Task:\n    def __init__(self, task_id: int, title: str, priority: str):\n        pass\n\nclass TaskManager:\n    def __init__(self):\n        pass\n\n    def add_task(self, task_id: int, title: str, priority: str) -> str:\n        pass\n\n    def complete_task(self, task_id: int) -> str:\n        pass\n\n    def delete_task(self, task_id: int) -> str:\n        pass\n\n    def list_tasks(self, filter: str = \"all\") -> str:\n        pass",
  "java": "import java.util.*;\nclass Task {\n    int id; String title, priority, status;\n    Task(int id, String title, String priority) {\n        this.id=id; this.title=title; this.priority=priority; this.status=\"pending\";\n    }\n}\nclass TaskManager {\n    private TreeMap<Integer,Task> tasks = new TreeMap<>();\n    public String add_task(int id, String title, String priority) {\n        if (tasks.containsKey(id)) return \"Task \"+id+\" already exists.\";\n        tasks.put(id, new Task(id,title,priority));\n        return \"Task \"+id+\" added.\";\n    }\n    public String complete_task(int id) {\n        if (!tasks.containsKey(id)) return \"Task \"+id+\" not found.\";\n        tasks.get(id).status=\"done\";\n        return \"Task \"+id+\" completed.\";\n    }\n    public String delete_task(int id) {\n        if (!tasks.containsKey(id)) return \"Task \"+id+\" not found.\";\n        tasks.remove(id);\n        return \"Task \"+id+\" deleted.\";\n    }\n    public String list_tasks(String filter) {\n        StringBuilder sb = new StringBuilder();\n        for (Task t : tasks.values()) {\n            if (filter.equals(\"pending\") && !t.status.equals(\"pending\")) continue;\n            if (filter.equals(\"done\") && !t.status.equals(\"done\")) continue;\n            if (sb.length()>0) sb.append(\"\\n\");\n            sb.append(\"[\"+t.status+\"] (\"+t.priority+\") \"+t.title);\n        }\n        return sb.length()==0 ? \"No tasks.\" : sb.toString();\n    }\n}",
  "typescript": "class Task {\n    id: number; title: string; priority: string; status: string;\n    constructor(id: number, title: string, priority: string) {\n        this.id=id; this.title=title; this.priority=priority; this.status='pending';\n    }\n}\nclass TaskManager {\n    private tasks = new Map<number, Task>();\n    add_task(id: number, title: string, priority: string): string {\n        if (this.tasks.has(id)) return `Task ${id} already exists.`;\n        this.tasks.set(id, new Task(id, title, priority));\n        return `Task ${id} added.`;\n    }\n    complete_task(id: number): string {\n        if (!this.tasks.has(id)) return `Task ${id} not found.`;\n        this.tasks.get(id)!.status = 'done';\n        return `Task ${id} completed.`;\n    }\n    delete_task(id: number): string {\n        if (!this.tasks.has(id)) return `Task ${id} not found.`;\n        this.tasks.delete(id);\n        return `Task ${id} deleted.`;\n    }\n    list_tasks(filter: string = 'all'): string {\n        const rows: string[] = [];\n        for (const t of [...this.tasks.values()].sort((a,b)=>a.id-b.id)) {\n            if (filter === 'pending' && t.status !== 'pending') continue;\n            if (filter === 'done' && t.status !== 'done') continue;\n            rows.push(`[${t.status}] (${t.priority}) ${t.title}`);\n        }\n        return rows.length === 0 ? 'No tasks.' : rows.join('\\n');\n    }\n}",
  "cpp": "#include <string>\n#include <map>\n#include <sstream>\nusing namespace std;\nstruct Task {\n    int id; string title, priority, status;\n    Task(int id,string title,string priority):id(id),title(title),priority(priority),status(\"pending\"){}\n};\nclass TaskManager {\n    map<int,Task> tasks;\npublic:\n    string add_task(int id,string title,string priority){\n        if(tasks.count(id)) return \"Task \"+to_string(id)+\" already exists.\";\n        tasks.emplace(id,Task(id,title,priority));\n        return \"Task \"+to_string(id)+\" added.\";\n    }\n    string complete_task(int id){\n        if(!tasks.count(id)) return \"Task \"+to_string(id)+\" not found.\";\n        tasks.at(id).status=\"done\";\n        return \"Task \"+to_string(id)+\" completed.\";\n    }\n    string delete_task(int id){\n        if(!tasks.count(id)) return \"Task \"+to_string(id)+\" not found.\";\n        tasks.erase(id);\n        return \"Task \"+to_string(id)+\" deleted.\";\n    }\n    string list_tasks(string filter){\n        string out;\n        for(auto& [id,t]:tasks){\n            if(filter==\"pending\"&&t.status!=\"pending\") continue;\n            if(filter==\"done\"&&t.status!=\"done\") continue;\n            if(!out.empty()) out+=\"\\n\";\n            out+=\"[\"+t.status+\"] (\"+t.priority+\") \"+t.title;\n        }\n        return out.empty()?\"No tasks.\":out;\n    }\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\ntm = TaskManager()\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"add\":\n        print(tm.add_task(int(parts[1]), parts[2], parts[3]))\n    elif cmd == \"complete\":\n        print(tm.complete_task(int(parts[1])))\n    elif cmd == \"delete\":\n        print(tm.delete_task(int(parts[1])))\n    elif cmd == \"list\":\n        print(tm.list_tasks(parts[1] if len(parts) > 1 else \"all\"))",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        TaskManager tm = new TaskManager();\n        while (sc.hasNextLine()) {\n            String line = sc.nextLine().trim();\n            if (line.isEmpty()) continue;\n            String[] p = line.split(\" \");\n            String cmd = p[0];\n            if (cmd.equals(\"add\")) System.out.println(tm.add_task(Integer.parseInt(p[1]),p[2],p[3]));\n            else if (cmd.equals(\"complete\")) System.out.println(tm.complete_task(Integer.parseInt(p[1])));\n            else if (cmd.equals(\"delete\")) System.out.println(tm.delete_task(Integer.parseInt(p[1])));\n            else if (cmd.equals(\"list\")) System.out.println(tm.list_tasks(p.length>1?p[1]:\"all\"));\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl = readline.createInterface({ input: process.stdin });\nconst tm = new TaskManager();\nrl.on('line', (line) => {\n    line = line.trim();\n    if (!line) return;\n    const p = line.split(' ');\n    const cmd = p[0];\n    if (cmd === 'add') console.log(tm.add_task(parseInt(p[1]), p[2], p[3]));\n    else if (cmd === 'complete') console.log(tm.complete_task(parseInt(p[1])));\n    else if (cmd === 'delete') console.log(tm.delete_task(parseInt(p[1])));\n    else if (cmd === 'list') console.log(tm.list_tasks(p[1] || 'all'));\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main() {\n    string line;\n    TaskManager tm;\n    while (getline(cin, line)) {\n        if (line.empty()) continue;\n        istringstream ss(line);\n        string cmd; ss >> cmd;\n        if (cmd == \"add\") {\n            int id; string title, pri;\n            ss >> id >> title >> pri;\n            cout << tm.add_task(id,title,pri) << \"\\n\";\n        } else if (cmd == \"complete\") {\n            int id; ss >> id;\n            cout << tm.complete_task(id) << \"\\n\";\n        } else if (cmd == \"delete\") {\n            int id; ss >> id;\n            cout << tm.delete_task(id) << \"\\n\";\n        } else if (cmd == \"list\") {\n            string f; ss >> f;\n            if (f.empty()) f = \"all\";\n            cout << tm.list_tasks(f) << \"\\n\";\n        }\n    }\n    return 0;\n}"
}$TH$::jsonb
);

INSERT INTO challenges (id, title, topic, difficulty, language, framework,
    description, starter_code, test_cases, test_harness, starter_codes, test_harnesses) VALUES (

-- oop_n04 -------------------------------------------------------
'oop_n04',
'Student Grade Book',
'OOP', 'Medium', 'python', 'Python / OOP',
$$Implement a grade book that tracks student scores and computes statistics.

**Requirements:**
- `Student(name)` — stores name and empty grades list
- `GradeBook`:
  - `enroll(name) -> str` — `"Enrolled {name}."` or `"{name} already enrolled."`
  - `add_grade(name, grade) -> str` — appends grade (0–100); `"Grade {grade:.1f} added for {name}."`, `"Student {name} not found."`, or `"Invalid grade."`
  - `average(name) -> str` — `"Average for {name}: {avg:.2f}"`, `"No grades for {name}."`, or `"Student {name} not found."`
  - `top_student() -> str` — `"Top student: {name} ({avg:.2f})"` or `"No grades recorded."`

**Constraints:**
- Grades are floats 0–100 inclusive; ties broken by enrollment order$$,

$$class Student:
    def __init__(self, name: str):
        pass

class GradeBook:
    def __init__(self):
        pass

    def enroll(self, name: str) -> str:
        pass

    def add_grade(self, name: str, grade: float) -> str:
        pass

    def average(self, name: str) -> str:
        pass

    def top_student(self) -> str:
        pass$$,

$TC$[
  {"input": "enroll Alice\ngrade Alice 90.0\naverage Alice", "expected_output": "Enrolled Alice.\nGrade 90.0 added for Alice.\nAverage for Alice: 90.00", "description": "Basic enroll, grade, average"},
  {"input": "enroll Bob\naverage Bob", "expected_output": "Enrolled Bob.\nNo grades for Bob.", "description": "Average with no grades"},
  {"input": "grade Ghost 80.0", "expected_output": "Student Ghost not found.", "description": "Grade for unknown student"},
  {"input": "enroll Alice\ngrade Alice 110.0", "expected_output": "Enrolled Alice.\nInvalid grade.", "description": "Grade above 100 is invalid"},
  {"input": "enroll Alice\ngrade Alice -5.0", "expected_output": "Enrolled Alice.\nInvalid grade.", "description": "Negative grade is invalid"},
  {"input": "enroll Alice\nenroll Bob\ngrade Alice 85.0\ngrade Alice 95.0\ngrade Bob 70.0\ntop", "expected_output": "Enrolled Alice.\nEnrolled Bob.\nGrade 85.0 added for Alice.\nGrade 95.0 added for Alice.\nGrade 70.0 added for Bob.\nTop student: Alice (90.00)", "description": "Top student is highest average"},
  {"input": "enroll Alice\nenroll Alice", "expected_output": "Enrolled Alice.\nAlice already enrolled.", "description": "Duplicate enroll rejected"},
  {"input": "top", "expected_output": "No grades recorded.", "description": "Top student with no grades"}
]$TC$::jsonb,

NULL,

$SC${"python": "class Student:\n    def __init__(self, name: str):\n        pass\n\nclass GradeBook:\n    def __init__(self):\n        pass\n\n    def enroll(self, name: str) -> str:\n        pass\n\n    def add_grade(self, name: str, grade: float) -> str:\n        pass\n\n    def average(self, name: str) -> str:\n        pass\n\n    def top_student(self) -> str:\n        pass",
  "java": "import java.util.*;\nclass Student {\n    String name; List<Double> grades = new ArrayList<>();\n    Student(String name) { this.name = name; }\n}\nclass GradeBook {\n    private LinkedHashMap<String,Student> students = new LinkedHashMap<>();\n    public String enroll(String name) {\n        if (students.containsKey(name)) return name+\" already enrolled.\";\n        students.put(name, new Student(name));\n        return \"Enrolled \"+name+\".\";\n    }\n    public String add_grade(String name, double grade) {\n        if (!students.containsKey(name)) return \"Student \"+name+\" not found.\";\n        if (grade < 0 || grade > 100) return \"Invalid grade.\";\n        students.get(name).grades.add(grade);\n        return String.format(\"Grade %.1f added for %s.\", grade, name);\n    }\n    public String average(String name) {\n        if (!students.containsKey(name)) return \"Student \"+name+\" not found.\";\n        List<Double> g = students.get(name).grades;\n        if (g.isEmpty()) return \"No grades for \"+name+\".\";\n        return String.format(\"Average for %s: %.2f\", name, g.stream().mapToDouble(d->d).average().getAsDouble());\n    }\n    public String top_student() {\n        String best=null; double bestAvg=-1;\n        for (Student s: students.values()) {\n            if (s.grades.isEmpty()) continue;\n            double avg=s.grades.stream().mapToDouble(d->d).average().getAsDouble();\n            if (best==null||avg>bestAvg){best=s.name;bestAvg=avg;}\n        }\n        if (best==null) return \"No grades recorded.\";\n        return String.format(\"Top student: %s (%.2f)\", best, bestAvg);\n    }\n}",
  "typescript": "class Student {\n    name: string; grades: number[] = [];\n    constructor(name: string) { this.name = name; }\n}\nclass GradeBook {\n    private students = new Map<string, Student>();\n    private order: string[] = [];\n    enroll(name: string): string {\n        if (this.students.has(name)) return `${name} already enrolled.`;\n        this.students.set(name, new Student(name));\n        this.order.push(name);\n        return `Enrolled ${name}.`;\n    }\n    add_grade(name: string, grade: number): string {\n        if (!this.students.has(name)) return `Student ${name} not found.`;\n        if (grade < 0 || grade > 100) return 'Invalid grade.';\n        this.students.get(name)!.grades.push(grade);\n        return `Grade ${grade.toFixed(1)} added for ${name}.`;\n    }\n    average(name: string): string {\n        if (!this.students.has(name)) return `Student ${name} not found.`;\n        const g = this.students.get(name)!.grades;\n        if (g.length === 0) return `No grades for ${name}.`;\n        const avg = g.reduce((a,b)=>a+b,0)/g.length;\n        return `Average for ${name}: ${avg.toFixed(2)}`;\n    }\n    top_student(): string {\n        let best='', bestAvg=-1;\n        for (const name of this.order) {\n            const g = this.students.get(name)!.grades;\n            if (!g.length) continue;\n            const avg = g.reduce((a,b)=>a+b,0)/g.length;\n            if (bestAvg < 0 || avg > bestAvg) { best=name; bestAvg=avg; }\n        }\n        if (!best) return 'No grades recorded.';\n        return `Top student: ${best} (${bestAvg.toFixed(2)})`;\n    }\n}",
  "cpp": "#include <string>\n#include <vector>\n#include <map>\n#include <sstream>\n#include <iomanip>\nusing namespace std;\nstruct Student { string name; vector<double> grades; };\nclass GradeBook {\n    vector<string> order;\n    map<string,Student> students;\npublic:\n    string enroll(string name){\n        if(students.count(name)) return name+\" already enrolled.\";\n        students[name]={name,{}};\n        order.push_back(name);\n        return \"Enrolled \"+name+\".\";\n    }\n    string add_grade(string name,double grade){\n        if(!students.count(name)) return \"Student \"+name+\" not found.\";\n        if(grade<0||grade>100) return \"Invalid grade.\";\n        students[name].grades.push_back(grade);\n        ostringstream os; os<<fixed<<setprecision(1)<<grade;\n        return \"Grade \"+os.str()+\" added for \"+name+\".\";\n    }\n    string average(string name){\n        if(!students.count(name)) return \"Student \"+name+\" not found.\";\n        auto& g=students[name].grades;\n        if(g.empty()) return \"No grades for \"+name+\".\";\n        double s=0; for(auto v:g)s+=v;\n        ostringstream os; os<<fixed<<setprecision(2)<<s/g.size();\n        return \"Average for \"+name+\": \"+os.str();\n    }\n    string top_student(){\n        string best; double bestAvg=-1;\n        for(auto& n:order){\n            auto& g=students[n].grades;\n            if(g.empty()) continue;\n            double s=0; for(auto v:g)s+=v;\n            double avg=s/g.size();\n            if(best.empty()||avg>bestAvg){best=n;bestAvg=avg;}\n        }\n        if(best.empty()) return \"No grades recorded.\";\n        ostringstream os; os<<fixed<<setprecision(2)<<bestAvg;\n        return \"Top student: \"+best+\" (\"+os.str()+\")\";\n    }\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\ngb = GradeBook()\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"enroll\": print(gb.enroll(parts[1]))\n    elif cmd == \"grade\": print(gb.add_grade(parts[1], float(parts[2])))\n    elif cmd == \"average\": print(gb.average(parts[1]))\n    elif cmd == \"top\": print(gb.top_student())",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        GradeBook gb = new GradeBook();\n        while (sc.hasNextLine()) {\n            String line = sc.nextLine().trim();\n            if (line.isEmpty()) continue;\n            String[] p = line.split(\" \");\n            String cmd = p[0];\n            if (cmd.equals(\"enroll\")) System.out.println(gb.enroll(p[1]));\n            else if (cmd.equals(\"grade\")) System.out.println(gb.add_grade(p[1], Double.parseDouble(p[2])));\n            else if (cmd.equals(\"average\")) System.out.println(gb.average(p[1]));\n            else if (cmd.equals(\"top\")) System.out.println(gb.top_student());\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl = readline.createInterface({ input: process.stdin });\nconst gb = new GradeBook();\nrl.on('line', (line) => {\n    line = line.trim(); if (!line) return;\n    const p = line.split(' ');\n    const cmd = p[0];\n    if (cmd === 'enroll') console.log(gb.enroll(p[1]));\n    else if (cmd === 'grade') console.log(gb.add_grade(p[1], parseFloat(p[2])));\n    else if (cmd === 'average') console.log(gb.average(p[1]));\n    else if (cmd === 'top') console.log(gb.top_student());\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main() {\n    string line; GradeBook gb;\n    while (getline(cin, line)) {\n        if (line.empty()) continue;\n        istringstream ss(line); string cmd; ss >> cmd;\n        if (cmd == \"enroll\") { string n; ss>>n; cout<<gb.enroll(n)<<\"\\n\"; }\n        else if (cmd == \"grade\") { string n; double g; ss>>n>>g; cout<<gb.add_grade(n,g)<<\"\\n\"; }\n        else if (cmd == \"average\") { string n; ss>>n; cout<<gb.average(n)<<\"\\n\"; }\n        else if (cmd == \"top\") { cout<<gb.top_student()<<\"\\n\"; }\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- oop_n05 -------------------------------------------------------
(
'oop_n05',
'Vehicle Fleet',
'OOP', 'Medium', 'python', 'Python / OOP',
$$Model a vehicle fleet with polymorphic fuel cost calculations.

**Requirements:**
- `Vehicle(make, model, year)` — base class; `info() -> str` returns `"{year} {make} {model}"`
- `Car(make, model, year, mpg)` — `fuel_cost(miles, price_per_gallon) -> str`: `"Fuel cost for {miles:.1f} miles: ${cost:.2f}"`; cost = miles / mpg * price
- `Truck(make, model, year, payload_tons, mpg)` — same `fuel_cost`; adds `max_payload() -> str`: `"Max payload: {payload_tons:.1f} tons"`
- `ElectricCar(make, model, year, range_miles)` — `fuel_cost(miles, price_per_kwh)`: cost = miles / 4.0 * price_per_kwh (4 miles/kWh)

**Constraints:**
- All subclasses call the parent constructor$$,

$$class Vehicle:
    def __init__(self, make: str, model: str, year: int):
        pass

    def info(self) -> str:
        pass

class Car(Vehicle):
    def __init__(self, make: str, model: str, year: int, mpg: float):
        pass

    def fuel_cost(self, miles: float, price_per_gallon: float) -> str:
        pass

class Truck(Vehicle):
    def __init__(self, make: str, model: str, year: int, payload_tons: float, mpg: float):
        pass

    def fuel_cost(self, miles: float, price_per_gallon: float) -> str:
        pass

    def max_payload(self) -> str:
        pass

class ElectricCar(Vehicle):
    def __init__(self, make: str, model: str, year: int, range_miles: float):
        pass

    def fuel_cost(self, miles: float, price_per_kwh: float) -> str:
        pass$$,

$TC$[
  {"input": "car Toyota Camry 2020 30.0\ninfo Camry", "expected_output": "2020 Toyota Camry", "description": "Vehicle info"},
  {"input": "car Honda Civic 2019 35.0\ncost Civic 350.0 3.50", "expected_output": "Fuel cost for 350.0 miles: $35.00", "description": "Car fuel cost"},
  {"input": "truck Ford F150 2021 2.5 20.0\ncost F150 200.0 4.00", "expected_output": "Fuel cost for 200.0 miles: $40.00", "description": "Truck fuel cost"},
  {"input": "truck Ford F150 2021 2.5 20.0\npayload F150", "expected_output": "Max payload: 2.5 tons", "description": "Truck max payload"},
  {"input": "electric Tesla Model3 2022 358.0\ncost Model3 100.0 0.12", "expected_output": "Fuel cost for 100.0 miles: $3.00", "description": "Electric car fuel cost"},
  {"input": "electric Tesla ModelS 2023 405.0\ninfo ModelS", "expected_output": "2023 Tesla ModelS", "description": "Electric car info"}
]$TC$::jsonb,

NULL,

$SC${"python": "class Vehicle:\n    def __init__(self, make: str, model: str, year: int):\n        pass\n    def info(self) -> str:\n        pass\nclass Car(Vehicle):\n    def __init__(self, make: str, model: str, year: int, mpg: float):\n        pass\n    def fuel_cost(self, miles: float, price_per_gallon: float) -> str:\n        pass\nclass Truck(Vehicle):\n    def __init__(self, make: str, model: str, year: int, payload_tons: float, mpg: float):\n        pass\n    def fuel_cost(self, miles: float, price_per_gallon: float) -> str:\n        pass\n    def max_payload(self) -> str:\n        pass\nclass ElectricCar(Vehicle):\n    def __init__(self, make: str, model: str, year: int, range_miles: float):\n        pass\n    def fuel_cost(self, miles: float, price_per_kwh: float) -> str:\n        pass",
  "java": "class Vehicle {\n    protected String make,model; protected int year;\n    Vehicle(String make,String model,int year){this.make=make;this.model=model;this.year=year;}\n    public String info(){return year+\" \"+make+\" \"+model;}\n}\nclass Car extends Vehicle {\n    protected double mpg;\n    Car(String make,String model,int year,double mpg){super(make,model,year);this.mpg=mpg;}\n    public String fuel_cost(double miles,double price){\n        return String.format(\"Fuel cost for %.1f miles: $%.2f\",miles,miles/mpg*price);\n    }\n}\nclass Truck extends Vehicle {\n    private double payload,mpg;\n    Truck(String make,String model,int year,double payload,double mpg){super(make,model,year);this.payload=payload;this.mpg=mpg;}\n    public String fuel_cost(double miles,double price){\n        return String.format(\"Fuel cost for %.1f miles: $%.2f\",miles,miles/mpg*price);\n    }\n    public String max_payload(){return String.format(\"Max payload: %.1f tons\",payload);}\n}\nclass ElectricCar extends Vehicle {\n    ElectricCar(String make,String model,int year,double range){super(make,model,year);}\n    public String fuel_cost(double miles,double price){\n        return String.format(\"Fuel cost for %.1f miles: $%.2f\",miles,miles/4.0*price);\n    }\n}",
  "typescript": "class Vehicle {\n    constructor(protected make:string,protected model:string,protected year:number){}\n    info():string{return `${this.year} ${this.make} ${this.model}`;}\n}\nclass Car extends Vehicle {\n    constructor(make:string,model:string,year:number,private mpg:number){super(make,model,year);}\n    fuel_cost(miles:number,price:number):string{\n        return `Fuel cost for ${miles.toFixed(1)} miles: $${(miles/this.mpg*price).toFixed(2)}`;\n    }\n}\nclass Truck extends Vehicle {\n    constructor(make:string,model:string,year:number,private payload:number,private mpg:number){super(make,model,year);}\n    fuel_cost(miles:number,price:number):string{\n        return `Fuel cost for ${miles.toFixed(1)} miles: $${(miles/this.mpg*price).toFixed(2)}`;\n    }\n    max_payload():string{return `Max payload: ${this.payload.toFixed(1)} tons`;}\n}\nclass ElectricCar extends Vehicle {\n    constructor(make:string,model:string,year:number,private range:number){super(make,model,year);}\n    fuel_cost(miles:number,price:number):string{\n        return `Fuel cost for ${miles.toFixed(1)} miles: $${(miles/4.0*price).toFixed(2)}`;\n    }\n}",
  "cpp": "#include <string>\n#include <sstream>\n#include <iomanip>\nusing namespace std;\nclass Vehicle {\nprotected: string make,model; int year;\npublic:\n    Vehicle(string make,string model,int year):make(make),model(model),year(year){}\n    virtual string info(){return to_string(year)+\" \"+make+\" \"+model;}\n};\nclass Car:public Vehicle{\n    double mpg;\npublic:\n    Car(string make,string model,int year,double mpg):Vehicle(make,model,year),mpg(mpg){}\n    string fuel_cost(double miles,double price){\n        ostringstream os; os<<fixed<<setprecision(1)<<miles;\n        ostringstream os2; os2<<fixed<<setprecision(2)<<miles/mpg*price;\n        return \"Fuel cost for \"+os.str()+\" miles: $\"+os2.str();\n    }\n};\nclass Truck:public Vehicle{\n    double payload,mpg;\npublic:\n    Truck(string make,string model,int year,double payload,double mpg):Vehicle(make,model,year),payload(payload),mpg(mpg){}\n    string fuel_cost(double miles,double price){\n        ostringstream os; os<<fixed<<setprecision(1)<<miles;\n        ostringstream os2; os2<<fixed<<setprecision(2)<<miles/mpg*price;\n        return \"Fuel cost for \"+os.str()+\" miles: $\"+os2.str();\n    }\n    string max_payload(){\n        ostringstream os; os<<fixed<<setprecision(1)<<payload;\n        return \"Max payload: \"+os.str()+\" tons\";\n    }\n};\nclass ElectricCar:public Vehicle{\npublic:\n    ElectricCar(string make,string model,int year,double range):Vehicle(make,model,year){}\n    string fuel_cost(double miles,double price){\n        ostringstream os; os<<fixed<<setprecision(1)<<miles;\n        ostringstream os2; os2<<fixed<<setprecision(2)<<miles/4.0*price;\n        return \"Fuel cost for \"+os.str()+\" miles: $\"+os2.str();\n    }\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\nfleet = {}\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"car\": fleet[parts[2]] = Car(parts[1],parts[2],int(parts[3]),float(parts[4]))\n    elif cmd == \"truck\": fleet[parts[2]] = Truck(parts[1],parts[2],int(parts[3]),float(parts[4]),float(parts[5]))\n    elif cmd == \"electric\": fleet[parts[2]] = ElectricCar(parts[1],parts[2],int(parts[3]),float(parts[4]))\n    elif cmd == \"info\": print(fleet[parts[1]].info())\n    elif cmd == \"cost\": print(fleet[parts[1]].fuel_cost(float(parts[2]),float(parts[3])))\n    elif cmd == \"payload\": print(fleet[parts[1]].max_payload())",
  "java": "import java.util.Scanner;\nimport java.util.HashMap;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        HashMap<String,Vehicle> fleet = new HashMap<>();\n        while (sc.hasNextLine()) {\n            String line = sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p = line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"car\")) fleet.put(p[2],new Car(p[1],p[2],Integer.parseInt(p[3]),Double.parseDouble(p[4])));\n            else if(cmd.equals(\"truck\")) fleet.put(p[2],new Truck(p[1],p[2],Integer.parseInt(p[3]),Double.parseDouble(p[4]),Double.parseDouble(p[5])));\n            else if(cmd.equals(\"electric\")) fleet.put(p[2],new ElectricCar(p[1],p[2],Integer.parseInt(p[3]),Double.parseDouble(p[4])));\n            else if(cmd.equals(\"info\")) System.out.println(fleet.get(p[1]).info());\n            else if(cmd.equals(\"cost\")) {\n                Vehicle v=fleet.get(p[1]);\n                double miles=Double.parseDouble(p[2]),price=Double.parseDouble(p[3]);\n                if(v instanceof Car) System.out.println(((Car)v).fuel_cost(miles,price));\n                else if(v instanceof Truck) System.out.println(((Truck)v).fuel_cost(miles,price));\n                else if(v instanceof ElectricCar) System.out.println(((ElectricCar)v).fuel_cost(miles,price));\n            } else if(cmd.equals(\"payload\")) System.out.println(((Truck)fleet.get(p[1])).max_payload());\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl = readline.createInterface({ input: process.stdin });\nconst fleet: Record<string,any> = {};\nrl.on('line', (line) => {\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='car') fleet[p[2]]=new Car(p[1],p[2],parseInt(p[3]),parseFloat(p[4]));\n    else if(cmd==='truck') fleet[p[2]]=new Truck(p[1],p[2],parseInt(p[3]),parseFloat(p[4]),parseFloat(p[5]));\n    else if(cmd==='electric') fleet[p[2]]=new ElectricCar(p[1],p[2],parseInt(p[3]),parseFloat(p[4]));\n    else if(cmd==='info') console.log(fleet[p[1]].info());\n    else if(cmd==='cost') console.log(fleet[p[1]].fuel_cost(parseFloat(p[2]),parseFloat(p[3])));\n    else if(cmd==='payload') console.log(fleet[p[1]].max_payload());\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\n#include <map>\nusing namespace std;\nint main() {\n    string line; map<string,Vehicle*> fleet;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"car\"){string make,model;int year;double mpg;ss>>make>>model>>year>>mpg;fleet[model]=new Car(make,model,year,mpg);}\n        else if(cmd==\"truck\"){string make,model;int year;double p,mpg;ss>>make>>model>>year>>p>>mpg;fleet[model]=new Truck(make,model,year,p,mpg);}\n        else if(cmd==\"electric\"){string make,model;int year;double r;ss>>make>>model>>year>>r;fleet[model]=new ElectricCar(make,model,year,r);}\n        else if(cmd==\"info\"){string n;ss>>n;cout<<fleet[n]->info()<<\"\\n\";}\n        else if(cmd==\"cost\"){string n;double mi,pr;ss>>n>>mi>>pr;\n            if(auto*c=dynamic_cast<Car*>(fleet[n])) cout<<c->fuel_cost(mi,pr)<<\"\\n\";\n            else if(auto*t=dynamic_cast<Truck*>(fleet[n])) cout<<t->fuel_cost(mi,pr)<<\"\\n\";\n            else if(auto*e=dynamic_cast<ElectricCar*>(fleet[n])) cout<<e->fuel_cost(mi,pr)<<\"\\n\";}\n        else if(cmd==\"payload\"){string n;ss>>n;cout<<((Truck*)fleet[n])->max_payload()<<\"\\n\";}\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- oop_n06 -------------------------------------------------------
(
'oop_n06',
'Hospital Patient Records',
'OOP', 'Hard', 'python', 'Python / OOP',
$$Build an encapsulated patient record system with access control.

**Requirements:**
- `Patient(patient_id, name, age)` — `add_record(note)`, `get_records() -> list` (copy), `info() -> str`: `"ID:{id} Name:{name} Age:{age}"`
- `Doctor(name, specialty)` — `treat(patient, note) -> str`: `"Dr. {name} treated {patient_name}: {note}"`
- `Hospital`:
  - `admit(patient_id, name, age) -> str` — `"Patient {id} admitted."` / `"Patient {id} already admitted."`
  - `discharge(patient_id) -> str` — `"Patient {id} discharged."` / `"Patient {id} not found."`
  - `add_doctor(name, specialty)` — silent registration
  - `treat(doctor_name, patient_id, note) -> str` — delegates; errors: `"Doctor {name} not found."` / `"Patient {id} not found."`
  - `history(patient_id) -> str` — numbered records `"1. {r}\n2. {r}..."`, `"No records."`, or `"Patient {id} not found."`

**Constraints:**
- `get_records()` returns a copy; patient dict stored as `_patients`$$,

$$class Patient:
    def __init__(self, patient_id: int, name: str, age: int):
        pass

    def add_record(self, record: str):
        pass

    def get_records(self) -> list:
        pass

    def info(self) -> str:
        pass

class Doctor:
    def __init__(self, name: str, specialty: str):
        pass

    def treat(self, patient, note: str) -> str:
        pass

class Hospital:
    def __init__(self):
        self._patients = {}
        self._doctors = {}

    def admit(self, patient_id: int, name: str, age: int) -> str:
        pass

    def discharge(self, patient_id: int) -> str:
        pass

    def add_doctor(self, name: str, specialty: str):
        pass

    def treat(self, doctor_name: str, patient_id: int, note: str) -> str:
        pass

    def history(self, patient_id: int) -> str:
        pass$$,

$TC$[
  {"input": "admit 1 Alice 30\ninfo 1", "expected_output": "Patient 1 admitted.\nID:1 Name:Alice Age:30", "description": "Admit and retrieve patient info"},
  {"input": "admit 1 Alice 30\nadmit 1 Alice 30", "expected_output": "Patient 1 admitted.\nPatient 1 already admitted.", "description": "Duplicate admission rejected"},
  {"input": "discharge 99", "expected_output": "Patient 99 not found.", "description": "Discharge unknown patient"},
  {"input": "admit 1 Alice 30\ndoctor Smith Cardiology\ntreat Smith 1 CheckedHeartRate\nhistory 1", "expected_output": "Patient 1 admitted.\nDr. Smith treated Alice: CheckedHeartRate\n1. CheckedHeartRate", "description": "Doctor treats patient, history recorded"},
  {"input": "admit 1 Bob 45\ntreat Ghost 1 Note", "expected_output": "Patient 1 admitted.\nDoctor Ghost not found.", "description": "Unknown doctor returns error"},
  {"input": "admit 1 Carol 25\ndoctor Jones Ortho\ntreat Jones 99 Note", "expected_output": "Patient 1 admitted.\nPatient 99 not found.", "description": "Treating unknown patient returns error"},
  {"input": "history 5", "expected_output": "Patient 5 not found.", "description": "History of unknown patient"},
  {"input": "admit 1 Dave 60\nhistory 1", "expected_output": "Patient 1 admitted.\nNo records.", "description": "History with no treatments"}
]$TC$::jsonb,

NULL,

$SC${"python": "class Patient:\n    def __init__(self, patient_id: int, name: str, age: int):\n        pass\n    def add_record(self, record: str): pass\n    def get_records(self) -> list: pass\n    def info(self) -> str: pass\nclass Doctor:\n    def __init__(self, name: str, specialty: str): pass\n    def treat(self, patient, note: str) -> str: pass\nclass Hospital:\n    def __init__(self):\n        self._patients = {}\n        self._doctors = {}\n    def admit(self, patient_id: int, name: str, age: int) -> str: pass\n    def discharge(self, patient_id: int) -> str: pass\n    def add_doctor(self, name: str, specialty: str): pass\n    def treat(self, doctor_name: str, patient_id: int, note: str) -> str: pass\n    def history(self, patient_id: int) -> str: pass",
  "java": "import java.util.*;\nclass Patient {\n    int id; String name; int age; List<String> records=new ArrayList<>();\n    Patient(int id,String name,int age){this.id=id;this.name=name;this.age=age;}\n    void addRecord(String r){records.add(r);}\n    List<String> getRecords(){return new ArrayList<>(records);}\n    String info(){return \"ID:\"+id+\" Name:\"+name+\" Age:\"+age;}\n}\nclass Doctor {\n    String name,specialty;\n    Doctor(String name,String specialty){this.name=name;this.specialty=specialty;}\n    String treat(Patient p,String note){p.addRecord(note);return \"Dr. \"+name+\" treated \"+p.name+\": \"+note;}\n}\nclass Hospital {\n    Map<Integer,Patient> patients=new LinkedHashMap<>();\n    Map<String,Doctor> doctors=new HashMap<>();\n    String admit(int id,String name,int age){\n        if(patients.containsKey(id)) return \"Patient \"+id+\" already admitted.\";\n        patients.put(id,new Patient(id,name,age)); return \"Patient \"+id+\" admitted.\";\n    }\n    String discharge(int id){\n        if(!patients.containsKey(id)) return \"Patient \"+id+\" not found.\";\n        patients.remove(id); return \"Patient \"+id+\" discharged.\";\n    }\n    void addDoctor(String name,String spec){doctors.put(name,new Doctor(name,spec));}\n    String treat(String docName,int pid,String note){\n        if(!doctors.containsKey(docName)) return \"Doctor \"+docName+\" not found.\";\n        if(!patients.containsKey(pid)) return \"Patient \"+pid+\" not found.\";\n        return doctors.get(docName).treat(patients.get(pid),note);\n    }\n    String history(int pid){\n        if(!patients.containsKey(pid)) return \"Patient \"+pid+\" not found.\";\n        List<String> r=patients.get(pid).getRecords();\n        if(r.isEmpty()) return \"No records.\";\n        StringBuilder sb=new StringBuilder();\n        for(int i=0;i<r.size();i++){if(i>0)sb.append(\"\\n\");sb.append((i+1)+\". \"+r.get(i));}\n        return sb.toString();\n    }\n}",
  "typescript": "class Patient {\n    records: string[] = [];\n    constructor(public id:number,public name:string,public age:number){}\n    addRecord(r:string){this.records.push(r);}\n    getRecords(){return [...this.records];}\n    info(){return `ID:${this.id} Name:${this.name} Age:${this.age}`;}\n}\nclass Doctor {\n    constructor(public name:string,public specialty:string){}\n    treat(p:Patient,note:string):string{p.addRecord(note);return `Dr. ${this.name} treated ${p.name}: ${note}`;}\n}\nclass Hospital {\n    _patients=new Map<number,Patient>();\n    _doctors=new Map<string,Doctor>();\n    admit(id:number,name:string,age:number):string{\n        if(this._patients.has(id)) return `Patient ${id} already admitted.`;\n        this._patients.set(id,new Patient(id,name,age)); return `Patient ${id} admitted.`;\n    }\n    discharge(id:number):string{\n        if(!this._patients.has(id)) return `Patient ${id} not found.`;\n        this._patients.delete(id); return `Patient ${id} discharged.`;\n    }\n    addDoctor(name:string,spec:string){this._doctors.set(name,new Doctor(name,spec));}\n    treat(docName:string,pid:number,note:string):string{\n        if(!this._doctors.has(docName)) return `Doctor ${docName} not found.`;\n        if(!this._patients.has(pid)) return `Patient ${pid} not found.`;\n        return this._doctors.get(docName)!.treat(this._patients.get(pid)!,note);\n    }\n    history(pid:number):string{\n        if(!this._patients.has(pid)) return `Patient ${pid} not found.`;\n        const r=this._patients.get(pid)!.getRecords();\n        if(!r.length) return 'No records.';\n        return r.map((v,i)=>`${i+1}. ${v}`).join('\\n');\n    }\n}",
  "cpp": "#include <string>\n#include <vector>\n#include <map>\n#include <sstream>\nusing namespace std;\nstruct Patient{\n    int id,age; string name; vector<string> records;\n    Patient(int id,string name,int age):id(id),name(name),age(age){}\n    void addRecord(string r){records.push_back(r);}\n    string info(){return \"ID:\"+to_string(id)+\" Name:\"+name+\" Age:\"+to_string(age);}\n};\nstruct Doctor{\n    string name,specialty;\n    Doctor(string n,string s):name(n),specialty(s){}\n    string treat(Patient& p,string note){p.addRecord(note);return \"Dr. \"+name+\" treated \"+p.name+\": \"+note;}\n};\nclass Hospital{\n    map<int,Patient> patients; map<string,Doctor> doctors;\npublic:\n    string admit(int id,string name,int age){\n        if(patients.count(id)) return \"Patient \"+to_string(id)+\" already admitted.\";\n        patients.emplace(id,Patient(id,name,age)); return \"Patient \"+to_string(id)+\" admitted.\";\n    }\n    string discharge(int id){\n        if(!patients.count(id)) return \"Patient \"+to_string(id)+\" not found.\";\n        patients.erase(id); return \"Patient \"+to_string(id)+\" discharged.\";\n    }\n    void addDoctor(string n,string s){doctors.emplace(n,Doctor(n,s));}\n    string treat(string doc,int pid,string note){\n        if(!doctors.count(doc)) return \"Doctor \"+doc+\" not found.\";\n        if(!patients.count(pid)) return \"Patient \"+to_string(pid)+\" not found.\";\n        return doctors.at(doc).treat(patients.at(pid),note);\n    }\n    string history(int pid){\n        if(!patients.count(pid)) return \"Patient \"+to_string(pid)+\" not found.\";\n        auto& r=patients.at(pid).records;\n        if(r.empty()) return \"No records.\";\n        string out;\n        for(int i=0;i<(int)r.size();i++){if(i)out+=\"\\n\";out+=to_string(i+1)+\". \"+r[i];}\n        return out;\n    }\n    Patient* getPatient(int id){return patients.count(id)?&patients.at(id):nullptr;}\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\nhospital = Hospital()\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"admit\": print(hospital.admit(int(parts[1]),parts[2],int(parts[3])))\n    elif cmd == \"discharge\": print(hospital.discharge(int(parts[1])))\n    elif cmd == \"doctor\": hospital.add_doctor(parts[1],parts[2])\n    elif cmd == \"treat\": print(hospital.treat(parts[1],int(parts[2]),parts[3]))\n    elif cmd == \"history\": print(hospital.history(int(parts[1])))\n    elif cmd == \"info\":\n        pid=int(parts[1]); p=hospital._patients.get(pid)\n        print(p.info() if p else f\"Patient {pid} not found.\")",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in);\n        Hospital h=new Hospital();\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"admit\")) System.out.println(h.admit(Integer.parseInt(p[1]),p[2],Integer.parseInt(p[3])));\n            else if(cmd.equals(\"discharge\")) System.out.println(h.discharge(Integer.parseInt(p[1])));\n            else if(cmd.equals(\"doctor\")) h.addDoctor(p[1],p[2]);\n            else if(cmd.equals(\"treat\")) System.out.println(h.treat(p[1],Integer.parseInt(p[2]),p[3]));\n            else if(cmd.equals(\"history\")) System.out.println(h.history(Integer.parseInt(p[1])));\n            else if(cmd.equals(\"info\")){\n                int pid=Integer.parseInt(p[1]);\n                Patient pt=h.patients.get(pid);\n                System.out.println(pt!=null?pt.info():\"Patient \"+pid+\" not found.\");\n            }\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nconst h=new Hospital();\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='admit') console.log(h.admit(parseInt(p[1]),p[2],parseInt(p[3])));\n    else if(cmd==='discharge') console.log(h.discharge(parseInt(p[1])));\n    else if(cmd==='doctor') h.addDoctor(p[1],p[2]);\n    else if(cmd==='treat') console.log(h.treat(p[1],parseInt(p[2]),p[3]));\n    else if(cmd==='history') console.log(h.history(parseInt(p[1])));\n    else if(cmd==='info'){\n        const pid=parseInt(p[1]); const pt=h._patients.get(pid);\n        console.log(pt?pt.info():`Patient ${pid} not found.`);\n    }\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main(){\n    string line; Hospital h;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"admit\"){int id,age;string name;ss>>id>>name>>age;cout<<h.admit(id,name,age)<<\"\\n\";}\n        else if(cmd==\"discharge\"){int id;ss>>id;cout<<h.discharge(id)<<\"\\n\";}\n        else if(cmd==\"doctor\"){string n,s;ss>>n>>s;h.addDoctor(n,s);}\n        else if(cmd==\"treat\"){string doc,note;int pid;ss>>doc>>pid>>note;cout<<h.treat(doc,pid,note)<<\"\\n\";}\n        else if(cmd==\"history\"){int id;ss>>id;cout<<h.history(id)<<\"\\n\";}\n        else if(cmd==\"info\"){int id;ss>>id;Patient* p=h.getPatient(id);cout<<(p?p->info():\"Patient \"+to_string(id)+\" not found.\")<<\"\\n\";}\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- oop_n07 -------------------------------------------------------
(
'oop_n07',
'Inventory Management System',
'OOP', 'Hard', 'python', 'Python / OOP',
$$Design an inventory system that tracks products, quantities, and low-stock alerts.

**Requirements:**
- `Product(sku, name, price, quantity)`
- `Inventory`:
  - `add_product(sku, name, price, quantity) -> str` — `"Added {name} (SKU:{sku})."` / `"SKU {sku} already exists."`
  - `restock(sku, qty) -> str` — `"Restocked {sku}: +{qty} units. Total: {total}."` / `"SKU {sku} not found."`
  - `sell(sku, qty) -> str` — `"Sold {qty} x {name}. Remaining: {remaining}."` / `"Insufficient stock."` / `"SKU {sku} not found."`
  - `low_stock(threshold) -> str` — lines `"{sku}: {qty} units"` sorted by qty asc then sku; `"All stocked."` if none
  - `total_value() -> str` — `"Total inventory value: ${value:.2f}"`

**Constraints:**
- Quantity never goes negative; SKU is the unique key$$,

$$class Product:
    def __init__(self, sku: str, name: str, price: float, quantity: int):
        pass

class Inventory:
    def __init__(self):
        pass

    def add_product(self, sku: str, name: str, price: float, quantity: int) -> str:
        pass

    def restock(self, sku: str, qty: int) -> str:
        pass

    def sell(self, sku: str, qty: int) -> str:
        pass

    def low_stock(self, threshold: int) -> str:
        pass

    def total_value(self) -> str:
        pass$$,

$TC$[
  {"input": "add A001 Widget 2.50 100\nvalue", "expected_output": "Added Widget (SKU:A001).\nTotal inventory value: $250.00", "description": "Add product and compute total value"},
  {"input": "add A001 Widget 2.50 100\nadd A001 Gadget 5.00 50", "expected_output": "Added Widget (SKU:A001).\nSKU A001 already exists.", "description": "Duplicate SKU rejected"},
  {"input": "add A001 Widget 2.50 10\nsell A001 3", "expected_output": "Added Widget (SKU:A001).\nSold 3 x Widget. Remaining: 7.", "description": "Selling reduces quantity"},
  {"input": "add A001 Widget 2.50 5\nsell A001 10", "expected_output": "Added Widget (SKU:A001).\nInsufficient stock.", "description": "Cannot sell more than in stock"},
  {"input": "add A001 Widget 2.50 5\nrestock A001 20", "expected_output": "Added Widget (SKU:A001).\nRestocked A001: +20 units. Total: 25.", "description": "Restock increases quantity"},
  {"input": "add A001 Widget 2.50 3\nadd B002 Gadget 5.00 8\nlow 5", "expected_output": "Added Widget (SKU:A001).\nAdded Gadget (SKU:B002).\nA001: 3 units", "description": "Low stock shows items at or below threshold"},
  {"input": "add A001 Widget 2.50 100\nadd B002 Gadget 5.00 200\nlow 50", "expected_output": "Added Widget (SKU:A001).\nAdded Gadget (SKU:B002).\nAll stocked.", "description": "All stocked"},
  {"input": "sell X999 1", "expected_output": "SKU X999 not found.", "description": "Selling unknown SKU"}
]$TC$::jsonb,

NULL,

$SC${"python": "class Product:\n    def __init__(self, sku: str, name: str, price: float, quantity: int):\n        pass\nclass Inventory:\n    def __init__(self): pass\n    def add_product(self, sku, name, price, quantity) -> str: pass\n    def restock(self, sku, qty) -> str: pass\n    def sell(self, sku, qty) -> str: pass\n    def low_stock(self, threshold) -> str: pass\n    def total_value(self) -> str: pass",
  "java": "import java.util.*;\nclass Product{String sku,name;double price;int qty;Product(String sku,String name,double price,int qty){this.sku=sku;this.name=name;this.price=price;this.qty=qty;}}\nclass Inventory{\n    LinkedHashMap<String,Product> products=new LinkedHashMap<>();\n    String add_product(String sku,String name,double price,int qty){\n        if(products.containsKey(sku)) return \"SKU \"+sku+\" already exists.\";\n        products.put(sku,new Product(sku,name,price,qty)); return \"Added \"+name+\" (SKU:\"+sku+\").\";\n    }\n    String restock(String sku,int qty){\n        if(!products.containsKey(sku)) return \"SKU \"+sku+\" not found.\";\n        products.get(sku).qty+=qty; return \"Restocked \"+sku+\": +\"+qty+\" units. Total: \"+products.get(sku).qty+\".\";\n    }\n    String sell(String sku,int qty){\n        if(!products.containsKey(sku)) return \"SKU \"+sku+\" not found.\";\n        Product p=products.get(sku);\n        if(p.qty<qty) return \"Insufficient stock.\";\n        p.qty-=qty; return \"Sold \"+qty+\" x \"+p.name+\". Remaining: \"+p.qty+\".\";\n    }\n    String low_stock(int threshold){\n        List<Product> low=new ArrayList<>();\n        for(Product p:products.values()) if(p.qty<=threshold) low.add(p);\n        if(low.isEmpty()) return \"All stocked.\";\n        low.sort((a,b)->a.qty!=b.qty?a.qty-b.qty:a.sku.compareTo(b.sku));\n        StringBuilder sb=new StringBuilder();\n        for(Product p:low){if(sb.length()>0)sb.append(\"\\n\");sb.append(p.sku+\": \"+p.qty+\" units\");}\n        return sb.toString();\n    }\n    String total_value(){\n        double v=0; for(Product p:products.values()) v+=p.price*p.qty;\n        return String.format(\"Total inventory value: $%.2f\",v);\n    }\n}",
  "typescript": "class Product{constructor(public sku:string,public name:string,public price:number,public qty:number){}}\nclass Inventory{\n    private products=new Map<string,Product>();\n    add_product(sku:string,name:string,price:number,qty:number):string{\n        if(this.products.has(sku)) return `SKU ${sku} already exists.`;\n        this.products.set(sku,new Product(sku,name,price,qty)); return `Added ${name} (SKU:${sku}).`;\n    }\n    restock(sku:string,qty:number):string{\n        if(!this.products.has(sku)) return `SKU ${sku} not found.`;\n        const p=this.products.get(sku)!; p.qty+=qty;\n        return `Restocked ${sku}: +${qty} units. Total: ${p.qty}.`;\n    }\n    sell(sku:string,qty:number):string{\n        if(!this.products.has(sku)) return `SKU ${sku} not found.`;\n        const p=this.products.get(sku)!;\n        if(p.qty<qty) return 'Insufficient stock.';\n        p.qty-=qty; return `Sold ${qty} x ${p.name}. Remaining: ${p.qty}.`;\n    }\n    low_stock(threshold:number):string{\n        const low=[...this.products.values()].filter(p=>p.qty<=threshold);\n        if(!low.length) return 'All stocked.';\n        low.sort((a,b)=>a.qty!==b.qty?a.qty-b.qty:a.sku.localeCompare(b.sku));\n        return low.map(p=>`${p.sku}: ${p.qty} units`).join('\\n');\n    }\n    total_value():string{\n        let v=0; for(const p of this.products.values()) v+=p.price*p.qty;\n        return `Total inventory value: $${v.toFixed(2)}`;\n    }\n}",
  "cpp": "#include <string>\n#include <map>\n#include <vector>\n#include <algorithm>\n#include <sstream>\n#include <iomanip>\nusing namespace std;\nstruct Product{string sku,name;double price;int qty;};\nclass Inventory{\n    map<string,Product> products;\npublic:\n    string add_product(string sku,string name,double price,int qty){\n        if(products.count(sku)) return \"SKU \"+sku+\" already exists.\";\n        products[sku]={sku,name,price,qty}; return \"Added \"+name+\" (SKU:\"+sku+\").\";\n    }\n    string restock(string sku,int qty){\n        if(!products.count(sku)) return \"SKU \"+sku+\" not found.\";\n        products[sku].qty+=qty;\n        return \"Restocked \"+sku+\": +\"+to_string(qty)+\" units. Total: \"+to_string(products[sku].qty)+\".\";\n    }\n    string sell(string sku,int qty){\n        if(!products.count(sku)) return \"SKU \"+sku+\" not found.\";\n        if(products[sku].qty<qty) return \"Insufficient stock.\";\n        products[sku].qty-=qty;\n        return \"Sold \"+to_string(qty)+\" x \"+products[sku].name+\". Remaining: \"+to_string(products[sku].qty)+\".\";\n    }\n    string low_stock(int threshold){\n        vector<Product*> low;\n        for(auto& [k,v]:products) if(v.qty<=threshold) low.push_back(&v);\n        if(low.empty()) return \"All stocked.\";\n        sort(low.begin(),low.end(),[](Product* a,Product* b){return a->qty!=b->qty?a->qty<b->qty:a->sku<b->sku;});\n        string out;\n        for(auto* p:low){if(!out.empty())out+=\"\\n\";out+=p->sku+\": \"+to_string(p->qty)+\" units\";}\n        return out;\n    }\n    string total_value(){\n        double v=0; for(auto& [k,p]:products) v+=p.price*p.qty;\n        ostringstream os; os<<fixed<<setprecision(2)<<v;\n        return \"Total inventory value: $\"+os.str();\n    }\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\ninv = Inventory()\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"add\": print(inv.add_product(parts[1],parts[2],float(parts[3]),int(parts[4])))\n    elif cmd == \"restock\": print(inv.restock(parts[1],int(parts[2])))\n    elif cmd == \"sell\": print(inv.sell(parts[1],int(parts[2])))\n    elif cmd == \"low\": print(inv.low_stock(int(parts[1])))\n    elif cmd == \"value\": print(inv.total_value())",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in); Inventory inv=new Inventory();\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"add\")) System.out.println(inv.add_product(p[1],p[2],Double.parseDouble(p[3]),Integer.parseInt(p[4])));\n            else if(cmd.equals(\"restock\")) System.out.println(inv.restock(p[1],Integer.parseInt(p[2])));\n            else if(cmd.equals(\"sell\")) System.out.println(inv.sell(p[1],Integer.parseInt(p[2])));\n            else if(cmd.equals(\"low\")) System.out.println(inv.low_stock(Integer.parseInt(p[1])));\n            else if(cmd.equals(\"value\")) System.out.println(inv.total_value());\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nconst inv=new Inventory();\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='add') console.log(inv.add_product(p[1],p[2],parseFloat(p[3]),parseInt(p[4])));\n    else if(cmd==='restock') console.log(inv.restock(p[1],parseInt(p[2])));\n    else if(cmd==='sell') console.log(inv.sell(p[1],parseInt(p[2])));\n    else if(cmd==='low') console.log(inv.low_stock(parseInt(p[1])));\n    else if(cmd==='value') console.log(inv.total_value());\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main(){\n    string line; Inventory inv;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"add\"){string sku,name;double price;int qty;ss>>sku>>name>>price>>qty;cout<<inv.add_product(sku,name,price,qty)<<\"\\n\";}\n        else if(cmd==\"restock\"){string sku;int qty;ss>>sku>>qty;cout<<inv.restock(sku,qty)<<\"\\n\";}\n        else if(cmd==\"sell\"){string sku;int qty;ss>>sku>>qty;cout<<inv.sell(sku,qty)<<\"\\n\";}\n        else if(cmd==\"low\"){int t;ss>>t;cout<<inv.low_stock(t)<<\"\\n\";}\n        else if(cmd==\"value\"){cout<<inv.total_value()<<\"\\n\";}\n    }\n    return 0;\n}"
}$TH$::jsonb
);

-- ============================================================
-- DESIGN PATTERNS CHALLENGES
-- ============================================================

INSERT INTO challenges (id, title, topic, difficulty, language, framework,
    description, starter_code, test_cases, test_harness, starter_codes, test_harnesses) VALUES (

-- dp_n01 -------------------------------------------------------
'dp_n01',
'Observer Pattern — Stock Ticker',
'Design Patterns', 'Easy', 'python', 'Python / Design Patterns',
$$Implement the Observer pattern to notify subscribers of stock price changes.

**Requirements:**
- `Observer` — abstract base with `update(symbol, price)` method
- `PriceAlertObserver(name, threshold)` — prints `"{name} ALERT: {symbol} hit ${price:.2f} (threshold: ${threshold:.2f})"` only when `price >= threshold`
- `LogObserver(name)` — always prints `"[LOG:{name}] {symbol} = ${price:.2f}"`
- `StockTicker` — subject: `subscribe(obs)`, `unsubscribe(obs)`, `set_price(symbol, price)`

**Constraints:**
- Observers notified in subscription order; duplicate unsubscribe silently ignored$$,

$$from abc import ABC, abstractmethod

class Observer(ABC):
    @abstractmethod
    def update(self, symbol: str, price: float):
        pass

class PriceAlertObserver(Observer):
    def __init__(self, name: str, threshold: float):
        pass
    def update(self, symbol: str, price: float):
        pass

class LogObserver(Observer):
    def __init__(self, name: str):
        pass
    def update(self, symbol: str, price: float):
        pass

class StockTicker:
    def __init__(self):
        pass
    def subscribe(self, observer):
        pass
    def unsubscribe(self, observer):
        pass
    def set_price(self, symbol: str, price: float):
        pass$$,

$TC$[
  {"input": "log L1\nsubscribe L1\nprice AAPL 150.00", "expected_output": "[LOG:L1] AAPL = $150.00", "description": "LogObserver logs every update"},
  {"input": "alert A1 200.00\nsubscribe A1\nprice AAPL 150.00", "expected_output": "", "description": "Alert silent when price below threshold"},
  {"input": "alert A1 100.00\nsubscribe A1\nprice AAPL 150.00", "expected_output": "A1 ALERT: AAPL hit $150.00 (threshold: $100.00)", "description": "Alert fires at or above threshold"},
  {"input": "log L1\nalert A1 100.00\nsubscribe L1\nsubscribe A1\nprice TSLA 250.00", "expected_output": "[LOG:L1] TSLA = $250.00\nA1 ALERT: TSLA hit $250.00 (threshold: $100.00)", "description": "Multiple observers notified in order"},
  {"input": "log L1\nsubscribe L1\nunsubscribe L1\nprice AAPL 100.00", "expected_output": "", "description": "Unsubscribed observer not notified"},
  {"input": "log L1\nlog L2\nsubscribe L1\nsubscribe L2\nprice GOOG 80.00", "expected_output": "[LOG:L1] GOOG = $80.00\n[LOG:L2] GOOG = $80.00", "description": "Two log observers both receive update"}
]$TC$::jsonb,

NULL,

$SC${"python": "from abc import ABC, abstractmethod\nclass Observer(ABC):\n    @abstractmethod\n    def update(self, symbol: str, price: float): pass\nclass PriceAlertObserver(Observer):\n    def __init__(self, name: str, threshold: float): pass\n    def update(self, symbol: str, price: float): pass\nclass LogObserver(Observer):\n    def __init__(self, name: str): pass\n    def update(self, symbol: str, price: float): pass\nclass StockTicker:\n    def __init__(self): pass\n    def subscribe(self, observer): pass\n    def unsubscribe(self, observer): pass\n    def set_price(self, symbol: str, price: float): pass",
  "java": "import java.util.*;\ninterface Observer { void update(String symbol, double price); }\nclass PriceAlertObserver implements Observer {\n    String name; double threshold;\n    PriceAlertObserver(String name,double threshold){this.name=name;this.threshold=threshold;}\n    public void update(String symbol,double price){\n        if(price>=threshold) System.out.printf(\"%s ALERT: %s hit $%.2f (threshold: $%.2f)%n\",name,symbol,price,threshold);\n    }\n}\nclass LogObserver implements Observer {\n    String name; LogObserver(String name){this.name=name;}\n    public void update(String symbol,double price){System.out.printf(\"[LOG:%s] %s = $%.2f%n\",name,symbol,price);}\n}\nclass StockTicker {\n    List<Observer> observers=new ArrayList<>();\n    void subscribe(Observer o){observers.add(o);}\n    void unsubscribe(Observer o){observers.remove(o);}\n    void set_price(String symbol,double price){for(Observer o:observers) o.update(symbol,price);}\n}",
  "typescript": "interface Observer { update(symbol: string, price: number): void; }\nclass PriceAlertObserver implements Observer {\n    constructor(private name:string,private threshold:number){}\n    update(symbol:string,price:number){\n        if(price>=this.threshold) console.log(`${this.name} ALERT: ${symbol} hit $${price.toFixed(2)} (threshold: $${this.threshold.toFixed(2)})`);\n    }\n}\nclass LogObserver implements Observer {\n    constructor(private name:string){}\n    update(symbol:string,price:number){console.log(`[LOG:${this.name}] ${symbol} = $${price.toFixed(2)}`);}\n}\nclass StockTicker {\n    private observers:Observer[]=[];\n    subscribe(o:Observer){this.observers.push(o);}\n    unsubscribe(o:Observer){const i=this.observers.indexOf(o);if(i>=0)this.observers.splice(i,1);}\n    set_price(symbol:string,price:number){this.observers.forEach(o=>o.update(symbol,price));}\n}",
  "cpp": "#include <string>\n#include <vector>\n#include <algorithm>\n#include <sstream>\n#include <iomanip>\n#include <iostream>\nusing namespace std;\nclass Observer{\npublic: virtual void update(string symbol,double price)=0; virtual ~Observer(){}\n};\nclass PriceAlertObserver:public Observer{\n    string name; double threshold;\npublic:\n    PriceAlertObserver(string n,double t):name(n),threshold(t){}\n    void update(string symbol,double price){\n        if(price>=threshold){\n            cout<<fixed<<setprecision(2);\n            cout<<name<<\" ALERT: \"<<symbol<<\" hit $\"<<price<<\" (threshold: $\"<<threshold<<\")\"<<\"\\n\";\n        }\n    }\n};\nclass LogObserver:public Observer{\n    string name;\npublic:\n    LogObserver(string n):name(n){}\n    void update(string symbol,double price){cout<<fixed<<setprecision(2)<<\"[LOG:\"<<name<<\"] \"<<symbol<<\" = $\"<<price<<\"\\n\";}\n};\nclass StockTicker{\n    vector<Observer*> observers;\npublic:\n    void subscribe(Observer* o){observers.push_back(o);}\n    void unsubscribe(Observer* o){observers.erase(find(observers.begin(),observers.end(),o));}\n    void set_price(string symbol,double price){for(auto* o:observers) o->update(symbol,price);}\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\nobservers = {}\nticker = StockTicker()\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"log\": observers[parts[1]] = LogObserver(parts[1])\n    elif cmd == \"alert\": observers[parts[1]] = PriceAlertObserver(parts[1], float(parts[2]))\n    elif cmd == \"subscribe\": ticker.subscribe(observers[parts[1]])\n    elif cmd == \"unsubscribe\": ticker.unsubscribe(observers[parts[1]])\n    elif cmd == \"price\": ticker.set_price(parts[1], float(parts[2]))",
  "java": "import java.util.Scanner;\nimport java.util.HashMap;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in);\n        HashMap<String,Observer> obs=new HashMap<>();\n        StockTicker ticker=new StockTicker();\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"log\")) obs.put(p[1],new LogObserver(p[1]));\n            else if(cmd.equals(\"alert\")) obs.put(p[1],new PriceAlertObserver(p[1],Double.parseDouble(p[2])));\n            else if(cmd.equals(\"subscribe\")) ticker.subscribe(obs.get(p[1]));\n            else if(cmd.equals(\"unsubscribe\")) ticker.unsubscribe(obs.get(p[1]));\n            else if(cmd.equals(\"price\")) ticker.set_price(p[1],Double.parseDouble(p[2]));\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nconst obs:Record<string,Observer>={}, ticker=new StockTicker();\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='log') obs[p[1]]=new LogObserver(p[1]);\n    else if(cmd==='alert') obs[p[1]]=new PriceAlertObserver(p[1],parseFloat(p[2]));\n    else if(cmd==='subscribe') ticker.subscribe(obs[p[1]]);\n    else if(cmd==='unsubscribe') ticker.unsubscribe(obs[p[1]]);\n    else if(cmd==='price') ticker.set_price(p[1],parseFloat(p[2]));\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <map>\n#include <string>\nusing namespace std;\nint main(){\n    string line;\n    map<string,Observer*> obs;\n    StockTicker ticker;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"log\"){string n;ss>>n;obs[n]=new LogObserver(n);}\n        else if(cmd==\"alert\"){string n;double t;ss>>n>>t;obs[n]=new PriceAlertObserver(n,t);}\n        else if(cmd==\"subscribe\"){string n;ss>>n;ticker.subscribe(obs[n]);}\n        else if(cmd==\"unsubscribe\"){string n;ss>>n;ticker.unsubscribe(obs[n]);}\n        else if(cmd==\"price\"){string sym;double pr;ss>>sym>>pr;ticker.set_price(sym,pr);}\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- dp_n02 -------------------------------------------------------
(
'dp_n02',
'Singleton — Application Logger',
'Design Patterns', 'Easy', 'python', 'Python / Design Patterns',
$$Implement the Singleton pattern so only one Logger instance ever exists.

**Requirements:**
- `Logger` — Singleton:
  - `get_instance()` — class/static method returning the single shared instance
  - `log(level, message)` — prints `"[{level}] {message}"` and increments count
  - `get_log_count() -> int` — total messages logged
  - `clear()` — resets count to 0

**Constraints:**
- `Logger.get_instance() is Logger.get_instance()` must be `True` (same object)
- Count accumulates across all references to the instance$$,

$$class Logger:
    _instance = None

    def __new__(cls):
        pass

    @classmethod
    def get_instance(cls):
        pass

    def log(self, level: str, message: str):
        pass

    def get_log_count(self) -> int:
        pass

    def clear(self):
        pass$$,

$TC$[
  {"input": "log INFO AppStarted\ncount", "expected_output": "[INFO] AppStarted\n1", "description": "Log a message and check count"},
  {"input": "log INFO Start\nlog WARNING LowMemory\nlog ERROR Crash\ncount", "expected_output": "[INFO] Start\n[WARNING] LowMemory\n[ERROR] Crash\n3", "description": "Multiple log levels counted"},
  {"input": "log INFO A\nclear\ncount", "expected_output": "[INFO] A\n0", "description": "Clear resets count to zero"},
  {"input": "same", "expected_output": "True", "description": "Two get_instance calls return the same object"},
  {"input": "log DEBUG Init\nlog INFO Ready\nclear\nlog WARNING Overload\ncount", "expected_output": "[DEBUG] Init\n[INFO] Ready\n[WARNING] Overload\n1", "description": "Count resets and resumes after clear"}
]$TC$::jsonb,

NULL,

$SC${"python": "class Logger:\n    _instance = None\n    def __new__(cls):\n        pass\n    @classmethod\n    def get_instance(cls):\n        pass\n    def log(self, level: str, message: str):\n        pass\n    def get_log_count(self) -> int:\n        pass\n    def clear(self):\n        pass",
  "java": "class Logger {\n    private static Logger instance = null;\n    private int count = 0;\n    private Logger() {}\n    public static Logger getInstance() {\n        // TODO: return single instance\n        return null;\n    }\n    public void log(String level, String message) {\n        // TODO: print and count\n    }\n    public int getLogCount() { return count; }\n    public void clear() { count = 0; }\n}",
  "typescript": "class Logger {\n    private static instance: Logger | null = null;\n    private count = 0;\n    private constructor() {}\n    static getInstance(): Logger {\n        // TODO: return single instance\n        return null as any;\n    }\n    log(level: string, message: string) {\n        // TODO: print and count\n    }\n    getLogCount(): number { return this.count; }\n    clear() { this.count = 0; }\n}",
  "cpp": "#include <string>\n#include <iostream>\nusing namespace std;\nclass Logger {\n    static Logger* instance;\n    int count = 0;\n    Logger() {}\npublic:\n    static Logger* getInstance() {\n        // TODO: return single instance\n        return nullptr;\n    }\n    void log(string level, string message) {\n        // TODO: print and count\n    }\n    int getLogCount() { return count; }\n    void clear() { count = 0; }\n};\nLogger* Logger::instance = nullptr;"
}$SC$::jsonb,

$TH${
  "python": "import sys\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"log\": Logger.get_instance().log(parts[1], parts[2])\n    elif cmd == \"count\": print(Logger.get_instance().get_log_count())\n    elif cmd == \"clear\": Logger.get_instance().clear()\n    elif cmd == \"same\": print(Logger.get_instance() is Logger.get_instance())",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in);\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"log\")) Logger.getInstance().log(p[1],p[2]);\n            else if(cmd.equals(\"count\")) System.out.println(Logger.getInstance().getLogCount());\n            else if(cmd.equals(\"clear\")) Logger.getInstance().clear();\n            else if(cmd.equals(\"same\")) System.out.println(Logger.getInstance()==Logger.getInstance()?\"True\":\"False\");\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='log') Logger.getInstance().log(p[1],p[2]);\n    else if(cmd==='count') console.log(Logger.getInstance().getLogCount());\n    else if(cmd==='clear') Logger.getInstance().clear();\n    else if(cmd==='same') console.log(Logger.getInstance()===Logger.getInstance()?'True':'False');\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main(){\n    string line;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"log\"){string lvl,msg;ss>>lvl>>msg;Logger::getInstance()->log(lvl,msg);}\n        else if(cmd==\"count\") cout<<Logger::getInstance()->getLogCount()<<\"\\n\";\n        else if(cmd==\"clear\") Logger::getInstance()->clear();\n        else if(cmd==\"same\") cout<<(Logger::getInstance()==Logger::getInstance()?\"True\":\"False\")<<\"\\n\";\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- dp_n03 -------------------------------------------------------
(
'dp_n03',
'Factory Pattern — Shape Renderer',
'Design Patterns', 'Easy', 'python', 'Python / Design Patterns',
$$Use the Factory pattern to create shapes and compute their properties.

**Requirements:**
- `Shape` — abstract base with `area() -> float`, `perimeter() -> float`, `describe() -> str`
- `Circle(radius)` — area = π·r², perimeter = 2π·r; describe: `"Circle(r={radius:.2f})"`
- `Rectangle(width, height)` — area = w·h, perimeter = 2(w+h); describe: `"Rectangle({width:.2f}x{height:.2f})"`
- `Triangle(a, b, c)` — Heron's formula for area, perimeter = a+b+c; describe: `"Triangle({a:.2f},{b:.2f},{c:.2f})"`
- `ShapeFactory.create(type, *args)` — raises `ValueError` for unknown types

**Constraints:**
- Use `math.pi`; area/perimeter printed to 2 decimal places$$,

$$import math
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self) -> float: pass
    @abstractmethod
    def perimeter(self) -> float: pass
    @abstractmethod
    def describe(self) -> str: pass

class Circle(Shape):
    def __init__(self, radius: float): pass
    def area(self) -> float: pass
    def perimeter(self) -> float: pass
    def describe(self) -> str: pass

class Rectangle(Shape):
    def __init__(self, width: float, height: float): pass
    def area(self) -> float: pass
    def perimeter(self) -> float: pass
    def describe(self) -> str: pass

class Triangle(Shape):
    def __init__(self, a: float, b: float, c: float): pass
    def area(self) -> float: pass
    def perimeter(self) -> float: pass
    def describe(self) -> str: pass

class ShapeFactory:
    @staticmethod
    def create(shape_type: str, *args):
        pass$$,

$TC$[
  {"input": "create circle 5.0\ndescribe\narea\nperimeter", "expected_output": "Circle(r=5.00)\n78.54\n31.42", "description": "Circle properties"},
  {"input": "create rectangle 4.0 6.0\ndescribe\narea\nperimeter", "expected_output": "Rectangle(4.00x6.00)\n24.00\n20.00", "description": "Rectangle properties"},
  {"input": "create triangle 3.0 4.0 5.0\ndescribe\narea\nperimeter", "expected_output": "Triangle(3.00,4.00,5.00)\n6.00\n12.00", "description": "3-4-5 right triangle"},
  {"input": "create circle 1.0\narea", "expected_output": "3.14", "description": "Unit circle area"},
  {"input": "create rectangle 10.0 2.0\nperimeter", "expected_output": "24.00", "description": "Rectangle perimeter"},
  {"input": "create unknown 1.0", "expected_output": "ValueError", "description": "Unknown shape raises ValueError"}
]$TC$::jsonb,

NULL,

$SC${"python": "import math\nfrom abc import ABC, abstractmethod\nclass Shape(ABC):\n    @abstractmethod\n    def area(self) -> float: pass\n    @abstractmethod\n    def perimeter(self) -> float: pass\n    @abstractmethod\n    def describe(self) -> str: pass\nclass Circle(Shape):\n    def __init__(self, radius: float): pass\n    def area(self) -> float: pass\n    def perimeter(self) -> float: pass\n    def describe(self) -> str: pass\nclass Rectangle(Shape):\n    def __init__(self, width: float, height: float): pass\n    def area(self) -> float: pass\n    def perimeter(self) -> float: pass\n    def describe(self) -> str: pass\nclass Triangle(Shape):\n    def __init__(self, a: float, b: float, c: float): pass\n    def area(self) -> float: pass\n    def perimeter(self) -> float: pass\n    def describe(self) -> str: pass\nclass ShapeFactory:\n    @staticmethod\n    def create(shape_type: str, *args): pass",
  "java": "import java.lang.Math;\ninterface Shape{double area();double perimeter();String describe();}\nclass Circle implements Shape{\n    double r; Circle(double r){this.r=r;}\n    public double area(){return Math.PI*r*r;}\n    public double perimeter(){return 2*Math.PI*r;}\n    public String describe(){return String.format(\"Circle(r=%.2f)\",r);}\n}\nclass Rectangle implements Shape{\n    double w,h; Rectangle(double w,double h){this.w=w;this.h=h;}\n    public double area(){return w*h;}\n    public double perimeter(){return 2*(w+h);}\n    public String describe(){return String.format(\"Rectangle(%.2fx%.2f)\",w,h);}\n}\nclass Triangle implements Shape{\n    double a,b,c; Triangle(double a,double b,double c){this.a=a;this.b=b;this.c=c;}\n    public double perimeter(){return a+b+c;}\n    public double area(){double s=(a+b+c)/2;return Math.sqrt(s*(s-a)*(s-b)*(s-c));}\n    public String describe(){return String.format(\"Triangle(%.2f,%.2f,%.2f)\",a,b,c);}\n}\nclass ShapeFactory{\n    static Shape create(String type,double... args){\n        if(type.equals(\"circle\")) return new Circle(args[0]);\n        if(type.equals(\"rectangle\")) return new Rectangle(args[0],args[1]);\n        if(type.equals(\"triangle\")) return new Triangle(args[0],args[1],args[2]);\n        throw new IllegalArgumentException(\"Unknown\");\n    }\n}",
  "typescript": "class Circle{\n    constructor(private r:number){}\n    area():number{return Math.PI*this.r*this.r;}\n    perimeter():number{return 2*Math.PI*this.r;}\n    describe():string{return `Circle(r=${this.r.toFixed(2)})`;}\n}\nclass Rectangle{\n    constructor(private w:number,private h:number){}\n    area():number{return this.w*this.h;}\n    perimeter():number{return 2*(this.w+this.h);}\n    describe():string{return `Rectangle(${this.w.toFixed(2)}x${this.h.toFixed(2)})`;}\n}\nclass Triangle{\n    constructor(private a:number,private b:number,private c:number){}\n    perimeter():number{return this.a+this.b+this.c;}\n    area():number{const s=(this.a+this.b+this.c)/2;return Math.sqrt(s*(s-this.a)*(s-this.b)*(s-this.c));}\n    describe():string{return `Triangle(${this.a.toFixed(2)},${this.b.toFixed(2)},${this.c.toFixed(2)})`;}\n}\nclass ShapeFactory{\n    static create(type:string,...args:number[]):any{\n        if(type==='circle') return new Circle(args[0]);\n        if(type==='rectangle') return new Rectangle(args[0],args[1]);\n        if(type==='triangle') return new Triangle(args[0],args[1],args[2]);\n        throw new Error('ValueError');\n    }\n}",
  "cpp": "#include <string>\n#include <cmath>\n#include <sstream>\n#include <iomanip>\n#include <stdexcept>\nusing namespace std;\nstruct Shape{virtual double area()=0;virtual double perimeter()=0;virtual string describe()=0;virtual ~Shape(){}};\nstruct Circle:Shape{\n    double r; Circle(double r):r(r){}\n    double area(){return M_PI*r*r;}\n    double perimeter(){return 2*M_PI*r;}\n    string describe(){ostringstream os;os<<fixed<<setprecision(2);os<<\"Circle(r=\"<<r<<\")\";return os.str();}\n};\nstruct Rectangle:Shape{\n    double w,h; Rectangle(double w,double h):w(w),h(h){}\n    double area(){return w*h;}\n    double perimeter(){return 2*(w+h);}\n    string describe(){ostringstream os;os<<fixed<<setprecision(2);os<<\"Rectangle(\"<<w<<\"x\"<<h<<\")\";return os.str();}\n};\nstruct Triangle:Shape{\n    double a,b,c; Triangle(double a,double b,double c):a(a),b(b),c(c){}\n    double perimeter(){return a+b+c;}\n    double area(){double s=(a+b+c)/2;return sqrt(s*(s-a)*(s-b)*(s-c));}\n    string describe(){ostringstream os;os<<fixed<<setprecision(2);os<<\"Triangle(\"<<a<<\",\"<<b<<\",\"<<c<<\")\";return os.str();}\n};\nShape* createShape(string type,double* args){\n    if(type==\"circle\") return new Circle(args[0]);\n    if(type==\"rectangle\") return new Rectangle(args[0],args[1]);\n    if(type==\"triangle\") return new Triangle(args[0],args[1],args[2]);\n    throw invalid_argument(\"ValueError\");\n}"
}$SC$::jsonb,

$TH${
  "python": "import sys, math\nshape = None\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"create\":\n        args = [float(x) for x in parts[2:]]\n        try: shape = ShapeFactory.create(parts[1], *args)\n        except ValueError: print(\"ValueError\")\n    elif cmd == \"describe\": print(shape.describe())\n    elif cmd == \"area\": print(f\"{shape.area():.2f}\")\n    elif cmd == \"perimeter\": print(f\"{shape.perimeter():.2f}\")",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in); Shape shape=null;\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"create\")){\n                double[] a=new double[p.length-2];\n                for(int i=0;i<a.length;i++) a[i]=Double.parseDouble(p[i+2]);\n                try{shape=ShapeFactory.create(p[1],a);}catch(Exception e){System.out.println(\"ValueError\");}\n            } else if(cmd.equals(\"describe\")) System.out.println(shape.describe());\n            else if(cmd.equals(\"area\")) System.out.printf(\"%.2f%n\",shape.area());\n            else if(cmd.equals(\"perimeter\")) System.out.printf(\"%.2f%n\",shape.perimeter());\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nlet shape:any=null;\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='create'){\n        const args=p.slice(2).map(Number);\n        try{shape=ShapeFactory.create(p[1],...args);}catch(e){console.log('ValueError');}\n    } else if(cmd==='describe') console.log(shape.describe());\n    else if(cmd==='area') console.log(shape.area().toFixed(2));\n    else if(cmd==='perimeter') console.log(shape.perimeter().toFixed(2));\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <iomanip>\n#include <stdexcept>\nusing namespace std;\nint main(){\n    string line; Shape* shape=nullptr;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"create\"){\n            string type; ss>>type;\n            double args[3]={0,0,0}; int i=0;\n            double v; while(ss>>v) args[i++]=v;\n            try{shape=createShape(type,args);}catch(...){cout<<\"ValueError\\n\";}\n        } else if(cmd==\"describe\") cout<<shape->describe()<<\"\\n\";\n        else if(cmd==\"area\"){cout<<fixed<<setprecision(2)<<shape->area()<<\"\\n\";}\n        else if(cmd==\"perimeter\"){cout<<fixed<<setprecision(2)<<shape->perimeter()<<\"\\n\";}\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- dp_n04 -------------------------------------------------------
(
'dp_n04',
'Decorator Pattern — Coffee Shop',
'Design Patterns', 'Medium', 'python', 'Python / Design Patterns',
$$Use the Decorator pattern to build a customisable beverage ordering system.

**Requirements:**
- `Beverage` — abstract base with `cost() -> float` and `description() -> str`
- `Espresso` — cost 2.50, description `"Espresso"`
- `Drip` — cost 1.00, description `"Drip Coffee"`
- `MilkDecorator(bev)` — +$0.50, appends `", Milk"`
- `SugarDecorator(bev)` — +$0.25, appends `", Sugar"`
- `WhipDecorator(bev)` — +$0.75, appends `", Whip"`
- `VanillaDecorator(bev)` — +$0.60, appends `", Vanilla"`

**Constraints:**
- Decorators compose arbitrarily; same decorator may be applied twice$$,

$$from abc import ABC, abstractmethod

class Beverage(ABC):
    @abstractmethod
    def cost(self) -> float: pass
    @abstractmethod
    def description(self) -> str: pass

class Espresso(Beverage):
    def cost(self): return 2.50
    def description(self): return "Espresso"

class Drip(Beverage):
    def cost(self): return 1.00
    def description(self): return "Drip Coffee"

class MilkDecorator(Beverage):
    def __init__(self, beverage): pass
    def cost(self) -> float: pass
    def description(self) -> str: pass

class SugarDecorator(Beverage):
    def __init__(self, beverage): pass
    def cost(self) -> float: pass
    def description(self) -> str: pass

class WhipDecorator(Beverage):
    def __init__(self, beverage): pass
    def cost(self) -> float: pass
    def description(self) -> str: pass

class VanillaDecorator(Beverage):
    def __init__(self, beverage): pass
    def cost(self) -> float: pass
    def description(self) -> str: pass$$,

$TC$[
  {"input": "espresso\ncost\ndesc", "expected_output": "2.50\nEspresso", "description": "Plain espresso"},
  {"input": "drip\ncost\ndesc", "expected_output": "1.00\nDrip Coffee", "description": "Plain drip coffee"},
  {"input": "espresso\nmilk\ncost\ndesc", "expected_output": "3.00\nEspresso, Milk", "description": "Espresso with milk"},
  {"input": "espresso\nsugar\nwhip\ncost\ndesc", "expected_output": "3.50\nEspresso, Sugar, Whip", "description": "Two decorators stacked"},
  {"input": "drip\nmilk\nsugar\nvanilla\ncost\ndesc", "expected_output": "2.35\nDrip Coffee, Milk, Sugar, Vanilla", "description": "Three decorators on drip"},
  {"input": "espresso\nmilk\nmilk\ncost\ndesc", "expected_output": "3.50\nEspresso, Milk, Milk", "description": "Same decorator applied twice"},
  {"input": "drip\nwhip\ncost", "expected_output": "1.75", "description": "Drip with whip"}
]$TC$::jsonb,

NULL,

$SC${"python": "from abc import ABC, abstractmethod\nclass Beverage(ABC):\n    @abstractmethod\n    def cost(self) -> float: pass\n    @abstractmethod\n    def description(self) -> str: pass\nclass Espresso(Beverage):\n    def cost(self): return 2.50\n    def description(self): return \"Espresso\"\nclass Drip(Beverage):\n    def cost(self): return 1.00\n    def description(self): return \"Drip Coffee\"\nclass MilkDecorator(Beverage):\n    def __init__(self, beverage): pass\n    def cost(self) -> float: pass\n    def description(self) -> str: pass\nclass SugarDecorator(Beverage):\n    def __init__(self, beverage): pass\n    def cost(self) -> float: pass\n    def description(self) -> str: pass\nclass WhipDecorator(Beverage):\n    def __init__(self, beverage): pass\n    def cost(self) -> float: pass\n    def description(self) -> str: pass\nclass VanillaDecorator(Beverage):\n    def __init__(self, beverage): pass\n    def cost(self) -> float: pass\n    def description(self) -> str: pass",
  "java": "abstract class Beverage{abstract double cost();abstract String description();}\nclass Espresso extends Beverage{double cost(){return 2.50;}String description(){return \"Espresso\";}}\nclass Drip extends Beverage{double cost(){return 1.00;}String description(){return \"Drip Coffee\";}}\nclass MilkDecorator extends Beverage{\n    Beverage b; MilkDecorator(Beverage b){this.b=b;}\n    double cost(){return b.cost()+0.50;}\n    String description(){return b.description()+\", Milk\";}\n}\nclass SugarDecorator extends Beverage{\n    Beverage b; SugarDecorator(Beverage b){this.b=b;}\n    double cost(){return b.cost()+0.25;}\n    String description(){return b.description()+\", Sugar\";}\n}\nclass WhipDecorator extends Beverage{\n    Beverage b; WhipDecorator(Beverage b){this.b=b;}\n    double cost(){return b.cost()+0.75;}\n    String description(){return b.description()+\", Whip\";}\n}\nclass VanillaDecorator extends Beverage{\n    Beverage b; VanillaDecorator(Beverage b){this.b=b;}\n    double cost(){return b.cost()+0.60;}\n    String description(){return b.description()+\", Vanilla\";}\n}",
  "typescript": "abstract class Beverage{abstract cost():number;abstract description():string;}\nclass Espresso extends Beverage{cost(){return 2.50;}description(){return 'Espresso';}}\nclass Drip extends Beverage{cost(){return 1.00;}description(){return 'Drip Coffee';}}\nclass MilkDecorator extends Beverage{\n    constructor(private b:Beverage){super();}\n    cost(){return this.b.cost()+0.50;}\n    description(){return this.b.description()+', Milk';}\n}\nclass SugarDecorator extends Beverage{\n    constructor(private b:Beverage){super();}\n    cost(){return this.b.cost()+0.25;}\n    description(){return this.b.description()+', Sugar';}\n}\nclass WhipDecorator extends Beverage{\n    constructor(private b:Beverage){super();}\n    cost(){return this.b.cost()+0.75;}\n    description(){return this.b.description()+', Whip';}\n}\nclass VanillaDecorator extends Beverage{\n    constructor(private b:Beverage){super();}\n    cost(){return this.b.cost()+0.60;}\n    description(){return this.b.description()+', Vanilla';}\n}",
  "cpp": "#include <string>\n#include <iomanip>\n#include <sstream>\nusing namespace std;\nstruct Beverage{virtual double cost()=0;virtual string description()=0;virtual ~Beverage(){}};\nstruct Espresso:Beverage{double cost(){return 2.50;}string description(){return \"Espresso\";}};\nstruct Drip:Beverage{double cost(){return 1.00;}string description(){return \"Drip Coffee\";}};\nstruct MilkDecorator:Beverage{Beverage* b;MilkDecorator(Beverage* b):b(b){}double cost(){return b->cost()+0.50;}string description(){return b->description()+\", Milk\";}};\nstruct SugarDecorator:Beverage{Beverage* b;SugarDecorator(Beverage* b):b(b){}double cost(){return b->cost()+0.25;}string description(){return b->description()+\", Sugar\";}};\nstruct WhipDecorator:Beverage{Beverage* b;WhipDecorator(Beverage* b):b(b){}double cost(){return b->cost()+0.75;}string description(){return b->description()+\", Whip\";}};\nstruct VanillaDecorator:Beverage{Beverage* b;VanillaDecorator(Beverage* b):b(b){}double cost(){return b->cost()+0.60;}string description(){return b->description()+\", Vanilla\";}};"
}$SC$::jsonb,

$TH${
  "python": "import sys\nbev = None\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    cmd = line\n    if cmd == \"espresso\": bev = Espresso()\n    elif cmd == \"drip\": bev = Drip()\n    elif cmd == \"milk\": bev = MilkDecorator(bev)\n    elif cmd == \"sugar\": bev = SugarDecorator(bev)\n    elif cmd == \"whip\": bev = WhipDecorator(bev)\n    elif cmd == \"vanilla\": bev = VanillaDecorator(bev)\n    elif cmd == \"cost\": print(f\"{bev.cost():.2f}\")\n    elif cmd == \"desc\": print(bev.description())",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in); Beverage bev=null;\n        while(sc.hasNextLine()){\n            String cmd=sc.nextLine().trim(); if(cmd.isEmpty()) continue;\n            if(cmd.equals(\"espresso\")) bev=new Espresso();\n            else if(cmd.equals(\"drip\")) bev=new Drip();\n            else if(cmd.equals(\"milk\")) bev=new MilkDecorator(bev);\n            else if(cmd.equals(\"sugar\")) bev=new SugarDecorator(bev);\n            else if(cmd.equals(\"whip\")) bev=new WhipDecorator(bev);\n            else if(cmd.equals(\"vanilla\")) bev=new VanillaDecorator(bev);\n            else if(cmd.equals(\"cost\")) System.out.printf(\"%.2f%n\",bev.cost());\n            else if(cmd.equals(\"desc\")) System.out.println(bev.description());\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nlet bev:Beverage|null=null;\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const cmd=line;\n    if(cmd==='espresso') bev=new Espresso();\n    else if(cmd==='drip') bev=new Drip();\n    else if(cmd==='milk') bev=new MilkDecorator(bev!);\n    else if(cmd==='sugar') bev=new SugarDecorator(bev!);\n    else if(cmd==='whip') bev=new WhipDecorator(bev!);\n    else if(cmd==='vanilla') bev=new VanillaDecorator(bev!);\n    else if(cmd==='cost') console.log(bev!.cost().toFixed(2));\n    else if(cmd==='desc') console.log(bev!.description());\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <iomanip>\nusing namespace std;\nint main(){\n    string line; Beverage* bev=nullptr;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        string cmd=line;\n        if(cmd==\"espresso\") bev=new Espresso();\n        else if(cmd==\"drip\") bev=new Drip();\n        else if(cmd==\"milk\") bev=new MilkDecorator(bev);\n        else if(cmd==\"sugar\") bev=new SugarDecorator(bev);\n        else if(cmd==\"whip\") bev=new WhipDecorator(bev);\n        else if(cmd==\"vanilla\") bev=new VanillaDecorator(bev);\n        else if(cmd==\"cost\"){cout<<fixed<<setprecision(2)<<bev->cost()<<\"\\n\";}\n        else if(cmd==\"desc\") cout<<bev->description()<<\"\\n\";\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- dp_n05 -------------------------------------------------------
(
'dp_n05',
'Command Pattern — Text Editor',
'Design Patterns', 'Medium', 'python', 'Python / Design Patterns',
$$Implement the Command pattern for an undoable text editor.

**Requirements:**
- `TextEditor` — holds `text`; `insert(pos, text)`, `delete(start, end)`, `get_text() -> str`
- `InsertCommand(editor, pos, text)` — `execute` inserts; `undo` reverses
- `DeleteCommand(editor, start, end)` — `execute` deletes slice; `undo` restores
- `EditorHistory` — `execute(cmd)` runs and pushes; `undo() -> str` pops and undoes, returns `"Undone."` or `"Nothing to undo."`

**Constraints:**
- `delete(start, end)` uses Python slice semantics (end exclusive)
- After undo, text must be exactly as before the undone command$$,

$$from abc import ABC, abstractmethod

class TextEditor:
    def __init__(self):
        self.text = ""
    def insert(self, pos: int, text: str):
        self.text = self.text[:pos] + text + self.text[pos:]
    def delete(self, start: int, end: int):
        self.text = self.text[:start] + self.text[end:]
    def get_text(self) -> str:
        return self.text

class Command(ABC):
    @abstractmethod
    def execute(self): pass
    @abstractmethod
    def undo(self): pass

class InsertCommand(Command):
    def __init__(self, editor, pos: int, text: str):
        pass
    def execute(self): pass
    def undo(self): pass

class DeleteCommand(Command):
    def __init__(self, editor, start: int, end: int):
        pass
    def execute(self): pass
    def undo(self): pass

class EditorHistory:
    def __init__(self): pass
    def execute(self, command): pass
    def undo(self) -> str: pass$$,

$TC$[
  {"input": "insert 0 Hello\nshow", "expected_output": "Hello", "description": "Insert at position 0"},
  {"input": "insert 0 Hello\ninsert 5 World\nshow", "expected_output": "HelloWorld", "description": "Two inserts"},
  {"input": "insert 0 Hello\ninsert 5 World\nundo\nshow", "expected_output": "Undone.\nHello", "description": "Undo reverses last insert"},
  {"input": "insert 0 HelloWorld\ndelete 5 10\nshow", "expected_output": "Hello", "description": "Delete removes slice"},
  {"input": "insert 0 HelloWorld\ndelete 5 10\nundo\nshow", "expected_output": "Undone.\nHelloWorld", "description": "Undo restores deleted text"},
  {"input": "undo", "expected_output": "Nothing to undo.", "description": "Undo on empty history"},
  {"input": "insert 0 Hi\ninsert 2 There\nundo\nundo\nshow", "expected_output": "Undone.\nUndone.\n", "description": "Undo all commands leaves empty text"}
]$TC$::jsonb,

NULL,

$SC${"python": "from abc import ABC, abstractmethod\nclass TextEditor:\n    def __init__(self): self.text = \"\"\n    def insert(self, pos, text): self.text = self.text[:pos]+text+self.text[pos:]\n    def delete(self, start, end): self.text = self.text[:start]+self.text[end:]\n    def get_text(self): return self.text\nclass Command(ABC):\n    @abstractmethod\n    def execute(self): pass\n    @abstractmethod\n    def undo(self): pass\nclass InsertCommand(Command):\n    def __init__(self, editor, pos, text): pass\n    def execute(self): pass\n    def undo(self): pass\nclass DeleteCommand(Command):\n    def __init__(self, editor, start, end): pass\n    def execute(self): pass\n    def undo(self): pass\nclass EditorHistory:\n    def __init__(self): pass\n    def execute(self, command): pass\n    def undo(self) -> str: pass",
  "java": "import java.util.Stack;\nclass TextEditor{\n    StringBuilder text=new StringBuilder();\n    void insert(int pos,String s){text.insert(pos,s);}\n    void delete(int s,int e){text.delete(s,e);}\n    String getText(){return text.toString();}\n}\ninterface Command{void execute();void undo();}\nclass InsertCommand implements Command{\n    TextEditor e; int pos; String s;\n    InsertCommand(TextEditor e,int pos,String s){this.e=e;this.pos=pos;this.s=s;}\n    public void execute(){e.insert(pos,s);}\n    public void undo(){e.delete(pos,pos+s.length());}\n}\nclass DeleteCommand implements Command{\n    TextEditor e; int start,end; String deleted;\n    DeleteCommand(TextEditor e,int start,int end){this.e=e;this.start=start;this.end=end;}\n    public void execute(){deleted=e.text.substring(start,end);e.delete(start,end);}\n    public void undo(){e.insert(start,deleted);}\n}\nclass EditorHistory{\n    Stack<Command> stack=new Stack<>();\n    void execute(Command c){c.execute();stack.push(c);}\n    String undo(){if(stack.isEmpty())return \"Nothing to undo.\";stack.pop().undo();return \"Undone.\";}\n}",
  "typescript": "class TextEditor{\n    text='';\n    insert(pos:number,s:string){this.text=this.text.slice(0,pos)+s+this.text.slice(pos);}\n    delete(start:number,end:number){this.text=this.text.slice(0,start)+this.text.slice(end);}\n    getText(){return this.text;}\n}\ninterface Command{execute():void;undo():void;}\nclass InsertCommand implements Command{\n    constructor(private e:TextEditor,private pos:number,private s:string){}\n    execute(){this.e.insert(this.pos,this.s);}\n    undo(){this.e.delete(this.pos,this.pos+this.s.length);}\n}\nclass DeleteCommand implements Command{\n    private deleted='';\n    constructor(private e:TextEditor,private start:number,private end:number){}\n    execute(){this.deleted=this.e.text.slice(this.start,this.end);this.e.delete(this.start,this.end);}\n    undo(){this.e.insert(this.start,this.deleted);}\n}\nclass EditorHistory{\n    private stack:Command[]=[];\n    execute(c:Command){c.execute();this.stack.push(c);}\n    undo():string{if(!this.stack.length)return 'Nothing to undo.';this.stack.pop()!.undo();return 'Undone.';}\n}",
  "cpp": "#include <string>\n#include <vector>\n#include <stdexcept>\nusing namespace std;\nstruct TextEditor{\n    string text;\n    void insert(int pos,string s){text.insert(pos,s);}\n    void del(int s,int e){text.erase(s,e-s);}\n    string getText(){return text;}\n};\nstruct Command{virtual void execute()=0;virtual void undo()=0;virtual ~Command(){}};\nstruct InsertCommand:Command{\n    TextEditor* e; int pos; string s;\n    InsertCommand(TextEditor* e,int pos,string s):e(e),pos(pos),s(s){}\n    void execute(){e->insert(pos,s);}\n    void undo(){e->del(pos,pos+s.size());}\n};\nstruct DeleteCommand:Command{\n    TextEditor* e; int start,end; string deleted;\n    DeleteCommand(TextEditor* e,int s,int en):e(e),start(s),end(en){}\n    void execute(){deleted=e->text.substr(start,end-start);e->del(start,end);}\n    void undo(){e->insert(start,deleted);}\n};\nstruct EditorHistory{\n    vector<Command*> stack;\n    void execute(Command* c){c->execute();stack.push_back(c);}\n    string undo(){if(stack.empty())return \"Nothing to undo.\";stack.back()->undo();stack.pop_back();return \"Undone.\";}\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\neditor = TextEditor()\nhistory = EditorHistory()\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"insert\": history.execute(InsertCommand(editor, int(parts[1]), parts[2]))\n    elif cmd == \"delete\": history.execute(DeleteCommand(editor, int(parts[1]), int(parts[2])))\n    elif cmd == \"undo\": print(history.undo())\n    elif cmd == \"show\": print(editor.get_text())",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in);\n        TextEditor ed=new TextEditor(); EditorHistory hist=new EditorHistory();\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"insert\")) hist.execute(new InsertCommand(ed,Integer.parseInt(p[1]),p[2]));\n            else if(cmd.equals(\"delete\")) hist.execute(new DeleteCommand(ed,Integer.parseInt(p[1]),Integer.parseInt(p[2])));\n            else if(cmd.equals(\"undo\")) System.out.println(hist.undo());\n            else if(cmd.equals(\"show\")) System.out.println(ed.getText());\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nconst ed=new TextEditor(), hist=new EditorHistory();\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='insert') hist.execute(new InsertCommand(ed,parseInt(p[1]),p[2]));\n    else if(cmd==='delete') hist.execute(new DeleteCommand(ed,parseInt(p[1]),parseInt(p[2])));\n    else if(cmd==='undo') console.log(hist.undo());\n    else if(cmd==='show') console.log(ed.getText());\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main(){\n    string line;\n    TextEditor ed; EditorHistory hist;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"insert\"){int pos;string s;ss>>pos>>s;hist.execute(new InsertCommand(&ed,pos,s));}\n        else if(cmd==\"delete\"){int s,e;ss>>s>>e;hist.execute(new DeleteCommand(&ed,s,e));}\n        else if(cmd==\"undo\") cout<<hist.undo()<<\"\\n\";\n        else if(cmd==\"show\") cout<<ed.getText()<<\"\\n\";\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- dp_n06 -------------------------------------------------------
(
'dp_n06',
'Strategy Pattern — Sorting Service',
'Design Patterns', 'Medium', 'python', 'Python / Design Patterns',
$$Use the Strategy pattern to swap sorting algorithms at runtime.

**Requirements:**
- `SortStrategy` — abstract base with `sort(data: list[int]) -> list[int]`
- `BubbleSortStrategy` — implement bubble sort (no built-in sort)
- `SelectionSortStrategy` — implement selection sort (no built-in sort)
- `MergeSortStrategy` — implement merge sort recursively (no built-in sort)
- `Sorter` — context: `set_strategy(strategy)`, `sort(data) -> str` space-separated ints; `""` for empty

**Constraints:**
- Each strategy implements the algorithm from scratch; sorting ascending$$,

$$from abc import ABC, abstractmethod

class SortStrategy(ABC):
    @abstractmethod
    def sort(self, data: list) -> list:
        pass

class BubbleSortStrategy(SortStrategy):
    def sort(self, data: list) -> list:
        pass

class SelectionSortStrategy(SortStrategy):
    def sort(self, data: list) -> list:
        pass

class MergeSortStrategy(SortStrategy):
    def sort(self, data: list) -> list:
        pass

class Sorter:
    def __init__(self):
        self._strategy = None
    def set_strategy(self, strategy):
        pass
    def sort(self, data: list) -> str:
        pass$$,

$TC$[
  {"input": "strategy bubble\nsort 5 3 1 4 2", "expected_output": "1 2 3 4 5", "description": "Bubble sort"},
  {"input": "strategy selection\nsort 9 1 5 3 7", "expected_output": "1 3 5 7 9", "description": "Selection sort"},
  {"input": "strategy merge\nsort 8 4 2 6 1 3 7 5", "expected_output": "1 2 3 4 5 6 7 8", "description": "Merge sort"},
  {"input": "strategy bubble\nsort 1", "expected_output": "1", "description": "Single element"},
  {"input": "strategy merge\nsort", "expected_output": "", "description": "Empty list returns empty string"},
  {"input": "strategy selection\nsort 3 3 1 2 1", "expected_output": "1 1 2 3 3", "description": "Duplicates handled"},
  {"input": "strategy bubble\nsort 5 4 3 2 1\nstrategy merge\nsort 5 4 3 2 1", "expected_output": "1 2 3 4 5\n1 2 3 4 5", "description": "Strategy swapped at runtime"}
]$TC$::jsonb,

NULL,

$SC${"python": "from abc import ABC, abstractmethod\nclass SortStrategy(ABC):\n    @abstractmethod\n    def sort(self, data: list) -> list: pass\nclass BubbleSortStrategy(SortStrategy):\n    def sort(self, data: list) -> list: pass\nclass SelectionSortStrategy(SortStrategy):\n    def sort(self, data: list) -> list: pass\nclass MergeSortStrategy(SortStrategy):\n    def sort(self, data: list) -> list: pass\nclass Sorter:\n    def __init__(self): self._strategy = None\n    def set_strategy(self, strategy): pass\n    def sort(self, data: list) -> str: pass",
  "java": "import java.util.*;\ninterface SortStrategy{int[] sort(int[] data);}\nclass BubbleSortStrategy implements SortStrategy{\n    public int[] sort(int[] data){\n        int[] d=data.clone();\n        for(int i=0;i<d.length;i++) for(int j=0;j<d.length-i-1;j++) if(d[j]>d[j+1]){int t=d[j];d[j]=d[j+1];d[j+1]=t;}\n        return d;\n    }\n}\nclass SelectionSortStrategy implements SortStrategy{\n    public int[] sort(int[] data){\n        int[] d=data.clone();\n        for(int i=0;i<d.length;i++){int m=i;for(int j=i+1;j<d.length;j++) if(d[j]<d[m]) m=j;int t=d[i];d[i]=d[m];d[m]=t;}\n        return d;\n    }\n}\nclass MergeSortStrategy implements SortStrategy{\n    public int[] sort(int[] data){return ms(data.clone());}\n    int[] ms(int[] d){if(d.length<=1)return d;int m=d.length/2;int[] l=ms(Arrays.copyOfRange(d,0,m));int[] r=ms(Arrays.copyOfRange(d,m,d.length));int[] res=new int[d.length];int i=0,j=0,k=0;while(i<l.length&&j<r.length) res[k++]=l[i]<=r[j]?l[i++]:r[j++];while(i<l.length)res[k++]=l[i++];while(j<r.length)res[k++]=r[j++];return res;}\n}\nclass Sorter{\n    SortStrategy strategy;\n    void set_strategy(SortStrategy s){strategy=s;}\n    String sort(int[] data){\n        if(data.length==0) return \"\";\n        int[] sorted=strategy.sort(data);\n        StringBuilder sb=new StringBuilder();\n        for(int i=0;i<sorted.length;i++){if(i>0)sb.append(\" \");sb.append(sorted[i]);}\n        return sb.toString();\n    }\n}",
  "typescript": "interface SortStrategy{sort(data:number[]):number[];}\nclass BubbleSortStrategy implements SortStrategy{\n    sort(data:number[]):number[]{\n        const d=[...data];\n        for(let i=0;i<d.length;i++) for(let j=0;j<d.length-i-1;j++) if(d[j]>d[j+1]){[d[j],d[j+1]]=[d[j+1],d[j]];}\n        return d;\n    }\n}\nclass SelectionSortStrategy implements SortStrategy{\n    sort(data:number[]):number[]{\n        const d=[...data];\n        for(let i=0;i<d.length;i++){let m=i;for(let j=i+1;j<d.length;j++) if(d[j]<d[m]) m=j;[d[i],d[m]]=[d[m],d[i]];}\n        return d;\n    }\n}\nclass MergeSortStrategy implements SortStrategy{\n    sort(data:number[]):number[]{return this.ms([...data]);}\n    ms(d:number[]):number[]{if(d.length<=1)return d;const m=Math.floor(d.length/2);const l=this.ms(d.slice(0,m));const r=this.ms(d.slice(m));const res:number[]=[];let i=0,j=0;while(i<l.length&&j<r.length) res.push(l[i]<=r[j]?l[i++]:r[j++]);return res.concat(l.slice(i)).concat(r.slice(j));}\n}\nclass Sorter{\n    private strategy!:SortStrategy;\n    set_strategy(s:SortStrategy){this.strategy=s;}\n    sort(data:number[]):string{if(!data.length)return '';return this.strategy.sort(data).join(' ');}\n}",
  "cpp": "#include <string>\n#include <vector>\n#include <sstream>\nusing namespace std;\nstruct SortStrategy{virtual vector<int> sort(vector<int> data)=0;virtual ~SortStrategy(){}};\nstruct BubbleSortStrategy:SortStrategy{\n    vector<int> sort(vector<int> d){for(int i=0;i<(int)d.size();i++) for(int j=0;j<(int)d.size()-i-1;j++) if(d[j]>d[j+1]) swap(d[j],d[j+1]);return d;}\n};\nstruct SelectionSortStrategy:SortStrategy{\n    vector<int> sort(vector<int> d){for(int i=0;i<(int)d.size();i++){int m=i;for(int j=i+1;j<(int)d.size();j++) if(d[j]<d[m]) m=j;swap(d[i],d[m]);}return d;}\n};\nstruct MergeSortStrategy:SortStrategy{\n    vector<int> ms(vector<int> d){if(d.size()<=1) return d;int m=d.size()/2;auto l=ms(vector<int>(d.begin(),d.begin()+m));auto r=ms(vector<int>(d.begin()+m,d.end()));vector<int> res;int i=0,j=0;while(i<(int)l.size()&&j<(int)r.size()) res.push_back(l[i]<=r[j]?l[i++]:r[j++]);while(i<(int)l.size()) res.push_back(l[i++]);while(j<(int)r.size()) res.push_back(r[j++]);return res;}\n    vector<int> sort(vector<int> d){return ms(d);}\n};\nclass Sorter{\n    SortStrategy* strategy=nullptr;\npublic:\n    void set_strategy(SortStrategy* s){strategy=s;}\n    string sort(vector<int> data){if(data.empty()) return \"\";auto sorted=strategy->sort(data);string out;for(int i=0;i<(int)sorted.size();i++){if(i) out+=\" \";out+=to_string(sorted[i]);}return out;}\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\nsorter = Sorter()\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"strategy\":\n        if parts[1]==\"bubble\": sorter.set_strategy(BubbleSortStrategy())\n        elif parts[1]==\"selection\": sorter.set_strategy(SelectionSortStrategy())\n        elif parts[1]==\"merge\": sorter.set_strategy(MergeSortStrategy())\n    elif cmd == \"sort\":\n        print(sorter.sort([int(x) for x in parts[1:]]))",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in); Sorter sorter=new Sorter();\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"strategy\")){\n                if(p[1].equals(\"bubble\")) sorter.set_strategy(new BubbleSortStrategy());\n                else if(p[1].equals(\"selection\")) sorter.set_strategy(new SelectionSortStrategy());\n                else if(p[1].equals(\"merge\")) sorter.set_strategy(new MergeSortStrategy());\n            } else if(cmd.equals(\"sort\")){\n                int[] data=new int[p.length-1];\n                for(int i=0;i<data.length;i++) data[i]=Integer.parseInt(p[i+1]);\n                System.out.println(sorter.sort(data));\n            }\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nconst sorter=new Sorter();\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='strategy'){\n        if(p[1]==='bubble') sorter.set_strategy(new BubbleSortStrategy());\n        else if(p[1]==='selection') sorter.set_strategy(new SelectionSortStrategy());\n        else if(p[1]==='merge') sorter.set_strategy(new MergeSortStrategy());\n    } else if(cmd==='sort') console.log(sorter.sort(p.slice(1).map(Number)));\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\n#include <vector>\nusing namespace std;\nint main(){\n    string line; Sorter sorter;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"strategy\"){string s;ss>>s;\n            if(s==\"bubble\") sorter.set_strategy(new BubbleSortStrategy());\n            else if(s==\"selection\") sorter.set_strategy(new SelectionSortStrategy());\n            else if(s==\"merge\") sorter.set_strategy(new MergeSortStrategy());\n        } else if(cmd==\"sort\"){\n            vector<int> data; int v; while(ss>>v) data.push_back(v);\n            cout<<sorter.sort(data)<<\"\\n\";\n        }\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- dp_n07 -------------------------------------------------------
(
'dp_n07',
'Builder Pattern — Pizza Order',
'Design Patterns', 'Hard', 'python', 'Python / Design Patterns',
$$Implement the Builder pattern to construct complex pizza orders step by step.

**Requirements:**
- `Pizza(size, crust, sauce, toppings, extra_cheese)` — `describe() -> str`:
  ```
  {size} pizza on {crust} crust with {sauce} sauce
  Toppings: {t1}, {t2}, ...   (or "No toppings")
  Extra cheese: Yes / No
  ```
- `PizzaBuilder` — fluent: `set_size`, `set_crust`, `set_sauce`, `add_topping`, `add_extra_cheese`, `build() -> Pizza`

**Constraints:**
- Defaults: size=`"Medium"`, crust=`"Thin"`, sauce=`"Tomato"`, toppings=`[]`, extra_cheese=`False`
- `build()` resets builder state so it can be reused$$,

$$class Pizza:
    def __init__(self, size, crust, sauce, toppings, extra_cheese):
        self.size = size; self.crust = crust; self.sauce = sauce
        self.toppings = toppings; self.extra_cheese = extra_cheese

    def describe(self) -> str:
        pass

class PizzaBuilder:
    def __init__(self):
        self._reset()

    def _reset(self):
        pass

    def set_size(self, size: str):
        pass

    def set_crust(self, crust: str):
        pass

    def set_sauce(self, sauce: str):
        pass

    def add_topping(self, topping: str):
        pass

    def add_extra_cheese(self):
        pass

    def build(self) -> Pizza:
        pass$$,

$TC$[
  {"input": "size Large\ncrust Thick\nsauce BBQ\ntopping Pepperoni\ntopping Mushrooms\nbuild\ndescribe", "expected_output": "Large pizza on Thick crust with BBQ sauce\nToppings: Pepperoni, Mushrooms\nExtra cheese: No", "description": "Full pizza with two toppings"},
  {"input": "build\ndescribe", "expected_output": "Medium pizza on Thin crust with Tomato sauce\nNo toppings\nExtra cheese: No", "description": "Default pizza"},
  {"input": "size Small\ncheese\nbuild\ndescribe", "expected_output": "Small pizza on Thin crust with Tomato sauce\nNo toppings\nExtra cheese: Yes", "description": "Extra cheese added"},
  {"input": "size Large\ncrust Thick\nsauce BBQ\ntopping Pepperoni\nbuild\nsize Medium\ntopping Olives\nbuild\ndescribe", "expected_output": "Medium pizza on Thin crust with Tomato sauce\nToppings: Olives\nExtra cheese: No", "description": "Builder resets after build"},
  {"input": "topping Pepperoni\ntopping Onions\ntopping Peppers\nbuild\ndescribe", "expected_output": "Medium pizza on Thin crust with Tomato sauce\nToppings: Pepperoni, Onions, Peppers\nExtra cheese: No", "description": "Three toppings in order"}
]$TC$::jsonb,

NULL,

$SC${"python": "class Pizza:\n    def __init__(self, size, crust, sauce, toppings, extra_cheese):\n        self.size=size; self.crust=crust; self.sauce=sauce; self.toppings=toppings; self.extra_cheese=extra_cheese\n    def describe(self) -> str: pass\nclass PizzaBuilder:\n    def __init__(self): self._reset()\n    def _reset(self): pass\n    def set_size(self, size): pass\n    def set_crust(self, crust): pass\n    def set_sauce(self, sauce): pass\n    def add_topping(self, topping): pass\n    def add_extra_cheese(self): pass\n    def build(self): pass",
  "java": "import java.util.*;\nclass Pizza{\n    String size,crust,sauce; List<String> toppings; boolean extraCheese;\n    Pizza(String size,String crust,String sauce,List<String> toppings,boolean ec){\n        this.size=size;this.crust=crust;this.sauce=sauce;this.toppings=toppings;this.extraCheese=ec;\n    }\n    String describe(){\n        String t=toppings.isEmpty()?\"No toppings\":\"Toppings: \"+String.join(\", \",toppings);\n        return size+\" pizza on \"+crust+\" crust with \"+sauce+\" sauce\\n\"+t+\"\\nExtra cheese: \"+(extraCheese?\"Yes\":\"No\");\n    }\n}\nclass PizzaBuilder{\n    String size=\"Medium\",crust=\"Thin\",sauce=\"Tomato\"; List<String> toppings=new ArrayList<>(); boolean ec=false;\n    PizzaBuilder set_size(String s){size=s;return this;}\n    PizzaBuilder set_crust(String c){crust=c;return this;}\n    PizzaBuilder set_sauce(String s){sauce=s;return this;}\n    PizzaBuilder add_topping(String t){toppings.add(t);return this;}\n    PizzaBuilder add_extra_cheese(){ec=true;return this;}\n    Pizza build(){Pizza p=new Pizza(size,crust,sauce,toppings,ec);size=\"Medium\";crust=\"Thin\";sauce=\"Tomato\";toppings=new ArrayList<>();ec=false;return p;}\n}",
  "typescript": "class Pizza{\n    constructor(public size:string,public crust:string,public sauce:string,public toppings:string[],public extraCheese:boolean){}\n    describe():string{\n        const t=this.toppings.length?'Toppings: '+this.toppings.join(', '):'No toppings';\n        return `${this.size} pizza on ${this.crust} crust with ${this.sauce} sauce\\n${t}\\nExtra cheese: ${this.extraCheese?'Yes':'No'}`;\n    }\n}\nclass PizzaBuilder{\n    private size='Medium';private crust='Thin';private sauce='Tomato';private toppings:string[]=[];private ec=false;\n    set_size(s:string){this.size=s;return this;}\n    set_crust(c:string){this.crust=c;return this;}\n    set_sauce(s:string){this.sauce=s;return this;}\n    add_topping(t:string){this.toppings.push(t);return this;}\n    add_extra_cheese(){this.ec=true;return this;}\n    build():Pizza{const p=new Pizza(this.size,this.crust,this.sauce,this.toppings,this.ec);this.size='Medium';this.crust='Thin';this.sauce='Tomato';this.toppings=[];this.ec=false;return p;}\n}",
  "cpp": "#include <string>\n#include <vector>\nusing namespace std;\nstruct Pizza{\n    string size,crust,sauce; vector<string> toppings; bool extraCheese;\n    string describe(){\n        string t;\n        if(toppings.empty()) t=\"No toppings\";\n        else{t=\"Toppings: \";for(int i=0;i<(int)toppings.size();i++){if(i)t+=\", \";t+=toppings[i];}}\n        return size+\" pizza on \"+crust+\" crust with \"+sauce+\" sauce\\n\"+t+\"\\nExtra cheese: \"+(extraCheese?\"Yes\":\"No\");\n    }\n};\nclass PizzaBuilder{\n    string size=\"Medium\",crust=\"Thin\",sauce=\"Tomato\"; vector<string> toppings; bool ec=false;\npublic:\n    PizzaBuilder& set_size(string s){size=s;return *this;}\n    PizzaBuilder& set_crust(string c){crust=c;return *this;}\n    PizzaBuilder& set_sauce(string s){sauce=s;return *this;}\n    PizzaBuilder& add_topping(string t){toppings.push_back(t);return *this;}\n    PizzaBuilder& add_extra_cheese(){ec=true;return *this;}\n    Pizza build(){Pizza p={size,crust,sauce,toppings,ec};size=\"Medium\";crust=\"Thin\";sauce=\"Tomato\";toppings={};ec=false;return p;}\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\nbuilder = PizzaBuilder()\npizza = None\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"size\": builder.set_size(parts[1])\n    elif cmd == \"crust\": builder.set_crust(parts[1])\n    elif cmd == \"sauce\": builder.set_sauce(parts[1])\n    elif cmd == \"topping\": builder.add_topping(parts[1])\n    elif cmd == \"cheese\": builder.add_extra_cheese()\n    elif cmd == \"build\": pizza = builder.build()\n    elif cmd == \"describe\": print(pizza.describe())",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in);\n        PizzaBuilder b=new PizzaBuilder(); Pizza pizza=null;\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"size\")) b.set_size(p[1]);\n            else if(cmd.equals(\"crust\")) b.set_crust(p[1]);\n            else if(cmd.equals(\"sauce\")) b.set_sauce(p[1]);\n            else if(cmd.equals(\"topping\")) b.add_topping(p[1]);\n            else if(cmd.equals(\"cheese\")) b.add_extra_cheese();\n            else if(cmd.equals(\"build\")) pizza=b.build();\n            else if(cmd.equals(\"describe\")) System.out.println(pizza.describe());\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nconst b=new PizzaBuilder(); let pizza:Pizza|null=null;\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='size') b.set_size(p[1]);\n    else if(cmd==='crust') b.set_crust(p[1]);\n    else if(cmd==='sauce') b.set_sauce(p[1]);\n    else if(cmd==='topping') b.add_topping(p[1]);\n    else if(cmd==='cheese') b.add_extra_cheese();\n    else if(cmd==='build') pizza=b.build();\n    else if(cmd==='describe') console.log(pizza!.describe());\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main(){\n    string line;\n    PizzaBuilder b; Pizza* pizza=nullptr;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"size\"){string s;ss>>s;b.set_size(s);}\n        else if(cmd==\"crust\"){string s;ss>>s;b.set_crust(s);}\n        else if(cmd==\"sauce\"){string s;ss>>s;b.set_sauce(s);}\n        else if(cmd==\"topping\"){string s;ss>>s;b.add_topping(s);}\n        else if(cmd==\"cheese\") b.add_extra_cheese();\n        else if(cmd==\"build\"){static Pizza p;p=b.build();pizza=&p;}\n        else if(cmd==\"describe\") cout<<pizza->describe()<<\"\\n\";\n    }\n    return 0;\n}"
}$TH$::jsonb
);

-- ============================================================
-- SYSTEM DESIGN CHALLENGES
-- ============================================================

INSERT INTO challenges (id, title, topic, difficulty, language, framework,
    description, starter_code, test_cases, test_harness, starter_codes, test_harnesses) VALUES (

-- sys_n01 -------------------------------------------------------
'sys_n01',
'LRU Cache',
'System Design', 'Medium', 'python', 'Python / System Design',
$$Implement a Least Recently Used (LRU) cache with O(1) get and put.

**Requirements:**
- `LRUCache(capacity)` — fixed-size cache
  - `get(key) -> int` — return value or `-1`; marks key as recently used
  - `put(key, value)` — insert or update; evict LRU entry first if at capacity
  - `size() -> int` — current number of entries
  - `contains(key) -> bool` — membership check without updating recency

**Constraints:**
- `capacity >= 1`; keys and values are integers
- Target O(1) for `get` and `put` (use `OrderedDict` or doubly-linked list)$$,

$$from collections import OrderedDict

class LRUCache:
    def __init__(self, capacity: int):
        pass

    def get(self, key: int) -> int:
        pass

    def put(self, key: int, value: int):
        pass

    def size(self) -> int:
        pass

    def contains(self, key: int) -> bool:
        pass$$,

$TC$[
  {"input": "init 2\nput 1 10\nput 2 20\nget 1", "expected_output": "10", "description": "Get existing key"},
  {"input": "init 2\nget 99", "expected_output": "-1", "description": "Get missing key returns -1"},
  {"input": "init 2\nput 1 10\nput 2 20\nput 3 30\nget 1", "expected_output": "-1", "description": "LRU evicted when capacity exceeded"},
  {"input": "init 2\nput 1 10\nput 2 20\nget 1\nput 3 30\nget 2", "expected_output": "10\n-1", "description": "Access refreshes recency; key 2 evicted"},
  {"input": "init 3\nput 1 1\nput 2 2\nput 3 3\nsize", "expected_output": "3", "description": "Size reflects entries"},
  {"input": "init 2\nput 1 10\nput 1 99\nget 1", "expected_output": "99", "description": "Update replaces value"},
  {"input": "init 2\nput 1 10\ncontains 1\ncontains 2", "expected_output": "True\nFalse", "description": "Contains checks presence"}
]$TC$::jsonb,

NULL,

$SC${"python": "from collections import OrderedDict\nclass LRUCache:\n    def __init__(self, capacity: int): pass\n    def get(self, key: int) -> int: pass\n    def put(self, key: int, value: int): pass\n    def size(self) -> int: pass\n    def contains(self, key: int) -> bool: pass",
  "java": "import java.util.*;\nclass LRUCache{\n    int capacity; LinkedHashMap<Integer,Integer> map;\n    LRUCache(int capacity){\n        this.capacity=capacity;\n        map=new LinkedHashMap<>(16,0.75f,true);\n    }\n    int get(int key){\n        // TODO: return value or -1; update recency\n        return -1;\n    }\n    void put(int key,int value){\n        // TODO: insert/update; evict LRU if needed\n    }\n    int size(){return map.size();}\n    boolean contains(int key){return map.containsKey(key);}\n}",
  "typescript": "class LRUCache{\n    private capacity:number;\n    private map=new Map<number,number>();\n    constructor(capacity:number){this.capacity=capacity;}\n    get(key:number):number{\n        // TODO: return value or -1; update recency\n        return -1;\n    }\n    put(key:number,value:number){\n        // TODO: insert/update; evict LRU if needed\n    }\n    size():number{return this.map.size;}\n    contains(key:number):boolean{return this.map.has(key);}\n}",
  "cpp": "#include <unordered_map>\n#include <list>\n#include <utility>\nusing namespace std;\nclass LRUCache{\n    int capacity;\n    list<pair<int,int>> order;\n    unordered_map<int,list<pair<int,int>>::iterator> map;\npublic:\n    LRUCache(int cap):capacity(cap){}\n    int get(int key){\n        // TODO: return value or -1; move to front\n        return -1;\n    }\n    void put(int key,int value){\n        // TODO: insert/update; evict LRU if at capacity\n    }\n    int size(){return map.size();}\n    bool contains(int key){return map.count(key)>0;}\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\ncache = None\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"init\": cache = LRUCache(int(parts[1]))\n    elif cmd == \"put\": cache.put(int(parts[1]),int(parts[2]))\n    elif cmd == \"get\": print(cache.get(int(parts[1])))\n    elif cmd == \"size\": print(cache.size())\n    elif cmd == \"contains\": print(cache.contains(int(parts[1])))",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in); LRUCache cache=null;\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"init\")) cache=new LRUCache(Integer.parseInt(p[1]));\n            else if(cmd.equals(\"put\")) cache.put(Integer.parseInt(p[1]),Integer.parseInt(p[2]));\n            else if(cmd.equals(\"get\")) System.out.println(cache.get(Integer.parseInt(p[1])));\n            else if(cmd.equals(\"size\")) System.out.println(cache.size());\n            else if(cmd.equals(\"contains\")) System.out.println(cache.contains(Integer.parseInt(p[1]))?\"True\":\"False\");\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nlet cache:LRUCache|null=null;\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='init') cache=new LRUCache(parseInt(p[1]));\n    else if(cmd==='put') cache!.put(parseInt(p[1]),parseInt(p[2]));\n    else if(cmd==='get') console.log(cache!.get(parseInt(p[1])));\n    else if(cmd==='size') console.log(cache!.size());\n    else if(cmd==='contains') console.log(cache!.contains(parseInt(p[1]))?'True':'False');\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main(){\n    string line; LRUCache* cache=nullptr;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"init\"){int c;ss>>c;cache=new LRUCache(c);}\n        else if(cmd==\"put\"){int k,v;ss>>k>>v;cache->put(k,v);}\n        else if(cmd==\"get\"){int k;ss>>k;cout<<cache->get(k)<<\"\\n\";}\n        else if(cmd==\"size\") cout<<cache->size()<<\"\\n\";\n        else if(cmd==\"contains\"){int k;ss>>k;cout<<(cache->contains(k)?\"True\":\"False\")<<\"\\n\";}\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- sys_n02 -------------------------------------------------------
(
'sys_n02',
'Token Bucket Rate Limiter',
'System Design', 'Medium', 'python', 'Python / System Design',
$$Implement a token bucket rate limiter that controls request throughput.

**Requirements:**
- `RateLimiter(capacity, refill_rate)` — `capacity` = max tokens; `refill_rate` = tokens/second; starts full
  - `allow(tokens=1) -> bool` — consume if available; `True` on success, `False` if insufficient
  - `refill(seconds)` — add `refill_rate * seconds` tokens (capped at capacity)
  - `available() -> int` — floor of current token count

**Constraints:**
- No real time — only `refill()` advances the token count
- Tokens never exceed capacity$$,

$$import math

class RateLimiter:
    def __init__(self, capacity: int, refill_rate: float):
        pass

    def allow(self, tokens: int = 1) -> bool:
        pass

    def refill(self, seconds: float):
        pass

    def available(self) -> int:
        pass$$,

$TC$[
  {"input": "init 10 1.0\navailable", "expected_output": "10", "description": "Starts at capacity"},
  {"input": "init 5 1.0\nallow 3\navailable", "expected_output": "True\n2", "description": "Consume tokens reduces available"},
  {"input": "init 3 1.0\nallow 5", "expected_output": "False", "description": "Cannot consume more than available"},
  {"input": "init 5 2.0\nallow 5\nrefill 2.0\navailable", "expected_output": "True\n4", "description": "Refill adds tokens"},
  {"input": "init 5 1.0\nallow 5\nrefill 10.0\navailable", "expected_output": "True\n5", "description": "Refill capped at capacity"},
  {"input": "init 2 1.0\nallow 1\nallow 1\nallow 1", "expected_output": "True\nTrue\nFalse", "description": "Empty bucket rejects requests"}
]$TC$::jsonb,

NULL,

$SC${"python": "import math\nclass RateLimiter:\n    def __init__(self, capacity: int, refill_rate: float): pass\n    def allow(self, tokens: int = 1) -> bool: pass\n    def refill(self, seconds: float): pass\n    def available(self) -> int: pass",
  "java": "class RateLimiter{\n    int capacity; double rate, tokens;\n    RateLimiter(int capacity, double rate){this.capacity=capacity;this.rate=rate;this.tokens=capacity;}\n    boolean allow(int n){\n        // TODO: consume n tokens if available\n        return false;\n    }\n    void refill(double seconds){\n        // TODO: add rate*seconds tokens, cap at capacity\n    }\n    int available(){return (int)tokens;}\n}",
  "typescript": "class RateLimiter{\n    private tokens:number;\n    constructor(private capacity:number,private rate:number){this.tokens=capacity;}\n    allow(n:number=1):boolean{\n        // TODO\n        return false;\n    }\n    refill(seconds:number){\n        // TODO\n    }\n    available():number{return Math.floor(this.tokens);}\n}",
  "cpp": "#include <cmath>\nclass RateLimiter{\n    int capacity; double rate, tokens;\npublic:\n    RateLimiter(int cap,double rate):capacity(cap),rate(rate),tokens(cap){}\n    bool allow(int n=1){\n        // TODO\n        return false;\n    }\n    void refill(double seconds){\n        // TODO\n    }\n    int available(){return (int)tokens;}\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys, math\nlimiter = None\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"init\": limiter = RateLimiter(int(parts[1]),float(parts[2]))\n    elif cmd == \"allow\": print(limiter.allow(int(parts[1]) if len(parts)>1 else 1))\n    elif cmd == \"refill\": limiter.refill(float(parts[1]))\n    elif cmd == \"available\": print(limiter.available())",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in); RateLimiter lim=null;\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"init\")) lim=new RateLimiter(Integer.parseInt(p[1]),Double.parseDouble(p[2]));\n            else if(cmd.equals(\"allow\")) System.out.println(lim.allow(p.length>1?Integer.parseInt(p[1]):1)?\"True\":\"False\");\n            else if(cmd.equals(\"refill\")) lim.refill(Double.parseDouble(p[1]));\n            else if(cmd.equals(\"available\")) System.out.println(lim.available());\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nlet lim:RateLimiter|null=null;\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='init') lim=new RateLimiter(parseInt(p[1]),parseFloat(p[2]));\n    else if(cmd==='allow') console.log(lim!.allow(p[1]?parseInt(p[1]):1)?'True':'False');\n    else if(cmd==='refill') lim!.refill(parseFloat(p[1]));\n    else if(cmd==='available') console.log(lim!.available());\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main(){\n    string line; RateLimiter* lim=nullptr;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"init\"){int c;double r;ss>>c>>r;lim=new RateLimiter(c,r);}\n        else if(cmd==\"allow\"){int n=1;ss>>n;cout<<(lim->allow(n)?\"True\":\"False\")<<\"\\n\";}\n        else if(cmd==\"refill\"){double s;ss>>s;lim->refill(s);}\n        else if(cmd==\"available\") cout<<lim->available()<<\"\\n\";\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- sys_n03 -------------------------------------------------------
(
'sys_n03',
'In-Memory Event Bus',
'System Design', 'Medium', 'python', 'Python / System Design',
$$Design a publish-subscribe event bus that decouples producers from consumers.

**Requirements:**
- `EventBus`:
  - `subscribe(event_type, handler_name)` — register; ignore duplicate (same event_type + handler_name)
  - `unsubscribe(event_type, handler_name)` — remove; silently ignore if not registered
  - `publish(event_type, data)` — invoke handlers in subscription order, each printing `"[{handler_name}] received {event_type}: {data}"`
  - `subscriber_count(event_type) -> int`

**Constraints:**
- Multiple event types independent; one handler can subscribe to multiple types
- `publish` on type with no subscribers produces no output$$,

$$class EventBus:
    def __init__(self):
        pass

    def subscribe(self, event_type: str, handler_name: str):
        pass

    def unsubscribe(self, event_type: str, handler_name: str):
        pass

    def publish(self, event_type: str, data: str):
        pass

    def subscriber_count(self, event_type: str) -> int:
        pass$$,

$TC$[
  {"input": "subscribe login AuthService\npublish login UserJoined", "expected_output": "[AuthService] received login: UserJoined", "description": "Single subscriber receives event"},
  {"input": "subscribe order Warehouse\nsubscribe order Billing\npublish order NewOrder123", "expected_output": "[Warehouse] received order: NewOrder123\n[Billing] received order: NewOrder123", "description": "Two subscribers notified in order"},
  {"input": "publish nothing NoOne", "expected_output": "", "description": "No subscribers produces no output"},
  {"input": "subscribe click Logger\nsubscribe click Logger\ncount click", "expected_output": "1", "description": "Duplicate subscription ignored"},
  {"input": "subscribe login AuthService\nunsubscribe login AuthService\npublish login Test", "expected_output": "", "description": "Unsubscribed handler not notified"},
  {"input": "subscribe payment PaySvc\nsubscribe payment AuditSvc\nunsubscribe payment PaySvc\npublish payment Paid", "expected_output": "[AuditSvc] received payment: Paid", "description": "Remaining subscriber notified after one unsubscribes"},
  {"input": "subscribe login A\nsubscribe order A\npublish login Hit\npublish order Miss\ncount login", "expected_output": "[A] received login: Hit\n[A] received order: Miss\n1", "description": "Handler subscribed to multiple event types"}
]$TC$::jsonb,

NULL,

$SC${"python": "class EventBus:\n    def __init__(self): pass\n    def subscribe(self, event_type: str, handler_name: str): pass\n    def unsubscribe(self, event_type: str, handler_name: str): pass\n    def publish(self, event_type: str, data: str): pass\n    def subscriber_count(self, event_type: str) -> int: pass",
  "java": "import java.util.*;\nclass EventBus{\n    Map<String,List<String>> subs=new HashMap<>();\n    void subscribe(String event,String handler){\n        subs.computeIfAbsent(event,k->new ArrayList<>());\n        if(!subs.get(event).contains(handler)) subs.get(event).add(handler);\n    }\n    void unsubscribe(String event,String handler){\n        if(subs.containsKey(event)) subs.get(event).remove(handler);\n    }\n    void publish(String event,String data){\n        if(!subs.containsKey(event)) return;\n        for(String h:subs.get(event)) System.out.println(\"[\"+h+\"] received \"+event+\": \"+data);\n    }\n    int subscriber_count(String event){return subs.getOrDefault(event,Collections.emptyList()).size();}\n}",
  "typescript": "class EventBus{\n    private subs=new Map<string,string[]>();\n    subscribe(event:string,handler:string){\n        if(!this.subs.has(event)) this.subs.set(event,[]);\n        const list=this.subs.get(event)!;\n        if(!list.includes(handler)) list.push(handler);\n    }\n    unsubscribe(event:string,handler:string){\n        const list=this.subs.get(event)||[];\n        const i=list.indexOf(handler); if(i>=0) list.splice(i,1);\n    }\n    publish(event:string,data:string){\n        for(const h of (this.subs.get(event)||[])) console.log(`[${h}] received ${event}: ${data}`);\n    }\n    subscriber_count(event:string):number{return (this.subs.get(event)||[]).length;}\n}",
  "cpp": "#include <string>\n#include <vector>\n#include <map>\n#include <algorithm>\n#include <iostream>\nusing namespace std;\nclass EventBus{\n    map<string,vector<string>> subs;\npublic:\n    void subscribe(string event,string handler){\n        auto& v=subs[event];\n        if(find(v.begin(),v.end(),handler)==v.end()) v.push_back(handler);\n    }\n    void unsubscribe(string event,string handler){\n        if(!subs.count(event)) return;\n        auto& v=subs[event]; v.erase(find(v.begin(),v.end(),handler),v.end());\n    }\n    void publish(string event,string data){\n        if(!subs.count(event)) return;\n        for(auto& h:subs[event]) cout<<\"[\"<<h<<\"] received \"<<event<<\": \"<<data<<\"\\n\";\n    }\n    int subscriber_count(string event){return subs.count(event)?subs[event].size():0;}\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\nbus = EventBus()\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"subscribe\": bus.subscribe(parts[1],parts[2])\n    elif cmd == \"unsubscribe\": bus.unsubscribe(parts[1],parts[2])\n    elif cmd == \"publish\": bus.publish(parts[1],parts[2] if len(parts)>2 else \"\")\n    elif cmd == \"count\": print(bus.subscriber_count(parts[1]))",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in); EventBus bus=new EventBus();\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"subscribe\")) bus.subscribe(p[1],p[2]);\n            else if(cmd.equals(\"unsubscribe\")) bus.unsubscribe(p[1],p[2]);\n            else if(cmd.equals(\"publish\")) bus.publish(p[1],p.length>2?p[2]:\"\");\n            else if(cmd.equals(\"count\")) System.out.println(bus.subscriber_count(p[1]));\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nconst bus=new EventBus();\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='subscribe') bus.subscribe(p[1],p[2]);\n    else if(cmd==='unsubscribe') bus.unsubscribe(p[1],p[2]);\n    else if(cmd==='publish') bus.publish(p[1],p[2]||'');\n    else if(cmd==='count') console.log(bus.subscriber_count(p[1]));\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main(){\n    string line; EventBus bus;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"subscribe\"){string e,h;ss>>e>>h;bus.subscribe(e,h);}\n        else if(cmd==\"unsubscribe\"){string e,h;ss>>e>>h;bus.unsubscribe(e,h);}\n        else if(cmd==\"publish\"){string e,d;ss>>e;if(ss>>d){}else d=\"\";bus.publish(e,d);}\n        else if(cmd==\"count\"){string e;ss>>e;cout<<bus.subscriber_count(e)<<\"\\n\";}\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- sys_n04 -------------------------------------------------------
(
'sys_n04',
'Priority Job Queue',
'System Design', 'Hard', 'python', 'Python / System Design',
$$Build a priority queue for a job scheduler where higher-priority jobs run first.

**Requirements:**
- `Job(job_id, name, priority)` — higher `priority` = runs first
- `JobQueue`:
  - `enqueue(job_id, name, priority) -> str` — `"Job {id} enqueued."` / `"Job {id} already in queue."`
  - `dequeue() -> str` — `"Running: {name} (priority={priority})"` / `"Queue is empty."`
  - `peek() -> str` — `"Next: {name} (priority={priority})"` without removing / `"Queue is empty."`
  - `size() -> int`
  - `cancel(job_id) -> str` — `"Job {id} cancelled."` / `"Job {id} not found."`

**Constraints:**
- Ties in priority broken by FIFO (earlier enqueue runs first)
- Use a heap internally$$,

$$import heapq

class Job:
    def __init__(self, job_id: int, name: str, priority: int):
        self.job_id = job_id
        self.name = name
        self.priority = priority

class JobQueue:
    def __init__(self):
        pass

    def enqueue(self, job_id: int, name: str, priority: int) -> str:
        pass

    def dequeue(self) -> str:
        pass

    def peek(self) -> str:
        pass

    def size(self) -> int:
        pass

    def cancel(self, job_id: int) -> str:
        pass$$,

$TC$[
  {"input": "enqueue 1 EmailSend 5\nenqueue 2 DBBackup 10\ndequeue", "expected_output": "Job 1 enqueued.\nJob 2 enqueued.\nRunning: DBBackup (priority=10)", "description": "Higher priority dequeues first"},
  {"input": "dequeue", "expected_output": "Queue is empty.", "description": "Dequeue empty queue"},
  {"input": "enqueue 1 Alpha 5\nenqueue 2 Beta 5\ndequeue\ndequeue", "expected_output": "Job 1 enqueued.\nJob 2 enqueued.\nRunning: Alpha (priority=5)\nRunning: Beta (priority=5)", "description": "FIFO tiebreak for equal priority"},
  {"input": "enqueue 1 Alpha 3\npeek\nsize", "expected_output": "Job 1 enqueued.\nNext: Alpha (priority=3)\n1", "description": "Peek does not remove"},
  {"input": "enqueue 1 Alpha 5\nenqueue 1 Dup 3", "expected_output": "Job 1 enqueued.\nJob 1 already in queue.", "description": "Duplicate job ID rejected"},
  {"input": "enqueue 1 Alpha 5\nenqueue 2 Beta 3\ncancel 1\ndequeue", "expected_output": "Job 1 enqueued.\nJob 2 enqueued.\nJob 1 cancelled.\nRunning: Beta (priority=3)", "description": "Cancel removes job"},
  {"input": "cancel 99", "expected_output": "Job 99 not found.", "description": "Cancel nonexistent job"}
]$TC$::jsonb,

NULL,

$SC${"python": "import heapq\nclass Job:\n    def __init__(self, job_id, name, priority): self.job_id=job_id; self.name=name; self.priority=priority\nclass JobQueue:\n    def __init__(self): pass\n    def enqueue(self, job_id, name, priority) -> str: pass\n    def dequeue(self) -> str: pass\n    def peek(self) -> str: pass\n    def size(self) -> int: pass\n    def cancel(self, job_id) -> str: pass",
  "java": "import java.util.*;\nclass Job{int id,priority;String name;long seq;Job(int id,String name,int priority,long seq){this.id=id;this.name=name;this.priority=priority;this.seq=seq;}}\nclass JobQueue{\n    PriorityQueue<Job> heap=new PriorityQueue<>((a,b)->a.priority!=b.priority?b.priority-a.priority:(int)(a.seq-b.seq));\n    Set<Integer> ids=new HashSet<>();\n    Set<Integer> cancelled=new HashSet<>();\n    long counter=0;\n    String enqueue(int id,String name,int priority){\n        if(ids.contains(id)) return \"Job \"+id+\" already in queue.\";\n        ids.add(id); heap.add(new Job(id,name,priority,counter++));\n        return \"Job \"+id+\" enqueued.\";\n    }\n    String dequeue(){\n        while(!heap.isEmpty()&&cancelled.contains(heap.peek().id)) heap.poll();\n        if(heap.isEmpty()) return \"Queue is empty.\";\n        Job j=heap.poll(); ids.remove(j.id);\n        return \"Running: \"+j.name+\" (priority=\"+j.priority+\")\";\n    }\n    String peek(){\n        while(!heap.isEmpty()&&cancelled.contains(heap.peek().id)) heap.poll();\n        if(heap.isEmpty()) return \"Queue is empty.\";\n        Job j=heap.peek(); return \"Next: \"+j.name+\" (priority=\"+j.priority+\")\";\n    }\n    int size(){return (int)(ids.size()-cancelled.size());}\n    String cancel(int id){\n        if(!ids.contains(id)) return \"Job \"+id+\" not found.\";\n        cancelled.add(id); ids.remove(id);\n        return \"Job \"+id+\" cancelled.\";\n    }\n}",
  "typescript": "class Job{constructor(public id:number,public name:string,public priority:number,public seq:number){}}\nclass JobQueue{\n    private heap:Job[]=[];\n    private ids=new Set<number>();\n    private cancelled=new Set<number>();\n    private counter=0;\n    private push(j:Job){this.heap.push(j);this.heap.sort((a,b)=>a.priority!==b.priority?b.priority-a.priority:a.seq-b.seq);}\n    private cleanTop(){while(this.heap.length&&this.cancelled.has(this.heap[0].id)) this.heap.shift();}\n    enqueue(id:number,name:string,priority:number):string{\n        if(this.ids.has(id)) return `Job ${id} already in queue.`;\n        this.ids.add(id); this.push(new Job(id,name,priority,this.counter++));\n        return `Job ${id} enqueued.`;\n    }\n    dequeue():string{\n        this.cleanTop(); if(!this.heap.length) return 'Queue is empty.';\n        const j=this.heap.shift()!; this.ids.delete(j.id);\n        return `Running: ${j.name} (priority=${j.priority})`;\n    }\n    peek():string{\n        this.cleanTop(); if(!this.heap.length) return 'Queue is empty.';\n        const j=this.heap[0]; return `Next: ${j.name} (priority=${j.priority})`;\n    }\n    size():number{return this.ids.size;}\n    cancel(id:number):string{\n        if(!this.ids.has(id)) return `Job ${id} not found.`;\n        this.cancelled.add(id); this.ids.delete(id); return `Job ${id} cancelled.`;\n    }\n}",
  "cpp": "#include <queue>\n#include <unordered_set>\n#include <string>\nusing namespace std;\nstruct Job{int id,priority;string name;long seq;};\nstruct Cmp{bool operator()(const Job& a,const Job& b){return a.priority!=b.priority?a.priority<b.priority:a.seq>b.seq;}};\nclass JobQueue{\n    priority_queue<Job,vector<Job>,Cmp> heap;\n    unordered_set<int> ids,cancelled;\n    long counter=0;\npublic:\n    string enqueue(int id,string name,int priority){\n        if(ids.count(id)) return \"Job \"+to_string(id)+\" already in queue.\";\n        ids.insert(id); heap.push({id,priority,name,counter++});\n        return \"Job \"+to_string(id)+\" enqueued.\";\n    }\n    void clean(){while(!heap.empty()&&cancelled.count(heap.top().id)) heap.pop();}\n    string dequeue(){clean();if(heap.empty()) return \"Queue is empty.\";Job j=heap.top();heap.pop();ids.erase(j.id);return \"Running: \"+j.name+\" (priority=\"+to_string(j.priority)+\")\";}\n    string peek(){clean();if(heap.empty()) return \"Queue is empty.\";Job j=heap.top();return \"Next: \"+j.name+\" (priority=\"+to_string(j.priority)+\")\";}\n    int size(){return ids.size()-cancelled.size();}\n    string cancel(int id){if(!ids.count(id)) return \"Job \"+to_string(id)+\" not found.\";cancelled.insert(id);ids.erase(id);return \"Job \"+to_string(id)+\" cancelled.\";}\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys, heapq\njq = JobQueue()\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"enqueue\": print(jq.enqueue(int(parts[1]),parts[2],int(parts[3])))\n    elif cmd == \"dequeue\": print(jq.dequeue())\n    elif cmd == \"peek\": print(jq.peek())\n    elif cmd == \"size\": print(jq.size())\n    elif cmd == \"cancel\": print(jq.cancel(int(parts[1])))",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in); JobQueue jq=new JobQueue();\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"enqueue\")) System.out.println(jq.enqueue(Integer.parseInt(p[1]),p[2],Integer.parseInt(p[3])));\n            else if(cmd.equals(\"dequeue\")) System.out.println(jq.dequeue());\n            else if(cmd.equals(\"peek\")) System.out.println(jq.peek());\n            else if(cmd.equals(\"size\")) System.out.println(jq.size());\n            else if(cmd.equals(\"cancel\")) System.out.println(jq.cancel(Integer.parseInt(p[1])));\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nconst jq=new JobQueue();\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='enqueue') console.log(jq.enqueue(parseInt(p[1]),p[2],parseInt(p[3])));\n    else if(cmd==='dequeue') console.log(jq.dequeue());\n    else if(cmd==='peek') console.log(jq.peek());\n    else if(cmd==='size') console.log(jq.size());\n    else if(cmd==='cancel') console.log(jq.cancel(parseInt(p[1])));\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main(){\n    string line; JobQueue jq;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"enqueue\"){int id,pri;string name;ss>>id>>name>>pri;cout<<jq.enqueue(id,name,pri)<<\"\\n\";}\n        else if(cmd==\"dequeue\") cout<<jq.dequeue()<<\"\\n\";\n        else if(cmd==\"peek\") cout<<jq.peek()<<\"\\n\";\n        else if(cmd==\"size\") cout<<jq.size()<<\"\\n\";\n        else if(cmd==\"cancel\"){int id;ss>>id;cout<<jq.cancel(id)<<\"\\n\";}\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- sys_n05 -------------------------------------------------------
(
'sys_n05',
'Key-Value Store with TTL',
'System Design', 'Hard', 'python', 'Python / System Design',
$$Build an in-memory key-value store with time-to-live expiry.

**Requirements:**
- `KVStore`:
  - `set(key, value, ttl)` — store; `ttl=0` means no expiry; overwrite resets TTL
  - `get(key) -> str` — value or `"(nil)"` if absent/expired
  - `delete(key) -> str` — `"OK"` / `"(nil)"`
  - `exists(key) -> str` — `"1"` / `"0"`
  - `ttl(key) -> str` — remaining seconds (int), `"-1"` (no expiry), `"-2"` (not found/expired)
  - `tick(seconds)` — advance clock; no output

**Constraints:**
- Clock starts at 0; only `tick` advances time; no `time.time()`
- Key expires at exactly `set_time + ttl`$$,

$$class KVStore:
    def __init__(self):
        pass

    def set(self, key: str, value: str, ttl: int):
        pass

    def get(self, key: str) -> str:
        pass

    def delete(self, key: str) -> str:
        pass

    def exists(self, key: str) -> str:
        pass

    def ttl(self, key: str) -> str:
        pass

    def tick(self, seconds: int):
        pass$$,

$TC$[
  {"input": "set name Alice 0\nget name", "expected_output": "Alice", "description": "Get existing key with no expiry"},
  {"input": "get missing", "expected_output": "(nil)", "description": "Get missing key"},
  {"input": "set x 42 10\ntick 5\nget x", "expected_output": "42", "description": "Key valid before expiry"},
  {"input": "set x 42 10\ntick 10\nget x", "expected_output": "(nil)", "description": "Key expired at TTL"},
  {"input": "set x 42 10\ntick 5\nttl x", "expected_output": "5", "description": "TTL returns remaining time"},
  {"input": "set x 42 0\nttl x", "expected_output": "-1", "description": "TTL -1 means no expiry"},
  {"input": "ttl ghost", "expected_output": "-2", "description": "TTL -2 for nonexistent key"},
  {"input": "set a 1 5\ndelete a\nget a", "expected_output": "OK\n(nil)", "description": "Deleted key not retrievable"},
  {"input": "set a 1 5\ntick 3\nset a 2 10\ntick 8\nget a", "expected_output": "2", "description": "Reset TTL on overwrite"},
  {"input": "set b 1 3\nexists b\ntick 3\nexists b", "expected_output": "1\n0", "description": "Exists returns 0 after expiry"}
]$TC$::jsonb,

NULL,

$SC${"python": "class KVStore:\n    def __init__(self): pass\n    def set(self, key, value, ttl): pass\n    def get(self, key) -> str: pass\n    def delete(self, key) -> str: pass\n    def exists(self, key) -> str: pass\n    def ttl(self, key) -> str: pass\n    def tick(self, seconds): pass",
  "java": "import java.util.*;\nclass KVStore{\n    Map<String,String> data=new HashMap<>();\n    Map<String,Long> expiry=new HashMap<>();\n    long clock=0;\n    boolean alive(String key){return data.containsKey(key)&&(expiry.get(key)==-1||clock<expiry.get(key));}\n    void set(String key,String value,int ttl){data.put(key,value);expiry.put(key,ttl==0?-1L:clock+ttl);}\n    String get(String key){return alive(key)?data.get(key):\"(nil)\";}\n    String delete(String key){if(!alive(key))return \"(nil)\";data.remove(key);expiry.remove(key);return \"OK\";}\n    String exists(String key){return alive(key)?\"1\":\"0\";}\n    String ttl(String key){\n        if(!alive(key)) return \"-2\";\n        long e=expiry.get(key); if(e==-1) return \"-1\";\n        return String.valueOf(e-clock);\n    }\n    void tick(int s){clock+=s;}\n}",
  "typescript": "class KVStore{\n    private data=new Map<string,string>();\n    private expiry=new Map<string,number>();\n    private clock=0;\n    private alive(key:string):boolean{return this.data.has(key)&&(this.expiry.get(key)===-1||this.clock<this.expiry.get(key)!);}\n    set(key:string,value:string,ttl:number){this.data.set(key,value);this.expiry.set(key,ttl===0?-1:this.clock+ttl);}\n    get(key:string):string{return this.alive(key)?this.data.get(key)!:'(nil)';}\n    delete(key:string):string{if(!this.alive(key))return '(nil)';this.data.delete(key);this.expiry.delete(key);return 'OK';}\n    exists(key:string):string{return this.alive(key)?'1':'0';}\n    ttl(key:string):string{if(!this.alive(key))return '-2';const e=this.expiry.get(key)!;if(e===-1)return '-1';return String(e-this.clock);}\n    tick(s:number){this.clock+=s;}\n}",
  "cpp": "#include <string>\n#include <unordered_map>\nusing namespace std;\nclass KVStore{\n    unordered_map<string,string> data;\n    unordered_map<string,long> expiry;\n    long clock=0;\n    bool alive(string k){return data.count(k)&&(expiry[k]==-1||clock<expiry[k]);}\npublic:\n    void set(string k,string v,int ttl){data[k]=v;expiry[k]=ttl==0?-1:clock+ttl;}\n    string get(string k){return alive(k)?data[k]:\"(nil)\";}\n    string del(string k){if(!alive(k))return \"(nil)\";data.erase(k);expiry.erase(k);return \"OK\";}\n    string exists(string k){return alive(k)?\"1\":\"0\";}\n    string ttl(string k){if(!alive(k))return \"-2\";long e=expiry[k];if(e==-1)return \"-1\";return to_string(e-clock);}\n    void tick(int s){clock+=s;}\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\nstore = KVStore()\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"set\": store.set(parts[1],parts[2],int(parts[3]))\n    elif cmd == \"get\": print(store.get(parts[1]))\n    elif cmd == \"delete\": print(store.delete(parts[1]))\n    elif cmd == \"exists\": print(store.exists(parts[1]))\n    elif cmd == \"ttl\": print(store.ttl(parts[1]))\n    elif cmd == \"tick\": store.tick(int(parts[1]))",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in); KVStore s=new KVStore();\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"set\")) s.set(p[1],p[2],Integer.parseInt(p[3]));\n            else if(cmd.equals(\"get\")) System.out.println(s.get(p[1]));\n            else if(cmd.equals(\"delete\")) System.out.println(s.delete(p[1]));\n            else if(cmd.equals(\"exists\")) System.out.println(s.exists(p[1]));\n            else if(cmd.equals(\"ttl\")) System.out.println(s.ttl(p[1]));\n            else if(cmd.equals(\"tick\")) s.tick(Integer.parseInt(p[1]));\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nconst store=new KVStore();\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='set') store.set(p[1],p[2],parseInt(p[3]));\n    else if(cmd==='get') console.log(store.get(p[1]));\n    else if(cmd==='delete') console.log(store.delete(p[1]));\n    else if(cmd==='exists') console.log(store.exists(p[1]));\n    else if(cmd==='ttl') console.log(store.ttl(p[1]));\n    else if(cmd==='tick') store.tick(parseInt(p[1]));\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main(){\n    string line; KVStore s;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"set\"){string k,v;int t;ss>>k>>v>>t;s.set(k,v,t);}\n        else if(cmd==\"get\"){string k;ss>>k;cout<<s.get(k)<<\"\\n\";}\n        else if(cmd==\"delete\"){string k;ss>>k;cout<<s.del(k)<<\"\\n\";}\n        else if(cmd==\"exists\"){string k;ss>>k;cout<<s.exists(k)<<\"\\n\";}\n        else if(cmd==\"ttl\"){string k;ss>>k;cout<<s.ttl(k)<<\"\\n\";}\n        else if(cmd==\"tick\"){int n;ss>>n;s.tick(n);}\n    }\n    return 0;\n}"
}$TH$::jsonb
),

-- sys_n06 -------------------------------------------------------
(
'sys_n06',
'Circuit Breaker',
'System Design', 'Hard', 'python', 'Python / System Design',
$$Implement the Circuit Breaker pattern to protect services from cascading failures.

**Requirements:**
- `CircuitBreaker(failure_threshold, recovery_timeout)` — three states: `CLOSED`, `OPEN`, `HALF_OPEN`
  - `call(success: bool) -> str`:
    - `CLOSED`: on success → `"OK"`; on failure → `"FAIL (n/{threshold})"` accumulating; at threshold → trip to OPEN → `"OPEN: circuit tripped"`
    - `OPEN`: → `"BLOCKED"` without recording
    - `HALF_OPEN`: success → reset to CLOSED, return `"RECOVERED: circuit closed"`; failure → re-trip OPEN, return `"OPEN: circuit tripped"`
  - `tick(seconds)` — advance clock; OPEN → HALF_OPEN when elapsed ≥ `recovery_timeout`
  - `state() -> str` — `"CLOSED"`, `"OPEN"`, or `"HALF_OPEN"`

**Constraints:**
- Failure count resets to 0 on transition to CLOSED
- Use internal clock (start 0); only `tick` advances time$$,

$$class CircuitBreaker:
    CLOSED    = "CLOSED"
    OPEN      = "OPEN"
    HALF_OPEN = "HALF_OPEN"

    def __init__(self, failure_threshold: int, recovery_timeout: int):
        pass

    def call(self, success: bool) -> str:
        pass

    def tick(self, seconds: int):
        pass

    def state(self) -> str:
        pass$$,

$TC$[
  {"input": "init 3 10\nstate", "expected_output": "CLOSED", "description": "Starts CLOSED"},
  {"input": "init 3 10\ncall true\ncall false\ncall false", "expected_output": "OK\nFAIL (1/3)\nFAIL (2/3)", "description": "Failures accumulate in CLOSED"},
  {"input": "init 3 10\ncall false\ncall false\ncall false\nstate", "expected_output": "FAIL (1/3)\nFAIL (2/3)\nOPEN: circuit tripped\nOPEN", "description": "Trips to OPEN at threshold"},
  {"input": "init 3 10\ncall false\ncall false\ncall false\ncall true", "expected_output": "FAIL (1/3)\nFAIL (2/3)\nOPEN: circuit tripped\nBLOCKED", "description": "OPEN blocks all calls"},
  {"input": "init 3 10\ncall false\ncall false\ncall false\ntick 10\nstate", "expected_output": "FAIL (1/3)\nFAIL (2/3)\nOPEN: circuit tripped\nHALF_OPEN", "description": "Moves to HALF_OPEN after timeout"},
  {"input": "init 3 10\ncall false\ncall false\ncall false\ntick 10\ncall true\nstate", "expected_output": "FAIL (1/3)\nFAIL (2/3)\nOPEN: circuit tripped\nRECOVERED: circuit closed\nCLOSED", "description": "Success in HALF_OPEN resets to CLOSED"},
  {"input": "init 3 10\ncall false\ncall false\ncall false\ntick 10\ncall false\nstate", "expected_output": "FAIL (1/3)\nFAIL (2/3)\nOPEN: circuit tripped\nOPEN: circuit tripped\nOPEN", "description": "Failure in HALF_OPEN re-trips"}
]$TC$::jsonb,

NULL,

$SC${"python": "class CircuitBreaker:\n    CLOSED = \"CLOSED\"; OPEN = \"OPEN\"; HALF_OPEN = \"HALF_OPEN\"\n    def __init__(self, failure_threshold, recovery_timeout): pass\n    def call(self, success: bool) -> str: pass\n    def tick(self, seconds: int): pass\n    def state(self) -> str: pass",
  "java": "class CircuitBreaker{\n    static final String CLOSED=\"CLOSED\",OPEN=\"OPEN\",HALF_OPEN=\"HALF_OPEN\";\n    int threshold,timeout,failures=0; long clock=0,openedAt=0; String state=CLOSED;\n    CircuitBreaker(int t,int to){threshold=t;timeout=to;}\n    String call(boolean success){\n        if(state.equals(OPEN)) return \"BLOCKED\";\n        if(state.equals(HALF_OPEN)){\n            if(success){state=CLOSED;failures=0;return \"RECOVERED: circuit closed\";}\n            else{state=OPEN;openedAt=clock;return \"OPEN: circuit tripped\";}\n        }\n        if(success) return \"OK\";\n        failures++;\n        if(failures>=threshold){state=OPEN;openedAt=clock;return \"OPEN: circuit tripped\";}\n        return \"FAIL (\"+failures+\"/\"+threshold+\")\";\n    }\n    void tick(int s){clock+=s;if(state.equals(OPEN)&&clock-openedAt>=timeout) state=HALF_OPEN;}\n    String state(){return state;}\n}",
  "typescript": "class CircuitBreaker{\n    static CLOSED='CLOSED';static OPEN='OPEN';static HALF_OPEN='HALF_OPEN';\n    private threshold:number;private timeout:number;\n    private failures=0;private clock=0;private openedAt=0;private _state='CLOSED';\n    constructor(threshold:number,timeout:number){this.threshold=threshold;this.timeout=timeout;}\n    call(success:boolean):string{\n        if(this._state===CircuitBreaker.OPEN) return 'BLOCKED';\n        if(this._state===CircuitBreaker.HALF_OPEN){\n            if(success){this._state=CircuitBreaker.CLOSED;this.failures=0;return 'RECOVERED: circuit closed';}\n            else{this._state=CircuitBreaker.OPEN;this.openedAt=this.clock;return 'OPEN: circuit tripped';}\n        }\n        if(success) return 'OK';\n        this.failures++;\n        if(this.failures>=this.threshold){this._state=CircuitBreaker.OPEN;this.openedAt=this.clock;return 'OPEN: circuit tripped';}\n        return `FAIL (${this.failures}/${this.threshold})`;\n    }\n    tick(s:number){this.clock+=s;if(this._state===CircuitBreaker.OPEN&&this.clock-this.openedAt>=this.timeout) this._state=CircuitBreaker.HALF_OPEN;}\n    state():string{return this._state;}\n}",
  "cpp": "#include <string>\nusing namespace std;\nclass CircuitBreaker{\n    int threshold,timeout,failures=0; long clock=0,openedAt=0; string _state=\"CLOSED\";\npublic:\n    CircuitBreaker(int t,int to):threshold(t),timeout(to){}\n    string call(bool success){\n        if(_state==\"OPEN\") return \"BLOCKED\";\n        if(_state==\"HALF_OPEN\"){\n            if(success){_state=\"CLOSED\";failures=0;return \"RECOVERED: circuit closed\";}\n            else{_state=\"OPEN\";openedAt=clock;return \"OPEN: circuit tripped\";}\n        }\n        if(success) return \"OK\";\n        failures++;\n        if(failures>=threshold){_state=\"OPEN\";openedAt=clock;return \"OPEN: circuit tripped\";}\n        return \"FAIL (\"+to_string(failures)+\"/\"+to_string(threshold)+\")\";\n    }\n    void tick(int s){clock+=s;if(_state==\"OPEN\"&&clock-openedAt>=timeout) _state=\"HALF_OPEN\";}\n    string state(){return _state;}\n};"
}$SC$::jsonb,

$TH${
  "python": "import sys\ncb = None\nfor line in sys.stdin:\n    line = line.strip()\n    if not line: continue\n    parts = line.split()\n    cmd = parts[0]\n    if cmd == \"init\": cb = CircuitBreaker(int(parts[1]),int(parts[2]))\n    elif cmd == \"call\": print(cb.call(parts[1].lower()==\"true\"))\n    elif cmd == \"tick\": cb.tick(int(parts[1]))\n    elif cmd == \"state\": print(cb.state())",
  "java": "import java.util.Scanner;\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc=new Scanner(System.in); CircuitBreaker cb=null;\n        while(sc.hasNextLine()){\n            String line=sc.nextLine().trim(); if(line.isEmpty()) continue;\n            String[] p=line.split(\" \"); String cmd=p[0];\n            if(cmd.equals(\"init\")) cb=new CircuitBreaker(Integer.parseInt(p[1]),Integer.parseInt(p[2]));\n            else if(cmd.equals(\"call\")) System.out.println(cb.call(p[1].equals(\"true\")));\n            else if(cmd.equals(\"tick\")) cb.tick(Integer.parseInt(p[1]));\n            else if(cmd.equals(\"state\")) System.out.println(cb.state());\n        }\n    }\n}",
  "typescript": "import * as readline from 'readline';\nconst rl=readline.createInterface({input:process.stdin});\nlet cb:CircuitBreaker|null=null;\nrl.on('line',(line)=>{\n    line=line.trim(); if(!line) return;\n    const p=line.split(' '); const cmd=p[0];\n    if(cmd==='init') cb=new CircuitBreaker(parseInt(p[1]),parseInt(p[2]));\n    else if(cmd==='call') console.log(cb!.call(p[1]==='true'));\n    else if(cmd==='tick') cb!.tick(parseInt(p[1]));\n    else if(cmd==='state') console.log(cb!.state());\n});",
  "cpp": "#include <iostream>\n#include <sstream>\n#include <string>\nusing namespace std;\nint main(){\n    string line; CircuitBreaker* cb=nullptr;\n    while(getline(cin,line)){\n        if(line.empty()) continue;\n        istringstream ss(line); string cmd; ss>>cmd;\n        if(cmd==\"init\"){int t,to;ss>>t>>to;cb=new CircuitBreaker(t,to);}\n        else if(cmd==\"call\"){string s;ss>>s;cout<<cb->call(s==\"true\")<<\"\\n\";}\n        else if(cmd==\"tick\"){int s;ss>>s;cb->tick(s);}\n        else if(cmd==\"state\") cout<<cb->state()<<\"\\n\";\n    }\n    return 0;\n}"
}$TH$::jsonb
);

-- ============================================================
-- LEARNING PATHS
-- ============================================================

INSERT INTO paths (slug, title, description, topic, icon, order_index) VALUES
(
  'oop-foundations',
  'OOP Foundations',
  'Build your OOP intuition from the ground up. Model real-world domains while internalising encapsulation, inheritance, and polymorphism one concept at a time.',
  'OOP', 'oop', 1
),
(
  'oop-advanced',
  'Advanced OOP Systems',
  'Step up to multi-class systems with strict invariants, access control, and complex state transitions — the kind of OOP design problems asked in technical interviews.',
  'OOP', 'oop', 2
),
(
  'design-patterns-creational-structural',
  'Creational & Structural Patterns',
  'Master Singleton, Factory, Builder, and Decorator — the five patterns that appear most frequently in production codebases.',
  'Design Patterns', 'patterns', 3
),
(
  'design-patterns-behavioral',
  'Behavioral Design Patterns',
  'Learn how objects communicate and share responsibility through Observer, Command, and Strategy.',
  'Design Patterns', 'patterns', 4
),
(
  'system-design-core',
  'System Design Core',
  'Implement the building blocks every backend engineer reaches for: LRU cache, rate limiter, event bus, job queue, key-value store with TTL, and circuit breaker.',
  'System Design', 'system', 5
);

-- Path 1: OOP Foundations (Easy)
INSERT INTO path_challenges (path_id, challenge_id, step_order)
SELECT p.id, c.challenge_id, c.step_order
FROM paths p CROSS JOIN (VALUES
  ('oop_n01', 1),
  ('oop_n02', 2)
) AS c(challenge_id, step_order)
WHERE p.slug = 'oop-foundations';

-- Path 2: Advanced OOP (Medium + Hard)
INSERT INTO path_challenges (path_id, challenge_id, step_order)
SELECT p.id, c.challenge_id, c.step_order
FROM paths p CROSS JOIN (VALUES
  ('oop_n03', 1),
  ('oop_n04', 2),
  ('oop_n05', 3),
  ('oop_n06', 4),
  ('oop_n07', 5)
) AS c(challenge_id, step_order)
WHERE p.slug = 'oop-advanced';

-- Path 3: Creational & Structural Patterns
INSERT INTO path_challenges (path_id, challenge_id, step_order)
SELECT p.id, c.challenge_id, c.step_order
FROM paths p CROSS JOIN (VALUES
  ('dp_n02', 1),
  ('dp_n03', 2),
  ('dp_n04', 3),
  ('dp_n07', 4)
) AS c(challenge_id, step_order)
WHERE p.slug = 'design-patterns-creational-structural';

-- Path 4: Behavioral Patterns
INSERT INTO path_challenges (path_id, challenge_id, step_order)
SELECT p.id, c.challenge_id, c.step_order
FROM paths p CROSS JOIN (VALUES
  ('dp_n01', 1),
  ('dp_n05', 2),
  ('dp_n06', 3)
) AS c(challenge_id, step_order)
WHERE p.slug = 'design-patterns-behavioral';

-- Path 5: System Design Core
INSERT INTO path_challenges (path_id, challenge_id, step_order)
SELECT p.id, c.challenge_id, c.step_order
FROM paths p CROSS JOIN (VALUES
  ('sys_n01', 1),
  ('sys_n02', 2),
  ('sys_n03', 3),
  ('sys_n04', 4),
  ('sys_n05', 5),
  ('sys_n06', 6)
) AS c(challenge_id, step_order)
WHERE p.slug = 'system-design-core';
