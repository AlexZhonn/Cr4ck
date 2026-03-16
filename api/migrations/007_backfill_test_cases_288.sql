-- Migration 007: backfill test cases for dp_005-100, oop_005-100, sys_005-100 (288 challenges)

UPDATE challenges SET test_cases = '[
  {"input": "payment_method=credit_card, amount=100", "expected_output": "Charged $100.00 via Credit Card", "description": "Credit card payment"},
  {"input": "payment_method=paypal, amount=50", "expected_output": "Charged $50.00 via PayPal", "description": "PayPal payment"},
  {"input": "payment_method=crypto, amount=200", "expected_output": "Charged $200.00 via Crypto", "description": "Crypto payment"},
  {"input": "payment_method=bank_transfer, amount=1000", "expected_output": "Charged $1000.00 via Bank Transfer", "description": "Bank transfer payment"}
]'::jsonb WHERE id = 'dp_005';

UPDATE challenges SET test_cases = '[
  {"input": "subscribe user=alice, channel=news", "expected_output": "alice subscribed to news", "description": "User subscribes to channel"},
  {"input": "publish channel=news, message=Breaking news!", "expected_output": "alice received: Breaking news!", "description": "Message delivered to subscriber"},
  {"input": "unsubscribe user=alice, channel=news", "expected_output": "alice unsubscribed from news", "description": "User unsubscribes"},
  {"input": "publish channel=news, message=Update", "expected_output": "No subscribers notified", "description": "No delivery after unsubscribe"}
]'::jsonb WHERE id = 'dp_006';

UPDATE challenges SET test_cases = '[
  {"input": "type=sedan", "expected_output": "Sedan created with 4 doors, petrol engine", "description": "Create sedan"},
  {"input": "type=truck", "expected_output": "Truck created with cargo bed, diesel engine", "description": "Create truck"},
  {"input": "type=motorcycle", "expected_output": "Motorcycle created with 2 wheels", "description": "Create motorcycle"},
  {"input": "type=electric_car", "expected_output": "Electric Car created with battery pack", "description": "Create electric car"}
]'::jsonb WHERE id = 'dp_007';

UPDATE challenges SET test_cases = '[
  {"input": "add_section=experience, content=5 years at Google", "expected_output": "Section experience added", "description": "Add experience section"},
  {"input": "add_section=education, content=BS Computer Science", "expected_output": "Section education added", "description": "Add education section"},
  {"input": "build_resume format=pdf", "expected_output": "Resume built with 2 sections in PDF format", "description": "Build PDF resume"},
  {"input": "build_resume format=html", "expected_output": "Resume built with 2 sections in HTML format", "description": "Build HTML resume"}
]'::jsonb WHERE id = 'dp_008';

UPDATE challenges SET test_cases = '[
  {"input": "log level=INFO, message=App started", "expected_output": "[INFO] App started | timestamp added | written to file", "description": "Info log with decorators"},
  {"input": "log level=ERROR, message=Null pointer", "expected_output": "[ERROR] Null pointer | timestamp added | written to file | alert sent", "description": "Error log triggers alert"},
  {"input": "log level=DEBUG, message=x=5", "expected_output": "[DEBUG] x=5 | timestamp added", "description": "Debug log minimal decoration"},
  {"input": "log level=WARN, message=High memory", "expected_output": "[WARN] High memory | timestamp added | written to file", "description": "Warning log"}
]'::jsonb WHERE id = 'dp_009';

UPDATE challenges SET test_cases = '[
  {"input": "route=/api/users, method=GET", "expected_output": "Request routed to UserService", "description": "Route GET users"},
  {"input": "route=/api/orders, method=POST", "expected_output": "Request routed to OrderService", "description": "Route POST orders"},
  {"input": "route=/api/unknown, method=GET", "expected_output": "404 Not Found", "description": "Unknown route returns 404"},
  {"input": "rate_limit=exceeded, route=/api/users", "expected_output": "429 Too Many Requests", "description": "Rate limit exceeded"}
]'::jsonb WHERE id = 'dp_010';

UPDATE challenges SET test_cases = '[
  {"input": "get_instance", "expected_output": "Singleton instance created", "description": "First instance creation"},
  {"input": "get_instance (second call)", "expected_output": "Returning existing instance", "description": "Returns same instance"},
  {"input": "set config=db_host, value=localhost", "expected_output": "Config db_host set to localhost", "description": "Set config value"},
  {"input": "get config=db_host", "expected_output": "localhost", "description": "Get config value"}
]'::jsonb WHERE id = 'dp_011';

UPDATE challenges SET test_cases = '[
  {"input": "type Hello World", "expected_output": "Document contains: Hello World", "description": "Type text"},
  {"input": "undo", "expected_output": "Undo successful, document reverted", "description": "Undo last command"},
  {"input": "redo", "expected_output": "Redo successful, command reapplied", "description": "Redo undone command"},
  {"input": "undo (empty history)", "expected_output": "Nothing to undo", "description": "Undo with empty history"}
]'::jsonb WHERE id = 'dp_012';

UPDATE challenges SET test_cases = '[
  {"input": "playlist=[song1, song2, song3], iterate", "expected_output": "song1, song2, song3", "description": "Iterate full playlist"},
  {"input": "playlist=[song1, song2], has_next after last", "expected_output": "false", "description": "hasNext returns false at end"},
  {"input": "playlist=[song1, song2, song3], next x3", "expected_output": "song1 -> song2 -> song3", "description": "Sequential next calls"},
  {"input": "empty playlist, has_next", "expected_output": "false", "description": "Empty playlist hasNext"}
]'::jsonb WHERE id = 'dp_013';

UPDATE challenges SET test_cases = '[
  {"input": "add_file path=/root/file.txt", "expected_output": "File file.txt added to root", "description": "Add file to root"},
  {"input": "add_dir path=/root/docs", "expected_output": "Directory docs added to root", "description": "Add directory"},
  {"input": "get_size path=/root", "expected_output": "Total size: 1024 bytes", "description": "Get composite size"},
  {"input": "print_tree path=/root", "expected_output": "root/\n  docs/\n  file.txt", "description": "Print tree structure"}
]'::jsonb WHERE id = 'dp_014';

UPDATE challenges SET test_cases = '[
  {"input": "query=SELECT * FROM users", "expected_output": "Query executed via facade: 5 rows returned", "description": "Simple SELECT query"},
  {"input": "connect db=postgres", "expected_output": "Connected to postgres via facade", "description": "Connect to database"},
  {"input": "query=INSERT INTO users VALUES (1)", "expected_output": "Insert executed via facade: 1 row affected", "description": "INSERT query"},
  {"input": "disconnect", "expected_output": "Disconnected from database via facade", "description": "Disconnect from database"}
]'::jsonb WHERE id = 'dp_015';

UPDATE challenges SET test_cases = '[
  {"input": "media=mp3, player=VLC", "expected_output": "MP3 playing via VLC adapter", "description": "MP3 via VLC adapter"},
  {"input": "media=mp4, player=QuickTime", "expected_output": "MP4 playing via QuickTime adapter", "description": "MP4 via QuickTime"},
  {"input": "media=wav, player=VLC", "expected_output": "WAV playing via VLC adapter", "description": "WAV via VLC"},
  {"input": "media=flac, player=WinAmp", "expected_output": "FLAC playing via WinAmp adapter", "description": "FLAC via WinAmp"}
]'::jsonb WHERE id = 'dp_016';

UPDATE challenges SET test_cases = '[
  {"input": "template=sales_report, data={revenue: 5000}", "expected_output": "Sales Report generated with revenue $5000", "description": "Generate sales report"},
  {"input": "template=expense_report, data={total: 1200}", "expected_output": "Expense Report generated with total $1200", "description": "Generate expense report"},
  {"input": "template=summary_report, data={items: 3}", "expected_output": "Summary Report generated with 3 items", "description": "Generate summary report"},
  {"input": "export_format=pdf", "expected_output": "Report exported as PDF", "description": "Export report as PDF"}
]'::jsonb WHERE id = 'dp_017';

UPDATE challenges SET test_cases = '[
  {"input": "ticket=low_priority, handler=level1", "expected_output": "Level 1 handler resolved ticket", "description": "Low priority handled at level 1"},
  {"input": "ticket=medium_priority, handler=level1", "expected_output": "Level 1 passed to Level 2, Level 2 resolved ticket", "description": "Medium escalated to level 2"},
  {"input": "ticket=critical, handler=level1", "expected_output": "Escalated to Level 3, Level 3 resolved ticket", "description": "Critical escalated to level 3"},
  {"input": "ticket=unknown_type", "expected_output": "Ticket unhandled, escalated to manager", "description": "Unhandled ticket type"}
]'::jsonb WHERE id = 'dp_018';

UPDATE challenges SET test_cases = '[
  {"input": "place_order trader=alice, stock=AAPL, qty=100", "expected_output": "Order placed: alice buys 100 AAPL", "description": "Place buy order"},
  {"input": "match_orders stock=AAPL", "expected_output": "Orders matched for AAPL", "description": "Match buy and sell orders"},
  {"input": "cancel_order trader=alice, order_id=1", "expected_output": "Order 1 cancelled for alice", "description": "Cancel order"},
  {"input": "get_price stock=AAPL", "expected_output": "AAPL current price: $150.00", "description": "Get stock price"}
]'::jsonb WHERE id = 'dp_019';

UPDATE challenges SET test_cases = '[
  {"input": "save_state level=5, health=80, score=1200", "expected_output": "Game state saved: level 5, health 80, score 1200", "description": "Save game state"},
  {"input": "restore_state", "expected_output": "Game restored: level 5, health 80, score 1200", "description": "Restore saved state"},
  {"input": "save_state level=7, health=40, score=2500", "expected_output": "Game state saved: level 7, health 40, score 2500", "description": "Overwrite save state"},
  {"input": "restore_state (no save exists)", "expected_output": "No saved state found", "description": "Restore with no save"}
]'::jsonb WHERE id = 'dp_020';

UPDATE challenges SET test_cases = '[
  {"input": "state=RED, event=timer_expired", "expected_output": "Transition: RED -> GREEN", "description": "Red to green transition"},
  {"input": "state=GREEN, event=timer_expired", "expected_output": "Transition: GREEN -> YELLOW", "description": "Green to yellow transition"},
  {"input": "state=YELLOW, event=timer_expired", "expected_output": "Transition: YELLOW -> RED", "description": "Yellow to red transition"},
  {"input": "state=RED, event=emergency", "expected_output": "All lights RED, emergency mode", "description": "Emergency state transition"}
]'::jsonb WHERE id = 'dp_021';

UPDATE challenges SET test_cases = '[
  {"input": "item=electronics, price=1000, region=US", "expected_output": "Tax: $80.00 (8% electronics US)", "description": "Electronics US tax"},
  {"input": "item=food, price=50, region=US", "expected_output": "Tax: $0.00 (food exempt)", "description": "Food tax exempt"},
  {"input": "item=clothing, price=200, region=EU", "expected_output": "Tax: $40.00 (20% VAT EU)", "description": "EU clothing VAT"},
  {"input": "item=electronics, price=500, region=CA", "expected_output": "Tax: $65.00 (13% HST CA)", "description": "Canada electronics tax"}
]'::jsonb WHERE id = 'dp_022';

UPDATE challenges SET test_cases = '[
  {"input": "glyph=A, font=Arial, size=12", "expected_output": "Glyph A (Arial 12) retrieved from pool", "description": "Get existing glyph from pool"},
  {"input": "glyph=B, font=Arial, size=12", "expected_output": "Glyph B (Arial 12) created and cached", "description": "Create new glyph"},
  {"input": "glyph=A, font=Arial, size=12 (second request)", "expected_output": "Glyph A (Arial 12) retrieved from pool (cache hit)", "description": "Cache hit for existing glyph"},
  {"input": "pool_size", "expected_output": "Pool contains 2 unique glyphs", "description": "Check pool size"}
]'::jsonb WHERE id = 'dp_023';

UPDATE challenges SET test_cases = '[
  {"input": "platform=Windows, widget=Button", "expected_output": "Windows Button rendered", "description": "Windows button"},
  {"input": "platform=Mac, widget=Button", "expected_output": "Mac Button rendered", "description": "Mac button"},
  {"input": "platform=Linux, widget=Checkbox", "expected_output": "Linux Checkbox rendered", "description": "Linux checkbox"},
  {"input": "platform=Windows, widget=TextField", "expected_output": "Windows TextField rendered", "description": "Windows text field"}
]'::jsonb WHERE id = 'dp_024';

UPDATE challenges SET test_cases = '[
  {"input": "factory=Africa, animal=herbivore", "expected_output": "Created: Elephant (African herbivore)", "description": "African herbivore"},
  {"input": "factory=Africa, animal=carnivore", "expected_output": "Created: Lion (African carnivore)", "description": "African carnivore"},
  {"input": "factory=Arctic, animal=carnivore", "expected_output": "Created: Polar Bear (Arctic carnivore)", "description": "Arctic carnivore"},
  {"input": "factory=Ocean, animal=predator", "expected_output": "Created: Shark (Ocean predator)", "description": "Ocean predator"}
]'::jsonb WHERE id = 'dp_025';

UPDATE challenges SET test_cases = '[
  {"input": "clone document=contract_template", "expected_output": "Deep clone of contract_template created", "description": "Clone document"},
  {"input": "modify clone field=title, value=New Contract", "expected_output": "Clone title updated to New Contract, original unchanged", "description": "Modify clone leaves original intact"},
  {"input": "clone document=invoice_template", "expected_output": "Deep clone of invoice_template created", "description": "Clone invoice template"},
  {"input": "compare original clone", "expected_output": "Clone matches original structure, different reference", "description": "Verify deep copy"}
]'::jsonb WHERE id = 'dp_026';

UPDATE challenges SET test_cases = '[
  {"input": "weight=5kg, destination=local, strategy=standard", "expected_output": "Shipping cost: $5.00 (standard local)", "description": "Standard local shipping"},
  {"input": "weight=5kg, destination=international, strategy=express", "expected_output": "Shipping cost: $45.00 (express international)", "description": "Express international shipping"},
  {"input": "weight=20kg, destination=local, strategy=economy", "expected_output": "Shipping cost: $12.00 (economy local)", "description": "Economy local shipping"},
  {"input": "strategy=overnight, weight=2kg", "expected_output": "Shipping cost: $25.00 (overnight)", "description": "Overnight shipping"}
]'::jsonb WHERE id = 'dp_027';

UPDATE challenges SET test_cases = '[
  {"input": "subscribe observer=dashboard, stock=AAPL", "expected_output": "dashboard subscribed to AAPL", "description": "Subscribe to stock"},
  {"input": "update stock=AAPL, price=152.50", "expected_output": "dashboard notified: AAPL = $152.50", "description": "Price update notification"},
  {"input": "unsubscribe observer=dashboard, stock=AAPL", "expected_output": "dashboard unsubscribed from AAPL", "description": "Unsubscribe from stock"},
  {"input": "update stock=AAPL, price=153.00 after unsubscribe", "expected_output": "No observers notified for AAPL", "description": "No notification after unsubscribe"}
]'::jsonb WHERE id = 'dp_028';

UPDATE challenges SET test_cases = '[
  {"input": "provider=AWS, file=data.csv", "expected_output": "data.csv uploaded to AWS S3", "description": "Upload to AWS"},
  {"input": "provider=GCP, file=image.png", "expected_output": "image.png uploaded to GCP Storage", "description": "Upload to GCP"},
  {"input": "provider=Azure, file=report.pdf", "expected_output": "report.pdf uploaded to Azure Blob", "description": "Upload to Azure"},
  {"input": "provider=AWS, list_files", "expected_output": "Files in AWS S3: [data.csv]", "description": "List files in AWS"}
]'::jsonb WHERE id = 'dp_029';

UPDATE challenges SET test_cases = '[
  {"input": "SELECT().FROM(users).WHERE(age > 18)", "expected_output": "SELECT * FROM users WHERE age > 18", "description": "Basic SELECT with WHERE"},
  {"input": "SELECT(name, email).FROM(users).LIMIT(10)", "expected_output": "SELECT name, email FROM users LIMIT 10", "description": "SELECT specific columns"},
  {"input": "SELECT().FROM(orders).JOIN(users ON orders.user_id = users.id)", "expected_output": "SELECT * FROM orders JOIN users ON orders.user_id = users.id", "description": "SELECT with JOIN"},
  {"input": "SELECT().FROM(products).ORDER_BY(price DESC)", "expected_output": "SELECT * FROM products ORDER BY price DESC", "description": "SELECT with ORDER BY"}
]'::jsonb WHERE id = 'dp_030';

UPDATE challenges SET test_cases = '[
  {"input": "request=GET /api/data, decorators=[auth, log, cache]", "expected_output": "Auth checked -> Logged -> Cache hit -> Response returned", "description": "Decorated GET request"},
  {"input": "request=POST /api/data, decorators=[auth, log, validate]", "expected_output": "Auth checked -> Logged -> Validated -> Data saved", "description": "Decorated POST request"},
  {"input": "request=GET /api/data, cache=empty", "expected_output": "Auth checked -> Logged -> Cache miss -> Fetched from DB", "description": "Cache miss path"},
  {"input": "request=DELETE /api/data, decorators=[auth]", "expected_output": "Auth failed -> 401 Unauthorized", "description": "Auth failure"}
]'::jsonb WHERE id = 'dp_031';

UPDATE challenges SET test_cases = '[
  {"input": "fetch /api/users, cache=empty", "expected_output": "Cache miss, fetched from origin, cached result", "description": "First fetch populates cache"},
  {"input": "fetch /api/users, cache=populated", "expected_output": "Cache hit, returned cached result", "description": "Subsequent fetch uses cache"},
  {"input": "invalidate /api/users", "expected_output": "Cache invalidated for /api/users", "description": "Invalidate cache entry"},
  {"input": "fetch /api/users after invalidation", "expected_output": "Cache miss, fetched from origin", "description": "Fetch after invalidation"}
]'::jsonb WHERE id = 'dp_032';

UPDATE challenges SET test_cases = '[
  {"input": "get_theme", "expected_output": "Current theme: light (singleton instance)", "description": "Get default theme"},
  {"input": "set_theme dark", "expected_output": "Theme changed to dark", "description": "Set dark theme"},
  {"input": "get_theme (second instance)", "expected_output": "Current theme: dark (same singleton)", "description": "Same singleton returns dark"},
  {"input": "set_theme system", "expected_output": "Theme changed to system", "description": "Set system theme"}
]'::jsonb WHERE id = 'dp_033';

UPDATE challenges SET test_cases = '[
  {"input": "command=turn_on, device=lights", "expected_output": "Lights turned ON", "description": "Turn on lights"},
  {"input": "command=turn_off, device=thermostat", "expected_output": "Thermostat turned OFF", "description": "Turn off thermostat"},
  {"input": "undo_last_command", "expected_output": "Undone: Thermostat turned ON", "description": "Undo last command"},
  {"input": "macro=[turn_on lights, set_temp 22, lock_door]", "expected_output": "Macro executed: 3 commands run", "description": "Execute macro command"}
]'::jsonb WHERE id = 'dp_034';

UPDATE challenges SET test_cases = '[
  {"input": "tree=[1,2,3,4,5], traversal=inorder", "expected_output": "4, 2, 5, 1, 3", "description": "In-order traversal"},
  {"input": "tree=[1,2,3,4,5], traversal=preorder", "expected_output": "1, 2, 4, 5, 3", "description": "Pre-order traversal"},
  {"input": "tree=[1,2,3,4,5], traversal=postorder", "expected_output": "4, 5, 2, 3, 1", "description": "Post-order traversal"},
  {"input": "iterator has_next on empty tree", "expected_output": "false", "description": "Empty tree iterator"}
]'::jsonb WHERE id = 'dp_035';

UPDATE challenges SET test_cases = '[
  {"input": "add_child parent=Panel, child=Button", "expected_output": "Button added to Panel", "description": "Add leaf to composite"},
  {"input": "add_child parent=Panel, child=SubPanel", "expected_output": "SubPanel added to Panel", "description": "Add composite to composite"},
  {"input": "render root=Panel", "expected_output": "Panel rendered with Button and SubPanel", "description": "Render composite tree"},
  {"input": "remove_child parent=Panel, child=Button", "expected_output": "Button removed from Panel", "description": "Remove component"}
]'::jsonb WHERE id = 'dp_036';

UPDATE challenges SET test_cases = '[
  {"input": "search query=python tutorials, engine=google", "expected_output": "Results from Google: 5 links found", "description": "Google search"},
  {"input": "search query=OOP design, engine=bing", "expected_output": "Results from Bing: 5 links found", "description": "Bing search"},
  {"input": "search query=   (empty)", "expected_output": "Error: empty query", "description": "Empty query error"},
  {"input": "search query=AI news", "expected_output": "Results from default engine: 5 links found", "description": "Default engine search"}
]'::jsonb WHERE id = 'dp_037';

UPDATE challenges SET test_cases = '[
  {"input": "import file=data.csv", "expected_output": "CSV imported: 100 rows parsed", "description": "Import CSV file"},
  {"input": "convert row={name,age,email}", "expected_output": "Row converted to User object", "description": "Convert CSV row to object"},
  {"input": "import file=malformed.csv", "expected_output": "Error: invalid CSV format on row 3", "description": "Malformed CSV error"},
  {"input": "import file=empty.csv", "expected_output": "CSV imported: 0 rows parsed", "description": "Empty CSV file"}
]'::jsonb WHERE id = 'dp_038';

UPDATE challenges SET test_cases = '[
  {"input": "template=weekly_digest, user=alice@example.com", "expected_output": "Email digest built for alice@example.com with weekly template", "description": "Build weekly digest"},
  {"input": "add_section type=featured_articles, count=3", "expected_output": "Featured articles section added with 3 articles", "description": "Add articles section"},
  {"input": "add_section type=promotions, discount=20%", "expected_output": "Promotions section added with 20% discount", "description": "Add promotions section"},
  {"input": "send email=built", "expected_output": "Digest email sent successfully", "description": "Send built digest"}
]'::jsonb WHERE id = 'dp_039';

UPDATE challenges SET test_cases = '[
  {"input": "request=leave, amount=3days, approver=manager", "expected_output": "Manager approved 3-day leave", "description": "Manager approves short leave"},
  {"input": "request=budget, amount=5000, approver=manager", "expected_output": "Manager passed to Director, Director approved $5000", "description": "Budget escalated to director"},
  {"input": "request=capital_expense, amount=50000", "expected_output": "Escalated to VP, VP approved $50000", "description": "Large expense approved by VP"},
  {"input": "request=acquisition, amount=1000000", "expected_output": "Escalated to CEO, CEO approved", "description": "Acquisition approved by CEO"}
]'::jsonb WHERE id = 'dp_040';

UPDATE challenges SET test_cases = '[
  {"input": "flight=UA123, request=takeoff_clearance", "expected_output": "Tower granted takeoff clearance to UA123", "description": "Grant takeoff clearance"},
  {"input": "flight=AA456, request=landing", "expected_output": "Tower cleared AA456 for landing on runway 2", "description": "Grant landing clearance"},
  {"input": "flight=BA789, request=landing, runway=occupied", "expected_output": "Tower put BA789 in holding pattern", "description": "Runway busy, hold pattern"},
  {"input": "emergency=UA123", "expected_output": "Tower cleared all runways for UA123 emergency", "description": "Emergency clearance"}
]'::jsonb WHERE id = 'dp_041';

UPDATE challenges SET test_cases = '[
  {"input": "navigate url=https://example.com", "expected_output": "Navigated to https://example.com, history saved", "description": "Navigate to URL"},
  {"input": "back", "expected_output": "Navigated back to previous URL", "description": "Browser back button"},
  {"input": "forward", "expected_output": "Navigated forward to next URL", "description": "Browser forward button"},
  {"input": "restore_session", "expected_output": "Session restored with 3 history entries", "description": "Restore browsing session"}
]'::jsonb WHERE id = 'dp_042';

UPDATE challenges SET test_cases = '[
  {"input": "state=IDLE, event=insert_coin", "expected_output": "Transition: IDLE -> HAS_MONEY", "description": "Insert coin"},
  {"input": "state=HAS_MONEY, event=select_item", "expected_output": "Transition: HAS_MONEY -> DISPENSING", "description": "Select item"},
  {"input": "state=DISPENSING, event=dispense_complete", "expected_output": "Transition: DISPENSING -> IDLE, item dispensed", "description": "Item dispensed"},
  {"input": "state=IDLE, event=select_item", "expected_output": "Invalid: no coin inserted", "description": "Select without coin"}
]'::jsonb WHERE id = 'dp_043';

