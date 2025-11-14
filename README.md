# Cairo Proof Delegation

A proof-of-concept for conditional proof verification in Cairo, supporting both local and remote proving mechanisms.

## Setup
- Requires Scarb (Cairo build toolchain)

## Build & Test
```bash
scarb build
scarb test -q
```

## Project Structure
- `src/` - Cairo source files
- `Scarb.toml` - Cairo project configuration

This POC demonstrates how proof verification can be conditionally delegated between local and remote environments.
