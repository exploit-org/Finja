# TronProvider

`TronProvider` is the `CoinProvider<Secp256k1PointOps>` implementation for the **TRON** blockchain.  
It provides full support for TRX, TRC-20 tokens, and bulk transfers via smart contracts.

---

## Features

- **Curve:** `Secp256k1`
- **Wallet class:** `TronWallet`
- **Transaction service:** `TronTransactionService`
- **Balance handling:** via `SmartCoinBalanceService`
- **Event system:** supported via event clients or polling
- **Supports:**
    - TRX transfers
    - TRC-20 tokens
    - Bulk transfers via a contract
    - Custom contract execution

---

## Wallet creation

```java
TronWallet wallet = provider.createWallet(privateKey);
// or
TronWallet wallet = provider.createWallet("TV...", privateKey);
```

From the wallet, you can:

- Send TRX or tokens with `.transaction(...)`
- Call contracts with `.execute(...)`
- Get balances with `.balance(...)`

---

## Bulk transfers

TRON supports contract-based **multi-send**. You can register and use a `TronMultiTransferContract` implementation.

See example contract below under [Multi-send Contract](#multi-send-contract).

```java
provider.registerContract(new TronMultiTransferContract("contractAddress"));
```

Then send multiple recipients:

```java
wallet.transaction(List.of(
    new Recipient("TV...", Amount.ofHuman("10")),
    new Recipient("TB...", Amount.ofHuman("5"))
), Flag.INCLUDE_FEE);
```

---

## Event system

There are two mechanisms to receive events:

### 1. Polling (recommended for most projects)

```java
provider = TronProvider.newBuilder()
    .node(webData)
    .listenerProvider(new TronPollingListenerProvider(60, new PollingLimiterConfig(...)))
    .eventClient(new TronGridEventClient(webData))
    .build();
```

This will check new blocks every 60 seconds using `PollingTxListener`.

### 2. Event client (TRON-specific)

The only supported event client out-of-the-box is [**TronGrid**](https://www.trongrid.io/).

You can use it with:

```java
new TronGridEventClient(webData);
```

It’s used to fetch TRC-20 transfers and other contract-level logs.

---

## Multi-send contract

To enable mass transfers on TRON, deploy the following contract (compatible with both native and token transfers):

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
provider.registerContract(new TronMultiTransferContract("contractAddress"));
```

---

## Custom contract calls
**NOTE**: Working with smart-contracts is in beta and may change in future releases.  
Behaviour is same as in [EVM](evm.md).

Custom smart contracts are supported via `.execute(...)`:

```java
wallet.execute(MyContract.class, "someMethod", List.of(...));
```

Make sure to register the contract first:

```java
provider.registerContract(new MyContract(...));
```

---