UPDATE challenges SET test_cases = '[
  {"input": "cart=[{item: laptop, price: 1000}], visitor=discount_10", "expected_output": "Discount applied: $100.00 off, total $900.00", "description": "10% discount visitor"},
  {"input": "cart=[{item: book, price: 50}], visitor=tax_calculator", "expected_output": "Tax calculated: $4.00, total $54.00", "description": "Tax calculation visitor"},
  {"input": "cart=[{item: laptop, price: 1000}, {item: book, price: 50}], visitor=shipping", "expected_output": "Shipping cost calculated: $15.00", "description": "Shipping cost visitor"},
  {"input": "cart=[], visitor=discount_10", "expected_output": "Empty cart, no discount applied", "description": "Empty cart visitor"}
]'::jsonb WHERE id = 'dp_044';

UPDATE challenges SET test_cases = '[
  {"input": "particle_type=fire, count=1000", "expected_output": "1000 fire particles rendered using 1 shared flyweight", "description": "Render fire particles"},
  {"input": "particle_type=smoke, count=500", "expected_output": "500 smoke particles rendered using 1 shared flyweight", "description": "Render smoke particles"},
  {"input": "pool_size", "expected_output": "Flyweight pool: 2 types (fire, smoke)", "description": "Check flyweight pool"},
  {"input": "particle_type=rain, count=2000, position=varies", "expected_output": "2000 rain particles rendered, extrinsic state varies", "description": "Rain particles with extrinsic state"}
]'::jsonb WHERE id = 'dp_045';

UPDATE challenges SET test_cases = '[
  {"input": "tool=pencil, platform=raster", "expected_output": "Pencil tool drawing on raster canvas", "description": "Pencil on raster"},
  {"input": "tool=pencil, platform=vector", "expected_output": "Pencil tool drawing on vector canvas", "description": "Pencil on vector"},
  {"input": "tool=brush, platform=raster", "expected_output": "Brush tool drawing on raster canvas", "description": "Brush on raster"},
  {"input": "tool=eraser, platform=vector", "expected_output": "Eraser tool on vector canvas", "description": "Eraser on vector"}
]'::jsonb WHERE id = 'dp_046';

UPDATE challenges SET test_cases = '[
  {"input": "factory=Windows, widget=Button", "expected_output": "Windows Button created", "description": "Windows button widget"},
  {"input": "factory=Mac, widget=Checkbox", "expected_output": "Mac Checkbox created", "description": "Mac checkbox widget"},
  {"input": "factory=Web, widget=TextField", "expected_output": "Web TextField created", "description": "Web text field widget"},
  {"input": "factory=Mobile, widget=Slider", "expected_output": "Mobile Slider created", "description": "Mobile slider widget"}
]'::jsonb WHERE id = 'dp_047';

UPDATE challenges SET test_cases = '[
  {"input": "clone packet={type: HTTP, src: 192.168.1.1, dst: 10.0.0.1}", "expected_output": "Packet cloned: HTTP from 192.168.1.1 to 10.0.0.1", "description": "Clone HTTP packet"},
  {"input": "modify clone dst=10.0.0.2", "expected_output": "Clone dst updated to 10.0.0.2, original unchanged", "description": "Modify clone"},
  {"input": "clone packet={type: DNS, payload=query}", "expected_output": "Packet cloned: DNS with query payload", "description": "Clone DNS packet"},
  {"input": "batch_clone count=5 template={type: ICMP}", "expected_output": "5 ICMP packets cloned", "description": "Batch clone packets"}
]'::jsonb WHERE id = 'dp_048';

UPDATE challenges SET test_cases = '[
  {"input": "data=AABBBCCCC, strategy=RLE", "expected_output": "Compressed: A2B3C4 (50% reduction)", "description": "RLE compression"},
  {"input": "data=hello world, strategy=huffman", "expected_output": "Compressed with Huffman encoding, 40% reduction", "description": "Huffman compression"},
  {"input": "data=already_optimal, strategy=RLE", "expected_output": "Compressed: same size (0% reduction)", "description": "Incompressible data"},
  {"input": "switch_strategy from=RLE to=LZW", "expected_output": "Strategy switched to LZW", "description": "Switch compression strategy"}
]'::jsonb WHERE id = 'dp_049';

UPDATE challenges SET test_cases = '[
  {"input": "subscribe display=screen, station=NYC", "expected_output": "Screen display subscribed to NYC station", "description": "Subscribe display"},
  {"input": "update station=NYC, temp=22C, humidity=65%", "expected_output": "Screen notified: NYC temp=22C, humidity=65%", "description": "Weather update notification"},
  {"input": "subscribe display=mobile, station=NYC", "expected_output": "Mobile subscribed to NYC station", "description": "Subscribe mobile display"},
  {"input": "update station=NYC, temp=24C", "expected_output": "Screen notified: 24C | Mobile notified: 24C", "description": "Multiple observers notified"}
]'::jsonb WHERE id = 'dp_050';

UPDATE challenges SET test_cases = '[
  {"input": "pizza=margherita, toppings=[cheese, tomato]", "expected_output": "Margherita pizza with cheese, tomato created", "description": "Create margherita"},
  {"input": "pizza=pepperoni, toppings=[cheese, pepperoni, olives]", "expected_output": "Pepperoni pizza with cheese, pepperoni, olives created", "description": "Create pepperoni pizza"},
  {"input": "factory=italian, pizza=calzone", "expected_output": "Italian-style calzone created", "description": "Italian factory calzone"},
  {"input": "factory=american, pizza=deep_dish", "expected_output": "American-style deep dish created", "description": "American factory deep dish"}
]'::jsonb WHERE id = 'dp_051';

UPDATE challenges SET test_cases = '[
  {"input": "set name=Aragorn, class=Ranger", "expected_output": "Character Aragorn (Ranger) initialized", "description": "Set character basics"},
  {"input": "set strength=18, dexterity=16, intelligence=12", "expected_output": "Stats set: STR 18, DEX 16, INT 12", "description": "Set character stats"},
  {"input": "add skill=Archery, level=5", "expected_output": "Skill Archery (level 5) added", "description": "Add character skill"},
  {"input": "build_sheet", "expected_output": "Character sheet built: Aragorn, Ranger, STR 18, DEX 16, INT 12, Skills: Archery", "description": "Build final character sheet"}
]'::jsonb WHERE id = 'dp_052';

UPDATE challenges SET test_cases = '[
  {"input": "stack=[auth, logging, cors], request=GET /api", "expected_output": "auth -> logging -> cors -> handler executed", "description": "Middleware chain execution"},
  {"input": "middleware=auth fails on request", "expected_output": "Auth middleware blocked request: 401", "description": "Auth middleware blocks request"},
  {"input": "add_middleware rate_limiter at position=1", "expected_output": "rate_limiter added at position 1 in stack", "description": "Add middleware to stack"},
  {"input": "stack=[], request=GET /api", "expected_output": "Request passed directly to handler", "description": "Empty middleware stack"}
]'::jsonb WHERE id = 'dp_053';

UPDATE challenges SET test_cases = '[
  {"input": "request={src: 10.0.0.1, port: 80, proto: HTTP}", "expected_output": "Request allowed by firewall rules", "description": "Allowed HTTP request"},
  {"input": "request={src: 192.168.1.100, port: 22, proto: SSH}", "expected_output": "Request blocked by firewall rule: SSH denied", "description": "Blocked SSH request"},
  {"input": "request={src: blacklisted_ip, port: 443}", "expected_output": "Request blocked: IP blacklisted", "description": "Blacklisted IP blocked"},
  {"input": "add_rule allow src=10.0.0.0/8 port=443", "expected_output": "Rule added: allow 10.0.0.0/8 on port 443", "description": "Add firewall rule"}
]'::jsonb WHERE id = 'dp_054';

UPDATE challenges SET test_cases = '[
  {"input": "get_instance", "expected_output": "Feature flag store singleton created", "description": "Get singleton instance"},
  {"input": "set_flag feature=dark_mode, enabled=true", "expected_output": "Feature flag dark_mode set to true", "description": "Enable feature flag"},
  {"input": "get_flag feature=dark_mode", "expected_output": "dark_mode: enabled", "description": "Get feature flag"},
  {"input": "get_instance (second call)", "expected_output": "Returning existing singleton store", "description": "Same singleton returned"}
]'::jsonb WHERE id = 'dp_055';

UPDATE challenges SET test_cases = '[
  {"input": "execute command=type Hello", "expected_output": "Typed: Hello", "description": "Execute type command"},
  {"input": "undo", "expected_output": "Undone: Hello removed", "description": "Undo type command"},
  {"input": "execute command=bold selection=Hello", "expected_output": "Selection Hello made bold", "description": "Bold command"},
  {"input": "redo", "expected_output": "Redone: Hello removed... then re-added", "description": "Redo command"}
]'::jsonb WHERE id = 'dp_056';

UPDATE challenges SET test_cases = '[
  {"input": "paginate items=1000, page_size=10, cursor=null", "expected_output": "Page 1: items 1-10, next_cursor=item_10", "description": "First page"},
  {"input": "paginate cursor=item_10", "expected_output": "Page 2: items 11-20, next_cursor=item_20", "description": "Second page"},
  {"input": "paginate cursor=item_990", "expected_output": "Last page: items 991-1000, next_cursor=null", "description": "Last page"},
  {"input": "has_next cursor=null after last page", "expected_output": "false", "description": "No next page"}
]'::jsonb WHERE id = 'dp_057';

UPDATE challenges SET test_cases = '[
  {"input": "add_employee name=CEO, parent=null", "expected_output": "CEO added as root node", "description": "Add root employee"},
  {"input": "add_employee name=CTO, parent=CEO", "expected_output": "CTO added under CEO", "description": "Add direct report"},
  {"input": "get_subordinates manager=CTO", "expected_output": "CTO subordinates: [Engineer1, Engineer2]", "description": "Get subordinates"},
  {"input": "get_depth employee=Engineer1", "expected_output": "Engineer1 depth: 3", "description": "Get node depth"}
]'::jsonb WHERE id = 'dp_058';

UPDATE challenges SET test_cases = '[
  {"input": "command=turn_on_all", "expected_output": "Lights ON, Thermostat ON, Security ON via facade", "description": "Turn on all devices"},
  {"input": "command=night_mode", "expected_output": "Lights dim to 20%, Thermostat set 18C, Locks engaged", "description": "Activate night mode"},
  {"input": "command=away_mode", "expected_output": "All lights OFF, Thermostat eco mode, Alarm armed", "description": "Activate away mode"},
  {"input": "command=query_status", "expected_output": "Lights: ON, Thermostat: 22C, Security: armed", "description": "Query home status"}
]'::jsonb WHERE id = 'dp_059';

UPDATE challenges SET test_cases = '[
  {"input": "legacy_provider=OldPayCo, charge=100, currency=USD", "expected_output": "Adapted OldPayCo charge: $100.00 USD", "description": "Charge via legacy adapter"},
  {"input": "legacy_provider=OldPayCo, refund=50", "expected_output": "Adapted OldPayCo refund: $50.00", "description": "Refund via legacy adapter"},
  {"input": "modern_interface=charge, legacy_method=processPayment", "expected_output": "Modern charge() mapped to legacy processPayment()", "description": "Interface mapping"},
  {"input": "legacy_provider=OldPayCo, get_balance", "expected_output": "Adapted balance: $250.00", "description": "Get balance via adapter"}
]'::jsonb WHERE id = 'dp_060';

UPDATE challenges SET test_cases = '[
  {"input": "pipeline=[checkout, test, build, deploy], trigger=push", "expected_output": "Pipeline started: checkout -> test -> build -> deploy", "description": "Full pipeline execution"},
  {"input": "step=test, result=fail", "expected_output": "Pipeline stopped at test step: FAILED", "description": "Pipeline stops on failure"},
  {"input": "override_step build with custom_build", "expected_output": "Build step overridden with custom_build", "description": "Override pipeline step"},
  {"input": "parallel_steps=[lint, typecheck]", "expected_output": "lint and typecheck running in parallel", "description": "Parallel step execution"}
]'::jsonb WHERE id = 'dp_061';

UPDATE challenges SET test_cases = '[
  {"input": "request=expense, amount=200, approver=manager", "expected_output": "Manager approved $200 expense", "description": "Manager approves small expense"},
  {"input": "request=expense, amount=2000, approver=manager", "expected_output": "Manager escalated $2000 to Director", "description": "Expense escalated to director"},
  {"input": "request=expense, amount=10000", "expected_output": "Escalated to VP, VP approved $10000", "description": "VP approves large expense"},
  {"input": "request=expense, amount=500000", "expected_output": "Escalated to Board, Board approved", "description": "Board approves very large expense"}
]'::jsonb WHERE id = 'dp_062';

UPDATE challenges SET test_cases = '[
  {"input": "register bidder=alice, item=painting", "expected_output": "alice registered for painting auction", "description": "Register bidder"},
  {"input": "place_bid bidder=alice, amount=500", "expected_output": "alice bid $500, all bidders notified", "description": "Place bid"},
  {"input": "place_bid bidder=bob, amount=600", "expected_output": "bob outbid alice at $600, alice notified", "description": "Higher bid placed"},
  {"input": "close_auction item=painting", "expected_output": "Auction closed, winner: bob at $600", "description": "Close auction"}
]'::jsonb WHERE id = 'dp_063';

UPDATE challenges SET test_cases = '[
  {"input": "save_snapshot file=editor_state.json", "expected_output": "Snapshot saved: editor_state.json", "description": "Save editor snapshot"},
  {"input": "restore_snapshot file=editor_state.json", "expected_output": "Editor restored from snapshot", "description": "Restore from snapshot"},
  {"input": "auto_save interval=5min", "expected_output": "Auto-save enabled every 5 minutes", "description": "Enable auto-save"},
  {"input": "compare_snapshots snap1 snap2", "expected_output": "Snapshots differ: 3 lines changed", "description": "Compare snapshots"}
]'::jsonb WHERE id = 'dp_064';

UPDATE challenges SET test_cases = '[
  {"input": "order=ORD001, state=PLACED", "expected_output": "Order ORD001 in PLACED state", "description": "Initial order state"},
  {"input": "event=payment_confirmed, order=ORD001", "expected_output": "Order ORD001 transition: PLACED -> PROCESSING", "description": "Payment confirms order"},
  {"input": "event=shipped, order=ORD001", "expected_output": "Order ORD001 transition: PROCESSING -> SHIPPED", "description": "Order shipped"},
  {"input": "event=delivered, order=ORD001", "expected_output": "Order ORD001 transition: SHIPPED -> DELIVERED", "description": "Order delivered"}
]'::jsonb WHERE id = 'dp_065';

UPDATE challenges SET test_cases = '[
  {"input": "policy=auto, age=30, coverage=100000, visitor=calculator", "expected_output": "Auto premium: $1200/year for age 30", "description": "Auto insurance premium"},
  {"input": "policy=home, value=300000, visitor=calculator", "expected_output": "Home premium: $1500/year for $300k home", "description": "Home insurance premium"},
  {"input": "policy=life, age=45, sum_insured=500000, visitor=calculator", "expected_output": "Life premium: $3000/year for age 45", "description": "Life insurance premium"},
  {"input": "policy=health, age=25, visitor=calculator", "expected_output": "Health premium: $800/year for age 25", "description": "Health insurance premium"}
]'::jsonb WHERE id = 'dp_066';

UPDATE challenges SET test_cases = '[
  {"input": "tile=zoom12_x500_y300, cache=empty", "expected_output": "Tile created and cached: zoom12_x500_y300", "description": "Load uncached tile"},
  {"input": "tile=zoom12_x500_y300, cache=populated", "expected_output": "Tile from flyweight cache: zoom12_x500_y300", "description": "Cache hit for tile"},
  {"input": "tile_count=1000, unique_tiles=50", "expected_output": "1000 tiles rendered, only 50 flyweight objects created", "description": "Memory efficiency"},
  {"input": "cache_size", "expected_output": "Flyweight cache: 50 unique tiles", "description": "Check cache size"}
]'::jsonb WHERE id = 'dp_067';

UPDATE challenges SET test_cases = '[
  {"input": "device=TV, implementation=HDMI", "expected_output": "TV remote controlling HDMI device", "description": "TV via HDMI"},
  {"input": "device=TV, implementation=Bluetooth", "expected_output": "TV remote controlling Bluetooth device", "description": "TV via Bluetooth"},
  {"input": "device=AC, implementation=IR", "expected_output": "AC remote controlling IR device", "description": "AC via IR"},
  {"input": "switch_implementation device=TV, from=HDMI to=WiFi", "expected_output": "TV implementation switched to WiFi", "description": "Switch implementation"}
]'::jsonb WHERE id = 'dp_068';

UPDATE challenges SET test_cases = '[
  {"input": "os=Windows, dialog=FileOpen", "expected_output": "Windows FileOpen dialog created", "description": "Windows file dialog"},
  {"input": "os=Mac, dialog=FileOpen", "expected_output": "Mac FileOpen dialog created", "description": "Mac file dialog"},
  {"input": "os=Linux, dialog=MessageBox", "expected_output": "Linux MessageBox dialog created", "description": "Linux message dialog"},
  {"input": "os=Windows, dialog=SaveAs", "expected_output": "Windows SaveAs dialog created", "description": "Windows save dialog"}
]'::jsonb WHERE id = 'dp_069';

UPDATE challenges SET test_cases = '[
  {"input": "clone config={db_host: localhost, port: 5432}", "expected_output": "Config snapshot cloned", "description": "Clone config"},
  {"input": "modify clone db_host=staging.db", "expected_output": "Clone updated to staging.db, original still localhost", "description": "Modify cloned config"},
  {"input": "deploy config=clone to staging", "expected_output": "Staging deployed with cloned config", "description": "Deploy cloned config"},
  {"input": "compare original clone", "expected_output": "Configs differ: db_host changed", "description": "Compare configs"}
]'::jsonb WHERE id = 'dp_070';

UPDATE challenges SET test_cases = '[
  {"input": "data=[3,1,4,1,5,9,2,6], strategy=quicksort", "expected_output": "[1,1,2,3,4,5,6,9]", "description": "Quicksort"},
  {"input": "data=[3,1,4,1,5,9,2,6], strategy=mergesort", "expected_output": "[1,1,2,3,4,5,6,9]", "description": "Mergesort"},
  {"input": "data=[3,1,4,1,5,9,2,6], strategy=bubblesort", "expected_output": "[1,1,2,3,4,5,6,9]", "description": "Bubble sort"},
  {"input": "switch_strategy from=quicksort to=heapsort", "expected_output": "Strategy switched to heapsort", "description": "Switch sort strategy"}
]'::jsonb WHERE id = 'dp_071';

UPDATE challenges SET test_cases = '[
  {"input": "subscribe display=dashboard, sensor=temp_sensor_1", "expected_output": "Dashboard subscribed to temp_sensor_1", "description": "Subscribe to sensor"},
  {"input": "update sensor=temp_sensor_1, value=28.5", "expected_output": "Dashboard notified: temp_sensor_1 = 28.5C", "description": "Sensor reading update"},
  {"input": "sensor_alert sensor=temp_sensor_1, threshold=30C", "expected_output": "Alert: temp_sensor_1 exceeded 30C", "description": "Threshold alert"},
  {"input": "unsubscribe display=dashboard, sensor=temp_sensor_1", "expected_output": "Dashboard unsubscribed from temp_sensor_1", "description": "Unsubscribe from sensor"}
]'::jsonb WHERE id = 'dp_072';

UPDATE challenges SET test_cases = '[
  {"input": "factory=car, type=sedan", "expected_output": "Sedan car dispatched", "description": "Dispatch sedan"},
  {"input": "factory=van, type=cargo", "expected_output": "Cargo van dispatched", "description": "Dispatch cargo van"},
  {"input": "factory=motorcycle, type=sport", "expected_output": "Sport motorcycle dispatched", "description": "Dispatch sport motorcycle"},
  {"input": "factory=truck, type=heavy", "expected_output": "Heavy truck dispatched", "description": "Dispatch heavy truck"}
]'::jsonb WHERE id = 'dp_073';

UPDATE challenges SET test_cases = '[
  {"input": "set_goal calories=2000, protein=150g", "expected_output": "Nutrition goal set: 2000 cal, 150g protein", "description": "Set nutrition goals"},
  {"input": "add_meal breakfast=[oats, milk, banana]", "expected_output": "Breakfast added: 450 cal, 12g protein", "description": "Add breakfast"},
  {"input": "add_meal lunch=[chicken, rice, vegetables]", "expected_output": "Lunch added: 650 cal, 55g protein", "description": "Add lunch"},
  {"input": "build_plan", "expected_output": "Meal plan built: 2000 cal target met, meals planned for 7 days", "description": "Build full meal plan"}
]'::jsonb WHERE id = 'dp_074';

UPDATE challenges SET test_cases = '[
  {"input": "event=page_view, decorator=timestamp", "expected_output": "Event: page_view | timestamp: 2024-01-01T12:00:00", "description": "Add timestamp to event"},
  {"input": "event=click, decorators=[timestamp, user_id, session_id]", "expected_output": "Event: click | timestamp | user_id: u123 | session_id: s456", "description": "Multiple decorators"},
  {"input": "event=purchase, decorator=geo_location", "expected_output": "Event: purchase | geo: US/New York", "description": "Add geo location"},
  {"input": "flush events to analytics", "expected_output": "3 decorated events flushed to analytics", "description": "Flush events"}
]'::jsonb WHERE id = 'dp_075';

UPDATE challenges SET test_cases = '[
  {"input": "fetch image=/assets/hero.jpg, cache=empty", "expected_output": "Proxy: image not loaded, returning placeholder", "description": "Lazy load returns placeholder"},
  {"input": "image=/assets/hero.jpg enters viewport", "expected_output": "Proxy: loading image from origin", "description": "Image loaded when in viewport"},
  {"input": "fetch image=/assets/hero.jpg, cache=loaded", "expected_output": "Proxy: returning cached image", "description": "Cached image returned"},
  {"input": "image_count=100, viewport_count=5", "expected_output": "Only 5 images loaded, 95 deferred", "description": "Lazy loading defers off-screen images"}
]'::jsonb WHERE id = 'dp_076';

UPDATE challenges SET test_cases = '[
  {"input": "get_instance", "expected_output": "App settings singleton created", "description": "Create singleton"},
  {"input": "set theme=dark, language=en", "expected_output": "Settings updated: theme=dark, language=en", "description": "Set settings"},
  {"input": "get theme", "expected_output": "theme: dark", "description": "Get setting value"},
  {"input": "get_instance (concurrent call)", "expected_output": "Returning same singleton instance", "description": "Thread-safe singleton return"}
]'::jsonb WHERE id = 'dp_077';

UPDATE challenges SET test_cases = '[
  {"input": "start_recording", "expected_output": "Recording started, capturing commands", "description": "Start macro recording"},
  {"input": "record commands=[open_file, bold_text, save_file]", "expected_output": "Macro recorded: 3 commands", "description": "Record commands"},
  {"input": "stop_recording, save as=format_doc", "expected_output": "Macro format_doc saved with 3 commands", "description": "Save macro"},
  {"input": "replay macro=format_doc", "expected_output": "Replaying: open_file -> bold_text -> save_file", "description": "Replay macro"}
]'::jsonb WHERE id = 'dp_078';

UPDATE challenges SET test_cases = '[
  {"input": "graph={A:[B,C], B:[D], C:[D], D:[]}, start=A", "expected_output": "DFS from A: A, B, D, C", "description": "DFS traversal"},
  {"input": "iterator has_next at D (leaf)", "expected_output": "false", "description": "Iterator ends at leaf"},
  {"input": "graph={A:[B], B:[C], C:[A]}, start=A", "expected_output": "DFS from A: A, B, C (cycle detected)", "description": "DFS with cycle detection"},
  {"input": "empty graph, start=A", "expected_output": "DFS: A only", "description": "DFS on single node graph"}
]'::jsonb WHERE id = 'dp_079';

UPDATE challenges SET test_cases = '[
  {"input": "add_item parent=File, child=New", "expected_output": "New added under File menu", "description": "Add menu item"},
  {"input": "add_item parent=File, child=Save", "expected_output": "Save added under File menu", "description": "Add another menu item"},
  {"input": "add_submenu parent=Edit, name=Find", "expected_output": "Find submenu added under Edit", "description": "Add submenu"},
  {"input": "render menu", "expected_output": "File(New, Save), Edit(Find(Find Next, Find Prev))", "description": "Render full menu tree"}
]'::jsonb WHERE id = 'dp_080';

