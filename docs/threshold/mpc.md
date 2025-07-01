## Enterprise MPC & Threshold Signatures

### What are Threshold Signatures?

Threshold signatures (TSS) are a cryptographic method that allows a group of participants to collectively produce a digital signature without ever reconstructing the full private key. Instead, each participant holds a **share** of the key, and a subset of them (threshold `t` out of total `n`) can jointly sign messages.

This approach offers significant security improvements over traditional private key storage:

- **Keys are never fully reconstructed**, even during signing.
- **Compromising a single machine is not enough** to leak the private key.
- Perfectly fits **custodial wallets**, **multi-party systems**, and **high-risk operations** (e.g., large withdrawals, treasury control).

### TKeeper Integration

Finja supports integration with [TKeeper](https://github.com/exploit-org/tkeeper) out of box, a production-ready TSS service built on top of `tss4j`.

TKeeper supports both:
- **Distributed key generation** (no trusted dealer)
- **Threshold signing** with:
    - **GG20 (ECDSA)** for Bitcoin, Ethereum, and other `secp256k1` networks
    - **FROST (Schnorr)** for `Ed25519`-based networks like Solana

To use TKeeper in Finja, just replace your `ECKeyManager` with one of the provided threshold managers. Configuration is minimal and designed for drop-in use.

For more details and API reference, see the official [TKeeper GitHub repository](https://github.com/exploit-org/tkeeper).

---

## Integration with Finja

Finja exposes drop-in support for threshold key management through the following classes:

- `ThresholdEd25519KeyManager` – supports Ed25519 + FROST (Schnorr signatures)
- `ThresholdSecp256k1KeyManager` – supports secp256k1 + GG20 (ECDSA signatures)

Both are compatible with Finja’s `ECKeyManager` interface and can be used anywhere in the system where a key manager is required. These classes rely on the `TSecurityClient`, which handles communication with one or more MPC nodes.

---

## What You Need to Provide

To instantiate a threshold key manager, you need:

- The **key ID** registered in your MPC system
- An instance of **TSecurityClient**, configured with:
    - Any of the Nodes URL (or balancer)
    - Authorization provider (e.g. `Auth0Authenticator` for Auth0-based flows). You can always extend `Authenticator` to implement custom authentication logic.

Example initialization:

```java
var client = new TSecurityClient("https://your-node", authenticator);
var keyManager = new ThresholdEd25519KeyManager("my-key-id", client);
```

Once configured, the key manager can be passed to any Finja wallet by passing key manager to `createWallet` method in any of providers.

---

## TSecurityClient

The `TSecurityClient` acts as the bridge between Finja and your TKeeper node.

### Responsibilities:

- Submits signing requests via MPC (`sign`)
- Fetches the public key (`publicKey`)
- Verifies remote signatures (`verify`)
- Generates new key shares (`generate`) — optional, for DKG flows

### Typical Methods:

- `ParsedTSSResult sign(Sign request)`
- `PublicKeyDto publicKey(String keyId)`
- `VerifyResult verify(Verify request)`
- `void generate(String keyId, CurveName curve, boolean overwrite)`

It supports any `Authenticator` implementation for securing the connection to your MPC node. A built-in `Auth0Authenticator` is available for services using Auth0.

---