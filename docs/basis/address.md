# Address Model

This section describes the abstractions related to generating, storing, and validating blockchain addresses in Finja.

---

## `CommonAddress`

```java
public record CommonAddress(String publicAddress, ReadOnlyBuffer privateKey) implements Sensitive {
    @Override
    public void erase() {
        privateKey.close();
    }
}
```

A simple record that holds both a public address and a private key buffer.

- Implements `Sensitive`, so it can be wiped from memory via `.erase()`
- Used for storing or restoring wallet information from configuration or storage

---

## `AddressGenerator<P extends PointOps<P>>`

```java
public interface AddressGenerator<P extends PointOps<P>> {
    CommonAddress generate();
    CommonAddress generate(ECKeyPair<P> keyPair);
    Asset asset();
}
```

Responsible for generating new addresses from random keypairs or provided ones.

- `generate()` — creates a new random keypair and returns a `CommonAddress`
- `generate(keyPair)` — generates the address from the given keypair
- `asset()` — identifies the blockchain this generator belongs to (e.g., BTC, ETH)

> Each blockchain has its own implementation of `AddressGenerator`.

---

## `AddressValidator`

```java
public interface AddressValidator {
    boolean isValidAddress(String address);
}
```

Simple interface for validating addresses.

- Performs format and checksum validation
- Each coin has its own validator implementation
- Used in API requests and internal checks

---

## `Asset`

```java
public enum Asset {
    BTC,
    BCH,
    LTC,
    DASH,
    TRX,
    SOL,
    EVM
}
```

Enumeration of supported blockchains.

- Used throughout the framework to distinguish coin-specific logic
- Returned by `CoinProvider.asset()` and `AddressGenerator.asset()`

---

## Summary

| Component          | Purpose                                         |
|--------------------|-------------------------------------------------|
| `CommonAddress`    | Combines public address with private key buffer |
| `AddressGenerator` | Generates new blockchain addresses              |
| `AddressValidator` | Validates address strings                       |
| `Asset`            | Enum representing supported blockchain networks |