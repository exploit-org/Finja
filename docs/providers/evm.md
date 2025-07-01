# EvmProvider

`EvmProvider` is a complete implementation of `CoinProvider` for Ethereum-compatible blockchains (EVM), such as Ethereum, BNB Smart Chain, Polygon, and others.

## Overview

This provider enables:

- Wallet generation and transaction signing
- Value conversion between human and unit amounts
- Token contract interactions
- Transaction history fetching
- Real-time or polling-based event listening

It uses the `Secp256k1` curve and supports the standard Ethereum transaction flow.

## Chain Separation

Each EVM provider is initialized with a specific `chainId` that identifies the target network.

Example chains:

```java
EvmProvider provider = EvmProvider.newBuilder()
    .chainId(ChainID.ETHEREUM)  // 1
    .build();
```

A helper class `ChainID` provides predefined constants for popular networks:

```java
ChainID.ETHEREUM   // 1
ChainID.BNB        // 56
ChainID.POLYGON    // 137
...
```

---

## Wallet

Wallets are created using private keys or key managers. Each wallet exposes the standard `CryptoWallet` interface.

```java
EvmWallet wallet = provider.createWallet(myKeyManager);
```

## Transactions

Wallets expose a `.transaction(...)` method which returns an `OutgoingTransaction`. Internally, it delegates to the `TransactionService`.

This service supports both simple native transfers and token transfers.

### Native Transfer

```java
wallet.transaction("0xRecipient", new Amount("0.01", AmountUnit.HUMAN)).send();
```

### Token Transfer

```java
wallet.transaction("0xRecipient", "0xTokenContract", new Amount("100", AmountUnit.HUMAN)).send();
```

> If the `INCLUDE_FEE` flag is passed, the transaction amount is automatically reduced to account for the gas fee. Otherwise, the full amount is sent, and the sender pays the fee separately.

### Gas Estimation and Fee Deduction

The `TransactionService` will automatically estimate the gas and calculate the fee if not provided. When `INCLUDE_FEE` is used, it adjusts the value accordingly:

```java
if ((flags & Flag.INCLUDE_FEE) != 0) {
    BigInteger fee = gasPrice * estimatedGas;
    value = value - fee;
}
```

---

## Token Transfers

When sending tokens (like USDT, USDC), the `TransactionService` encodes the standard ERC-20 `transfer(address,uint256)` function and sets it as the `input` in the transaction.

Gas and nonce are still fetched from the node.

---

## Event Listening

`EvmProvider` uses two components for event tracking:

- `EventClient` — provides **historical transaction fetches** (`EventFetcher`).
- `ListenerProvider` — provides **real-time or polling-based listeners** (`TransactionListener`).

### EventClient Implementations

Finja provides built-in `EventClient` implementations:

- **BlockBookEventClient** – fetches data from a BlockBook-compatible explorer.
- **EtherScanEventClient** – fetches data from [etherscan.io](https://etherscan.io) using an API key.

Example:

```java
var client = new EtherScanEventClient();
provider = EvmProvider.newBuilder()
    .eventClient(client)
    ...
    .build();
```

### ListenerProvider Implementations

There are two types of listeners:

- **EvmNodeListenerProvider** – uses the node's WebSocket/RPC `eth_subscribe` support. Requires a node that supports subscriptions.
- **EvmPollingListenerProvider** – periodically fetches event data using the provided `EventClient` and simulates real-time behavior.

```java
var polling = new EvmPollingListenerProvider(10, new PollingLimiterConfig());
provider = EvmProvider.newBuilder().listenerProvider(polling).build();
```

> Polling-based listeners internally use `provider.eventFetcher()` to access the historical event source.

> Chain ID is included in meta of TxnEvent to allow filtering by chain.
---

## Multi-send contract

To enable mass transfers on any EVM network, deploy the following contract (compatible with both native and token transfers):

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MultiSend is ReentrancyGuard {
    using Address for address payable;
    using SafeERC20 for IERC20;

    function send(address[] calldata recipients, uint256[] calldata amounts) external payable nonReentrant {
        require(recipients.length == amounts.length, "MultiSend: Recipients and amounts arrays length mismatch");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            require(recipients[i] != address(0), "MultiSend: Cannot send to zero address");
            totalAmount += amounts[i];
        }

        require(msg.value == totalAmount, "MultiSend: Incorrect Ether value sent");

        for (uint256 i = 0; i < recipients.length; i++) {
            payable(recipients[i]).sendValue(amounts[i]);
        }
    }

    function sendToken(address token, address[] calldata recipients, uint256[] calldata amounts) external nonReentrant {
        require(recipients.length == amounts.length, "MultiSend: Recipients and amounts arrays length mismatch");

        uint256 totalAmount = 0;
        IERC20 erc20 = IERC20(token);

        for (uint256 i = 0; i < amounts.length; i++) {
            require(recipients[i] != address(0), "MultiSend: Cannot send to zero address");
            totalAmount += amounts[i];
        }

        require(erc20.allowance(msg.sender, address(this)) >= totalAmount, "MultiSend: Not enough allowance");

        for (uint256 i = 0; i < recipients.length; i++) {
            erc20.safeTransferFrom(msg.sender, recipients[i], amounts[i]);
        }
    }
}
```

After deployment:

```java
provider.registerContract(new EthMultiTransferContract("contractAddress"));
```
___

## Contract Registry
**NOTE**: Working with smart-contracts is in beta and may change in future releases.

`EvmProvider` supports a lightweight contract registry:

```java
provider.registerContract(new MyTokenContract());
MyTokenContract token = provider.findContract(MyTokenContract.class);
```

This makes it easy to store references to known tokens or apps and interact with them later.

---