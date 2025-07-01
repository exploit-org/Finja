# Basis

This section documents the core building blocks of Finja — the unified interface layer for interacting with multiple blockchains in a modular and abstracted way.

All higher-level features (wallets, smart contracts, providers) are built on top of the foundation described here.

---

## Architecture Overview

Finja is structured around a set of unified abstractions. The central concept is the `CoinProvider` interface, which exposes all required functionality for interacting with a blockchain.

Each `CoinProvider` implementation exposes:

## AddressGenerator

Handles address generation, typically using key pairs or HD wallet derivation.

- Produces `CommonAddress` — a unified representation of an address.
- May internally rely on `ECKeyPair` or `XKeyPair` for material.

## CryptoWallet

Used to create and sign outgoing transactions.

- Returns `OutgoingTx`, an abstract representation of a signed transaction.
- Internally uses `ECKeyManager` or threshold-based key managers.
- For EVM chains, includes support for smart contract calls.

## CoinBalanceService

Fetches balances or UTXO states depending on the underlying model.

- May fetch raw values or cooperate with `ValueConverter`.

## ValueConverter

Responsible for converting between minimal units and human-readable amounts (e.g., satoshis to BTC).

- Produces `Value` or `Amount`.

## Key Material Flow

All key-related functionality is managed by:

- `ECKeyPair` or `XKeyPair` (HD).
- `ECKeyManager`, which handles storage, derivation, and signing.
- `ECFlag` provides metadata such as key type or derivation scheme.
- `ReadOnlyBuffer` is used to hold key material securely in memory.

## Address Validation

Each chain provides a dedicated `AddressValidator` implementation.

## Transaction Listening

Finja supports two kinds of listeners:

### Polling-based

- Implemented via `PollingTxListener` and chain-specific classes like `EvmPollingListenerProvider`, `TronPollingListenerProvider`, etc.
- Periodically polls nodes for activity using `EventFetcher`.

### Push-based

- Uses `TransactionListener` implementations such as `EthTransactionListener`.
- Works over WebSockets where supported.

Note: All listeners are registered inside `EventScope` and may be configured via `SubscriptionConfig`.

## WebData

All node URLs, authorization strategies, and optional rate limiting are provided through the `WebData` class.

- Contains `httpUrl`, `wsUrl`, and `Authorization`.
- Internally uses Jettyx for HTTP and WebSocket clients.
- `bucket` field integrates with Bucket4j for rate limiting.

For authorization configuration details, refer to the Jettyx repository:

https://github.com/exploit-org/Jettyx

## HD Wallet Support

Finja supports HD wallets through the `HDWallet` class.

- Seeds are generated from mnemonic phrases via `Mnemonics` and `Seeds`.
- Paths like `m/44'/60'/0'/0/0` are supported.
- Derivation is curve-aware (`Secp256k1`, `Ed25519`).
- Returned keys implement `XKeyPair`. It can be used with `AddressGen` to produce addresses.


## What's in This Section

| File                       | Description                                                              |
|----------------------------|--------------------------------------------------------------------------|
| [Keys](./keys.md)          | Secure memory allocation, key pairs, signing, and supported curves       |
| [Addresses](./address.md)  | Address generation, validation, and supported assets                     |
| [Wallets](./wallet.md)     | Stateless wallets and transaction handling                               |
| [Providers](./provider.md) | Core blockchain providers and their capabilities                         |
| [Events](./event.md)       | Unified event model and real-time transaction tracking                   |
| [Values](./value.md)       | Decimal vs. unit values and how conversion works across chains           |
| [WebData](./webdata.md)    | Configuration for blockchain nodes, APIs, and rate limiting              |

Each of these layers is extensible and coin-agnostic, making it easy to support additional blockchains with minimal effort.

---