# Transaction Events

This section describes how Finja tracks and processes blockchain activity in real time or retrospectively using a unified event system.

The event model is designed to work across different blockchains (EVM, Bitcoin, Solana, etc.) without exposing coin-specific internals.

---

## Overview

Finja separates **live event listening** and **event fetching**:

- **`TransactionListener`**: used for real-time monitoring of wallet addresses
- **`EventFetcher`**: used to query historical transactions (e.g., from a given timestamp)

All events are delivered in the form of a standard data structure: `TxnEvent`.

---

## Powered by Signalix

Under the hood, Finja’s event system is backed by [Signalix](https://github.com/exploit-org/Signalix) — a lightweight event bus designed for  systems.

To receive events like `TxnEvent`, you register your handler into the local `EventScope` passed to the provider.

### Example:

```java
import org.exploit.signalix.annotation.EventHandler;
import org.exploit.signalix.marker.Listener;
import org.exploit.finja.core.event.TxnEvent;
import org.exploit.finja.core.event.TxnCancelledEvent;
import org.exploit.finja.core.event.TxType;

public class WalletListener implements Listener {

    @EventHandler
    public void onTxn(TxnEvent event) {
        if (event.type() == TxType.RECEIVE) {
            System.out.println("Received " + event.value().amount() + " to " + event.address());
        }
    }

    @EventHandler
    public void onCancelled(TxnCancelledEvent cancelled) {
        var original = cancelled.getLatestEvent();
        System.out.println("Transaction " + original.txid() + " was cancelled or replaced");
    }
}
```

Then register it via the event scope:

```java
EventScope scope = new EventScope();
scope.registerListener(new WalletListener());

TransactionListener listener = provider.listener(scope);
listener.listen("your-wallet-address");
```

---

## `TransactionListener`

This component listens for new blockchain events related to a specific address. It supports:

- Listening to an address starting from a given timestamp
- Removing listeners
- Optional restore mode (historical replay)
- `start()` hook — used to bootstrap backend listeners if required

Each listener is tied to an `Asset`, so it's aware of which coin it belongs to.

> Use this when you need to react to deposits, withdrawals, or token transfers in real time.

---

## `EventFetcher`

This component provides access to past events:

- `events(address, startTimestamp)` returns a stream of historical `TxnEvent` objects
- Can be used for rebuilding state, syncing missed transactions, or audit purposes

Used internally by the listener in restore mode or manually if needed.

---

## `TxnEvent`

This is the core event object emitted by all providers.

### Fields:

- `type`: `SEND` or `RECEIVE`
- `asset`: coin or token associated with the transaction
- `txid`: transaction hash
- `address`: the affected address
- `value`: transferred value (in units + human)
- `confirmations`: number of confirmations
- `timestamp`: time the transaction was observed
- `smartContract`: (optional) address of the contract, if token-based
- `memo`: user-defined metadata (e.g., label, reason)
- `meta`: arbitrary map for extra fields (e.g., `chainId`)

### Helpers:

- `confirmed()` — true if at least one confirmation

> This structure is intentionally generic to support coins, tokens, and smart contracts.

---

## `TxnCancelledEvent`

An optional secondary event that may be emitted when a transaction gets dropped or double-spent

Contains a reference to the original `TxnEvent` via `latestEvent`.

---

## `TxType`

Enum used in all events:

- `SEND` — outgoing transaction
- `RECEIVE` — incoming transaction

---

## Summary

| Component             | Purpose                                                |
|-----------------------|--------------------------------------------------------|
| `TransactionListener` | Subscribes to real-time on-chain events                |
| `EventFetcher`        | Queries historical transaction events                  |
| `TxnEvent`            | Generic cross-chain event representation               |
| `TxnCancelledEvent`   | Signals dropped or overwritten transactions            |
| `TxType`              | Type indicator: SEND or RECEIVE                        |
| `Signalix`            | Event system used internally (scoped via `EventScope`) |