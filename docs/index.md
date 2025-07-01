# Finja

**Finja** is a modular cryptographic framework for interacting with multiple cryptocurrency networks in a unified, extensible, and production-ready way.

It provides consistent abstractions for:

- Address generation and validation
- Transaction creation and sending
- Balance tracking
- HD wallet derivation (BIP32/BIP44/SLIP-0010)
- Threshold signing (MPC via TKeeper)
- Event listening via WebSocket or polling

Finja is built for high-performance financial systems, custody services, and infrastructure projects.

---

## Version

`1.0.0-BETA`

---

## Installation

Finja consists of a core module and multiple pluggable providers.

### Required

```groovy
implementation 'org.exploit:finja:1.0.0-BETA'
```

### Supported Providers

Add only what you use:

```groovy
// Bitcoin-based providers
implementation 'org.exploit:bitcoin:1.0.0-BETA'
implementation 'org.exploit:litecoin:1.0.0-BETA'
implementation 'org.exploit:dash:1.0.0-BETA'
implementation 'org.exploit:bitcoincash:1.0.0-BETA'

// EVM-compatible networks
implementation 'org.exploit:evm:1.0.0-BETA'

// TRON support
implementation 'org.exploit:tron:1.0.0-BETA'

// Solana support
implementation 'org.exploit:solana:1.0.0-BETA'
```

### HD Wallet Support

```groovy
implementation 'org.exploit:hdwallet:1.0.0-BETA'
```

### BlockBook Indexer Support

```groovy
// Base BlockBook integration
implementation 'org.exploit:blockbook:1.0.0-BETA'

// Bitcoin-compatible BlockBook provider
implementation 'org.exploit:blockbook-bitcoin:1.0.0-BETA'
```
## Native Dependencies

Finja is security-oriented and relies on native cryptographic libraries for constant-time operations:

- `libsecp256k1` for Secp256k1 curve operations
- `libsodium` for Ed25519 operations
- `libgmp` for large integer math and constant-time ^sec operations

Add the appropriate native dependency for your platform:

```groovy
// macOS (Apple Silicon)
runtimeOnly 'org.exploit:tss4j-natives-macos-aarch64:1.0.0'

// Linux (x64)
runtimeOnly 'org.exploit:tss4j-natives-linux-amd64:1.0.0'

// Windows (x64)
runtimeOnly 'org.exploit:tss4j-natives-windows-x64:1.0.0'
```

___

## License

Finja is fully open-source. We believe in open innovation and developer freedom — all components are available under permissive licenses:

- **Apache 2.0**
- **BSD-2-Clause**
- **MIT**

Use, modify, and integrate freely — no strings attached.