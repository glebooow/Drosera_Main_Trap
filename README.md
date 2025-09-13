# BalanceDeltaTrap

A custom Drosera trap implementation that monitors **balance changes (deltas)** on a given address.
The trap detects when the account balance increases or decreases beyond a defined threshold and triggers a response.

This repository contains the Solidity smart contract and integration logic for running the trap with the Drosera Operator.

---

## Features

* **Balance delta detection** – reacts to increases or decreases in ETH balance.
* **Configurable threshold** – only triggers when the delta is greater than 0 (can be extended for custom logic).
* **Lightweight implementation** – simple collect/respond interface.
* **Compatible with Drosera Operator** – works seamlessly with the Drosera attestation and submission system.

---

## Contract Overview

* **`collect()`**
  Gathers the current balance state of the target account.

* **`shouldRespond()`**
  Compares the balance difference between two collected states.
  Returns `true` if a delta is detected (positive or negative).

* **`respond()`** *(optional, depending on use case)*
  Can be extended to trigger an action when a response condition is met.

---

## How it Works

1. The trap collects balance snapshots of the monitored account.
2. When a new block arrives, the trap compares the latest snapshot against the previous one.
3. If the balance difference (`delta`) is **not zero**, the trap marks it as an anomaly and produces a response.
4. The Drosera Operator then aggregates attestations and submits the claim on-chain.

---

## Installation

Clone the repository:

```bash
git clone https://github.com/<glebooow>/BalanceDeltaTrap.git
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

You can deploy the trap contract to your network (example using Foundry):

```bash
forge create src/BalanceDeltaTrap.sol:BalanceDeltaTrap \
  --rpc-url <YOUR_RPC_URL> \
  --private-key <YOUR_PRIVATE_KEY> \
  --broadcast
```

---

## Running with Drosera Operator

1. Build and deploy the trap contract.
2. Register the trap address in your Drosera Operator config.
3. Start the operator service:

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

* Make sure only **one operator instance** is running with the same private key to avoid nonce issues.
* Works with any EVM-compatible chain supported by Drosera.

---

## License

MIT License.
