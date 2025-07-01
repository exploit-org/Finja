# WebData

The `WebData` class in Finja is a core utility for configuring access to blockchain nodes and APIs. It encapsulates:

- `httpUrl`: the base URL of the node (e.g., RPC endpoint)
- `wsUrl`: optional WebSocket endpoint for subscriptions
- `auth`: any authorization scheme (Bearer, Basic, Header, Query, or `NoAuth`)
- `bucket`: optional [Bucket4j](https://github.com/bucket4j/bucket4j) rate limiter integration for controlling request throughput

Internally, `WebData` is used to pass all required info to  [Jettyx](https://github.com/exploit-org/Jettyx) interfaces, a modern HTTP client with support for multiple versions, fluent request interfaces, async calls, and built-in serialization via Jackson.

## Authorization Support

Out of the box, `WebData` supports:

- `NoAuth`
- `BearerAuth`
- `BasicAuth`
- `HeaderAuth`
- `QueryAuth`

These are directly passed to Jettyx. You can always extend `Authorization` interface from Jettyx and define your own authorization scheme if needed.

---

## Notes

- `WebData` is used throughout Finja to define blockchain node endpoints and external APIs.
- You can customize rate limiting using any `Bucket` from Bucket4j.
- WebSocket URLs (`wsUrl`) are used for event clients where supported.
- For detailed HTTP behavior or authorization setups, refer to the [Jettyx GitHub repository](https://github.com/exploit-org/Jettyx)