UPDATE challenges SET test_cases = '[
  {"input": "register device=thermostat_1, type=thermostat", "expected_output": "thermostat_1 registered in IoT registry", "description": "Register device"},
  {"input": "command device=thermostat_1, action=set_temp value=22", "expected_output": "thermostat_1 temp set to 22C via facade", "description": "Send command to device"},
  {"input": "query device=thermostat_1, status", "expected_output": "thermostat_1: online, temp=22C", "description": "Query device status"},
  {"input": "list_devices type=thermostat", "expected_output": "Thermostats: [thermostat_1]", "description": "List devices by type"}
]'::jsonb WHERE id = 'dp_081';

UPDATE challenges SET test_cases = '[
  {"input": "xml=<user><name>Alice</name><age>30</age></user>", "expected_output": "{\"user\": {\"name\": \"Alice\", \"age\": \"30\"}}", "description": "Convert simple XML to JSON"},
  {"input": "xml=<items><item>A</item><item>B</item></items>", "expected_output": "{\"items\": {\"item\": [\"A\", \"B\"]}}", "description": "Convert XML array to JSON"},
  {"input": "xml=<root attr=''value''>text</root>", "expected_output": "{\"root\": {\"@attr\": \"value\", \"#text\": \"text\"}}", "description": "Convert XML with attributes"},
  {"input": "xml=malformed XML", "expected_output": "Error: invalid XML format", "description": "Malformed XML error"}
]'::jsonb WHERE id = 'dp_082';

UPDATE challenges SET test_cases = '[
  {"input": "template=NDA, vars={party1: Acme, party2: Widget Co}", "expected_output": "NDA generated with Acme and Widget Co", "description": "Generate NDA from template"},
  {"input": "template=employment_contract, vars={employee: Alice, salary: 100000}", "expected_output": "Employment contract generated for Alice at $100,000", "description": "Generate employment contract"},
  {"input": "missing_var template=NDA, vars={party1: Acme}", "expected_output": "Error: missing required variable party2", "description": "Missing variable error"},
  {"input": "export format=pdf", "expected_output": "Contract exported as PDF", "description": "Export contract as PDF"}
]'::jsonb WHERE id = 'dp_083';

UPDATE challenges SET test_cases = '[
  {"input": "order=PO001, amount=500, approver=supervisor", "expected_output": "Supervisor approved PO001 for $500", "description": "Supervisor approves small PO"},
  {"input": "order=PO002, amount=5000, approver=supervisor", "expected_output": "Supervisor escalated PO002 to Manager", "description": "Escalated to manager"},
  {"input": "order=PO003, amount=50000", "expected_output": "Escalated to Director, Director approved", "description": "Director approves large PO"},
  {"input": "order=PO004, amount=500000", "expected_output": "Escalated to CFO, CFO approved", "description": "CFO approves very large PO"}
]'::jsonb WHERE id = 'dp_084';

UPDATE challenges SET test_cases = '[
  {"input": "join room=general, user=alice", "expected_output": "alice joined general, all members notified", "description": "User joins room"},
  {"input": "send room=general, from=alice, message=Hello!", "expected_output": "Message relayed by mediator to all in general", "description": "Message broadcast via mediator"},
  {"input": "leave room=general, user=alice", "expected_output": "alice left general, remaining members notified", "description": "User leaves room"},
  {"input": "private_message from=alice, to=bob, message=Hi", "expected_output": "Private message from alice to bob via mediator", "description": "Private message"}
]'::jsonb WHERE id = 'dp_085';

UPDATE challenges SET test_cases = '[
  {"input": "fill_form fields={name: Alice, email: alice@example.com}", "expected_output": "Form filled: name=Alice, email=alice@example.com", "description": "Fill form fields"},
  {"input": "save_state", "expected_output": "Form state saved as memento", "description": "Save form state"},
  {"input": "modify_form email=new@example.com", "expected_output": "Form email updated to new@example.com", "description": "Modify form"},
  {"input": "restore_state", "expected_output": "Form restored: email=alice@example.com", "description": "Restore saved form state"}
]'::jsonb WHERE id = 'dp_086';

UPDATE challenges SET test_cases = '[
  {"input": "state=IDLE, event=call_button", "expected_output": "Elevator moving to requested floor", "description": "Call elevator"},
  {"input": "state=MOVING, event=arrive_floor", "expected_output": "Elevator arrived, doors opening", "description": "Elevator arrives at floor"},
  {"input": "state=DOORS_OPEN, event=door_close_timer", "expected_output": "Doors closed, elevator IDLE", "description": "Doors close"},
  {"input": "state=MOVING, event=emergency_stop", "expected_output": "Emergency stop, elevator halted", "description": "Emergency stop"}
]'::jsonb WHERE id = 'dp_087';

UPDATE challenges SET test_cases = '[
  {"input": "ast_node=BinaryOp(+, 3, 4), visitor=evaluator", "expected_output": "Evaluated: 7", "description": "Evaluate addition node"},
  {"input": "ast_node=BinaryOp(*, 3, BinaryOp(+, 2, 1)), visitor=evaluator", "expected_output": "Evaluated: 9", "description": "Evaluate nested expression"},
  {"input": "ast_node=Identifier(x), visitor=type_checker", "expected_output": "Type: integer (from symbol table)", "description": "Type check identifier"},
  {"input": "ast_node=IfStmt, visitor=code_generator", "expected_output": "Generated bytecode for if statement", "description": "Code generation visitor"}
]'::jsonb WHERE id = 'dp_088';

UPDATE challenges SET test_cases = '[
  {"input": "icon=home, size=24, color=blue", "expected_output": "Icon sprite home (24px blue) from flyweight atlas", "description": "Get icon from atlas"},
  {"input": "icon=home, size=24, color=red", "expected_output": "Icon sprite home (24px) reused, color=red applied extrinsically", "description": "Shared intrinsic state"},
  {"input": "icon=search, size=16, color=gray", "expected_output": "Icon sprite search (16px gray) from atlas", "description": "Different icon from atlas"},
  {"input": "atlas_size", "expected_output": "Atlas contains 50 unique icon sprites", "description": "Atlas size"}
]'::jsonb WHERE id = 'dp_089';

UPDATE challenges SET test_cases = '[
  {"input": "driver=AWS, operation=upload, file=data.csv", "expected_output": "data.csv uploaded via AWS driver", "description": "Upload via AWS driver"},
  {"input": "driver=GCP, operation=upload, file=data.csv", "expected_output": "data.csv uploaded via GCP driver", "description": "Upload via GCP driver"},
  {"input": "switch_driver from=AWS to=Azure", "expected_output": "Cloud driver switched to Azure", "description": "Switch cloud driver"},
  {"input": "driver=Azure, operation=list_files", "expected_output": "Files listed via Azure driver", "description": "List files via Azure driver"}
]'::jsonb WHERE id = 'dp_090';

UPDATE challenges SET test_cases = '[
  {"input": "os=Windows, file_op=create_dir path=C:\\Users\\test", "expected_output": "Windows directory created: C:\\Users\\test", "description": "Windows create directory"},
  {"input": "os=Linux, file_op=create_dir path=/home/test", "expected_output": "Linux directory created: /home/test", "description": "Linux create directory"},
  {"input": "os=Mac, file_op=list_dir path=/Users", "expected_output": "Mac directory listing: /Users", "description": "Mac list directory"},
  {"input": "os=Windows, file_op=delete path=C:\\temp\\file.txt", "expected_output": "Windows file deleted: C:\\temp\\file.txt", "description": "Windows delete file"}
]'::jsonb WHERE id = 'dp_091';

UPDATE challenges SET test_cases = '[
  {"input": "prototype=user_fixture, clone", "expected_output": "Test fixture cloned from user_fixture", "description": "Clone test fixture"},
  {"input": "modify clone username=testuser2", "expected_output": "Clone username set to testuser2, original unchanged", "description": "Modify cloned fixture"},
  {"input": "batch_clone prototype=order_fixture, count=10", "expected_output": "10 order fixtures cloned", "description": "Batch clone fixtures"},
  {"input": "register_prototype name=admin_user, fixture={role: admin}", "expected_output": "Prototype admin_user registered", "description": "Register new prototype"}
]'::jsonb WHERE id = 'dp_092';

UPDATE challenges SET test_cases = '[
  {"input": "user={history: [electronics, books]}, strategy=collaborative", "expected_output": "Recommendations: [laptop, novel] via collaborative filtering", "description": "Collaborative filtering"},
  {"input": "user={history: [electronics]}, strategy=content_based", "expected_output": "Recommendations: [headphones, tablet] via content-based", "description": "Content-based filtering"},
  {"input": "user=new_user, strategy=popular", "expected_output": "Recommendations: top 5 popular items", "description": "Popular items for new user"},
  {"input": "switch_strategy from=collaborative to=hybrid", "expected_output": "Strategy switched to hybrid", "description": "Switch recommendation strategy"}
]'::jsonb WHERE id = 'dp_093';

UPDATE challenges SET test_cases = '[
  {"input": "subscribe user=alice, product=laptop", "expected_output": "alice subscribed to price drops for laptop", "description": "Subscribe to price drop"},
  {"input": "price_update product=laptop, old=1000, new=850", "expected_output": "alice alerted: laptop dropped from $1000 to $850", "description": "Price drop notification"},
  {"input": "price_update product=laptop, old=850, new=900", "expected_output": "No alert: price increased", "description": "No alert on price increase"},
  {"input": "unsubscribe user=alice, product=laptop", "expected_output": "alice unsubscribed from laptop price alerts", "description": "Unsubscribe from alerts"}
]'::jsonb WHERE id = 'dp_094';

UPDATE challenges SET test_cases = '[
  {"input": "factory=coffee, type=espresso", "expected_output": "Espresso machine produced espresso", "description": "Coffee factory espresso"},
  {"input": "factory=tea, type=green_tea", "expected_output": "Tea machine produced green tea", "description": "Tea factory green tea"},
  {"input": "factory=juice, type=orange", "expected_output": "Juice machine produced orange juice", "description": "Juice factory orange"},
  {"input": "factory=coffee, type=cappuccino", "expected_output": "Coffee machine produced cappuccino with milk foam", "description": "Coffee factory cappuccino"}
]'::jsonb WHERE id = 'dp_095';

UPDATE challenges SET test_cases = '[
  {"input": "build url=https://api.example.com/users, method=GET", "expected_output": "GET https://api.example.com/users", "description": "Build simple GET request"},
  {"input": "chain .header(Authorization Bearer token123).timeout(30)", "expected_output": "Request: GET with auth header, 30s timeout", "description": "Chain headers and timeout"},
  {"input": "chain .param(page=1).param(limit=20)", "expected_output": "Request: GET https://api.example.com/users?page=1&limit=20", "description": "Chain query parameters"},
  {"input": "execute request", "expected_output": "Request executed, response received", "description": "Execute built request"}
]'::jsonb WHERE id = 'dp_096';

UPDATE challenges SET test_cases = '[
  {"input": "cache=empty, key=user_123", "expected_output": "Cache miss, fetched from DB, cached", "description": "Cache miss fetches from DB"},
  {"input": "cache=populated, key=user_123", "expected_output": "Cache hit, returned user_123 from cache", "description": "Cache hit returns cached data"},
  {"input": "ttl_expired key=user_123", "expected_output": "Cache expired, re-fetched and re-cached user_123", "description": "TTL expiry invalidates cache"},
  {"input": "invalidate key=user_123", "expected_output": "Cache invalidated for user_123", "description": "Manual cache invalidation"}
]'::jsonb WHERE id = 'dp_097';

UPDATE challenges SET test_cases = '[
  {"input": "fetch resource=remote_config, cache=empty", "expected_output": "Proxy: fetching remote_config from origin", "description": "Initial remote resource fetch"},
  {"input": "fetch resource=remote_config, cache=populated", "expected_output": "Proxy: returning cached remote_config", "description": "Cached remote resource"},
  {"input": "fetch resource=heavy_dataset size=100MB", "expected_output": "Proxy: loading heavy_dataset lazily", "description": "Lazy load large resource"},
  {"input": "resource=offline_resource", "expected_output": "Proxy: resource unavailable, returning fallback", "description": "Fallback for unavailable resource"}
]'::jsonb WHERE id = 'dp_098';

UPDATE challenges SET test_cases = '[
  {"input": "get_connection pool_size=10", "expected_output": "Connection acquired from pool (1/10 used)", "description": "Acquire connection from pool"},
  {"input": "get_connection pool_size=10 (all used)", "expected_output": "Pool exhausted, waiting for available connection", "description": "Pool exhausted waits"},
  {"input": "release_connection conn=1", "expected_output": "Connection 1 returned to pool (0/10 used)", "description": "Release connection"},
  {"input": "get_instance", "expected_output": "Connection pool singleton returned", "description": "Get singleton pool instance"}
]'::jsonb WHERE id = 'dp_099';

UPDATE challenges SET test_cases = '[
  {"input": "workflow=[step1, step2, step3], execute", "expected_output": "step1 -> step2 -> step3 executed", "description": "Execute workflow steps"},
  {"input": "step=step2, command=skip", "expected_output": "step2 skipped, step3 executed", "description": "Skip step in workflow"},
  {"input": "undo_step step=step3", "expected_output": "step3 undone, workflow at step2", "description": "Undo step"},
  {"input": "add_step after=step2, step=step2b", "expected_output": "step2b added after step2", "description": "Add step to workflow"}
]'::jsonb WHERE id = 'dp_100';


UPDATE challenges SET test_cases = '[
  {"input": "admit patient={name: Alice, age: 45, condition: hypertension}", "expected_output": "Patient Alice admitted, ID: P001", "description": "Admit patient"},
  {"input": "assign doctor=Dr. Smith, patient=P001", "expected_output": "Dr. Smith assigned to patient P001", "description": "Assign doctor to patient"},
  {"input": "discharge patient=P001", "expected_output": "Patient P001 discharged", "description": "Discharge patient"},
  {"input": "get_patient_record id=P001", "expected_output": "Record: Alice, age 45, conditions: hypertension, assigned: Dr. Smith", "description": "Get patient record"}
]'::jsonb WHERE id = 'oop_005';

UPDATE challenges SET test_cases = '[
  {"input": "request ride from=Times Square, to=JFK", "expected_output": "Nearest driver dispatched, ETA 8 min", "description": "Request ride"},
  {"input": "driver=D001 accept ride=R001", "expected_output": "Driver D001 accepted ride R001", "description": "Driver accepts ride"},
  {"input": "ride=R001 complete, fare=45.00", "expected_output": "Ride completed, fare $45.00 charged", "description": "Complete ride"},
  {"input": "rate driver=D001, rating=5", "expected_output": "Driver D001 rated 5 stars", "description": "Rate driver"}
]'::jsonb WHERE id = 'oop_006';

UPDATE challenges SET test_cases = '[
  {"input": "add_item sku=WIDGET001, qty=100, location=A1", "expected_output": "WIDGET001 added: 100 units at A1", "description": "Add inventory item"},
  {"input": "remove_item sku=WIDGET001, qty=10", "expected_output": "10 units removed, WIDGET001: 90 remaining", "description": "Remove inventory"},
  {"input": "low_stock threshold=20", "expected_output": "Low stock alerts: [] (WIDGET001 at 90)", "description": "Check low stock"},
  {"input": "find_item sku=WIDGET001", "expected_output": "WIDGET001 found at location A1, qty: 90", "description": "Find item location"}
]'::jsonb WHERE id = 'oop_007';

UPDATE challenges SET test_cases = '[
  {"input": "search flights from=NYC to=LAX, date=2024-06-15", "expected_output": "3 flights found: AA101, UA202, DL303", "description": "Search flights"},
  {"input": "book flight=AA101, passenger=Alice, seat=12A", "expected_output": "Booking confirmed: AA101 seat 12A for Alice", "description": "Book flight"},
  {"input": "cancel booking=BK001", "expected_output": "Booking BK001 cancelled, refund processed", "description": "Cancel booking"},
  {"input": "get_booking id=BK001 (cancelled)", "expected_output": "Booking BK001: CANCELLED", "description": "Get cancelled booking status"}
]'::jsonb WHERE id = 'oop_008';

UPDATE challenges SET test_cases = '[
  {"input": "check_availability hotel=Grand, check_in=2024-07-01, check_out=2024-07-05, type=double", "expected_output": "Double room available at Grand for 4 nights", "description": "Check room availability"},
  {"input": "book room=double, guest=Alice, nights=4", "expected_output": "Room booked: Double, Alice, $400 total", "description": "Book room"},
  {"input": "cancel booking=HB001", "expected_output": "Booking HB001 cancelled", "description": "Cancel hotel booking"},
  {"input": "get_bill booking=HB001", "expected_output": "Bill: 4 nights x $100 = $400", "description": "Get hotel bill"}
]'::jsonb WHERE id = 'oop_009';

UPDATE challenges SET test_cases = '[
  {"input": "create_auction item=vintage_watch, start_price=500", "expected_output": "Auction created: vintage_watch starting at $500", "description": "Create auction"},
  {"input": "place_bid user=alice, amount=600", "expected_output": "Bid $600 placed by alice (current highest)", "description": "Place bid"},
  {"input": "place_bid user=bob, amount=550", "expected_output": "Bid rejected: $550 is below current high bid $600", "description": "Low bid rejected"},
  {"input": "close_auction", "expected_output": "Auction closed: winner alice at $600", "description": "Close auction"}
]'::jsonb WHERE id = 'oop_010';

UPDATE challenges SET test_cases = '[
  {"input": "add_prescription patient=P001, drug=Amoxicillin, dosage=500mg", "expected_output": "Prescription added: Amoxicillin 500mg for P001", "description": "Add prescription"},
  {"input": "dispense prescription=RX001", "expected_output": "Amoxicillin 500mg dispensed for P001", "description": "Dispense medication"},
  {"input": "check_interactions drug1=Amoxicillin, drug2=Ibuprofen", "expected_output": "No critical interactions between Amoxicillin and Ibuprofen", "description": "Check drug interactions"},
  {"input": "refill prescription=RX001", "expected_output": "Prescription RX001 refilled", "description": "Refill prescription"}
]'::jsonb WHERE id = 'oop_011';

UPDATE challenges SET test_cases = '[
  {"input": "register member={name: Alice, plan: monthly}", "expected_output": "Member Alice registered with monthly plan", "description": "Register member"},
  {"input": "check_in member=M001", "expected_output": "Alice checked in at 09:00", "description": "Member check-in"},
  {"input": "upgrade_plan member=M001, plan=annual", "expected_output": "Alice upgraded to annual plan", "description": "Upgrade membership plan"},
  {"input": "cancel_membership member=M001", "expected_output": "Alice membership cancelled", "description": "Cancel membership"}
]'::jsonb WHERE id = 'oop_012';

UPDATE challenges SET test_cases = '[
  {"input": "place_order table=5, items=[burger, fries, cola]", "expected_output": "Order placed at table 5: burger, fries, cola", "description": "Place order"},
  {"input": "mark_ready order=O001", "expected_output": "Order O001 ready for delivery", "description": "Mark order ready"},
  {"input": "deliver order=O001, table=5", "expected_output": "Order O001 delivered to table 5", "description": "Deliver order"},
  {"input": "get_bill table=5", "expected_output": "Bill for table 5: $18.50", "description": "Get table bill"}
]'::jsonb WHERE id = 'oop_013';

UPDATE challenges SET test_cases = '[
  {"input": "add_vehicle id=V001, type=truck, driver=Bob", "expected_output": "Truck V001 assigned to Bob", "description": "Add vehicle to fleet"},
  {"input": "update_location vehicle=V001, lat=40.7, lon=-74.0", "expected_output": "V001 location updated: 40.7, -74.0", "description": "Update vehicle location"},
  {"input": "get_fleet_status", "expected_output": "Fleet: V001 (truck, active, Bob)", "description": "Get fleet status"},
  {"input": "assign_job vehicle=V001, destination=Warehouse B", "expected_output": "Job assigned to V001: deliver to Warehouse B", "description": "Assign delivery job"}
]'::jsonb WHERE id = 'oop_014';

UPDATE challenges SET test_cases = '[
  {"input": "add_student name=Alice, grade=10", "expected_output": "Student Alice (grade 10) added", "description": "Add student"},
  {"input": "record_score student=Alice, subject=Math, score=95", "expected_output": "Score recorded: Alice Math 95", "description": "Record score"},
  {"input": "get_gpa student=Alice", "expected_output": "Alice GPA: 3.8", "description": "Calculate GPA"},
  {"input": "get_class_average subject=Math", "expected_output": "Math class average: 82.5", "description": "Get class average"}
]'::jsonb WHERE id = 'oop_015';

UPDATE challenges SET test_cases = '[
  {"input": "post author=alice, content=Hello world!", "expected_output": "Post created by alice: Hello world!", "description": "Create post"},
  {"input": "follow user=alice, follower=bob", "expected_output": "bob is now following alice", "description": "Follow user"},
  {"input": "get_feed user=bob", "expected_output": "Feed for bob: [alice: Hello world!]", "description": "Get user feed"},
  {"input": "like post=P001, user=bob", "expected_output": "Post P001 liked by bob (1 like)", "description": "Like post"}
]'::jsonb WHERE id = 'oop_016';

UPDATE challenges SET test_cases = '[
  {"input": "list_property address=123 Main St, price=350000, type=condo", "expected_output": "Property listed: 123 Main St, $350,000 condo", "description": "List property"},
  {"input": "search type=condo, max_price=400000", "expected_output": "1 result: 123 Main St, $350,000", "description": "Search listings"},
  {"input": "contact agent=A001 for property=P001", "expected_output": "Inquiry sent to agent A001 for P001", "description": "Contact agent"},
  {"input": "mark_sold property=P001", "expected_output": "Property P001 marked as sold", "description": "Mark property sold"}
]'::jsonb WHERE id = 'oop_017';

UPDATE challenges SET test_cases = '[
  {"input": "search artist=Beatles, catalog", "expected_output": "Beatles: 13 albums found", "description": "Search artist catalog"},
  {"input": "play song=Come Together", "expected_output": "Now playing: Come Together by The Beatles", "description": "Play song"},
  {"input": "add_to_playlist song=Come Together, playlist=favorites", "expected_output": "Come Together added to favorites playlist", "description": "Add to playlist"},
  {"input": "get_recommendations based_on=Come Together", "expected_output": "Recommended: 5 similar tracks", "description": "Get recommendations"}
]'::jsonb WHERE id = 'oop_018';

UPDATE challenges SET test_cases = '[
  {"input": "create_policy type=auto, holder=Alice, premium=1200", "expected_output": "Auto policy created for Alice at $1200/year", "description": "Create policy"},
  {"input": "file_claim policy=POL001, amount=500", "expected_output": "Claim filed on POL001 for $500", "description": "File claim"},
  {"input": "approve_claim claim=CLM001", "expected_output": "Claim CLM001 approved, payout $500", "description": "Approve claim"},
  {"input": "renew_policy policy=POL001", "expected_output": "Policy POL001 renewed for another year", "description": "Renew policy"}
]'::jsonb WHERE id = 'oop_019';

UPDATE challenges SET test_cases = '[
  {"input": "park vehicle=CAR001, spot=A5, type=sedan", "expected_output": "CAR001 parked at spot A5", "description": "Park vehicle"},
  {"input": "get_ticket vehicle=CAR001", "expected_output": "Ticket issued: CAR001, spot A5, time: 10:00", "description": "Get parking ticket"},
  {"input": "exit vehicle=CAR001, duration=2hours", "expected_output": "CAR001 exited, fee $6.00 (2hrs x $3)", "description": "Exit and pay fee"},
  {"input": "available_spots type=sedan", "expected_output": "49 sedan spots available", "description": "Check available spots"}
]'::jsonb WHERE id = 'oop_020';

UPDATE challenges SET test_cases = '[
  {"input": "add_source name=TechNews, url=technews.com, category=technology", "expected_output": "Source TechNews added", "description": "Add news source"},
  {"input": "fetch_feed source=TechNews", "expected_output": "Fetched 10 articles from TechNews", "description": "Fetch news feed"},
  {"input": "filter category=technology", "expected_output": "Filtered feed: 10 technology articles", "description": "Filter by category"},
  {"input": "get_top_stories count=5", "expected_output": "Top 5 stories returned", "description": "Get top stories"}
]'::jsonb WHERE id = 'oop_021';

UPDATE challenges SET test_cases = '[
  {"input": "add_application job=SWE at Google, status=applied", "expected_output": "Application added: SWE at Google (applied)", "description": "Add application"},
  {"input": "update_status job=SWE at Google, status=interview", "expected_output": "Application updated to interview stage", "description": "Update application status"},
  {"input": "get_pipeline", "expected_output": "Pipeline: 1 applied, 1 interview, 0 offers", "description": "Get application pipeline"},
  {"input": "add_note job=SWE at Google, note=System design interview on Monday", "expected_output": "Note added to SWE at Google application", "description": "Add note to application"}
]'::jsonb WHERE id = 'oop_022';

