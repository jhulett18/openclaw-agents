# Agent Config

Agent-specific configuration data. Structure varies by agent type.

## Example: Scanner Config

```json
{
  "subreddits": ["<subreddit>"],
  "postsPerSubreddit": 50,
  "commentsPerPost": 15,
  "sort": "hot",
  "apifyActorId": "<actor-id>",
  "telegramChatId": "<chat-id>",
  "schedule": "0 9 * * *"
}
```

## Example: Client Config

```json
{
  "clients": [],
  "dashboardUrl": "http://localhost:3000",
  "databasePath": "<path-to-sqlite-db>"
}
```
