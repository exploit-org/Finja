# SolanaProvider

`SolanaProvider` is the `CoinProvider<Ed25519PointOps>` implementation for the **Solana** blockchain.  
It enables native transfers, fee-included splits, and basic polling-based event listening.

> ⚠️ This provider is currently **BETA** – API may change, and only native SOL transfers are supported.

---

## Features

- **Curve:** `Ed25519`
- **Wallet class:** `SolanaWallet`
- **Transaction service:** Native transaction builder
- **Balance service:** `SolanaBalanceService`
- **Event system:** Polling-based
- **Custom contract support:** ❌ Not supported yet
- **Token support:** ❌ SPL tokens not yet supported

---

## Wallet creation

```java
SolanaWallet wallet = provider.createWallet(privateKey);
// or
SolanaWallet wallet = provider.createWallet("5G3M...", privateKey);
```

---

## Transfers

You can send to a single address:

```java
wallet.transaction("recipientAddress", Amount.ofHuman("0.01"));
```

Or multiple addresses with flags:

```java
wallet.transaction(List.of(
    new Recipient("recipient1", Amount.ofHuman("0.02")),
    new Recipient("recipient2", Amount.ofHuman("0.01"))
), Flag.INCLUDE_FEE);
```

With `INCLUDE_FEE`, the total fee is deducted proportionally from recipients.

---

## Fee adjustment logic

When `Flag.INCLUDE_FEE` is set, the total transaction fee is distributed across recipients relative to their amounts:

```java
var newAmount = originalAmount - (originalAmount * totalFee) / sumOfAllAmounts;
```

If any result is negative, the transaction is aborted.

---

## Event system

Solana uses **polling-based** event listeners.  
You can create a listener using:

```java
SolanaProvider provider = SolanaProvider.newBuilder()
    .node(webData)
    .listenerProvider(new SolanaPollingListenerProvider(10, new PollingLimiterConfig()))
    .build();
```

This sets up polling every 10 seconds for known addresses.

Polling is based on signatures from `getSignaturesForAddress` and `getTransaction`.

---

## RPC client

`SolanaRpcClient` is used internally to access methods such as:

- `getLatestBlockHash`
- `getBalance`
- `getTransaction`
- `sendTransaction`
- `simulateTransaction`
- etc.

It wraps the standard Solana RPC API and throws descriptive exceptions (e.g., on invalid responses or missing transactions).

---

## Public address derivation

Solana uses Ed25519. Public addresses are base58-encoded public keys:

```java
String address = Base58.getInstance().encode(publicKey.encoded());
```

---

## Notes

- SPL token support (e.g., USDC) is **not** implemented yet.
- Smart contract interaction is not yet supported.