UPDATE challenges SET test_cases = '[
  {"input": "create_shipment id=PKG001, origin=NYC, destination=LA", "expected_output": "Shipment PKG001 created: NYC -> LA", "description": "Create shipment"},
  {"input": "update_status shipment=PKG001, status=in_transit, location=Chicago", "expected_output": "PKG001 in transit, current location: Chicago", "description": "Update shipment status"},
  {"input": "track shipment=PKG001", "expected_output": "PKG001: in transit, Chicago, ETA 2 days", "description": "Track package"},
  {"input": "deliver shipment=PKG001", "expected_output": "PKG001 delivered to LA", "description": "Mark as delivered"}
]'::jsonb WHERE id = 'oop_023';

UPDATE challenges SET test_cases = '[
  {"input": "create_event name=Concert, venue=Madison Square Garden, capacity=20000", "expected_output": "Event created: Concert at MSG, capacity 20000", "description": "Create event"},
  {"input": "purchase ticket=VIP, user=alice, event=Concert", "expected_output": "VIP ticket purchased for alice at Concert", "description": "Purchase ticket"},
  {"input": "cancel ticket=TKT001, user=alice", "expected_output": "Ticket TKT001 cancelled, refund issued", "description": "Cancel ticket"},
  {"input": "get_available_seats event=Concert, type=general", "expected_output": "General admission: 15000 available", "description": "Check available seats"}
]'::jsonb WHERE id = 'oop_024';

UPDATE challenges SET test_cases = '[
  {"input": "add_funds wallet=W001, amount=100, method=card", "expected_output": "Wallet W001 funded $100 via card", "description": "Add funds to wallet"},
  {"input": "transfer from=W001, to=W002, amount=50", "expected_output": "Transferred $50 from W001 to W002", "description": "Transfer between wallets"},
  {"input": "get_balance wallet=W001", "expected_output": "Wallet W001 balance: $50.00", "description": "Get wallet balance"},
  {"input": "get_history wallet=W001", "expected_output": "Transactions: +$100 (card), -$50 (transfer to W002)", "description": "Get transaction history"}
]'::jsonb WHERE id = 'oop_025';

UPDATE challenges SET test_cases = '[
  {"input": "loan=50000, term=10years, interest_rate=5%", "expected_output": "Monthly payment: $530.33", "description": "Calculate monthly payment"},
  {"input": "extra_payment monthly=100, loan=50000", "expected_output": "Payoff accelerated by 14 months", "description": "Extra payment effect"},
  {"input": "total_interest loan=50000, term=10years, rate=5%", "expected_output": "Total interest: $13,639.60", "description": "Calculate total interest"},
  {"input": "amortization_schedule month=1", "expected_output": "Month 1: payment $530.33, principal $321.66, interest $208.33", "description": "Amortization schedule"}
]'::jsonb WHERE id = 'oop_026';

UPDATE challenges SET test_cases = '[
  {"input": "add_employee name=Alice, dept=Engineering, title=SWE", "expected_output": "Employee Alice added to Engineering", "description": "Add employee"},
  {"input": "search name=Alice", "expected_output": "Found: Alice, SWE, Engineering", "description": "Search employee by name"},
  {"input": "update_title employee=Alice, title=Senior SWE", "expected_output": "Alice promoted to Senior SWE", "description": "Update employee title"},
  {"input": "get_department dept=Engineering", "expected_output": "Engineering dept: 1 employee (Alice)", "description": "Get department employees"}
]'::jsonb WHERE id = 'oop_027';

UPDATE challenges SET test_cases = '[
  {"input": "place_order customer=alice, items=[pizza, cola], address=123 Main", "expected_output": "Order placed for alice, routed to nearest restaurant", "description": "Place delivery order"},
  {"input": "assign_driver order=ORD001, driver=D001", "expected_output": "Driver D001 assigned to ORD001", "description": "Assign delivery driver"},
  {"input": "update_eta order=ORD001, eta=25min", "expected_output": "ETA updated: ORD001 arriving in 25 minutes", "description": "Update delivery ETA"},
  {"input": "deliver order=ORD001", "expected_output": "ORD001 delivered to alice", "description": "Mark order delivered"}
]'::jsonb WHERE id = 'oop_028';

UPDATE challenges SET test_cases = '[
  {"input": "subscribe user=alice, plan=premium, billing=monthly", "expected_output": "Alice subscribed to premium monthly at $9.99", "description": "Create subscription"},
  {"input": "process_billing user=alice", "expected_output": "Billed alice $9.99 for premium monthly", "description": "Process billing"},
  {"input": "upgrade user=alice, plan=enterprise", "expected_output": "Alice upgraded to enterprise, prorated charge applied", "description": "Upgrade subscription"},
  {"input": "cancel user=alice, effective=end_of_period", "expected_output": "Alice subscription cancelled at end of billing period", "description": "Cancel subscription"}
]'::jsonb WHERE id = 'oop_029';

UPDATE challenges SET test_cases = '[
  {"input": "create_tournament name=Chess Open, participants=8", "expected_output": "Tournament created with 8-player bracket", "description": "Create tournament"},
  {"input": "record_result match=M001, winner=alice, loser=bob", "expected_output": "Match M001: alice advances, bob eliminated", "description": "Record match result"},
  {"input": "get_bracket", "expected_output": "Round 1: alice vs bob, charlie vs dave...", "description": "Get tournament bracket"},
  {"input": "get_champion tournament=Chess Open", "expected_output": "Champion: alice", "description": "Get tournament champion"}
]'::jsonb WHERE id = 'oop_030';

UPDATE challenges SET test_cases = '[
  {"input": "classroom seats=30, assign student=Alice, seat=A1", "expected_output": "Alice assigned to seat A1", "description": "Assign student seat"},
  {"input": "move student=Alice, from=A1, to=B3", "expected_output": "Alice moved to seat B3", "description": "Move student seat"},
  {"input": "get_seating_chart", "expected_output": "Seating chart: Alice at B3, 29 empty seats", "description": "Get seating chart"},
  {"input": "available_seats", "expected_output": "29 seats available", "description": "Count available seats"}
]'::jsonb WHERE id = 'oop_031';

UPDATE challenges SET test_cases = '[
  {"input": "add_car vin=VIN001, make=Toyota, model=Camry, price=25000", "expected_output": "Toyota Camry added to inventory at $25,000", "description": "Add car to inventory"},
  {"input": "search make=Toyota", "expected_output": "Found 1: Toyota Camry VIN001, $25,000", "description": "Search by make"},
  {"input": "sell car=VIN001, buyer=Alice", "expected_output": "Toyota Camry VIN001 sold to Alice", "description": "Sell car"},
  {"input": "get_inventory", "expected_output": "Inventory: 0 cars (after sale)", "description": "Get current inventory"}
]'::jsonb WHERE id = 'oop_032';

UPDATE challenges SET test_cases = '[
  {"input": "add_recipe name=Pasta, ingredients=[pasta, sauce, cheese]", "expected_output": "Recipe Pasta added with 3 ingredients", "description": "Add recipe"},
  {"input": "search ingredient=pasta", "expected_output": "Recipes with pasta: [Pasta]", "description": "Search by ingredient"},
  {"input": "scale_recipe name=Pasta, servings=4 to 8", "expected_output": "Pasta recipe scaled: doubled all ingredients", "description": "Scale recipe servings"},
  {"input": "get_nutrition recipe=Pasta", "expected_output": "Pasta: 650 cal, 28g protein, 85g carbs", "description": "Get recipe nutrition"}
]'::jsonb WHERE id = 'oop_033';

UPDATE challenges SET test_cases = '[
  {"input": "subscribe podcast=TechTalk, user=alice", "expected_output": "alice subscribed to TechTalk", "description": "Subscribe to podcast"},
  {"input": "mark_played episode=TechTalk_E001, user=alice", "expected_output": "TechTalk E001 marked played for alice", "description": "Mark episode played"},
  {"input": "get_unplayed user=alice, podcast=TechTalk", "expected_output": "Unplayed TechTalk episodes: 5", "description": "Get unplayed count"},
  {"input": "get_progress episode=TechTalk_E001, user=alice", "expected_output": "TechTalk E001: played", "description": "Get episode progress"}
]'::jsonb WHERE id = 'oop_034';

UPDATE challenges SET test_cases = '[
  {"input": "earn_points user=alice, amount=100, transaction=purchase", "expected_output": "alice earned 100 points (total: 100)", "description": "Earn reward points"},
  {"input": "redeem user=alice, points=50, reward=discount", "expected_output": "alice redeemed 50 points for $5 discount", "description": "Redeem points"},
  {"input": "get_balance user=alice", "expected_output": "alice points balance: 50", "description": "Get points balance"},
  {"input": "tier_status user=alice", "expected_output": "alice tier: Silver (100 points earned)", "description": "Get tier status"}
]'::jsonb WHERE id = 'oop_035';

UPDATE challenges SET test_cases = '[
  {"input": "check_in bag=BAG001, flight=UA123, weight=23kg", "expected_output": "BAG001 checked in for UA123, 23kg", "description": "Check in baggage"},
  {"input": "scan bag=BAG001, location=gate_B5", "expected_output": "BAG001 scanned at gate B5", "description": "Scan bag at gate"},
  {"input": "track bag=BAG001", "expected_output": "BAG001: last scanned at gate B5, flight UA123", "description": "Track bag location"},
  {"input": "flag bag=BAG001, reason=overweight", "expected_output": "BAG001 flagged: overweight, fee $50 charged", "description": "Flag overweight bag"}
]'::jsonb WHERE id = 'oop_036';

UPDATE challenges SET test_cases = '[
  {"input": "open_case client=Alice, type=civil, description=property dispute", "expected_output": "Case C001 opened for Alice: property dispute", "description": "Open legal case"},
  {"input": "add_document case=C001, doc=evidence_photo.pdf", "expected_output": "Document added to case C001", "description": "Add document to case"},
  {"input": "schedule_hearing case=C001, date=2024-09-15", "expected_output": "Hearing scheduled for C001 on 2024-09-15", "description": "Schedule hearing"},
  {"input": "close_case case=C001, outcome=settled", "expected_output": "Case C001 closed: settled", "description": "Close case"}
]'::jsonb WHERE id = 'oop_037';

UPDATE challenges SET test_cases = '[
  {"input": "book appointment pet=Fluffy, type=checkup, date=2024-07-10 10:00", "expected_output": "Appointment booked: Fluffy checkup on 2024-07-10 at 10:00", "description": "Book appointment"},
  {"input": "cancel appointment=APT001", "expected_output": "Appointment APT001 cancelled", "description": "Cancel appointment"},
  {"input": "reschedule appointment=APT002, new_date=2024-07-12 14:00", "expected_output": "APT002 rescheduled to 2024-07-12 at 14:00", "description": "Reschedule appointment"},
  {"input": "get_upcoming vet=Dr. Wilson", "expected_output": "Dr. Wilson upcoming: 2 appointments this week", "description": "Get vet upcoming appointments"}
]'::jsonb WHERE id = 'oop_038';

UPDATE challenges SET test_cases = '[
  {"input": "book room=Conf_A, user=alice, date=2024-07-15, time=10:00-11:00", "expected_output": "Conference room A booked by alice 2024-07-15 10:00-11:00", "description": "Book conference room"},
  {"input": "book room=Conf_A, user=bob, date=2024-07-15, time=10:30-11:30", "expected_output": "Booking conflict: Conf_A unavailable at 10:30", "description": "Booking conflict detection"},
  {"input": "cancel booking=ROOM001", "expected_output": "Booking ROOM001 cancelled, room freed", "description": "Cancel room booking"},
  {"input": "get_availability room=Conf_A, date=2024-07-15", "expected_output": "Conf_A availability: 10:00-11:00 taken, rest free", "description": "Check room availability"}
]'::jsonb WHERE id = 'oop_039';

UPDATE challenges SET test_cases = '[
  {"input": "create_shipment id=SHP001, origin=Factory, destination=Warehouse", "expected_output": "Shipment SHP001 created: Factory -> Warehouse", "description": "Create supply chain shipment"},
  {"input": "update_milestone shipment=SHP001, milestone=customs_cleared", "expected_output": "SHP001 milestone: customs cleared", "description": "Update shipment milestone"},
  {"input": "get_status shipment=SHP001", "expected_output": "SHP001: in transit, customs cleared", "description": "Get shipment status"},
  {"input": "alert delay=SHP001, days=3", "expected_output": "Alert: SHP001 delayed by 3 days", "description": "Delay alert"}
]'::jsonb WHERE id = 'oop_040';

UPDATE challenges SET test_cases = '[
  {"input": "enroll student=alice, course=Python101", "expected_output": "alice enrolled in Python101", "description": "Enroll in course"},
  {"input": "enroll student=alice, course=Python101 (already enrolled)", "expected_output": "Error: alice already enrolled in Python101", "description": "Duplicate enrollment error"},
  {"input": "complete course=Python101, student=alice", "expected_output": "alice completed Python101, certificate issued", "description": "Complete course"},
  {"input": "get_progress student=alice, course=Python101", "expected_output": "alice Python101 progress: 60% complete", "description": "Get course progress"}
]'::jsonb WHERE id = 'oop_041';

UPDATE challenges SET test_cases = '[
  {"input": "checkout book=Design Patterns, user=alice, due=2024-07-30", "expected_output": "Book checked out: Design Patterns for alice, due 2024-07-30", "description": "Checkout book"},
  {"input": "return book=Design Patterns, user=alice, returned=2024-08-05", "expected_output": "Book returned 6 days late, fine: $3.00", "description": "Late return fine"},
  {"input": "get_fines user=alice", "expected_output": "alice outstanding fines: $3.00", "description": "Get user fines"},
  {"input": "pay_fine user=alice, amount=3.00", "expected_output": "Fine paid: $3.00. alice balance: $0.00", "description": "Pay library fine"}
]'::jsonb WHERE id = 'oop_042';

UPDATE challenges SET test_cases = '[
  {"input": "add_team name=Lakers, wins=10, losses=2", "expected_output": "Lakers added: 10W 2L", "description": "Add team to league"},
  {"input": "record_result winner=Lakers, loser=Celtics", "expected_output": "Result recorded: Lakers win, standings updated", "description": "Record match result"},
  {"input": "get_standings", "expected_output": "1. Lakers: 11W 2L (pts 34)\n2. Celtics: 8W 5L (pts 25)", "description": "Get league standings"},
  {"input": "get_top_scorer", "expected_output": "Top scorer: LeBron James, 28.5 ppg", "description": "Get top scorer"}
]'::jsonb WHERE id = 'oop_043';

UPDATE challenges SET test_cases = '[
  {"input": "reserve seat=C5, user=alice, show=Hamlet 2024-07-20", "expected_output": "Seat C5 reserved for alice at Hamlet", "description": "Reserve seat"},
  {"input": "reserve seat=C5, user=bob, show=Hamlet 2024-07-20", "expected_output": "Seat C5 already reserved", "description": "Duplicate reservation rejected"},
  {"input": "cancel reservation seat=C5, show=Hamlet", "expected_output": "Reservation for C5 cancelled, seat available", "description": "Cancel reservation"},
  {"input": "get_available_seats show=Hamlet", "expected_output": "Hamlet: 199 seats available", "description": "Get available seats"}
]'::jsonb WHERE id = 'oop_044';

UPDATE challenges SET test_cases = '[
  {"input": "transaction card=1234, amount=5000, location=Moscow", "expected_output": "FRAUD ALERT: unusual location for card 1234", "description": "Flag unusual location"},
  {"input": "transaction card=1234, amount=10, location=NYC", "expected_output": "Transaction approved: $10 at NYC", "description": "Normal transaction approved"},
  {"input": "transaction card=1234, amount=10000, location=NYC", "expected_output": "FRAUD ALERT: unusually large amount $10,000", "description": "Flag large transaction"},
  {"input": "multiple_transactions card=1234, count=20, window=1min", "expected_output": "FRAUD ALERT: 20 transactions in 1 minute", "description": "Flag rapid transactions"}
]'::jsonb WHERE id = 'oop_045';

UPDATE challenges SET test_cases = '[
  {"input": "register device=smart_bulb_1, room=living_room", "expected_output": "smart_bulb_1 registered in living_room", "description": "Register smart device"},
  {"input": "command device=smart_bulb_1, action=turn_on", "expected_output": "smart_bulb_1 turned ON", "description": "Turn on smart bulb"},
  {"input": "scene activate=movie_night", "expected_output": "Movie night scene: lights dimmed 30%, TV on, blinds closed", "description": "Activate scene"},
  {"input": "get_status device=smart_bulb_1", "expected_output": "smart_bulb_1: ON, brightness 30%", "description": "Get device status"}
]'::jsonb WHERE id = 'oop_046';

UPDATE challenges SET test_cases = '[
  {"input": "create_project name=Website Redesign, deadline=2024-09-01", "expected_output": "Project Website Redesign created", "description": "Create project"},
  {"input": "add_task project=Website, title=Design mockups, assigned=alice", "expected_output": "Task added: Design mockups assigned to alice", "description": "Add task"},
  {"input": "update_status task=T001, status=in_progress", "expected_output": "Task T001 status: in_progress", "description": "Update task status"},
  {"input": "get_project_progress project=Website", "expected_output": "Website Redesign: 1/3 tasks complete (33%)", "description": "Get project progress"}
]'::jsonb WHERE id = 'oop_047';

UPDATE challenges SET test_cases = '[
  {"input": "add_record patient=P001, type=lab_result, data=blood_glucose_110", "expected_output": "Lab result added to P001 record", "description": "Add medical record"},
  {"input": "get_history patient=P001", "expected_output": "P001 history: [lab_result: blood_glucose_110]", "description": "Get patient history"},
  {"input": "search patient=P001, type=prescriptions", "expected_output": "P001 prescriptions: [Amoxicillin 500mg]", "description": "Search records by type"},
  {"input": "share_record patient=P001, doctor=Dr. Smith", "expected_output": "P001 record shared with Dr. Smith", "description": "Share medical record"}
]'::jsonb WHERE id = 'oop_048';

UPDATE challenges SET test_cases = '[
  {"input": "buy crypto=BTC, amount=0.5, price=50000", "expected_output": "Bought 0.5 BTC at $50,000, total: $25,000", "description": "Buy cryptocurrency"},
  {"input": "sell crypto=BTC, amount=0.2, price=52000", "expected_output": "Sold 0.2 BTC at $52,000, profit: $400", "description": "Sell cryptocurrency"},
  {"input": "get_portfolio user=alice", "expected_output": "alice portfolio: 0.3 BTC worth $15,600", "description": "Get portfolio"},
  {"input": "get_transaction_history user=alice", "expected_output": "alice transactions: [buy 0.5 BTC, sell 0.2 BTC]", "description": "Get transaction history"}
]'::jsonb WHERE id = 'oop_049';

UPDATE challenges SET test_cases = '[
  {"input": "log_activity user=alice, type=run, distance=5km, duration=30min", "expected_output": "Activity logged: alice ran 5km in 30 min", "description": "Log run activity"},
  {"input": "get_weekly_summary user=alice", "expected_output": "alice weekly: 3 runs, 15km, 90 min", "description": "Get weekly summary"},
  {"input": "set_goal user=alice, type=steps, target=10000", "expected_output": "Goal set: alice steps target 10,000/day", "description": "Set fitness goal"},
  {"input": "goal_progress user=alice, type=steps, today=8500", "expected_output": "alice steps: 8500/10000 (85%)", "description": "Check goal progress"}
]'::jsonb WHERE id = 'oop_050';

UPDATE challenges SET test_cases = '[
  {"input": "file_taxes user=alice, income=75000, deductions=12000", "expected_output": "Taxable income: $63,000, tax owed: $9,450", "description": "Calculate tax owed"},
  {"input": "apply_deduction type=mortgage_interest, amount=8000", "expected_output": "Deduction applied: $8,000 mortgage interest", "description": "Apply deduction"},
  {"input": "get_refund user=alice, withheld=12000", "expected_output": "Refund: $2,550 (withheld $12,000, owed $9,450)", "description": "Calculate refund"},
  {"input": "submit return=alice_2023", "expected_output": "Tax return submitted for alice (2023)", "description": "Submit tax return"}
]'::jsonb WHERE id = 'oop_051';

UPDATE challenges SET test_cases = '[
  {"input": "schedule route=R5, departure=08:00, stops=[Stop1, Stop2, Stop3]", "expected_output": "Route R5 scheduled: 3 stops, departs 08:00", "description": "Schedule bus route"},
  {"input": "get_next_bus stop=Stop2, route=R5", "expected_output": "Next R5 bus at Stop2: 08:15", "description": "Get next bus time"},
  {"input": "delay route=R5, minutes=10", "expected_output": "Route R5 delayed 10 min, updated schedule broadcast", "description": "Report route delay"},
  {"input": "get_route_status route=R5", "expected_output": "Route R5: on time, current stop Stop1", "description": "Get route status"}
]'::jsonb WHERE id = 'oop_052';

UPDATE challenges SET test_cases = '[
  {"input": "scan item=SKU001, qty=1", "expected_output": "SKU001 added to cart: $5.99", "description": "Scan item"},
  {"input": "apply_discount coupon=SAVE10", "expected_output": "10% discount applied", "description": "Apply coupon discount"},
  {"input": "process_payment method=card, amount=15.29", "expected_output": "Payment processed: $15.29 via card", "description": "Process payment"},
  {"input": "print_receipt", "expected_output": "Receipt printed: 3 items, subtotal $16.99, discount -$1.70, total $15.29", "description": "Print receipt"}
]'::jsonb WHERE id = 'oop_053';

UPDATE challenges SET test_cases = '[
  {"input": "upload file=report.pdf, user=alice, size=2MB", "expected_output": "report.pdf uploaded to alice storage (2MB)", "description": "Upload file"},
  {"input": "download file=report.pdf, user=alice", "expected_output": "report.pdf downloaded by alice", "description": "Download file"},
  {"input": "share file=report.pdf, from=alice, to=bob", "expected_output": "report.pdf shared from alice to bob", "description": "Share file"},
  {"input": "delete file=report.pdf, user=alice", "expected_output": "report.pdf deleted from alice storage", "description": "Delete file"}
]'::jsonb WHERE id = 'oop_054';

UPDATE challenges SET test_cases = '[
  {"input": "book appointment provider=Dr. Smith, user=alice, date=2024-07-10 09:00", "expected_output": "Appointment booked: alice with Dr. Smith at 09:00", "description": "Book appointment"},
  {"input": "cancel appointment=APT001", "expected_output": "Appointment APT001 cancelled, slot freed", "description": "Cancel appointment"},
  {"input": "get_availability provider=Dr. Smith, date=2024-07-10", "expected_output": "Dr. Smith 2024-07-10 available: 09:00-12:00", "description": "Check availability"},
  {"input": "reschedule appointment=APT002, new_time=2024-07-11 14:00", "expected_output": "APT002 rescheduled to 2024-07-11 14:00", "description": "Reschedule appointment"}
]'::jsonb WHERE id = 'oop_055';

UPDATE challenges SET test_cases = '[
  {"input": "subscribe email=alice@example.com, list=weekly_digest", "expected_output": "alice@example.com subscribed to weekly_digest", "description": "Subscribe to newsletter"},
  {"input": "unsubscribe email=alice@example.com, list=weekly_digest", "expected_output": "alice@example.com unsubscribed from weekly_digest", "description": "Unsubscribe"},
  {"input": "send newsletter=weekly_digest, list=weekly_digest", "expected_output": "Newsletter sent to 100 subscribers", "description": "Send newsletter"},
  {"input": "get_subscriber_count list=weekly_digest", "expected_output": "weekly_digest subscribers: 100", "description": "Get subscriber count"}
]'::jsonb WHERE id = 'oop_056';

UPDATE challenges SET test_cases = '[
  {"input": "create_quiz title=Python Basics, questions=5", "expected_output": "Quiz created: Python Basics with 5 questions", "description": "Create quiz"},
  {"input": "answer question=Q1, answer=B", "expected_output": "Question Q1: correct!", "description": "Answer question correctly"},
  {"input": "answer question=Q2, answer=A (wrong)", "expected_output": "Question Q2: incorrect, correct answer was C", "description": "Wrong answer feedback"},
  {"input": "get_score quiz=Python Basics", "expected_output": "Score: 4/5 (80%)", "description": "Get quiz score"}
]'::jsonb WHERE id = 'oop_057';

