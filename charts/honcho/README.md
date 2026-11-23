# Honcho

Advanced memory system for AI agents.

## GUI

The GUI is supported with the open source project [OpenConcho](https://github.com/offendingcommit/openconcho).

Note that because OpenConcho uses a client-side connection, the web browser needs to be able to see the Honcho URL. Thus, use the external URL and not the interal one, which may require deploying with a dummy Honcho URL value and then edit it in OpenConcho settings.

## Hermes agent config

Drop to the console when in the web app using ```Ctrl + ` ```, then configure the memory plugin:

```bash
hermes plugins install honcho
hermes memory setup honcho 
```
`

curl -s -X POST "http://localhost:32248/v3/workspaces/hermes/peers" \
  -H "Authorization: Bearer ***" \
  -H "Content-Type: application/json" \
  -d '{"id": "user"}' | python3 -m json.tool
curl -s -X POST "http://localhost:32248/v3/workspaces/hermes/peers" \
  -H "Authorization: Bearer ***" \
  -H "Content-Type: application/json" \
  -d '{"id": "hermie"}' | python3 -m json.tool

curl -s -X POST "http://localhost:32248/v3/workspaces/hermes/sessions" \
  -H "Authorization: Bearer ***" \
  -H "Content-Type: application/json" \
  -d '{"id": "hermes-default"}' | python3 -m json.tool

curl -X 'POST' \
  'http://localhost:32248/v3/workspaces/hermes/sessions/hermes-default/messages' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -d '{
  "messages": [
    {
      "content": "my favourite theme is dark mode.",
      "peer_id": "user",
      "configuration": {
        "reasoning": {
          "enabled": true
        }
      },
      "created_at": "2026-11-11T10:09:20.698Z"
    }
  ]
}' | python3 -m json.tool
