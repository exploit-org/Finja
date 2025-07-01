# HD Wallets & Key Derivation

Finja provides a secure and flexible HD (Hierarchical Deterministic) wallet infrastructure
supporting multiple curves (e.g., SECP256K1, ED25519), with clean separation of concerns
between seed, key derivation, and address generation.

---

## Quick Overview

You start with a mnemonic phrase:

```java
var mnemonic = Mnemonics.generateMnemonic(Mnemonics.generateEntropy(256));
var seed = Seeds.create(mnemonic, "optional-passphrase".toCharArray());
var wallet = new HDWallet(seed);
```

Then derive a key:

```java
var key = wallet.derive(SupportedCurve.SECP256K1, "m/44'/60'/0'/0/0");
```

---

## Internals

- `XKeyPair` – Abstract base for keypairs (private/public) with curve awareness
- `Seeds` – Handles PBKDF2 derivation from mnemonic using `"mnemonic"` as salt prefix (BIP-39 standard)
- `Mnemonics` – Converts entropy to mnemonic using BIP-39 with SHA-256 checksum
- `HDKeyService` – Responsible for deriving child keys from a given keypair and index
- `MasterKeys` – Creates master keys for each supported curve from the seed

Each `XKeyPair` subclass knows how to derive hardened/non-hardened child keys, reconstruct new public keys, and manage internal metadata like fingerprint, depth, and chain code.

---

## Curve-specific Notes

- `SECP256K1` allows both hardened and non-hardened derivation.
- `ED25519` (e.g., for Solana) **only supports hardened derivation**.
  - Paths like `m/44'/501'/0'/0'` are typical.
  - Non-hardened derivation will be automatically hardened internally.

---

## Address Generation

Once a key is derived, it can be used with the appropriate generator:

```java
var ecKeyPair = (Secp256k1KeyPair) derived.asECKeyPair();
var address = provider.generator().generate(ecKeyPair);
```

Each coin provider in Finja (e.g., BitcoinProvider, EvmProvider) contains a compatible `AddressGenerator` that accepts any ECKeyPair, depending on the network.

---

## Secure by Default

- `Seed`, `Mnemonic`, `XPrivateKey`, `XKeyPair`, etc. implement `Sensitive` and support secure zeroization.
- Mnemonic and passphrase are zeroed immediately after seed generation.

---

## Custom Derivation Use Case

To derive with a custom chain code:

```java
wallet.derive(SupportedCurve.SECP256K1, "m/44'/60'/0'/0/0", customChainCode);
```

By default, chain code is set to zero, but this allows integration with schemes like hardened domain-specific derivations or curve extensions.

---

This HD wallet infrastructure is foundational for multi-chain key derivation and secure signing in Finja.
