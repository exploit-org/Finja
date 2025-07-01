# Coin Providers

A `CoinProvider` is the central access point for working with a specific blockchain (e.g., BTC, ETH, TRX) in Finja.  
It encapsulates the logic for creating wallets, handling transactions, validating addresses, checking balances, and listening to on-chain activity.

Each supported blockchain has its own implementation of this interface, but exposes a common set of methods to ensure unified behavior across coins.

---

## Responsibilities

A `CoinProvider` exposes the following capabilities:

- Creating stateless wallets from keys, addresses, or combined structures
- Validating and generating blockchain addresses
- Fetching balances for wallets and contracts
- Streaming live transaction events or restoring history
- Performing amount conversions (e.g., BTC ⇄ satoshi)

---

## Wallet Creation

`CoinProvider` supports multiple ways of creating a `CryptoWallet`:

- From a public address and `ECKeyManager` (useful when signing is external)
- From a `ReadOnlyBuffer` or raw private key
- From a `CommonAddress` structure (bundled key + address)

The wallet itself is stateless and provides methods to create and send transactions.

---

## Event Subscriptions

Each provider can return a `TransactionListener` that listens to live on-chain events.

- Events are scoped using an `EventScope`
- You can restore historical events from a given timestamp
- Used to detect incoming or outgoing transactions, token transfers, etc.

---

## Address Operations

A `CoinProvider` includes:

- An `AddressGenerator`, which creates new addresses (random or from key)
- An `AddressValidator`, which checks address format and checksums

These ensure proper handling of address logic without relying on external libraries.

---

## Balances

The balance system depends on the blockchain's nature:

- For coins like BTC or SOL, the provider returns a `CoinBalanceService`
- For smart contract platforms (EVM, TRON), a `SmartCoinBalanceService` is returned instead, allowing token-specific balance lookups

---

## Value Conversion

Amounts in Finja are typically stored in native units (`BigInteger`) but displayed to users in decimal form (`BigDecimal`).

Each provider supplies a `ValueConverter`:

- `toUnit(BigDecimal)` — converts human input to native units
- `toHuman(BigInteger)` — formats native units for display

Smart contract platforms may use a `SmartValueConverter`, which performs contract-specific conversions.

---

## Curve Declaration

Every provider exposes its supported elliptic curve via `curve()`:

- `SECP256K1` — used by Bitcoin-like chains
- `ED25519` — used by Solana, some Cosmos-based chains, etc.

This helps in generating compatible key pairs and signing logic.

---

## Summary

| Feature           | Description                                                 |
|-------------------|-------------------------------------------------------------|
| Wallet creation   | Flexible methods for creating wallets from various sources  |
| Address handling  | Generation and validation of blockchain addresses           |
| Balances          | Native or contract-based balance services                   |
| Event listening   | Live and historical on-chain activity                       |
| Amount conversion | From user-friendly decimals to native blockchain units      |
| Curve support     | Indicates which cryptographic curve is used by the provider |

---

Next:
→ [Events](./event.md)  
→ [Values](./value.md)