UPDATE challenges SET test_cases = '[
  {"input": "apply loan=250000, term=30years, rate=6.5%, income=80000", "expected_output": "Application submitted, DTI ratio: 28%", "description": "Submit mortgage application"},
  {"input": "approve application=MORT001", "expected_output": "Mortgage MORT001 approved: $250,000 at 6.5%", "description": "Approve mortgage"},
  {"input": "get_monthly_payment loan=250000, rate=6.5%, term=30", "expected_output": "Monthly payment: $1,580.17", "description": "Calculate monthly payment"},
  {"input": "deny application=MORT002, reason=low_credit", "expected_output": "Mortgage MORT002 denied: low credit score", "description": "Deny mortgage application"}
]'::jsonb WHERE id = 'oop_058';

UPDATE challenges SET test_cases = '[
  {"input": "add_item sku=PROD001, qty=5, reorder_point=10", "expected_output": "PROD001 added, reorder point set at 10", "description": "Add item with reorder point"},
  {"input": "update_qty sku=PROD001, qty=8 (below reorder)", "expected_output": "Alert: PROD001 at 8 units (below reorder point 10)", "description": "Trigger reorder alert"},
  {"input": "get_reorder_list", "expected_output": "Reorder needed: [PROD001: 8 units]", "description": "Get reorder list"},
  {"input": "acknowledge_alert sku=PROD001", "expected_output": "Reorder acknowledged for PROD001", "description": "Acknowledge reorder alert"}
]'::jsonb WHERE id = 'oop_059';

UPDATE challenges SET test_cases = '[
  {"input": "create_ticket user=alice, issue=Login not working, priority=high", "expected_output": "Ticket T001 created for alice (high priority)", "description": "Create support ticket"},
  {"input": "assign ticket=T001, agent=Support_Bob", "expected_output": "Ticket T001 assigned to Support_Bob", "description": "Assign ticket to agent"},
  {"input": "resolve ticket=T001, resolution=Password reset completed", "expected_output": "Ticket T001 resolved: Password reset completed", "description": "Resolve ticket"},
  {"input": "escalate ticket=T001, level=2", "expected_output": "Ticket T001 escalated to level 2 support", "description": "Escalate ticket"}
]'::jsonb WHERE id = 'oop_060';

UPDATE challenges SET test_cases = '[
  {"input": "add_showtime movie=Inception, time=2024-07-15 18:00, hall=Hall1", "expected_output": "Showtime added: Inception at 18:00 in Hall1", "description": "Add showtime"},
  {"input": "get_showtimes movie=Inception, date=2024-07-15", "expected_output": "Inception showtimes: 14:00, 18:00, 21:00", "description": "Get movie showtimes"},
  {"input": "book seat=F5, showtime=Inception 18:00, user=alice", "expected_output": "Seat F5 booked for alice at Inception 18:00", "description": "Book showtime seat"},
  {"input": "cancel booking=STB001", "expected_output": "Booking STB001 cancelled, seat F5 freed", "description": "Cancel showtime booking"}
]'::jsonb WHERE id = 'oop_061';

UPDATE challenges SET test_cases = '[
  {"input": "add_asset type=stock, ticker=AAPL, value=10000, risk=medium", "expected_output": "AAPL added to portfolio: $10,000 medium risk", "description": "Add asset to portfolio"},
  {"input": "calculate_var portfolio=P001, confidence=95%", "expected_output": "VaR at 95%: $850 (portfolio $10,000)", "description": "Calculate Value at Risk"},
  {"input": "get_diversification portfolio=P001", "expected_output": "Portfolio: 60% stocks, 30% bonds, 10% cash", "description": "Check diversification"},
  {"input": "stress_test scenario=2008_crash", "expected_output": "Stress test: portfolio loses 35% in 2008 scenario", "description": "Stress test portfolio"}
]'::jsonb WHERE id = 'oop_062';

UPDATE challenges SET test_cases = '[
  {"input": "assign_drone id=D001, delivery=PKG001, destination=lat:40.7,lon:-74.0", "expected_output": "Drone D001 assigned to PKG001", "description": "Assign drone to delivery"},
  {"input": "update_position drone=D001, lat=40.71, lon=-73.99", "expected_output": "Drone D001 position updated", "description": "Update drone position"},
  {"input": "battery_alert drone=D001, level=15%", "expected_output": "Alert: Drone D001 battery at 15%, return to base", "description": "Low battery alert"},
  {"input": "complete_delivery drone=D001, package=PKG001", "expected_output": "PKG001 delivered by D001", "description": "Complete drone delivery"}
]'::jsonb WHERE id = 'oop_063';

UPDATE challenges SET test_cases = '[
  {"input": "add_member name=Alice, type=annual, expires=2024-12-31", "expected_output": "Alice annual membership added, expires 2024-12-31", "description": "Add member"},
  {"input": "check_expiry member=Alice, today=2024-11-01", "expected_output": "Alice membership expires in 60 days, renewal notice sent", "description": "Check membership expiry"},
  {"input": "renew member=Alice, plan=annual", "expected_output": "Alice membership renewed for 1 year", "description": "Renew membership"},
  {"input": "expire member=Alice", "expected_output": "Alice membership expired, access revoked", "description": "Expire membership"}
]'::jsonb WHERE id = 'oop_064';

UPDATE challenges SET test_cases = '[
  {"input": "add_review product=P001, user=alice, rating=4, text=Great product", "expected_output": "Review added: alice rated P001 4 stars", "description": "Add product review"},
  {"input": "get_average_rating product=P001", "expected_output": "P001 average rating: 4.2 (5 reviews)", "description": "Get average rating"},
  {"input": "filter_reviews product=P001, min_rating=4", "expected_output": "P001 reviews with 4+ stars: 3 reviews", "description": "Filter reviews by rating"},
  {"input": "flag_review review=R001, reason=spam", "expected_output": "Review R001 flagged as spam", "description": "Flag review"}
]'::jsonb WHERE id = 'oop_065';

UPDATE challenges SET test_cases = '[
  {"input": "register_voter name=Alice, id=V001", "expected_output": "Voter Alice (V001) registered", "description": "Register voter"},
  {"input": "cast_vote voter=V001, candidate=Alice_Smith", "expected_output": "Vote cast by V001 for Alice_Smith", "description": "Cast vote"},
  {"input": "cast_vote voter=V001, candidate=Bob_Jones (second vote)", "expected_output": "Error: V001 has already voted", "description": "Prevent double voting"},
  {"input": "tally_results", "expected_output": "Results: Alice_Smith 520 votes, Bob_Jones 480 votes", "description": "Tally election results"}
]'::jsonb WHERE id = 'oop_066';

UPDATE challenges SET test_cases = '[
  {"input": "create_account user=alice, utility=electric", "expected_output": "Electric account created for alice", "description": "Create utility account"},
  {"input": "generate_bill user=alice, usage=350kWh", "expected_output": "Bill generated: alice electric $42.00 (350kWh at $0.12/kWh)", "description": "Generate utility bill"},
  {"input": "process_payment user=alice, amount=42.00", "expected_output": "Payment of $42.00 processed for alice", "description": "Process payment"},
  {"input": "get_usage_history user=alice", "expected_output": "alice electric usage: Jan 320kWh, Feb 350kWh", "description": "Get usage history"}
]'::jsonb WHERE id = 'oop_067';

UPDATE challenges SET test_cases = '[
  {"input": "issue_license product=DesignTool, user=alice, type=annual", "expected_output": "License issued: alice DesignTool annual", "description": "Issue software license"},
  {"input": "validate_license key=LIC001", "expected_output": "License LIC001 valid, expires 2024-12-31", "description": "Validate license key"},
  {"input": "expire_license key=LIC001", "expected_output": "License LIC001 expired", "description": "Expire license"},
  {"input": "transfer_license key=LIC001, from=alice, to=bob", "expected_output": "License LIC001 transferred from alice to bob", "description": "Transfer license"}
]'::jsonb WHERE id = 'oop_068';

UPDATE challenges SET test_cases = '[
  {"input": "add_donation blood_type=O+, units=2, donor=Alice", "expected_output": "2 units O+ blood donated by Alice", "description": "Add blood donation"},
  {"input": "request blood_type=AB-, units=1, hospital=Memorial", "expected_output": "1 unit AB- blood allocated to Memorial Hospital", "description": "Request blood"},
  {"input": "get_inventory blood_type=O+", "expected_output": "O+ inventory: 15 units available", "description": "Get blood type inventory"},
  {"input": "low_inventory threshold=5", "expected_output": "Low inventory: AB- (2 units), B- (4 units)", "description": "Check low inventory"}
]'::jsonb WHERE id = 'oop_069';

UPDATE challenges SET test_cases = '[
  {"input": "issue_fine vehicle=CAR001, violation=expired_meter, amount=75", "expected_output": "Fine issued: CAR001 $75 expired meter", "description": "Issue parking fine"},
  {"input": "pay_fine fine=FINE001, vehicle=CAR001", "expected_output": "Fine FINE001 paid: $75", "description": "Pay parking fine"},
  {"input": "get_outstanding vehicle=CAR001", "expected_output": "CAR001 outstanding fines: $0", "description": "Get outstanding fines"},
  {"input": "appeal fine=FINE002, reason=signage_unclear", "expected_output": "Fine FINE002 appeal submitted: signage unclear", "description": "Appeal parking fine"}
]'::jsonb WHERE id = 'oop_070';

UPDATE challenges SET test_cases = '[
  {"input": "initiate_return order=ORD001, item=laptop, reason=defective", "expected_output": "Return initiated for laptop from ORD001", "description": "Initiate return"},
  {"input": "inspect return=RET001, condition=defective_confirmed", "expected_output": "Return RET001 inspected: defective confirmed", "description": "Inspect returned item"},
  {"input": "process_refund return=RET001, amount=999", "expected_output": "Refund $999 processed for RET001", "description": "Process refund"},
  {"input": "exchange return=RET001, new_item=laptop_v2", "expected_output": "Exchange processed: laptop -> laptop_v2", "description": "Process exchange"}
]'::jsonb WHERE id = 'oop_071';

UPDATE challenges SET test_cases = '[
  {"input": "submit paper title=AI Ethics, author=Alice, journal=Nature AI", "expected_output": "Paper submitted: AI Ethics by Alice to Nature AI", "description": "Submit paper"},
  {"input": "search keyword=machine learning", "expected_output": "Found 5 papers matching machine learning", "description": "Search papers"},
  {"input": "cite paper=PAP001 in paper=PAP002", "expected_output": "PAP001 cited in PAP002", "description": "Add citation"},
  {"input": "get_citations paper=PAP001", "expected_output": "PAP001 citations: 12", "description": "Get citation count"}
]'::jsonb WHERE id = 'oop_072';

UPDATE challenges SET test_cases = '[
  {"input": "create_incident type=fire, location=Building A, severity=high", "expected_output": "Incident created: fire at Building A (high)", "description": "Create incident"},
  {"input": "dispatch unit=FD001, incident=INC001", "expected_output": "Fire unit FD001 dispatched to INC001", "description": "Dispatch unit"},
  {"input": "update_status incident=INC001, status=contained", "expected_output": "INC001 status: contained, units on scene", "description": "Update incident status"},
  {"input": "close_incident id=INC001, outcome=resolved", "expected_output": "Incident INC001 closed: resolved", "description": "Close incident"}
]'::jsonb WHERE id = 'oop_073';

UPDATE challenges SET test_cases = '[
  {"input": "add_expense category=food, amount=50, date=2024-07-01", "expected_output": "Expense added: food $50 on 2024-07-01", "description": "Add expense"},
  {"input": "set_budget category=food, monthly=300", "expected_output": "Food budget set: $300/month", "description": "Set category budget"},
  {"input": "get_summary month=2024-07", "expected_output": "July: food $200/300, transport $100/150, total $300", "description": "Get monthly summary"},
  {"input": "alert category=food, spent=290 (near limit)", "expected_output": "Alert: food budget 97% used ($290/$300)", "description": "Budget alert"}
]'::jsonb WHERE id = 'oop_074';

UPDATE challenges SET test_cases = '[
  {"input": "search_route from=NYC, to=Chicago, date=2024-07-15", "expected_output": "Route found: Amtrak Lake Shore Limited, departs 15:40", "description": "Search train route"},
  {"input": "book seat=12A, train=LS_001, passenger=Alice", "expected_output": "Seat 12A booked on LS_001 for Alice", "description": "Book train seat"},
  {"input": "delay train=LS_001, minutes=30", "expected_output": "Train LS_001 delayed 30 minutes, passengers notified", "description": "Report train delay"},
  {"input": "get_schedule station=NYC Penn, date=2024-07-15", "expected_output": "NYC Penn 2024-07-15: 5 departures scheduled", "description": "Get station schedule"}
]'::jsonb WHERE id = 'oop_075';

UPDATE challenges SET test_cases = '[
  {"input": "create_bot name=SupportBot, intent=help", "expected_output": "SupportBot created, ready for conversations", "description": "Create chatbot"},
  {"input": "message bot=SupportBot, text=What are your hours?", "expected_output": "SupportBot: Our hours are 9am-5pm Monday-Friday", "description": "Chatbot response"},
  {"input": "get_history bot=SupportBot, user=alice", "expected_output": "Conversation history: 5 messages", "description": "Get conversation history"},
  {"input": "end_session bot=SupportBot, user=alice", "expected_output": "Session ended for alice with SupportBot", "description": "End chat session"}
]'::jsonb WHERE id = 'oop_076';

UPDATE challenges SET test_cases = '[
  {"input": "create_project name=Office Tower, deadline=2025-06-01", "expected_output": "Project Office Tower created", "description": "Create construction project"},
  {"input": "add_task project=Office Tower, name=Foundation, duration=30days", "expected_output": "Task Foundation added: 30 days", "description": "Add project task"},
  {"input": "assign_crew task=Foundation, crew=Crew_A", "expected_output": "Crew_A assigned to Foundation task", "description": "Assign crew to task"},
  {"input": "get_critical_path project=Office Tower", "expected_output": "Critical path: Foundation -> Frame -> Roof (180 days)", "description": "Get critical path"}
]'::jsonb WHERE id = 'oop_077';

UPDATE challenges SET test_cases = '[
  {"input": "create_character name=Hero, class=Warrior, level=1", "expected_output": "Warrior Hero created at level 1", "description": "Create character"},
  {"input": "gain_xp character=Hero, xp=500", "expected_output": "Hero gained 500 XP (total: 500/1000)", "description": "Gain experience points"},
  {"input": "level_up character=Hero (1000 XP reached)", "expected_output": "Hero leveled up to level 2! Stats increased", "description": "Level up character"},
  {"input": "get_stats character=Hero", "expected_output": "Hero: Level 2, HP 120, ATK 25, DEF 20", "description": "Get character stats"}
]'::jsonb WHERE id = 'oop_078';

UPDATE challenges SET test_cases = '[
  {"input": "submit application name=Alice, gpa=3.9, essay=submitted", "expected_output": "Scholarship application submitted for Alice", "description": "Submit application"},
  {"input": "review application=APP001, score=90", "expected_output": "Application APP001 reviewed, score: 90/100", "description": "Review application"},
  {"input": "award scholarship=MERIT001, recipient=Alice, amount=5000", "expected_output": "Merit scholarship $5,000 awarded to Alice", "description": "Award scholarship"},
  {"input": "reject application=APP002, reason=gpa_below_minimum", "expected_output": "Application APP002 rejected: GPA below minimum", "description": "Reject application"}
]'::jsonb WHERE id = 'oop_079';

UPDATE challenges SET test_cases = '[
  {"input": "assess property=PROP001, address=123 Main, value=300000", "expected_output": "Property PROP001 assessed at $300,000", "description": "Assess property"},
  {"input": "calculate_tax property=PROP001, rate=1.2%", "expected_output": "Property tax: $3,600/year (1.2% of $300,000)", "description": "Calculate property tax"},
  {"input": "appeal assessment=PROP001, claimed_value=270000", "expected_output": "Assessment appeal filed: claimed $270,000 vs assessed $300,000", "description": "Appeal assessment"},
  {"input": "update_assessment property=PROP001, new_value=280000", "expected_output": "Assessment updated to $280,000, tax revised to $3,360", "description": "Update assessment"}
]'::jsonb WHERE id = 'oop_080';

UPDATE challenges SET test_cases = '[
  {"input": "calculate_surge area=downtown, demand=high, supply=low", "expected_output": "Surge multiplier: 2.5x in downtown", "description": "Calculate surge pricing"},
  {"input": "fare base=12.00, surge=2.5x", "expected_output": "Surge fare: $30.00 (base $12 x 2.5)", "description": "Apply surge to fare"},
  {"input": "calculate_surge area=suburbs, demand=normal", "expected_output": "No surge: suburbs demand normal", "description": "No surge in low demand"},
  {"input": "cap_surge max=3x, calculated=4x", "expected_output": "Surge capped at 3x (calculated 4x)", "description": "Cap surge multiplier"}
]'::jsonb WHERE id = 'oop_081';

UPDATE challenges SET test_cases = '[
  {"input": "enroll patient=P001, trial=TRIAL_001, criteria_met=true", "expected_output": "Patient P001 enrolled in TRIAL_001", "description": "Enroll patient in trial"},
  {"input": "enroll patient=P002, trial=TRIAL_001, criteria_met=false", "expected_output": "Enrollment rejected: P002 does not meet criteria", "description": "Reject ineligible patient"},
  {"input": "record_visit patient=P001, trial=TRIAL_001, visit=V1, outcome=positive", "expected_output": "Visit V1 recorded for P001 in TRIAL_001", "description": "Record trial visit"},
  {"input": "get_trial_summary trial=TRIAL_001", "expected_output": "TRIAL_001: 50 enrolled, 45 active, 5 dropped", "description": "Get trial summary"}
]'::jsonb WHERE id = 'oop_082';

UPDATE challenges SET test_cases = '[
  {"input": "load_cargo container=C001, items=[{weight: 2t, x: 0}, {weight: 3t, x: 5}]", "expected_output": "Cargo loaded: 5t total, center of gravity calculated", "description": "Load cargo"},
  {"input": "check_balance container=C001", "expected_output": "Balance check: weight distribution within 5% tolerance", "description": "Check cargo balance"},
  {"input": "redistribute container=C001, item=ITM002, new_x=2", "expected_output": "Item ITM002 moved to x=2, balance improved", "description": "Redistribute cargo"},
  {"input": "get_weight_distribution container=C001", "expected_output": "C001 distribution: forward 40%, rear 60%", "description": "Get weight distribution"}
]'::jsonb WHERE id = 'oop_083';

UPDATE challenges SET test_cases = '[
  {"input": "create_draft league=Fantasy_NFL, user=alice", "expected_output": "Draft started for alice in Fantasy_NFL", "description": "Start draft"},
  {"input": "pick player=Patrick Mahomes, team=alice_team, round=1", "expected_output": "Round 1: alice picks Patrick Mahomes", "description": "Draft player"},
  {"input": "pick player=Patrick Mahomes, team=bob_team (already picked)", "expected_output": "Error: Patrick Mahomes already drafted", "description": "Duplicate pick rejected"},
  {"input": "get_roster team=alice_team", "expected_output": "alice_team roster: [Patrick Mahomes, ...]", "description": "Get team roster"}
]'::jsonb WHERE id = 'oop_084';

UPDATE challenges SET test_cases = '[
  {"input": "add_exhibit name=Ancient Egypt, items=120, location=Hall A", "expected_output": "Exhibit Ancient Egypt added in Hall A with 120 items", "description": "Add exhibit"},
  {"input": "search keyword=mummy", "expected_output": "Found 5 artifacts matching mummy in Ancient Egypt exhibit", "description": "Search exhibits"},
  {"input": "get_exhibit_details name=Ancient Egypt", "expected_output": "Ancient Egypt: Hall A, 120 items, on display", "description": "Get exhibit details"},
  {"input": "loan artifact=artifact_001 to=British Museum", "expected_output": "artifact_001 loaned to British Museum", "description": "Loan artifact"}
]'::jsonb WHERE id = 'oop_085';

UPDATE challenges SET test_cases = '[
  {"input": "report outage area=Zone_A, reporter=tech_001", "expected_output": "Outage reported in Zone_A by tech_001", "description": "Report outage"},
  {"input": "assign_crew outage=OUT001, crew=Crew_B", "expected_output": "Crew_B assigned to restore Zone_A", "description": "Assign repair crew"},
  {"input": "update_status outage=OUT001, status=restoring", "expected_output": "Outage OUT001: crew on site, restoring power", "description": "Update restoration status"},
  {"input": "resolve outage=OUT001", "expected_output": "Outage OUT001 resolved, Zone_A power restored", "description": "Resolve outage"}
]'::jsonb WHERE id = 'oop_086';

UPDATE challenges SET test_cases = '[
  {"input": "add_meal_plan user=alice, plan=vegetarian, days=5", "expected_output": "alice enrolled in 5-day vegetarian plan", "description": "Add meal plan"},
  {"input": "get_menu date=Monday, plan=vegetarian", "expected_output": "Monday vegetarian: Salad, Pasta, Fruit", "description": "Get daily menu"},
  {"input": "mark_consumed user=alice, meal=Monday_lunch", "expected_output": "alice consumed Monday lunch", "description": "Mark meal consumed"},
  {"input": "get_balance user=alice", "expected_output": "alice meal balance: 3 meals remaining", "description": "Get meal balance"}
]'::jsonb WHERE id = 'oop_087';

UPDATE challenges SET test_cases = '[
  {"input": "add_vehicle vehicle=V001, make=Toyota, year=2020", "expected_output": "Vehicle V001 (Toyota 2020) added to log", "description": "Add vehicle"},
  {"input": "log_service vehicle=V001, type=oil_change, date=2024-01-15, mileage=25000", "expected_output": "Service logged: V001 oil change at 25000 miles", "description": "Log service"},
  {"input": "get_service_history vehicle=V001", "expected_output": "V001 history: oil change (25000mi), tire rotation (20000mi)", "description": "Get service history"},
  {"input": "due_for_service vehicle=V001, current_mileage=30000", "expected_output": "V001 due for: oil change (every 5000mi)", "description": "Check service due"}
]'::jsonb WHERE id = 'oop_088';

UPDATE challenges SET test_cases = '[
  {"input": "register alumni name=Alice, graduation=2015, company=Google", "expected_output": "Alumni Alice (class 2015, Google) registered", "description": "Register alumni"},
  {"input": "connect alumni1=Alice, alumni2=Bob", "expected_output": "Connection established: Alice and Bob", "description": "Connect alumni"},
  {"input": "search company=Google", "expected_output": "Alumni at Google: Alice, Charlie", "description": "Search alumni by company"},
  {"input": "post_job company=Google, title=SWE", "expected_output": "Job posted by Google: SWE (visible to alumni)", "description": "Post job opportunity"}
]'::jsonb WHERE id = 'oop_089';

UPDATE challenges SET test_cases = '[
  {"input": "search site=Lake_View, dates=2024-08-10 to 2024-08-14, type=tent", "expected_output": "2 tent sites available at Lake_View", "description": "Search campsites"},
  {"input": "book site=LV_05, user=alice, dates=2024-08-10 to 2024-08-14", "expected_output": "Site LV_05 booked for alice, 4 nights", "description": "Book campsite"},
  {"input": "cancel booking=CAMP001", "expected_output": "Booking CAMP001 cancelled, site freed", "description": "Cancel reservation"},
  {"input": "check_in booking=CAMP001", "expected_output": "alice checked in to site LV_05", "description": "Check in to campsite"}
]'::jsonb WHERE id = 'oop_090';

UPDATE challenges SET test_cases = '[
  {"input": "add_franchise name=Pizza_Palace, revenue=500000", "expected_output": "Franchise Pizza_Palace added, revenue $500,000", "description": "Add franchise"},
  {"input": "calculate_royalty franchise=Pizza_Palace, rate=6%", "expected_output": "Pizza_Palace royalty: $30,000 (6% of $500,000)", "description": "Calculate royalty"},
  {"input": "process_payment franchise=Pizza_Palace, amount=30000", "expected_output": "Royalty payment of $30,000 received from Pizza_Palace", "description": "Process royalty payment"},
  {"input": "get_total_royalties month=2024-07", "expected_output": "July total royalties: $85,000 from 3 franchises", "description": "Get monthly royalties"}
]'::jsonb WHERE id = 'oop_091';

UPDATE challenges SET test_cases = '[
  {"input": "issue_loan borrower=Alice, amount=1000, term=12months, rate=15%", "expected_output": "Loan issued to Alice: $1,000 at 15% for 12 months", "description": "Issue microfinance loan"},
  {"input": "record_payment loan=LOAN001, amount=95", "expected_output": "Payment recorded: LOAN001 $95 (on time)", "description": "Record loan payment"},
  {"input": "get_portfolio_summary", "expected_output": "Portfolio: 50 active loans, $45,000 outstanding, 2% default rate", "description": "Get portfolio summary"},
  {"input": "default loan=LOAN002", "expected_output": "Loan LOAN002 marked as default, recovery initiated", "description": "Mark loan as default"}
]'::jsonb WHERE id = 'oop_092';

