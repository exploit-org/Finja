# Bitcoin Family Providers

All Bitcoin-derived coins in Finja implement the shared `BitcoinProtocolProvider` interface.  
This gives them a common structure for:

- UTXO management
- Fee estimation
- Transaction signing
- Address generation
- Script handling
- Event subscription

This includes:

- **Bitcoin (BTC)**
- **Litecoin (LTC)**
- **Bitcoin Cash (BCH)**
- **Dash (DASH)**

---

## Features Shared Across All

| Feature                 | Description                                             |
|-------------------------|---------------------------------------------------------|
| UTXO model              | All wallets operate with explicit unspent outputs       |
| Fee estimation          | Uses `BitcoinFeeProvider` (e.g., Core, fixed, dynamic)  |
| Address generator       | Type- and network-aware (`legacy`, `segwit`, etc.)      |
| Explorer integration    | via `BitcoinExplorer` (e.g., BlockBook, RPC)           |
| Event support           | via `PollingListener` + `EventFetcher`                 |
| Script resolver         | `getScript(address)` returns the appropriate script     |
| Curve                   | `secp256k1` for all networks                            |

---

## Big Wallets: `BigBitcoinProtocolWallet`

When you need to move funds from multiple wallets (i.e., multiple addresses / keys), you can create a single "big wallet" that aggregates them.

### When to use?

- Consolidating UTXOs
- Sweeping all funds from multiple addresses into one
- Building a single transaction with inputs from multiple keys

### Example:

```java
List<BitcoinProtocolWallet> wallets = ...;

BigBitcoinProtocolWallet bigWallet = provider.createBigWallet(wallets);

OutgoingTransaction tx = bigWallet.transaction(
    List.of(new Recipient("bc1q...", new Amount("0.1"))),
    "change-address"
);
```

The transaction will:

- Collect inputs from all underlying wallets
- Sign each input with the correct key manager
- Estimate fee based on total size
- Route change to the provided address

> The default SIGHASH is `SIGHASH_ALL`, but you can override it per call.

---

## Coin-Specific Differences

| Asset        | Taproot | CashAddr | ForkID    | Address Types Supported            |
|--------------|---------|----------|-----------|------------------------------------|
| **Bitcoin**  | ✅ Yes  | ❌ No    | ❌ No     | `LEGACY`, `SEGWIT`, `TAPROOT`      |
| **Litecoin** | ✅ Yes  | ❌ No    | ❌ No     | `LEGACY`, `SEGWIT`, `TAPROOT`      |
| **Bitcoin Cash** | ❌ No  | ✅ Yes   | ✅ Yes    | `LEGACY`, `CASH_ADDR`              |
| **Dash**     | ❌ No  | ❌ No    | ❌ No     | `LEGACY` only                      |

---

## Explorers and Fee Providers

The following infrastructure is reusable across all Bitcoin-like coins:

### Explorer

- [`BitcoinBlockBookExplorer`](../basis/webdata.md)  
  Indexes UTXOs, fetches transactions, supports event backfill

### Fee Provider

- [`BitcoinCoreFeeProvider`](../basis/webdata.md)  
  Queries `estimatesmartfee` from Core node, supports profiles: `SLOW`, `NORMAL`, `FAST`, `NO_PRIORITY`

> Custom implementations can also be plugged via the provider builder.

---

## Address Handling

Each provider can construct its own `BitcoinAddressGenerator` based on:

- `NetworkType` → `MAIN` or `TEST`
- `AddressType` → `LEGACY`, `SEGWIT`, `TAPROOT`, `CASH_ADDR`

For example:

```java
provider.generator(NetworkType.MAIN, AddressType.SEGWIT);
```

> Some networks (like Dash) only support `LEGACY`.

---

## Listener Support

Each provider creates a `TransactionListener` via a `ListenerProvider`, commonly:

- `BitcoinPollingListenerProvider` — polls explorer on interval
- Supports double-spend detection, event restore, and caching

```java
TransactionListener listener = provider.listener(eventScope);
listener.listen("my-addr");
```

---

## Summary

Bitcoin-family providers share the same architecture and can be extended consistently.  
Finja unifies their handling through `BitcoinProtocolProvider` and separates coin-specific logic via metadata and configuration.

This makes it easy to integrate and scale across different forks without rewriting core logic.