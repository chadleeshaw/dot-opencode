---
name: python
description: Python best practices for readable, maintainable code
license: MIT
compatibility: opencode
---

# Python Code Agent

Write clean, maintainable Python following best practices for procedural programming, with focus on AI, data science, and ML applications.

## Core Principles

1. **Self-documenting code** - Clear names eliminate need for comments
2. **Follow PEP 8** - Python's official style guide
3. **Procedural first** - Use functions, avoid classes unless necessary
4. **One task per function** - Small, focused functions
5. **Minimal comments** - Code should explain itself

## Naming Conventions

### Variables and Functions: snake_case
```python
# Good
user_email = "user@example.com"
total_count = 42

def calculate_average_score(scores):
    return sum(scores) / len(scores)
```

### Constants: UPPER_SNAKE_CASE
```python
MAX_RETRIES = 3
DEFAULT_TIMEOUT = 30
LEARNING_RATE = 0.01
```

### Classes: PascalCase
```python
class DataProcessor:
    def __init__(self, data):
        self.data = data
```

### Booleans: is/has/should prefix
```python
is_valid = True
has_permission = False
should_continue = True
```

### Counter Variables
Single letters only for loops: `i`, `j`, `k`

```python
for i in range(10):
    for j in range(5):
        print(i, j)
```

## Code Structure

### Imports
```python
# Standard library
import os
import sys
from pathlib import Path

# Third-party
import numpy as np
import pandas as pd

# Local
from .utils import helper_function
```

### Spacing
```python
# Good - proper spacing
def process_data(input_data, threshold=0.5):
    result = input_data * 2
    if result > threshold:
        return result
    return None

# Bad - inconsistent spacing
def process_data(input_data,threshold=0.5):
    result=input_data*2
    if result>threshold:
        return result
    return None
```

## Functions

### Keep functions small (under 20-30 lines)
```python
# Good - focused function
def calculate_discount(price, discount_percent):
    return price * (1 - discount_percent / 100)

def apply_tax(price, tax_rate):
    return price * (1 + tax_rate)

def calculate_final_price(price, discount_percent, tax_rate):
    discounted_price = calculate_discount(price, discount_percent)
    return apply_tax(discounted_price, tax_rate)

# Bad - doing too much
def calculate_final_price(price, discount_percent, tax_rate, coupon_code, 
                         shipping_cost, is_member):
    # 50+ lines of mixed logic
    pass
```

### Use type hints
```python
def process_user_data(user_id: int, email: str) -> dict:
    return {
        'id': user_id,
        'email': email,
        'verified': True
    }
```

### Early returns to reduce nesting
```python
# Good
def validate_user(user):
    if not user:
        return False
    if not user.email:
        return False
    if not user.verified:
        return False
    return True

# Bad - nested
def validate_user(user):
    if user:
        if user.email:
            if user.verified:
                return True
    return False
```

## Data Structures

### Use list comprehensions (when simple)
```python
# Good - clear and concise
squares = [x**2 for x in range(10)]
evens = [x for x in numbers if x % 2 == 0]

# Bad - too complex (use regular loop instead)
result = [x**2 if x > 0 else abs(x) for x in data if x != 0 and x < 100]
```

### Dictionary operations
```python
# Good - use .get() with defaults
user_age = user_data.get('age', 0)

# Good - dict comprehension
squared_dict = {k: v**2 for k, v in data.items()}

# Good - merge dicts (Python 3.9+)
combined = default_config | user_config
```

### Use f-strings for formatting
```python
# Good
name = "Alice"
age = 30
message = f"User {name} is {age} years old"

# Avoid
message = "User " + name + " is " + str(age) + " years old"
message = "User {} is {} years old".format(name, age)
```

## Control Flow

### Boolean expressions
```python
# Good - clear conditions
is_adult = age >= 18
has_valid_email = email and '@' in email
should_process = is_adult and has_valid_email

if should_process:
    process_user()

# Bad - complex inline
if age >= 18 and email and '@' in email and user.verified:
    process_user()
```

### Avoid else after return
```python
# Good
def get_status(value):
    if value > 100:
        return "high"
    if value > 50:
        return "medium"
    return "low"

# Bad
def get_status(value):
    if value > 100:
        return "high"
    else:
        if value > 50:
            return "medium"
        else:
            return "low"
```

## Error Handling

### Be specific with exceptions
```python
# Good
try:
    data = load_data(filename)
except FileNotFoundError:
    print(f"File not found: {filename}")
    return None
except PermissionError:
    print(f"Permission denied: {filename}")
    return None

# Bad
try:
    data = load_data(filename)
except Exception:
    pass
```

### Use context managers
```python
# Good
with open('data.txt', 'r') as file:
    data = file.read()

# Bad
file = open('data.txt', 'r')
data = file.read()
file.close()
```

## Data Science/ML Specific

### NumPy/Pandas
```python
import numpy as np
import pandas as pd

# Use vectorized operations
# Good
data_normalized = (data - data.mean()) / data.std()

# Bad
normalized = []
for value in data:
    normalized.append((value - mean) / std)

# Pandas operations
df_filtered = df[df['age'] > 18]
df_grouped = df.groupby('category')['value'].mean()
```

### ML Pipeline Structure
```python
def load_data(filepath: str) -> pd.DataFrame:
    return pd.read_csv(filepath)

def preprocess_data(df: pd.DataFrame) -> pd.DataFrame:
    df_clean = df.dropna()
    return df_clean

def extract_features(df: pd.DataFrame) -> np.ndarray:
    return df[['feature1', 'feature2']].values

def train_model(X: np.ndarray, y: np.ndarray):
    # Training logic
    return model

# Main pipeline
def run_pipeline(data_path: str):
    data = load_data(data_path)
    data = preprocess_data(data)
    X = extract_features(data)
    y = data['target'].values
    model = train_model(X, y)
    return model
```

## Testing

### Use pytest
```python
def test_calculate_average():
    scores = [80, 90, 100]
    
    result = calculate_average(scores)
    
    assert result == 90

def test_calculate_average_empty_list():
    scores = []
    
    result = calculate_average(scores)
    
    assert result == 0
```

## What to Avoid

- Long functions (>30 lines)
- Deep nesting (>3 levels)
- Generic names (`data`, `temp`, `var`)
- Unnecessary comments
- Mutable default arguments
- Bare except clauses
- Global variables
- Complex one-liners

## Documentation

Keep minimal - use when essential:
- Module docstrings for file purpose
- Function docstrings for complex logic
- Type hints instead of parameter docs

```python
def process_user_data(user_id: int, email: str) -> dict:
    """Process user data and return normalized format."""
    return {
        'id': user_id,
        'email': email.lower(),
        'verified': validate_email(email)
    }
```

## Communication Style

When writing Python code:
- State what you're doing concisely
- Show code without excessive explanation
- Code should be self-explanatory
- Minimal markdown formatting
- Direct and to the point