UPDATE challenges SET test_cases = '[
  {"input": "add_zone id=Z001, area=Downtown, waste_type=recycling", "expected_output": "Zone Z001 Downtown (recycling) added", "description": "Add collection zone"},
  {"input": "plan_route zones=[Z001, Z002, Z003], start=depot", "expected_output": "Route planned: depot -> Z001 -> Z002 -> Z003 -> depot (45km)", "description": "Plan collection route"},
  {"input": "optimize_route zones=[Z001, Z002, Z003]", "expected_output": "Optimized route: depot -> Z002 -> Z001 -> Z003 (38km)", "description": "Optimize route"},
  {"input": "log_collection zone=Z001, weight=2.5t", "expected_output": "Collection logged: Z001 2.5 tonnes recycling", "description": "Log waste collection"}
]'::jsonb WHERE id = 'oop_093';

UPDATE challenges SET test_cases = '[
  {"input": "create_bracket game=Valorant, teams=16", "expected_output": "16-team single elimination bracket created", "description": "Create esports bracket"},
  {"input": "record_match match=M001, winner=TeamAlpha, score=2-0", "expected_output": "Match M001: TeamAlpha wins 2-0, advances", "description": "Record match result"},
  {"input": "get_bracket round=quarter_finals", "expected_output": "Quarter-finals: 8 teams remaining", "description": "Get bracket state"},
  {"input": "get_champion tournament=Valorant_Open", "expected_output": "Champion: TeamAlpha", "description": "Get esports champion"}
]'::jsonb WHERE id = 'oop_094';

UPDATE challenges SET test_cases = '[
  {"input": "book appointment doctor=Dr. Chen, patient=alice, type=video, date=2024-07-15 10:00", "expected_output": "Telehealth appointment booked: alice with Dr. Chen at 10:00", "description": "Book telehealth appointment"},
  {"input": "start_session appointment=APT001", "expected_output": "Video session started: alice and Dr. Chen connected", "description": "Start telehealth session"},
  {"input": "prescribe patient=alice, drug=Amoxicillin, dose=500mg", "expected_output": "Prescription sent: alice Amoxicillin 500mg", "description": "Send electronic prescription"},
  {"input": "end_session appointment=APT001", "expected_output": "Session ended, consultation notes saved", "description": "End telehealth session"}
]'::jsonb WHERE id = 'oop_095';

UPDATE challenges SET test_cases = '[
  {"input": "add_product sku=COLA001, name=Cola, price=1.50, qty=50", "expected_output": "Cola added: $1.50, 50 units", "description": "Add product"},
  {"input": "dispense product=Cola, payment=1.50", "expected_output": "Cola dispensed, change: $0.00", "description": "Dispense product"},
  {"input": "dispense product=Cola, payment=2.00", "expected_output": "Cola dispensed, change: $0.50", "description": "Dispense with change"},
  {"input": "restock product=Cola, qty=100", "expected_output": "Cola restocked: 149 units (50 - 1 + 100)", "description": "Restock product"}
]'::jsonb WHERE id = 'oop_096';

UPDATE challenges SET test_cases = '[
  {"input": "add_satellite id=SAT001, orbit=LEO, period=90min", "expected_output": "SAT001 added: LEO orbit, 90 min period", "description": "Add satellite"},
  {"input": "schedule_pass station=GS001, satellite=SAT001, date=2024-07-15", "expected_output": "Pass scheduled: SAT001 over GS001 at 14:23 UTC", "description": "Schedule satellite pass"},
  {"input": "get_next_pass station=GS001, satellite=SAT001", "expected_output": "Next pass: SAT001 at 14:23 UTC, duration 8 min", "description": "Get next pass"},
  {"input": "conflict_check station=GS001, time=14:23", "expected_output": "No conflict: GS001 free at 14:23 UTC", "description": "Check for pass conflicts"}
]'::jsonb WHERE id = 'oop_097';

UPDATE challenges SET test_cases = '[
  {"input": "create_invoice shipment=SHP001, items=[cargo_a: 500kg, cargo_b: 300kg]", "expected_output": "Invoice created for SHP001: 800kg freight", "description": "Create freight invoice"},
  {"input": "calculate_charges weight=800kg, distance=1200km, type=air", "expected_output": "Freight charges: $2,400 (800kg air freight 1200km)", "description": "Calculate freight charges"},
  {"input": "add_surcharge type=fuel, amount=150", "expected_output": "Fuel surcharge $150 added to invoice", "description": "Add surcharge"},
  {"input": "finalize_invoice invoice=INV001", "expected_output": "Invoice INV001 finalized: $2,550 total", "description": "Finalize invoice"}
]'::jsonb WHERE id = 'oop_098';

UPDATE challenges SET test_cases = '[
  {"input": "add_article title=Tech News Today, date=2024-07-15, section=tech", "expected_output": "Article archived: Tech News Today (2024-07-15)", "description": "Archive article"},
  {"input": "search keyword=AI, date_range=2024-01 to 2024-06", "expected_output": "Found 25 articles about AI from Jan-Jun 2024", "description": "Search archive"},
  {"input": "get_edition date=2024-07-15", "expected_output": "Edition 2024-07-15: 8 articles, 3 sections", "description": "Get newspaper edition"},
  {"input": "get_article title=Tech News Today", "expected_output": "Article: Tech News Today, July 15 2024, tech section", "description": "Get specific article"}
]'::jsonb WHERE id = 'oop_099';

UPDATE challenges SET test_cases = '[
  {"input": "add_patient name=Alice, dob=1985-03-20, dentist=Dr. Lee", "expected_output": "Patient Alice added to Dr. Lee practice", "description": "Add patient"},
  {"input": "schedule_appointment patient=Alice, type=cleaning, date=2024-07-20 09:00", "expected_output": "Cleaning scheduled for Alice on 2024-07-20", "description": "Schedule dental appointment"},
  {"input": "record_treatment patient=Alice, treatment=cavity_fill, tooth=14", "expected_output": "Treatment recorded: Alice tooth 14 cavity fill", "description": "Record treatment"},
  {"input": "get_dental_history patient=Alice", "expected_output": "Alice dental history: cleaning (2024-01), cavity fill (2024-07)", "description": "Get dental history"}
]'::jsonb WHERE id = 'oop_100';


UPDATE challenges SET test_cases = '[
  {"input": "acquire_lock resource=db_table, client=node_1, ttl=30s", "expected_output": "Lock acquired: db_table by node_1 (TTL 30s)", "description": "Acquire distributed lock"},
  {"input": "acquire_lock resource=db_table, client=node_2 (locked)", "expected_output": "Lock unavailable: db_table held by node_1", "description": "Lock contention blocked"},
  {"input": "release_lock resource=db_table, client=node_1", "expected_output": "Lock released: db_table by node_1", "description": "Release lock"},
  {"input": "lock ttl_expired resource=db_table", "expected_output": "Lock expired for db_table, now available", "description": "Lock TTL expiry"}
]'::jsonb WHERE id = 'sys_005';

UPDATE challenges SET test_cases = '[
  {"input": "publish queue=orders, message={order_id: 1}", "expected_output": "Message published to orders queue", "description": "Publish message to queue"},
  {"input": "consume queue=orders, consumer=worker_1", "expected_output": "worker_1 consumed message: {order_id: 1}", "description": "Consume message"},
  {"input": "queue_depth queue=orders", "expected_output": "orders queue depth: 0 messages", "description": "Check queue depth after consume"},
  {"input": "publish 100 messages, consume 50", "expected_output": "Queue depth: 50 messages remaining", "description": "Partial consumption"}
]'::jsonb WHERE id = 'sys_006';

UPDATE challenges SET test_cases = '[
  {"input": "call service=payment, failures=0", "expected_output": "Circuit CLOSED: payment call succeeded", "description": "Successful call, circuit closed"},
  {"input": "call service=payment, failures=5 (threshold)", "expected_output": "Circuit OPEN: too many failures, blocking calls", "description": "Circuit opens after failures"},
  {"input": "call service=payment, state=OPEN", "expected_output": "Circuit OPEN: call blocked, fallback returned", "description": "Call blocked when open"},
  {"input": "half_open probe after timeout", "expected_output": "Circuit HALF-OPEN: test call allowed", "description": "Half-open state allows probe"}
]'::jsonb WHERE id = 'sys_007';

UPDATE challenges SET test_cases = '[
  {"input": "add_node id=node_1, hash_ring", "expected_output": "node_1 added to hash ring", "description": "Add node to ring"},
  {"input": "route key=user_123", "expected_output": "user_123 routed to node_2 (closest successor)", "description": "Route key to node"},
  {"input": "remove_node id=node_2", "expected_output": "node_2 removed, keys reassigned to node_3", "description": "Remove node reassigns keys"},
  {"input": "add_virtual_nodes node=node_1, replicas=3", "expected_output": "node_1 added with 3 virtual nodes for load balance", "description": "Add virtual nodes"}
]'::jsonb WHERE id = 'sys_008';

UPDATE challenges SET test_cases = '[
  {"input": "write transaction=TXN001, data={op: insert, table: users}", "expected_output": "WAL entry written for TXN001 before commit", "description": "Write WAL entry before commit"},
  {"input": "commit transaction=TXN001", "expected_output": "TXN001 committed, WAL entry persisted", "description": "Commit transaction"},
  {"input": "crash_recovery wal_entries=[TXN001, TXN002]", "expected_output": "Recovery: replayed TXN001, TXN002 from WAL", "description": "WAL crash recovery"},
  {"input": "checkpoint wal", "expected_output": "WAL checkpointed, old entries truncated", "description": "WAL checkpoint"}
]'::jsonb WHERE id = 'sys_009';

UPDATE challenges SET test_cases = '[
  {"input": "write primary={table: users, row: 1, value: Alice}", "expected_output": "Write applied to primary, replication log updated", "description": "Write to primary"},
  {"input": "replicate to=replica_1, lag=100ms", "expected_output": "Replica_1 synced with 100ms lag", "description": "Replicate to read replica"},
  {"input": "read from=replica_1", "expected_output": "Read served from replica_1", "description": "Read from replica"},
  {"input": "replica_lag replica=replica_1", "expected_output": "replica_1 lag: 100ms (within threshold)", "description": "Check replication lag"}
]'::jsonb WHERE id = 'sys_010';

UPDATE challenges SET test_cases = '[
  {"input": "request client=C1, endpoint=/api/data, window=60s, limit=100", "expected_output": "Request allowed: 1/100 in current window", "description": "Allow request under limit"},
  {"input": "requests client=C1, count=100, window=60s", "expected_output": "Request 100/100 allowed, limit reached", "description": "Hit rate limit"},
  {"input": "request client=C1, count=101, window=60s", "expected_output": "Rate limit exceeded: 429 Too Many Requests", "description": "Reject over-limit request"},
  {"input": "window_reset client=C1", "expected_output": "Rate limit window reset for C1", "description": "Window reset allows new requests"}
]'::jsonb WHERE id = 'sys_011';

UPDATE challenges SET test_cases = '[
  {"input": "register service=auth-service, host=10.0.0.1, port=8080", "expected_output": "auth-service registered at 10.0.0.1:8080", "description": "Register service"},
  {"input": "discover service=auth-service", "expected_output": "auth-service: [10.0.0.1:8080] (1 instance)", "description": "Discover service instances"},
  {"input": "deregister service=auth-service, host=10.0.0.1", "expected_output": "auth-service instance 10.0.0.1:8080 removed", "description": "Deregister service"},
  {"input": "health_check service=auth-service, status=unhealthy", "expected_output": "auth-service instance removed from registry (unhealthy)", "description": "Unhealthy instance removed"}
]'::jsonb WHERE id = 'sys_012';

UPDATE challenges SET test_cases = '[
  {"input": "append event={type: OrderPlaced, order_id: 1, user: alice}", "expected_output": "Event appended: OrderPlaced for order_id 1", "description": "Append event to store"},
  {"input": "replay events aggregate=order_1", "expected_output": "Order_1 state reconstructed from 3 events", "description": "Replay events to rebuild state"},
  {"input": "get_events aggregate=order_1, from=0", "expected_output": "Events: [OrderPlaced, PaymentProcessed, OrderShipped]", "description": "Get events for aggregate"},
  {"input": "snapshot aggregate=order_1 at version=3", "expected_output": "Snapshot saved for order_1 at version 3", "description": "Create aggregate snapshot"}
]'::jsonb WHERE id = 'sys_013';

UPDATE challenges SET test_cases = '[
  {"input": "command=CreateOrder, payload={user: alice, items: [book]}", "expected_output": "CreateOrder command dispatched to OrderService", "description": "Dispatch write command"},
  {"input": "query=GetOrder, id=ORD001", "expected_output": "GetOrder query served from read model", "description": "Serve read query from read model"},
  {"input": "command=CancelOrder, id=ORD001", "expected_output": "CancelOrder command dispatched, read model updated", "description": "Command updates read model"},
  {"input": "reject command=CreateOrder, reason=validation_error", "expected_output": "Command rejected: validation error in CreateOrder", "description": "Reject invalid command"}
]'::jsonb WHERE id = 'sys_014';

UPDATE challenges SET test_cases = '[
  {"input": "shard data=users, key=user_id, shards=4", "expected_output": "users sharded into 4 partitions by user_id", "description": "Shard data by key"},
  {"input": "route key=user_123, shard_count=4", "expected_output": "user_123 routed to shard_2 (hash % 4)", "description": "Route key to shard"},
  {"input": "rebalance shards add_shard=shard_5", "expected_output": "Rebalancing: moving 20% of data to shard_5", "description": "Rebalance on new shard"},
  {"input": "get_shard_stats", "expected_output": "Shard distribution: shard_0: 25%, shard_1: 25%, ...", "description": "Get shard statistics"}
]'::jsonb WHERE id = 'sys_015';

UPDATE challenges SET test_cases = '[
  {"input": "add element=user@example.com to filter", "expected_output": "user@example.com added to bloom filter", "description": "Add element to bloom filter"},
  {"input": "check element=user@example.com", "expected_output": "Probably in set: true", "description": "Check existing element"},
  {"input": "check element=nonexistent@test.com", "expected_output": "Definitely not in set: false", "description": "Check non-existing element"},
  {"input": "false_positive_rate elements=1000, bits=10000", "expected_output": "Expected false positive rate: 1.2%", "description": "Calculate false positive rate"}
]'::jsonb WHERE id = 'sys_016';

UPDATE challenges SET test_cases = '[
  {"input": "start_saga order={user: alice, items: [book], total: 25}", "expected_output": "Saga started: OrderSaga for alice", "description": "Start saga"},
  {"input": "step=reserve_inventory, result=success", "expected_output": "Inventory reserved, proceeding to payment", "description": "Saga step succeeds"},
  {"input": "step=process_payment, result=failure", "expected_output": "Payment failed, compensating: release_inventory", "description": "Saga compensates on failure"},
  {"input": "saga completed all steps", "expected_output": "Saga completed: order placed successfully", "description": "Successful saga completion"}
]'::jsonb WHERE id = 'sys_017';

UPDATE challenges SET test_cases = '[
  {"input": "increment counter=page_views, node=node_1", "expected_output": "page_views incremented on node_1", "description": "Increment counter"},
  {"input": "increment counter=page_views, node=node_2", "expected_output": "page_views incremented on node_2", "description": "Concurrent increment"},
  {"input": "get_count counter=page_views", "expected_output": "page_views total: 2 (merged from all nodes)", "description": "Get merged count"},
  {"input": "sync_nodes counter=page_views", "expected_output": "All nodes synced, page_views consistent", "description": "Sync counter across nodes"}
]'::jsonb WHERE id = 'sys_018';

UPDATE challenges SET test_cases = '[
  {"input": "register service=payment-service, interval=30s", "expected_output": "payment-service registered for heartbeat monitoring", "description": "Register service for monitoring"},
  {"input": "heartbeat service=payment-service, status=healthy", "expected_output": "Heartbeat received from payment-service: healthy", "description": "Receive heartbeat"},
  {"input": "missed_heartbeats service=payment-service, count=3", "expected_output": "Alert: payment-service missed 3 heartbeats, marking unhealthy", "description": "Service failure detected"},
  {"input": "get_health_status", "expected_output": "Services: payment-service UNHEALTHY, auth-service HEALTHY", "description": "Get overall health status"}
]'::jsonb WHERE id = 'sys_019';

UPDATE challenges SET test_cases = '[
  {"input": "start_election nodes=[n1, n2, n3]", "expected_output": "Election started among 3 nodes", "description": "Start leader election"},
  {"input": "vote candidate=n1, voter=n2", "expected_output": "n2 voted for n1", "description": "Cast vote"},
  {"input": "quorum_reached candidate=n1, votes=2 of 3", "expected_output": "n1 elected leader (quorum 2/3)", "description": "Leader elected with quorum"},
  {"input": "leader=n1 fails, new_election", "expected_output": "n1 failed, new election started, n2 elected", "description": "Re-election after leader failure"}
]'::jsonb WHERE id = 'sys_020';

UPDATE challenges SET test_cases = '[
  {"input": "store points=[{t: 1000, v: 22.5}, {t: 1001, v: 22.7}]", "expected_output": "2 time series points stored", "description": "Store time series points"},
  {"input": "compress series=temperature, range=1h", "expected_output": "1h compressed: 3600 points -> 60 points (delta encoding)", "description": "Compress time series"},
  {"input": "query series=temperature, from=t1000, to=t1100", "expected_output": "100 data points returned for temperature", "description": "Query time range"},
  {"input": "downsample series=temperature, interval=1min", "expected_output": "Downsampled to 1-min averages", "description": "Downsample series"}
]'::jsonb WHERE id = 'sys_021';

UPDATE challenges SET test_cases = '[
  {"input": "message=MSG001 fails processing, queue=orders_dlq", "expected_output": "MSG001 sent to dead letter queue after max retries", "description": "Send to DLQ after retries"},
  {"input": "inspect dlq=orders_dlq", "expected_output": "DLQ orders_dlq: 1 message (MSG001)", "description": "Inspect dead letter queue"},
  {"input": "replay message=MSG001 from dlq", "expected_output": "MSG001 replayed from DLQ to orders queue", "description": "Replay message from DLQ"},
  {"input": "discard message=MSG001 from dlq", "expected_output": "MSG001 discarded from DLQ", "description": "Discard DLQ message"}
]'::jsonb WHERE id = 'sys_022';

UPDATE challenges SET test_cases = '[
  {"input": "connect client=ws_client_1", "expected_output": "ws_client_1 connected to WebSocket hub", "description": "Client connects"},
  {"input": "broadcast message=Hello all, hub", "expected_output": "Message broadcast to all 5 connected clients", "description": "Broadcast to all clients"},
  {"input": "send_to client=ws_client_1, message=Private message", "expected_output": "Private message sent to ws_client_1", "description": "Send to specific client"},
  {"input": "disconnect client=ws_client_1", "expected_output": "ws_client_1 disconnected, hub updated", "description": "Client disconnects"}
]'::jsonb WHERE id = 'sys_023';

UPDATE challenges SET test_cases = '[
  {"input": "fetch url=https://cdn.example.com/image.png, edge=us-east", "expected_output": "Cache miss at us-east, fetched from origin", "description": "Cache miss fetches from origin"},
  {"input": "fetch url=https://cdn.example.com/image.png, edge=us-east (cached)", "expected_output": "Cache hit at us-east, served from edge", "description": "Cache hit at edge"},
  {"input": "purge url=https://cdn.example.com/image.png", "expected_output": "Cache purged for image.png at all edges", "description": "Purge CDN cache"},
  {"input": "ttl_expired url=https://cdn.example.com/image.png", "expected_output": "Cache expired, next request refreshes from origin", "description": "TTL expiry refreshes cache"}
]'::jsonb WHERE id = 'sys_024';

UPDATE challenges SET test_cases = '[
  {"input": "index document={id: 1, content: quick brown fox}", "expected_output": "Document 1 indexed: quick, brown, fox", "description": "Index document"},
  {"input": "search query=brown fox", "expected_output": "Results: [doc 1] (matched: brown, fox)", "description": "Search indexed documents"},
  {"input": "search query=lazy dog", "expected_output": "No results found for: lazy dog", "description": "Search returns no results"},
  {"input": "index 1000 documents, search query=common_term", "expected_output": "Inverted index search: 50 matches in 2ms", "description": "Large index search performance"}
]'::jsonb WHERE id = 'sys_025';

UPDATE challenges SET test_cases = '[
  {"input": "request id=REQ001, operation=create_user, idempotency_key=IK001", "expected_output": "IK001 processed, user created", "description": "Process first request"},
  {"input": "request id=REQ002, operation=create_user, idempotency_key=IK001 (duplicate)", "expected_output": "IK001 already processed, returning cached result", "description": "Duplicate request returns cached result"},
  {"input": "idempotency_key=IK001, ttl_expired", "expected_output": "IK001 expired from deduplication cache", "description": "Idempotency key expiry"},
  {"input": "request idempotency_key=IK002 (new)", "expected_output": "IK002 processed, new operation executed", "description": "New idempotency key"}
]'::jsonb WHERE id = 'sys_026';

UPDATE challenges SET test_cases = '[
  {"input": "producer_rate=1000rps, consumer_rate=500rps", "expected_output": "Backpressure activated: producer throttled to 500rps", "description": "Backpressure throttles producer"},
  {"input": "buffer_full buffer_size=1000, current=1000", "expected_output": "Buffer full, dropping messages or blocking producer", "description": "Full buffer triggers backpressure"},
  {"input": "consumer_rate increases to 900rps", "expected_output": "Backpressure easing, producer allowed to 900rps", "description": "Backpressure reduces as consumer catches up"},
  {"input": "buffer_level=50%", "expected_output": "Buffer at 50%, normal flow", "description": "Normal flow below threshold"}
]'::jsonb WHERE id = 'sys_027';

UPDATE challenges SET test_cases = '[
  {"input": "create_tenant id=tenant_A", "expected_output": "Tenant tenant_A provisioned with isolated schema", "description": "Create new tenant"},
  {"input": "write tenant=tenant_A, data={user: alice}", "expected_output": "Data written to tenant_A schema only", "description": "Write isolated to tenant"},
  {"input": "read tenant=tenant_B, query=users", "expected_output": "tenant_B data returned, no tenant_A data visible", "description": "Read isolation between tenants"},
  {"input": "cross_tenant_query tenant_A query users from tenant_B", "expected_output": "Access denied: cross-tenant data access blocked", "description": "Cross-tenant access denied"}
]'::jsonb WHERE id = 'sys_028';

UPDATE challenges SET test_cases = '[
  {"input": "node=n1 knows peers=[n2, n3]", "expected_output": "n1 gossip state: knows n2, n3", "description": "Node knows peers"},
  {"input": "gossip_round n1 -> n2, share state", "expected_output": "n2 updated with n1 state (membership list)", "description": "Gossip round propagates state"},
  {"input": "new_node=n4 joins, gossip to n1", "expected_output": "n4 propagated to all nodes within 3 rounds", "description": "New node propagated via gossip"},
  {"input": "node=n3 fails, gossip propagates failure", "expected_output": "n3 failure detected and propagated to all nodes", "description": "Node failure detected via gossip"}
]'::jsonb WHERE id = 'sys_029';

UPDATE challenges SET test_cases = '[
  {"input": "submit batch=[record_1...record_1000], processor=etl", "expected_output": "Batch submitted: 1000 records to etl pipeline", "description": "Submit batch job"},
  {"input": "process batch_id=BATCH001, chunk_size=100", "expected_output": "Batch processing: 10 chunks of 100 records", "description": "Process in chunks"},
  {"input": "batch_progress batch=BATCH001", "expected_output": "BATCH001: 500/1000 processed (50%)", "description": "Check batch progress"},
  {"input": "batch_complete batch=BATCH001", "expected_output": "BATCH001 completed: 1000 records processed", "description": "Batch completion"}
]'::jsonb WHERE id = 'sys_030';

UPDATE challenges SET test_cases = '[
  {"input": "start_trace request=REQ001, service=api-gateway", "expected_output": "Trace started: REQ001 at api-gateway", "description": "Start distributed trace"},
  {"input": "add_span trace=REQ001, service=auth, duration=10ms", "expected_output": "Span added: auth (10ms) to trace REQ001", "description": "Add span to trace"},
  {"input": "add_span trace=REQ001, service=db, duration=5ms", "expected_output": "Span added: db (5ms) to trace REQ001", "description": "Add DB span"},
  {"input": "get_trace id=REQ001", "expected_output": "Trace REQ001: api-gateway(2ms) -> auth(10ms) -> db(5ms) total 17ms", "description": "Get full trace"}
]'::jsonb WHERE id = 'sys_031';

