# Keys & Buffers

This section documents the core abstractions for working with private/public keys, elliptic curve operations, secure memory buffers, and signature flags.

All cryptographic operations in Finja are curve-agnostic and implemented using generic interfaces with curve-specific implementations (e.g., `secp256k1`, `ed25519`).

---

## `ReadOnlyBuffer`

A secure, read-only wrapper around byte arrays.  
It is used to safely store private keys and sensitive data in unswappable locked memory.

- Prevents accidental mutation
- Implements `AutoCloseable` to explicitly erase contents (`.close()` wipes memory)
- Used across the entire framework wherever private key bytes are required

**Typical usage:**

```java
try (var buf = new ReadOnlyBuffer(privateKeyBytes)) {
    // use buf
}
```

---

## `ECKeyPair<P extends PointOps<P>>`

Represents a standard elliptic curve key pair.

```java
public interface ECKeyPair<P extends PointOps<P>> extends Sensitive {
    ECPrivateKey privateKey();
    ECPublicKey<P> publicKey();
}
```

This interface provides access to:

- `privateKey()` — returns the low-level private key object
- `publicKey()` — returns the matching public key object

> Implementations are provided for `secp256k1` and `ed25519`, and depend on the selected curve.

---

## `ECKeyManager<P extends PointOps<P>>`

Wraps the signing logic for a private key.  
Useful when the key is stored in a secure module or when signing should be abstracted.

```java
public interface ECKeyManager<P extends PointOps<P>> extends Sensitive {
    Signature sign(byte[] data, int flags);
    ECPublicKey<P> getPublicKey();
}
```

### Why use a `KeyManager`?

- Allows you to separate wallet logic from signing
- Can be backed by:
    - Software key (in-memory)
    - HSM
    - Threshold signer (e.g., via TKeeper)
- Enables signing with flags (`ECFlag`), such as Taproot Schnorr support

---

## Built-in Implementations

### `Ed25519KeyManager`

Uses libsodium-backed Ed25519 private keys.

- Default signing algorithm: EdDSA
- Uses the `Ed25519Provider` for all math operations

```java
new Ed25519KeyManager(privateKeyBytes);
```

---

### `Secp256k1KeyManager`

Supports both ECDSA and Schnorr over `secp256k1`, backed by libsecp256k1.

- If `ECFlag.USE_TAPROOT_SCHNORR` is set, signs with Taproot-compatible Schnorr
- Otherwise uses deterministic ECDSA (RFC6979)

```java
new Secp256k1KeyManager(privateKeyBytes);
```

---

## `SupportedCurve`

Defines the supported elliptic curves within the Finja framework.

```java
public enum SupportedCurve {
    SECP256K1("Bitcoin seed"),
    ED25519("ed25519 seed");
}
```

Used by `CoinProvider.curve()` to indicate which curve the coin uses.

---

## `ECFlag`

Defines signature behavior modifiers for key managers.

```java
public final class ECFlag {
    public static final int USE_TAPROOT_SCHNORR = 1;
}
```

- `USE_TAPROOT_SCHNORR`: instructs `Secp256k1KeyManager` to use BIP340-compatible Schnorr signing (Bitcoin Taproot)

---

## Summary

| Component        | Purpose                                       |
|------------------|-----------------------------------------------|
| `ReadOnlyBuffer` | Secure memory wrapper for private keys        |
| `ECKeyPair`      | Represents a private/public key pair          |
| `ECKeyManager`   | Abstracts signing logic                       |
| `SupportedCurve` | Declares supported elliptic curves            |
| `ECFlag`         | Signature flags (e.g., for Schnorr / Taproot) |