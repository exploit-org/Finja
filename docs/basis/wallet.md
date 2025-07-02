# Wallet Abstractions

This section documents the core wallet interfaces used to create, sign, and send transactions in Finja.

---

## `CryptoWallet`

```java
public interface CryptoWallet extends Sensitive {
    String publicAddress();

    OutgoingTransaction transaction(String to, Amount amount, int flags);
    OutgoingTransaction transaction(List<Recipient> recipients, int flags);

    default OutgoingTransaction transaction(String to, Amount amount) {
        return transaction(to, amount, 0);
    }

    default OutgoingTransaction transaction(List<Recipient> recipients) {
        return transaction(recipients, 0);
    }

    Value balance();
}
```

Represents a stateless, address-bound wallet capable of creating transactions and querying balances.

### Notes:
- Stateless: the wallet doesn't hold any mutable internal state
- Sensitive: private key data should be cleaned up explicitly if applicable
- Supports single- and multi-recipient transactions
- Uses `Amount` as input and returns `Value` from `balance()`

---

## `SmartContractWallet`

```java
public interface SmartContractWallet extends CryptoWallet {
    OutgoingTransaction transaction(String to, String contractAddress, Amount amount);
    OutgoingTransaction transaction(String contractAddress, List<Recipient> recipients);

    SmartTransactionService transactions();

    OutgoingTransaction execute(Class<SolidityContract> contract, String functionName, List<Type> args);
    ContractCall call(Class<SolidityContract> contract, String functionName, List<Type> args);

    Value balance(String contractAddress);
}
```

Extension of `CryptoWallet` with support for smart contracts.

### Additional capabilities:
- Create token-based transfers via contract address
- Call or execute smart contract methods (EVM or TRON)
- Token-specific balance lookup
- Uses ABI-aware helpers for function calls

> Smart wallets are only available for providers that support smart contracts (e.g., EVM, TRON).

---

## `OutgoingTransaction`

```java
public interface OutgoingTransaction {
    String dump();
    String computeTxid();
    Receipt send();
    long fee();
}
```

Represents a signed or signable transaction that can be inspected or sent.

- `dump()` — returns a raw hex or JSON representation (implementation-specific)
- `computeTxid()` — calculates the transaction ID before broadcasting
- `send()` — broadcasts the transaction and returns a `Receipt`
- `fee()` — estimated or actual transaction fee in smallest units

---

## `Receipt`

```java
public record Receipt(String txid, long fee) {}
```

Simple record returned after broadcasting a transaction.

- `txid`: the transaction hash
- `fee`: the network fee in smallest units (e.g., satoshis, wei)

---

## Summary

| Component             | Purpose                                                 |
|-----------------------|---------------------------------------------------------|
| `CryptoWallet`        | Stateless wallet capable of creating basic transactions |
| `SmartContractWallet` | Extends `CryptoWallet` with smart contract capabilities |
| `OutgoingTransaction` | Represents a prepared or signed transaction             |
| `Receipt`             | Result of broadcasting a transaction                    |