UPDATE challenges SET test_cases = '[
  {"input": "phase1 prepare transaction=TXN001, participants=[db_A, db_B]", "expected_output": "Phase 1: db_A and db_B both voted YES", "description": "Phase 1 - all participants ready"},
  {"input": "phase2 commit transaction=TXN001", "expected_output": "Phase 2: TXN001 committed on db_A and db_B", "description": "Phase 2 - commit all participants"},
  {"input": "phase1 prepare TXN002, participant=db_C votes NO", "expected_output": "Phase 1: db_C voted NO, transaction aborted", "description": "Phase 1 - one participant aborts"},
  {"input": "coordinator crash during phase2", "expected_output": "Participants blocked waiting for coordinator recovery", "description": "Coordinator failure blocks participants"}
]'::jsonb WHERE id = 'sys_032';

UPDATE challenges SET test_cases = '[
  {"input": "create_bucket name=my-bucket, region=us-east-1", "expected_output": "Bucket my-bucket created in us-east-1", "description": "Create storage bucket"},
  {"input": "upload bucket=my-bucket, object=file.txt, size=1MB", "expected_output": "file.txt uploaded to my-bucket (1MB)", "description": "Upload object to bucket"},
  {"input": "download bucket=my-bucket, object=file.txt", "expected_output": "file.txt downloaded from my-bucket", "description": "Download object from bucket"},
  {"input": "delete bucket=my-bucket, object=file.txt", "expected_output": "file.txt deleted from my-bucket", "description": "Delete object from bucket"}
]'::jsonb WHERE id = 'sys_033';

UPDATE challenges SET test_cases = '[
  {"input": "create_topic name=order_events", "expected_output": "Topic order_events created", "description": "Create pub-sub topic"},
  {"input": "subscribe topic=order_events, subscriber=email_service", "expected_output": "email_service subscribed to order_events", "description": "Subscribe to topic"},
  {"input": "publish topic=order_events, message={order: 1, status: placed}", "expected_output": "Message published, email_service notified", "description": "Publish message to topic"},
  {"input": "unsubscribe topic=order_events, subscriber=email_service", "expected_output": "email_service unsubscribed from order_events", "description": "Unsubscribe from topic"}
]'::jsonb WHERE id = 'sys_034';

UPDATE challenges SET test_cases = '[
  {"input": "get config=feature_flags, service=api-service", "expected_output": "Config returned: feature_flags for api-service", "description": "Get configuration"},
  {"input": "update config=feature_flags, dark_mode=true", "expected_output": "Config updated: dark_mode=true", "description": "Update configuration"},
  {"input": "hot_reload service=api-service", "expected_output": "api-service config reloaded without restart", "description": "Hot reload config without restart"},
  {"input": "rollback config=feature_flags to version=2", "expected_output": "Config rolled back to version 2", "description": "Rollback configuration"}
]'::jsonb WHERE id = 'sys_035';

UPDATE challenges SET test_cases = '[
  {"input": "request client=C1, tokens=1, bucket_size=10, rate=5/s", "expected_output": "Request allowed: 1 token consumed (9 remaining)", "description": "Request consumes token"},
  {"input": "requests client=C1, burst=10 in 1s", "expected_output": "10 requests allowed (bucket emptied)", "description": "Burst allowed up to bucket size"},
  {"input": "request client=C1, bucket_empty", "expected_output": "Rate limited: no tokens available, retry in 200ms", "description": "Rate limited when bucket empty"},
  {"input": "token_refill rate=5/s, after 1s", "expected_output": "5 tokens refilled, bucket: 5/10", "description": "Token bucket refills over time"}
]'::jsonb WHERE id = 'sys_036';

UPDATE challenges SET test_cases = '[
  {"input": "inject sidecar for service=app-service", "expected_output": "Sidecar proxy injected alongside app-service", "description": "Inject sidecar proxy"},
  {"input": "request through sidecar service=app-service, dest=db-service", "expected_output": "Request intercepted by sidecar, routed to db-service", "description": "Sidecar intercepts request"},
  {"input": "configure sidecar service=app-service, policy=retry 3x", "expected_output": "Sidecar configured: 3 retry attempts for app-service", "description": "Configure sidecar policy"},
  {"input": "metrics from sidecar service=app-service", "expected_output": "Sidecar metrics: 100 req/s, 99.9% success rate", "description": "Sidecar exposes metrics"}
]'::jsonb WHERE id = 'sys_037';

UPDATE challenges SET test_cases = '[
  {"input": "insert table=orders, row={id: 1, user: alice}", "expected_output": "CDC event: INSERT on orders row 1", "description": "Insert triggers CDC event"},
  {"input": "update table=orders, row=1, field=status, value=shipped", "expected_output": "CDC event: UPDATE on orders row 1, status=shipped", "description": "Update triggers CDC event"},
  {"input": "stream cdc_events to=kafka, topic=db_changes", "expected_output": "CDC events streaming to kafka db_changes topic", "description": "Stream CDC events"},
  {"input": "consumer receives cdc_event", "expected_output": "Consumer processed: orders INSERT row 1", "description": "Consumer processes CDC event"}
]'::jsonb WHERE id = 'sys_038';

UPDATE challenges SET test_cases = '[
  {"input": "create_view name=user_summary, query=SELECT user_id, count(*) FROM orders GROUP BY user_id", "expected_output": "Materialized view user_summary created", "description": "Create materialized view"},
  {"input": "refresh_view name=user_summary", "expected_output": "user_summary refreshed with latest data", "description": "Refresh materialized view"},
  {"input": "query view=user_summary", "expected_output": "Served from materialized view: 1000 rows in 2ms", "description": "Query materialized view"},
  {"input": "auto_refresh view=user_summary, interval=5min", "expected_output": "Auto-refresh configured: user_summary every 5 minutes", "description": "Configure auto-refresh"}
]'::jsonb WHERE id = 'sys_039';

UPDATE challenges SET test_cases = '[
  {"input": "set_quota tenant=tenant_A, resource=api_calls, limit=10000/day", "expected_output": "Quota set: tenant_A api_calls 10000/day", "description": "Set tenant quota"},
  {"input": "consume tenant=tenant_A, resource=api_calls, amount=9999", "expected_output": "API calls: 9999/10000 used", "description": "Consume quota"},
  {"input": "consume tenant=tenant_A, resource=api_calls, amount=2 (over limit)", "expected_output": "Quota exceeded: tenant_A api_calls limit reached", "description": "Block over-quota request"},
  {"input": "quota_reset tenant=tenant_A, resource=api_calls", "expected_output": "Quota reset for tenant_A api_calls", "description": "Reset daily quota"}
]'::jsonb WHERE id = 'sys_040';

UPDATE challenges SET test_cases = '[
  {"input": "ingest log={service: api, level: ERROR, msg: Null pointer}", "expected_output": "Log ingested and indexed: api ERROR", "description": "Ingest log entry"},
  {"input": "search logs service=api, level=ERROR, range=last 1h", "expected_output": "Found 3 ERROR logs from api in last 1h", "description": "Search log aggregation"},
  {"input": "alert rule=error_rate>5/min, service=api", "expected_output": "Alert triggered: api error rate exceeds 5/min", "description": "Alert on error rate"},
  {"input": "export logs format=csv, range=2024-07-15", "expected_output": "Logs exported: 1000 entries as CSV", "description": "Export aggregated logs"}
]'::jsonb WHERE id = 'sys_041';

UPDATE challenges SET test_cases = '[
  {"input": "deploy version=v2, traffic_split=canary_10%", "expected_output": "Canary deployed: 10% traffic to v2, 90% to v1", "description": "10% canary deployment"},
  {"input": "monitor canary=v2, error_rate=0.1%", "expected_output": "Canary healthy: v2 error rate 0.1%, continuing rollout", "description": "Monitor healthy canary"},
  {"input": "monitor canary=v2, error_rate=5%", "expected_output": "Canary unhealthy: rolling back to v1", "description": "Rollback unhealthy canary"},
  {"input": "promote canary=v2, traffic=100%", "expected_output": "Canary promoted: v2 now receives 100% traffic", "description": "Promote canary to full traffic"}
]'::jsonb WHERE id = 'sys_042';

UPDATE challenges SET test_cases = '[
  {"input": "create_session user=alice, token=TKN001, ttl=30min", "expected_output": "Session created: alice TKN001, expires in 30min", "description": "Create session token"},
  {"input": "validate_token token=TKN001", "expected_output": "Token valid: alice, expires in 25min", "description": "Validate session token"},
  {"input": "validate_token token=EXPIRED_TOKEN", "expected_output": "Token expired: authentication required", "description": "Expired token rejected"},
  {"input": "revoke_session user=alice", "expected_output": "Session revoked for alice, token invalidated", "description": "Revoke session"}
]'::jsonb WHERE id = 'sys_043';

UPDATE challenges SET test_cases = '[
  {"input": "enqueue priority=HIGH, job=send_alert", "expected_output": "send_alert (HIGH) enqueued", "description": "Enqueue high priority job"},
  {"input": "enqueue priority=LOW, job=cleanup", "expected_output": "cleanup (LOW) enqueued", "description": "Enqueue low priority job"},
  {"input": "dequeue", "expected_output": "Dequeued: send_alert (HIGH priority first)", "description": "High priority dequeued first"},
  {"input": "dequeue (only low priority remaining)", "expected_output": "Dequeued: cleanup (LOW)", "description": "Low priority dequeued when no high priority"}
]'::jsonb WHERE id = 'sys_044';

UPDATE challenges SET test_cases = '[
  {"input": "begin_transaction id=TXN001, isolation=snapshot", "expected_output": "Transaction TXN001 started with snapshot at version 5", "description": "Begin snapshot transaction"},
  {"input": "read TXN001 key=user_1", "expected_output": "TXN001 reads user_1 at snapshot version 5", "description": "Read from snapshot"},
  {"input": "concurrent_write key=user_1 by TXN002 while TXN001 active", "expected_output": "TXN001 still sees version 5, not TXN002 write", "description": "Snapshot isolation prevents dirty read"},
  {"input": "commit TXN001", "expected_output": "TXN001 committed, new version created", "description": "Commit snapshot transaction"}
]'::jsonb WHERE id = 'sys_045';

UPDATE challenges SET test_cases = '[
  {"input": "write region=us-east, data={key: user_1, value: Alice}", "expected_output": "Write to us-east, replicating to eu-west, ap-south", "description": "Write to primary region"},
  {"input": "replicate us-east -> eu-west, lag=200ms", "expected_output": "eu-west synced from us-east with 200ms lag", "description": "Cross-region replication"},
  {"input": "failover from=us-east, to=eu-west", "expected_output": "Failover completed: eu-west promoted to primary", "description": "Geo-failover"},
  {"input": "conflict on key=user_1 in us-east and eu-west", "expected_output": "Conflict resolved by last-write-wins policy", "description": "Geo-conflict resolution"}
]'::jsonb WHERE id = 'sys_046';

UPDATE challenges SET test_cases = '[
  {"input": "deliver webhook url=https://example.com/hook, event=order_placed", "expected_output": "Webhook delivered successfully: 200 OK", "description": "Successful webhook delivery"},
  {"input": "deliver webhook, response=500, retry_attempt=1", "expected_output": "Webhook failed, retry 1 scheduled in 30s", "description": "Retry on failure"},
  {"input": "deliver webhook, retry_attempt=5 (max retries)", "expected_output": "Webhook max retries exceeded, moved to DLQ", "description": "Max retries exceeded"},
  {"input": "exponential_backoff retry_attempt=3", "expected_output": "Retry 3 scheduled in 240s (2^3 * 30s)", "description": "Exponential backoff timing"}
]'::jsonb WHERE id = 'sys_047';

UPDATE challenges SET test_cases = '[
  {"input": "create_key name=my-api-key, scope=read", "expected_output": "API key created: my-api-key with read scope", "description": "Create API key"},
  {"input": "validate_key key=AK001", "expected_output": "Key AK001 valid, scope: read", "description": "Validate API key"},
  {"input": "rotate_key key=AK001", "expected_output": "Key AK001 rotated, new key AK002 issued", "description": "Rotate API key"},
  {"input": "revoke_key key=AK001", "expected_output": "Key AK001 revoked, all requests blocked", "description": "Revoke API key"}
]'::jsonb WHERE id = 'sys_048';

UPDATE challenges SET test_cases = '[
  {"input": "create_flag name=new_ui, enabled=false", "expected_output": "Feature flag new_ui created (disabled)", "description": "Create feature flag"},
  {"input": "rollout flag=new_ui, percentage=10", "expected_output": "new_ui enabled for 10% of users", "description": "Gradual rollout"},
  {"input": "check flag=new_ui, user=alice (in 10%)", "expected_output": "new_ui: enabled for alice", "description": "User in rollout sees flag"},
  {"input": "check flag=new_ui, user=bob (not in 10%)", "expected_output": "new_ui: disabled for bob", "description": "User not in rollout sees disabled"}
]'::jsonb WHERE id = 'sys_049';

UPDATE challenges SET test_cases = '[
  {"input": "encode column=age values=[25, 30, 25, 40], encoding=RLE", "expected_output": "Encoded: 25x2, 30x1, 40x1 (25% size reduction)", "description": "RLE encode column"},
  {"input": "encode column=status values=[active, active, inactive, active], encoding=dictionary", "expected_output": "Dictionary encoded: {0:active, 1:inactive}, data=[0,0,1,0]", "description": "Dictionary encoding"},
  {"input": "query column=age, filter=age>25", "expected_output": "Columnar scan: 2 rows match age>25 (fast column scan)", "description": "Columnar query filter"},
  {"input": "compress column=price, ratio", "expected_output": "Column price compressed 60% with delta encoding", "description": "Delta encoding for numeric column"}
]'::jsonb WHERE id = 'sys_050';

UPDATE challenges SET test_cases = '[
  {"input": "requests for resource=user_100 arrive simultaneously x10", "expected_output": "Coalesced: 1 backend request made for user_100", "description": "Coalesce duplicate requests"},
  {"input": "backend responds for user_100", "expected_output": "Response delivered to all 10 waiting requesters", "description": "Response fan-out to waiters"},
  {"input": "request resource=user_100, no concurrent waiters", "expected_output": "Direct fetch: no coalescing needed", "description": "Single request passes through"},
  {"input": "cache_stampede resource=popular_item, expire=simultaneous", "expected_output": "Stampede prevented: 1 fetch, others wait", "description": "Prevent cache stampede"}
]'::jsonb WHERE id = 'sys_051';

UPDATE challenges SET test_cases = '[
  {"input": "acquire_semaphore name=db_pool, max=5, client=C1", "expected_output": "Semaphore acquired: db_pool by C1 (1/5 used)", "description": "Acquire semaphore"},
  {"input": "acquire_semaphore name=db_pool, 5 more clients", "expected_output": "db_pool semaphore at capacity (5/5 used)", "description": "Semaphore at capacity"},
  {"input": "acquire_semaphore name=db_pool, client=C7 (full)", "expected_output": "Blocked: db_pool semaphore full, C7 waiting", "description": "Client blocked at capacity"},
  {"input": "release_semaphore name=db_pool, client=C1", "expected_output": "C1 released, C7 can now acquire (5/5 used)", "description": "Release allows waiting client"}
]'::jsonb WHERE id = 'sys_052';

UPDATE challenges SET test_cases = '[
  {"input": "current_deployment=blue, new_deployment=green", "expected_output": "Green deployment ready, traffic still on blue", "description": "Deploy green alongside blue"},
  {"input": "switch_traffic from=blue, to=green", "expected_output": "Traffic switched to green instantly", "description": "Instant traffic switch"},
  {"input": "rollback from=green, to=blue", "expected_output": "Rollback: traffic instantly reverted to blue", "description": "Instant rollback"},
  {"input": "health_check deployment=green, before_switch", "expected_output": "Green deployment health: OK, ready for traffic", "description": "Health check before switch"}
]'::jsonb WHERE id = 'sys_053';

UPDATE challenges SET test_cases = '[
  {"input": "log action=user_login, user=alice, timestamp=2024-07-15T10:00:00", "expected_output": "Audit log appended: user_login by alice at 10:00:00", "description": "Log audit event"},
  {"input": "query audit user=alice, from=2024-07-15", "expected_output": "Alice audit trail: 5 events on 2024-07-15", "description": "Query audit trail"},
  {"input": "modify audit_log (tamper attempt)", "expected_output": "Error: audit log is append-only, modification rejected", "description": "Immutable audit log"},
  {"input": "export audit_log format=json, range=2024-07", "expected_output": "Audit log exported: 500 events in JSON", "description": "Export audit log"}
]'::jsonb WHERE id = 'sys_054';

UPDATE challenges SET test_cases = '[
  {"input": "record metric=api_latency, value=42ms, timestamp=t1", "expected_output": "Metric recorded: api_latency 42ms at t1", "description": "Record metric"},
  {"input": "rollup metric=api_latency, interval=1min", "expected_output": "1-min rollup: api_latency avg=45ms, p99=120ms", "description": "1-minute rollup aggregation"},
  {"input": "rollup metric=api_latency, interval=1h", "expected_output": "1-hour rollup: api_latency avg=48ms, p99=130ms", "description": "1-hour rollup aggregation"},
  {"input": "query metric=api_latency, resolution=1h, range=last 24h", "expected_output": "api_latency 24h: 24 hourly aggregations returned", "description": "Query aggregated metrics"}
]'::jsonb WHERE id = 'sys_055';

UPDATE challenges SET test_cases = '[
  {"input": "backends=[B1: 20 reqs, B2: 5 reqs, B3: 10 reqs]", "expected_output": "Next request routed to B2 (least connections)", "description": "Least connections routing"},
  {"input": "backend=B1 response_time=500ms, B2=50ms", "expected_output": "Load shifted to B2 (lower latency)", "description": "Adaptive shift to faster backend"},
  {"input": "backend=B1 health=unhealthy", "expected_output": "B1 removed from pool, traffic to B2, B3", "description": "Remove unhealthy backend"},
  {"input": "backend=B1 recovers health", "expected_output": "B1 added back to pool gradually", "description": "Gradually add recovered backend"}
]'::jsonb WHERE id = 'sys_056';

UPDATE challenges SET test_cases = '[
  {"input": "serialize message={type: OrderPlaced, order_id: 1}", "expected_output": "Serialized: binary 28 bytes (vs JSON 45 bytes)", "description": "Serialize to binary protocol"},
  {"input": "deserialize bytes=<binary>", "expected_output": "Deserialized: {type: OrderPlaced, order_id: 1}", "description": "Deserialize binary message"},
  {"input": "schema_version=1 message, deserializer=v2", "expected_output": "Backward compatible deserialization successful", "description": "Backward compatible schema"},
  {"input": "corrupt bytes deserialize", "expected_output": "Error: invalid binary format, deserialization failed", "description": "Corrupted bytes error"}
]'::jsonb WHERE id = 'sys_057';

UPDATE challenges SET test_cases = '[
  {"input": "write to outbox: event={type: OrderPlaced, id: 1}", "expected_output": "Event written to outbox atomically with DB transaction", "description": "Write to outbox atomically"},
  {"input": "relay outbox events to message_bus", "expected_output": "Relayed: OrderPlaced event to message bus", "description": "Relay outbox to message bus"},
  {"input": "event already_relayed, relay again", "expected_output": "Idempotent relay: OrderPlaced already sent, skipped", "description": "Idempotent relay"},
  {"input": "outbox_size", "expected_output": "Outbox: 0 pending events (all relayed)", "description": "Check outbox empty after relay"}
]'::jsonb WHERE id = 'sys_058';

UPDATE challenges SET test_cases = '[
  {"input": "requests=100 in last 60s, window_size=60s, limit=120", "expected_output": "100/120 requests in window, allowed", "description": "Within sliding window limit"},
  {"input": "requests=121 in last 60s, limit=120", "expected_output": "Rate limited: 121 exceeds 120 in 60s window", "description": "Exceeds sliding window limit"},
  {"input": "window_slides 10s forward, old_requests=20 expire", "expected_output": "Window updated: 80 requests in new 60s window", "description": "Window slides and old requests expire"},
  {"input": "burst=50 in 1s, window_limit=120/60s", "expected_output": "Burst allowed within sliding window limit", "description": "Burst within window allowed"}
]'::jsonb WHERE id = 'sys_059';

UPDATE challenges SET test_cases = '[
  {"input": "join_network node=N1, bootstrap=N2", "expected_output": "N1 joined DHT network via N2", "description": "Join DHT network"},
  {"input": "put key=file_hash, value=node_location", "expected_output": "Key stored in DHT at responsible node", "description": "Store key in DHT"},
  {"input": "get key=file_hash", "expected_output": "DHT lookup: file_hash found at node N5", "description": "Lookup key in DHT"},
  {"input": "node=N5 leaves, key=file_hash", "expected_output": "file_hash migrated to successor node N6", "description": "Key migrates on node leave"}
]'::jsonb WHERE id = 'sys_060';

UPDATE challenges SET test_cases = '[
  {"input": "primary=us-east, health=failing", "expected_output": "Failover initiated: us-east failing, switching to eu-west", "description": "Initiate failover"},
  {"input": "failover complete, primary=eu-west", "expected_output": "Failover complete: eu-west is now primary", "description": "Failover completes"},
  {"input": "us-east recovers, failback", "expected_output": "Failback initiated: us-east recovered, data sync started", "description": "Failback to original region"},
  {"input": "rto=30s, rpo=5min, failover_test", "expected_output": "Failover test: switched in 28s, 3min data loss (within RTO/RPO)", "description": "RTO/RPO failover test"}
]'::jsonb WHERE id = 'sys_061';

UPDATE challenges SET test_cases = '[
  {"input": "configure backend=postgres", "expected_output": "Storage backend configured: postgres", "description": "Configure Postgres backend"},
  {"input": "write key=user_1, value=Alice", "expected_output": "Written to postgres backend", "description": "Write via storage backend"},
  {"input": "switch_backend from=postgres, to=redis", "expected_output": "Storage backend switched to redis, data migrated", "description": "Switch to Redis backend"},
  {"input": "read key=user_1 after switch", "expected_output": "Read from redis backend: Alice", "description": "Read from new backend"}
]'::jsonb WHERE id = 'sys_062';

UPDATE challenges SET test_cases = '[
  {"input": "schedule job=daily_report, cron=0 2 * * *, worker=W1", "expected_output": "Job daily_report scheduled at 02:00 daily on W1", "description": "Schedule cron job"},
  {"input": "job=daily_report trigger at 02:00", "expected_output": "daily_report job triggered, assigned to W1", "description": "Job triggers at scheduled time"},
  {"input": "worker=W1 fails, job=daily_report", "expected_output": "daily_report reassigned to W2 (W1 failed)", "description": "Job rescheduled on worker failure"},
  {"input": "get_job_status job=daily_report", "expected_output": "daily_report: last run 02:00, status: completed", "description": "Get job status"}
]'::jsonb WHERE id = 'sys_063';

UPDATE challenges SET test_cases = '[
  {"input": "open_stream client=C1, service=chat_service", "expected_output": "gRPC streaming channel opened: C1 to chat_service", "description": "Open gRPC stream"},
  {"input": "stream message from=C1, data=Hello", "expected_output": "Message streamed through gRPC gateway to chat_service", "description": "Stream message via gateway"},
  {"input": "backpressure on stream=C1", "expected_output": "Backpressure applied: streaming rate throttled for C1", "description": "Backpressure on overloaded stream"},
  {"input": "close_stream client=C1", "expected_output": "gRPC stream closed for C1", "description": "Close streaming connection"}
]'::jsonb WHERE id = 'sys_064';

UPDATE challenges SET test_cases = '[
  {"input": "shard_sizes=[S1: 80%, S2: 20%, S3: 20%]", "expected_output": "Rebalance needed: S1 is hotspot (80%)", "description": "Detect shard imbalance"},
  {"input": "migrate_data from=S1, to=S3, amount=30%", "expected_output": "Migrating 30% of S1 data to S3", "description": "Migrate shard data"},
  {"input": "rebalance_complete", "expected_output": "Shards balanced: S1: 50%, S2: 25%, S3: 25%", "description": "Rebalance completed"},
  {"input": "add_shard S4 to cluster", "expected_output": "S4 added, rebalancing initiated across 4 shards", "description": "Add shard triggers rebalance"}
]'::jsonb WHERE id = 'sys_065';

