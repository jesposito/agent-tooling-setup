# Mem0 - Universal Memory Layer Guide

**Persistent memory across AI agent sessions**

## What is Mem0?

Mem0 provides a memory layer for AI agents that persists across sessions. Instead of starting fresh every time, your AI agents can:
- Remember previous conversations
- Build up knowledge over time
- Maintain context across sessions
- Share knowledge between different agents

## Quick Start

### 1. Get API Key

Sign up at [https://app.mem0.ai](https://app.mem0.ai) to get your API key.

### 2. Set Environment Variable

```bash
# Add to your shell config (~/.bashrc or ~/.zshrc)
export MEM0_API_KEY='m0-...'

# Or create .env file (recommended)
echo "MEM0_API_KEY=m0-..." >> .env
```

### 3. Test Connection

```bash
python3 test_mem0_platform.py
```

## Basic Usage

### Python Example

```python
from mem0 import MemoryClient
import os

# Initialize client
client = MemoryClient(api_key=os.getenv('MEM0_API_KEY'))

# User/Agent ID (unique identifier for this context)
user_id = "my-project"

# Add memories
client.add(
    messages=[{"role": "user", "content": "I'm working on the authentication feature"}],
    user_id=user_id
)

# Search memories
results = client.search(
    query="What am I working on?",
    user_id=user_id,
    filters={"user_id": user_id},
    limit=5
)

for memory in results['results']:
    print(memory['memory'])
```

## Use Cases for Agent-Tooling-Setup

### 1. Track Project Progress

```python
# Add what you're working on
client.add(
    messages=[{
        "role": "user",
        "content": "Completed the AI tools integration. Added docs for gptme, aider, opencommit."
    }],
    user_id="agent-tooling-setup"
)

# Later, ask what was done
results = client.search(
    query="What features were recently completed?",
    user_id="agent-tooling-setup",
    filters={"user_id": "agent-tooling-setup"}
)
```

### 2. Remember Known Issues

```python
# Document a bug or limitation
client.add(
    messages=[{
        "role": "user",
        "content": "opencommit requires OPENAI_API_KEY. Fails with 400 if not set."
    }],
    user_id="agent-tooling-setup"
)

# Recall later
results = client.search(
    query="What's the issue with opencommit?",
    user_id="agent-tooling-setup",
    filters={"user_id": "agent-tooling-setup"}
)
```

### 3. Share Knowledge Between Agents

```python
# One agent adds knowledge
client.add(
    messages=[{
        "role": "user",
        "content": "The installer checks for gptme, aider, and opencommit in PATH."
    }],
    user_id="team-shared"
)

# Another agent can query it
results = client.search(
    query="How does the installer detect AI tools?",
    user_id="team-shared",
    filters={"user_id": "team-shared"}
)
```

## Integration with Agent Workflow

### Start of Session

```python
from mem0 import MemoryClient
import os

client = MemoryClient(api_key=os.getenv('MEM0_API_KEY'))
user_id = "agent-tooling-setup"

# Recall what you were working on
results = client.search(
    query="What was I working on last?",
    user_id=user_id,
    filters={"user_id": user_id},
    limit=3
)

print("Last session context:")
for mem in results['results']:
    print(f"  - {mem['memory']}")
```

### During Work

```python
# Add key decisions or learnings
client.add(
    messages=[{
        "role": "user",
        "content": "Decided to use Mem0 Platform instead of local Qdrant for simplicity."
    }],
    user_id=user_id
)
```

### End of Session

```python
# Store what you accomplished
client.add(
    messages=[{
        "role": "user",
        "content": "Successfully integrated mem0. Created test script and usage guide."
    }],
    user_id=user_id
)
```

## Advanced Features

### Filtering

```python
# Search with metadata filters
results = client.search(
    query="AI tools",
    user_id=user_id,
    filters={
        "user_id": user_id,
        # Add custom filters here
    },
    limit=5
)
```

### Get All Memories

```python
# Retrieve all stored memories
all_memories = client.get_all(
    user_id=user_id,
    filters={"user_id": user_id}
)

for mem in all_memories['results']:
    print(f"[{mem['id']}] {mem['memory']}")
```

### Delete Memories

```python
# Delete specific memory by ID
client.delete(memory_id="uuid-here")

# Or delete all memories for a user
client.delete_all(user_id=user_id)
```

## Best Practices

### 1. Choose Good User IDs

- **Per-project**: `"agent-tooling-setup"`
- **Per-user**: `"claude-for-user-123"`
- **Shared team**: `"team-shared-context"`
- **Per-feature**: `"auth-feature-work"`

### 2. Add Context, Not Raw Data

❌ Bad:
```python
client.add(messages=[{"role": "user", "content": "commit abc123"}])
```

✅ Good:
```python
client.add(messages=[{
    "role": "user",
    "content": "Fixed authentication bug in commit abc123. Issue was token expiration handling."
}])
```

### 3. Use Descriptive Queries

❌ Vague:
```python
results = client.search(query="stuff", user_id=user_id, filters={"user_id": user_id})
```

✅ Specific:
```python
results = client.search(
    query="What authentication issues were fixed?",
    user_id=user_id,
    filters={"user_id": user_id}
)
```

### 4. Regular Cleanup

```python
# Periodically review and clean old/irrelevant memories
all_memories = client.get_all(user_id=user_id, filters={"user_id": user_id})

# Delete outdated ones
for mem in all_memories['results']:
    if is_outdated(mem):  # Your logic
        client.delete(memory_id=mem['id'])
```

## Cost Considerations

Mem0 Platform pricing (as of 2025):
- **Free tier**: Generous limits for development
- **Paid tiers**: Based on storage and API calls

### Optimize Costs

1. **Consolidate memories**: Don't add duplicate info
2. **Use filters**: Narrow searches to reduce API calls
3. **Batch operations**: Add multiple memories at once when possible
4. **Clean old data**: Delete outdated memories

## Integration with Other Tools

### With Empirica (Epistemic Tracking)

```python
# At start of session
empirica_session = empirica.session_create(ai_id="claude")

# Load context from mem0
mem0_context = client.search(
    query="Recent project decisions and learnings",
    user_id="project-id",
    filters={"user_id": "project-id"}
)

# At end of session
# Save empirica findings to mem0
client.add(
    messages=[{
        "role": "user",
        "content": f"Session {empirica_session['id']}: Learned that mem0 works great with hosted platform."
    }],
    user_id="project-id"
)
```

### With Beads (Task Tracking)

```python
# Remember task context
task_id = "agent-tooling-setup-abc"
task_info = bd.show(task_id)

client.add(
    messages=[{
        "role": "user",
        "content": f"Working on task {task_id}: {task_info['title']}. Current status: in_progress."
    }],
    user_id="agent-tooling-setup"
)

# Later, recall what tasks you were on
results = client.search(
    query="What tasks am I working on?",
    user_id="agent-tooling-setup",
    filters={"user_id": "agent-tooling-setup"}
)
```

## Troubleshooting

### API Key Not Working

```bash
# Verify it's set
echo $MEM0_API_KEY

# Check it's not empty
if [ -z "$MEM0_API_KEY" ]; then echo "NOT SET"; fi

# Test connection
python3 test_mem0_platform.py
```

### 400 Bad Request Errors

The Mem0 v2 API requires `filters` in most operations:

```python
# ❌ This will fail
results = client.search(query="...", user_id="...")

# ✅ This works
results = client.search(
    query="...",
    user_id="...",
    filters={"user_id": "..."}  # Required!
)
```

### No Results from Search

1. **Verify memories exist**:
   ```python
   all_mems = client.get_all(user_id="...", filters={"user_id": "..."})
   print(f"Total memories: {len(all_mems['results'])}")
   ```

2. **Try broader query**:
   ```python
   # Instead of "What's the auth bug?"
   # Try "authentication" or "auth issues"
   ```

3. **Check user_id**:
   ```python
   # Make sure you're using the same user_id
   # that you used when adding memories
   ```

## Example Script

See `test_mem0_platform.py` for a complete working example that:
- Connects to Mem0 Platform
- Adds multiple memories
- Searches with different queries
- Retrieves all memories
- Demonstrates best practices

## Learn More

- **Mem0 Docs**: https://docs.mem0.ai
- **API Reference**: https://docs.mem0.ai/api-reference
- **Platform Dashboard**: https://app.mem0.ai

---

**Next Steps:**
1. Get your API key from https://app.mem0.ai
2. Run `python3 test_mem0_platform.py` to test
3. Start adding memories to your agent workflows!
