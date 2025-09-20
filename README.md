# BalanceDeltaTrap

A custom **Drosera trap** implementation that monitors **balance changes (deltas)** on a given Ethereum address.  
The trap detects when the account balance increases or decreases beyond a defined threshold and triggers a response via the Drosera Operator.

This repository contains both the Solidity smart contract (`BalanceDeltaTrap.sol`) and the responder contract (`LogAlertReceiver.sol`) for logging balance change alerts.

---

## Features

* **Balance delta detection** - reacts to increases or decreases in ETH balance.
* **Configurable threshold** - triggers only when the balance change exceeds a defined value in wei.
* **ABI-compatible payloads** - returns ABI-encoded strings for responder compatibility.
* **Compatible with Drosera Operator** - fully integrates with the Drosera attestation and submission system.

---

## Contract Overview

### `BalanceDeltaTrap.sol`

Implements the `ITrap` interface required by Drosera.

- **`collect()`**
  Collects the current balance and timestamp of the monitored address:
  ```solidity
  return abi.encode(target.balance, block.timestamp);
  ```

- **`shouldRespond()`**
  Compares two balance snapshots:
  - `data[0] = newest`
  - `data[1] = previous`

  If the difference is greater than `thresholdWei`, it returns:
  ```solidity
  (true, abi.encode(<string_message>))
  ```
  where `<string_message>` is human-readable and ABI-encoded.

- **Example message format**
  ```
  Balance change detected: prev=1000000000000000000 curr=2000000000000000000 diff=1000000000000000000 ts_prev=1700000000 ts_curr=1700000300
  ```

---

### `LogAlertReceiver.sol`

A simple responder contract that logs alerts from the trap.

- **Event**
  ```solidity
  event BalanceAlert(string message, address indexed trap, uint256 timestamp);
  ```

- **Response function**
  ```solidity
  function logBalanceChange(string calldata message) external
  ```
  Emits the `BalanceAlert` event.

- **TOML configuration**
  ```toml
  response_function = "logBalanceChange(string)"
  ```

---

## How it Works

1. The trap collects `(balance, timestamp)` snapshots of the monitored account.
2. When a new block arrives, Drosera passes the newest and previous snapshots to `shouldRespond()`.
3. If the balance delta is greater than the defined threshold, the trap returns `true` and an ABI-encoded string.
4. The Drosera Operator calls the configured responder contract, which logs the anomaly on-chain.

---

## Installation

Clone the repository:

```bash
git clone https://github.com/<your-username>/BalanceDeltaTrap.git
cd BalanceDeltaTrap
```

Install dependencies:

```bash
forge install
```

Compile contracts:

```bash
forge build
```

Run tests:

```bash
forge test
```

---

## Deploy

Deploy the trap contract (example using Foundry):

```bash
forge create src/BalanceDeltaTrap.sol:BalanceDeltaTrap \
  --rpc-url <YOUR_RPC_URL> \
  --private-key <YOUR_PRIVATE_KEY> \
  --broadcast
```

Deploy the responder contract:

```bash
forge create src/LogAlertReceiver.sol:LogAlertReceiver \
  --rpc-url <YOUR_RPC_URL> \
  --private-key <YOUR_PRIVATE_KEY> \
  --broadcast
```

---

## Running with Drosera Operator

1. Deploy `BalanceDeltaTrap` and `LogAlertReceiver`.
2. Configure your Drosera Operator to monitor the trap and use the responder:
   ```toml
   response_contract = "<LogAlertReceiver_Address>"
   response_function = "logBalanceChange(string)"
   ```
3. Start the operator:
   ```bash
   cargo run --bin drosera-operator
   ```
4. Monitor logs to confirm trap triggers and submissions.

---

## Example Log Output

```
INFO drosera_services::operator::submission::runner: Aggregated attestation result is 'shouldRespond=true'
INFO drosera_services::operator::submission::runner: This node is selected to submit the claim
```

---

## Notes

* Replace `target` in `BalanceDeltaTrap.sol` with the actual address to monitor.
* `data[0]` is **newest**, `data[1]` is **previous** – keep snapshot order correct.
* Only one operator instance should run with the same private key to avoid nonce issues.
* Works on the Hoodi testnet and any EVM-compatible network supported by Drosera.

---

## License

MIT License.