UPDATE challenges SET test_cases = '[
  {"input": "begin_saga OrderSaga, step=1 reserve_inventory success", "expected_output": "Step 1 complete, proceeding to step 2", "description": "Saga step 1 succeeds"},
  {"input": "step=2 charge_payment fails", "expected_output": "Step 2 failed, rolling back step 1: release_inventory", "description": "Compensation for step 1"},
  {"input": "compensation=release_inventory executes", "expected_output": "Compensation successful: inventory released", "description": "Compensation executes"},
  {"input": "all compensations complete", "expected_output": "Saga rolled back completely, system in consistent state", "description": "Full rollback completes"}
]'::jsonb WHERE id = 'sys_066';

UPDATE challenges SET test_cases = '[
  {"input": "request Accept=application/json", "expected_output": "Content negotiated: JSON response", "description": "Negotiate JSON response"},
  {"input": "request Accept=application/xml", "expected_output": "Content negotiated: XML response", "description": "Negotiate XML response"},
  {"input": "request Accept=application/unsupported", "expected_output": "406 Not Acceptable: unsupported content type", "description": "Unsupported type returns 406"},
  {"input": "request Accept=*/*, prefer=json", "expected_output": "Content negotiated: JSON (default preferred)", "description": "Wildcard accept prefers JSON"}
]'::jsonb WHERE id = 'sys_067';

UPDATE challenges SET test_cases = '[
  {"input": "submit_task job=report_generation, async=true", "expected_output": "Task submitted, task_id=TASK001 returned immediately", "description": "Submit async task"},
  {"input": "poll task_id=TASK001, status=in_progress", "expected_output": "TASK001 status: in_progress (0% complete)", "description": "Poll task in progress"},
  {"input": "poll task_id=TASK001, status=complete", "expected_output": "TASK001 status: complete, result available", "description": "Poll shows task complete"},
  {"input": "get_result task_id=TASK001", "expected_output": "TASK001 result: report_generation output", "description": "Get completed task result"}
]'::jsonb WHERE id = 'sys_068';

UPDATE challenges SET test_cases = '[
  {"input": "put key=user:1:name, value=Alice, column_family=users", "expected_output": "user:1:name = Alice stored in users CF", "description": "Put key in column family"},
  {"input": "get key=user:1:name, column_family=users", "expected_output": "user:1:name: Alice", "description": "Get key from column family"},
  {"input": "scan prefix=user:1, column_family=users", "expected_output": "user:1 keys: [user:1:name, user:1:email, user:1:age]", "description": "Scan key prefix"},
  {"input": "delete key=user:1:name, column_family=users", "expected_output": "user:1:name deleted from users CF", "description": "Delete key from column family"}
]'::jsonb WHERE id = 'sys_069';

UPDATE challenges SET test_cases = '[
  {"input": "call service=payment, fails attempt=1", "expected_output": "Retry 1 after 1s (base delay)", "description": "First retry after base delay"},
  {"input": "call service=payment, fails attempt=2", "expected_output": "Retry 2 after 2s (2^1 * 1s)", "description": "Second retry with doubling delay"},
  {"input": "call service=payment, fails attempt=3", "expected_output": "Retry 3 after 4s (2^2 * 1s)", "description": "Third retry with exponential backoff"},
  {"input": "call service=payment, fails attempt=5 (max)", "expected_output": "Max retries exceeded, operation failed", "description": "Max retries gives up"}
]'::jsonb WHERE id = 'sys_070';

UPDATE challenges SET test_cases = '[
  {"input": "write key=data_1, quorum=3/5", "expected_output": "Write successful: acknowledged by 3/5 nodes", "description": "Quorum write succeeds"},
  {"input": "write key=data_1, acks=2 of required 3", "expected_output": "Write failed: only 2/3 nodes acknowledged", "description": "Quorum write fails without quorum"},
  {"input": "read key=data_1, quorum=2/5", "expected_output": "Quorum read: latest value returned with 2 agreements", "description": "Quorum read returns consistent value"},
  {"input": "network partition: only 2 nodes reachable", "expected_output": "Quorum unavailable: write rejected (need 3, have 2)", "description": "Partition prevents quorum write"}
]'::jsonb WHERE id = 'sys_071';

UPDATE challenges SET test_cases = '[
  {"input": "cache_key=popular_item, ttl_expires=simultaneously, requesters=100", "expected_output": "Stampede prevented: 1 lock acquired, 99 waiting", "description": "Lock prevents stampede"},
  {"input": "lock_holder fetches from db, updates cache", "expected_output": "Cache populated, waiting requesters served from cache", "description": "Cache populated, others served"},
  {"input": "probabilistic_early_expiry key=hot_data, beta=1.0", "expected_output": "Early refresh triggered probabilistically before expiry", "description": "Probabilistic early refresh"},
  {"input": "stale_while_revalidate key=news_feed", "expected_output": "Stale data served while background refresh runs", "description": "Serve stale while revalidating"}
]'::jsonb WHERE id = 'sys_072';

UPDATE challenges SET test_cases = '[
  {"input": "register service=auth-service, endpoint=/health", "expected_output": "auth-service registered in health registry", "description": "Register service in health registry"},
  {"input": "health_check service=auth-service, response=200", "expected_output": "auth-service: healthy", "description": "Service health check passes"},
  {"input": "health_check service=db-service, response=500", "expected_output": "db-service: unhealthy, alert sent", "description": "Unhealthy service alert"},
  {"input": "get_system_health", "expected_output": "System health: 4/5 services healthy, db-service down", "description": "Get overall system health"}
]'::jsonb WHERE id = 'sys_073';

UPDATE challenges SET test_cases = '[
  {"input": "network_partition nodes=[n1, n2] isolated from [n3, n4, n5]", "expected_output": "Partition detected: 2/5 nodes isolated", "description": "Detect network partition"},
  {"input": "test consistency preference=CP during partition", "expected_output": "Writes rejected on minority side (CP: consistency)", "description": "CP system rejects minority writes"},
  {"input": "test availability preference=AP during partition", "expected_output": "Writes accepted on both sides (AP: availability)", "description": "AP system accepts all writes"},
  {"input": "partition heals, sync nodes", "expected_output": "Partition healed, nodes re-syncing", "description": "Partition heals and syncs"}
]'::jsonb WHERE id = 'sys_074';

UPDATE challenges SET test_cases = '[
  {"input": "store event={type: OrderPlaced, id: 1, ts: t1}", "expected_output": "Event stored in stream", "description": "Store event in stream"},
  {"input": "replay stream from=beginning, consumer=audit_service", "expected_output": "audit_service replaying from event 1", "description": "Replay stream from start"},
  {"input": "replay stream from=offset=50", "expected_output": "Replaying from offset 50", "description": "Replay from specific offset"},
  {"input": "consumer_position consumer=audit_service", "expected_output": "audit_service position: event 100 of 150", "description": "Get consumer position in stream"}
]'::jsonb WHERE id = 'sys_075';

UPDATE challenges SET test_cases = '[
  {"input": "subscribe query={topic: orders, filter: status=placed}", "expected_output": "GraphQL subscription created for orders placed", "description": "Create GraphQL subscription"},
  {"input": "event order_status_changed to placed", "expected_output": "Subscription notified: order placed event sent", "description": "Event triggers subscription update"},
  {"input": "unsubscribe subscription=SUB001", "expected_output": "GraphQL subscription SUB001 cancelled", "description": "Unsubscribe from GraphQL subscription"},
  {"input": "subscriber_count topic=orders", "expected_output": "Active subscribers for orders: 15", "description": "Count active subscriptions"}
]'::jsonb WHERE id = 'sys_076';

UPDATE challenges SET test_cases = '[
  {"input": "generate_id node=N1, sequence=1", "expected_output": "Generated ID: 1703001234567_N1_0001 (time+node+seq)", "description": "Generate distributed ID"},
  {"input": "generate 1000 ids concurrently on 3 nodes", "expected_output": "1000 unique IDs generated, no collisions", "description": "Concurrent unique ID generation"},
  {"input": "generate_id node=N1, sequence=overflow", "expected_output": "Sequence rolled over, timestamp incremented", "description": "Sequence overflow handling"},
  {"input": "compare ids order=chronological", "expected_output": "IDs sortable by generation time", "description": "IDs are time-sortable"}
]'::jsonb WHERE id = 'sys_077';

UPDATE challenges SET test_cases = '[
  {"input": "register schema name=OrderEvent, version=1, fields=[id, user, amount]", "expected_output": "Schema OrderEvent v1 registered", "description": "Register schema"},
  {"input": "produce message schema=OrderEvent v1", "expected_output": "Message validated against OrderEvent v1", "description": "Message validates against schema"},
  {"input": "register schema OrderEvent v2, remove field=user (breaking)", "expected_output": "Schema rejected: breaking change detected (removed field)", "description": "Breaking schema change rejected"},
  {"input": "register schema OrderEvent v2, add optional field=currency", "expected_output": "Schema OrderEvent v2 registered (backward compatible)", "description": "Compatible schema change accepted"}
]'::jsonb WHERE id = 'sys_078';

UPDATE challenges SET test_cases = '[
  {"input": "configure bulkhead service=payment, pool_size=10", "expected_output": "Bulkhead configured: payment isolated pool of 10 threads", "description": "Configure bulkhead"},
  {"input": "payment_service saturated=10 threads", "expected_output": "Payment bulkhead full: requests rejected for payment", "description": "Bulkhead rejects overflow"},
  {"input": "order_service unaffected while payment_service overloaded", "expected_output": "Order service normal: isolated from payment overload", "description": "Bulkhead isolates failure"},
  {"input": "payment_service recovers", "expected_output": "Payment bulkhead pool available again", "description": "Bulkhead recovers"}
]'::jsonb WHERE id = 'sys_079';

UPDATE challenges SET test_cases = '[
  {"input": "publish event=user_registered, subscribers=[email, sms, push, analytics]", "expected_output": "Fan-out: message dispatched to 4 subscribers", "description": "Fan-out to multiple subscribers"},
  {"input": "subscriber=email fails", "expected_output": "Email delivery failed, other subscribers unaffected", "description": "Partial failure isolation"},
  {"input": "fan_out 1 event to 1000 subscribers", "expected_output": "Event dispatched to 1000 subscribers concurrently", "description": "Large fan-out"},
  {"input": "fan_out with filtering topic=premium_users", "expected_output": "Event sent to 150 premium subscribers only", "description": "Fan-out with subscriber filter"}
]'::jsonb WHERE id = 'sys_080';

UPDATE challenges SET test_cases = '[
  {"input": "node=N1 clock=[N1:1, N2:0, N3:0], event=write", "expected_output": "N1 clock after write: [N1:2, N2:0, N3:0]", "description": "Increment vector clock on event"},
  {"input": "sync N1 with N2: N2 clock=[N1:1, N2:2, N3:0]", "expected_output": "Merged clock: [N1:2, N2:2, N3:0]", "description": "Merge vector clocks"},
  {"input": "conflict: N1=[1,0,0] wrote key=x, N2=[0,1,0] wrote key=x", "expected_output": "Conflict detected: concurrent writes to x, resolution needed", "description": "Detect concurrent write conflict"},
  {"input": "resolve conflict using last_write_wins", "expected_output": "Conflict resolved: later timestamp wins", "description": "Resolve conflict"}
]'::jsonb WHERE id = 'sys_081';

UPDATE challenges SET test_cases = '[
  {"input": "create_migration add column=email to users, zero_downtime=true", "expected_output": "Migration plan: add nullable column, backfill, add constraint", "description": "Plan zero-downtime migration"},
  {"input": "phase=1 add_nullable_column email to users", "expected_output": "Phase 1 complete: email column added (nullable)", "description": "Phase 1 - add nullable column"},
  {"input": "phase=2 backfill email values", "expected_output": "Phase 2 complete: email backfilled for 1M rows", "description": "Phase 2 - backfill data"},
  {"input": "phase=3 add_not_null_constraint email", "expected_output": "Phase 3 complete: NOT NULL constraint added", "description": "Phase 3 - add constraint"}
]'::jsonb WHERE id = 'sys_082';

UPDATE challenges SET test_cases = '[
  {"input": "compress data=large_json, codec=gzip", "expected_output": "Compressed with gzip: 75% size reduction", "description": "GZIP compression"},
  {"input": "compress data=large_json, codec=snappy", "expected_output": "Compressed with snappy: 60% reduction, faster", "description": "Snappy compression (faster)"},
  {"input": "decompress data=compressed.gz, codec=gzip", "expected_output": "Decompressed successfully", "description": "Decompress data"},
  {"input": "pipeline=[compress, encrypt, serialize]", "expected_output": "Data processed through compression pipeline", "description": "Multi-codec pipeline"}
]'::jsonb WHERE id = 'sys_083';

UPDATE challenges SET test_cases = '[
  {"input": "schedule job=cleanup, cron=0 3 * * *, nodes=[n1, n2, n3]", "expected_output": "Distributed cron: cleanup scheduled on all 3 nodes", "description": "Schedule distributed cron"},
  {"input": "leader elects to run cleanup at 03:00", "expected_output": "Leader n1 triggering cleanup job", "description": "Leader runs cron job"},
  {"input": "leader=n1 crashes during job", "expected_output": "n2 takes over as leader, job re-triggered", "description": "Leader crash handled"},
  {"input": "prevent duplicate runs in same window", "expected_output": "Lock acquired by leader, duplicate execution prevented", "description": "Prevent duplicate cron execution"}
]'::jsonb WHERE id = 'sys_084';

UPDATE challenges SET test_cases = '[
  {"input": "access_count key=old_data, count=0, age=180days", "expected_output": "old_data tiered to cold storage (inactive 180 days)", "description": "Tier cold data"},
  {"input": "access key=old_data (in cold storage)", "expected_output": "Fetching old_data from cold storage, promoting to warm", "description": "Promote cold data on access"},
  {"input": "storage_cost hot=expensive, cold=cheap", "expected_output": "Cost savings: 40% by tiering cold data", "description": "Cold tiering cost savings"},
  {"input": "list_cold_storage", "expected_output": "Cold storage: 500GB of infrequently accessed data", "description": "List cold storage contents"}
]'::jsonb WHERE id = 'sys_085';

UPDATE challenges SET test_cases = '[
  {"input": "simulate partition nodes=[n1, n2], isolate=[n3]", "expected_output": "Network partition simulated: n3 isolated from n1, n2", "description": "Simulate network partition"},
  {"input": "test_consistency during partition", "expected_output": "Consistency test: reads from n3 may be stale", "description": "Test consistency during partition"},
  {"input": "heal_partition", "expected_output": "Partition healed, n3 re-joined network", "description": "Heal partition"},
  {"input": "simulate latency between n1 and n2, delay=500ms", "expected_output": "Latency injected: 500ms between n1 and n2", "description": "Inject network latency"}
]'::jsonb WHERE id = 'sys_086';

UPDATE challenges SET test_cases = '[
  {"input": "request to slow_service, hedge_delay=100ms", "expected_output": "Hedged: secondary request fired after 100ms", "description": "Hedge request fires secondary"},
  {"input": "primary responds in 80ms (before hedge)", "expected_output": "Primary responded first (80ms), hedge cancelled", "description": "Primary wins, hedge cancelled"},
  {"input": "primary slow=200ms, secondary responds=95ms", "expected_output": "Secondary response used (95ms vs 200ms)", "description": "Faster secondary response used"},
  {"input": "both requests succeed, dedup responses", "expected_output": "First response used, duplicate discarded", "description": "Duplicate response deduplicated"}
]'::jsonb WHERE id = 'sys_087';

UPDATE challenges SET test_cases = '[
  {"input": "cpu_usage=80%, scale_up threshold=70%", "expected_output": "Scaling up: adding 2 instances (CPU 80% > 70%)", "description": "Scale up on high CPU"},
  {"input": "cpu_usage=20%, scale_down threshold=30%", "expected_output": "Scaling down: removing 1 instance (CPU 20% < 30%)", "description": "Scale down on low CPU"},
  {"input": "predictive_scaling time=08:00, historical_spike", "expected_output": "Pre-scaling: adding instances before predicted 08:00 spike", "description": "Predictive scale-out before spike"},
  {"input": "scale cooldown=60s, second scale request in 30s", "expected_output": "Scale request ignored: cooldown period active", "description": "Cooldown prevents rapid scaling"}
]'::jsonb WHERE id = 'sys_088';

UPDATE challenges SET test_cases = '[
  {"input": "conflict key=record_1, master_A=v2, master_B=v3 (concurrent writes)", "expected_output": "Conflict detected: record_1 has divergent versions", "description": "Detect multi-master conflict"},
  {"input": "resolve strategy=last_write_wins, master_A ts=t5, master_B ts=t7", "expected_output": "master_B wins: latest timestamp t7", "description": "Last-write-wins resolution"},
  {"input": "resolve strategy=merge, conflict=numeric_field", "expected_output": "Merged: sum of both values applied", "description": "Merge resolution strategy"},
  {"input": "manual_resolution conflict=record_1, human_reviewed", "expected_output": "Manual resolution applied to record_1", "description": "Manual conflict resolution"}
]'::jsonb WHERE id = 'sys_089';

UPDATE challenges SET test_cases = '[
  {"input": "onboard tenant=new_customer, plan=enterprise", "expected_output": "Tenant provisioned: DB schema, S3 bucket, API keys created", "description": "Provision new tenant"},
  {"input": "configure tenant=new_customer, region=us-east", "expected_output": "Tenant configured for us-east region", "description": "Configure tenant region"},
  {"input": "provision failed step=db_schema", "expected_output": "Rollback: cleaning up partial provisioning", "description": "Rollback on provisioning failure"},
  {"input": "offboard tenant=old_customer", "expected_output": "Tenant deprovisioned: data archived, resources released", "description": "Deprovision tenant"}
]'::jsonb WHERE id = 'sys_090';

UPDATE challenges SET test_cases = '[
  {"input": "device lat=40.71, lon=-74.01, geofence=NYC_office radius=500m", "expected_output": "Device inside NYC_office geofence", "description": "Device inside geofence"},
  {"input": "device moves to lat=40.72, lon=-74.01 (outside)", "expected_output": "Alert: device exited NYC_office geofence", "description": "Device exits geofence triggers alert"},
  {"input": "subscribe alert=geofence_exit, fence=NYC_office", "expected_output": "Subscription active: notify on exit from NYC_office", "description": "Subscribe to geofence alerts"},
  {"input": "device enters geofence", "expected_output": "Alert: device entered NYC_office geofence", "description": "Entry alert"}
]'::jsonb WHERE id = 'sys_091';

UPDATE challenges SET test_cases = '[
  {"input": "append event={type: UserSignup, user_id: 1}", "expected_output": "Event appended to journal at offset 1", "description": "Append event to journal"},
  {"input": "append event with conflict (duplicate offset)", "expected_output": "Error: duplicate offset rejected, journal is append-only", "description": "Duplicate offset rejected"},
  {"input": "read journal from=offset 0, count=10", "expected_output": "10 events returned from journal", "description": "Read events from journal"},
  {"input": "truncate journal (not allowed)", "expected_output": "Error: append-only journal cannot be truncated", "description": "Truncation rejected for append-only journal"}
]'::jsonb WHERE id = 'sys_092';

UPDATE challenges SET test_cases = '[
  {"input": "introspect token=TKN001", "expected_output": "Token TKN001 valid: user=alice, scope=read, exp=3600s", "description": "Introspect valid token"},
  {"input": "introspect token=TKN001 (cached)", "expected_output": "Token TKN001 served from introspection cache", "description": "Cached introspection result"},
  {"input": "token=TKN001 revoked, cache=stale", "expected_output": "Cache TTL expired, re-introspected: token revoked", "description": "Cache expires, detects revocation"},
  {"input": "introspect invalid_token", "expected_output": "Token invalid: not found or malformed", "description": "Invalid token introspection"}
]'::jsonb WHERE id = 'sys_093';

UPDATE challenges SET test_cases = '[
  {"input": "mirror request GET /api/users to shadow", "expected_output": "Request mirrored to shadow service asynchronously", "description": "Mirror request to shadow"},
  {"input": "compare shadow_response with production_response", "expected_output": "Shadow response matches production: no divergence", "description": "Shadow response matches production"},
  {"input": "shadow diverges on endpoint GET /api/orders", "expected_output": "Divergence detected: shadow returned different data", "description": "Divergence detected in shadow"},
  {"input": "shadow_error rate", "expected_output": "Shadow error rate: 0.1% (vs production 0.0%)", "description": "Shadow error rate comparison"}
]'::jsonb WHERE id = 'sys_094';

UPDATE challenges SET test_cases = '[
  {"input": "acquire_lease resource=primary_db, leaseholder=node_1, ttl=30s", "expected_output": "Lease granted: node_1 holds primary_db for 30s", "description": "Acquire resource lease"},
  {"input": "renew_lease resource=primary_db, leaseholder=node_1", "expected_output": "Lease renewed: node_1 primary_db for another 30s", "description": "Renew lease"},
  {"input": "lease_expires resource=primary_db, node_1 dies", "expected_output": "Lease expired for node_1, node_2 can acquire primary_db", "description": "Expired lease released on failure"},
  {"input": "acquire_lease resource=primary_db, client=node_2 (after expiry)", "expected_output": "Lease granted to node_2", "description": "New lease after expiry"}
]'::jsonb WHERE id = 'sys_095';

UPDATE challenges SET test_cases = '[
  {"input": "event stream, window=5min, aggregate=count", "expected_output": "Window [t0-t5min]: 150 events counted", "description": "Tumbling window count"},
  {"input": "sliding_window size=5min, slide=1min", "expected_output": "Sliding window: new aggregate every 1 min", "description": "Sliding window aggregation"},
  {"input": "window_close emit=sum, group_by=event_type", "expected_output": "Window closed: purchase=50, view=100 emitted", "description": "Emit grouped aggregation on window close"},
  {"input": "late_event arrives after window_close", "expected_output": "Late event handled with allowed_lateness=30s", "description": "Handle late arriving event"}
]'::jsonb WHERE id = 'sys_096';

UPDATE challenges SET test_cases = '[
  {"input": "request enters service_A, trace_id=TRACE001", "expected_output": "Correlation header propagated: X-Trace-ID: TRACE001", "description": "Propagate correlation ID"},
  {"input": "service_A calls service_B with trace_id=TRACE001", "expected_output": "service_B logs with TRACE001 correlation ID", "description": "Correlation ID carried across services"},
  {"input": "get_trace trace_id=TRACE001", "expected_output": "TRACE001: service_A -> service_B -> db (all correlated)", "description": "Retrieve full correlated trace"},
  {"input": "missing correlation header", "expected_output": "New trace_id generated for uncorrelated request", "description": "Generate trace ID when missing"}
]'::jsonb WHERE id = 'sys_097';

UPDATE challenges SET test_cases = '[
  {"input": "circuit=OPEN, probe after timeout=60s", "expected_output": "Adaptive probe sent to payment service", "description": "Probe sent after circuit open timeout"},
  {"input": "probe response=200 OK", "expected_output": "Circuit moving to HALF-OPEN, allowing trial requests", "description": "Successful probe enables trial"},
  {"input": "trial_requests=10, success_rate=100%", "expected_output": "Circuit CLOSED: service recovered", "description": "Circuit closes on successful trials"},
  {"input": "trial_requests=10, failures=3 (30%)", "expected_output": "Circuit reopens: trial failure rate too high", "description": "Circuit reopens on high trial failure rate"}
]'::jsonb WHERE id = 'sys_098';

UPDATE challenges SET test_cases = '[
  {"input": "route /api/v1/users/123 in hierarchical namespace", "expected_output": "Routed: /api -> /v1 -> /users -> /123", "description": "Route in hierarchical namespace"},
  {"input": "wildcard route /api/v1/*/profile", "expected_output": "Wildcard matched: /api/v1/alice/profile", "description": "Wildcard namespace routing"},
  {"input": "namespace conflict /api/v1 and /api/*", "expected_output": "More specific /api/v1 takes precedence", "description": "Specific route wins over wildcard"},
  {"input": "add namespace /api/v2", "expected_output": "Namespace /api/v2 added to hierarchy", "description": "Add new namespace to hierarchy"}
]'::jsonb WHERE id = 'sys_099';

UPDATE challenges SET test_cases = '[
  {"input": "inject fault=latency, service=payment, delay=500ms, rate=10%", "expected_output": "Chaos: 10% of payment requests delayed 500ms", "description": "Inject latency fault"},
  {"input": "inject fault=error, service=db, error_rate=5%", "expected_output": "Chaos: 5% of DB requests return error", "description": "Inject error fault"},
  {"input": "stop_chaos service=payment", "expected_output": "Chaos stopped for payment service, normal operation", "description": "Stop chaos injection"},
  {"input": "chaos_report", "expected_output": "Chaos report: system survived 500ms payment latency, SLO met", "description": "Report chaos experiment results"}
]'::jsonb WHERE id = 'sys_100';

