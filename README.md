# Xwift

**Xwift** is a private, secure, untraceable, decentralised digital currency fork based on Monero, with customized consensus parameters and economic model.

Original copyright (c) 2014-2024, The Monero Project  
Portions Copyright (c) 2012-2013 The Cryptonote developers.

## Quick Start

For Xwift-specific deployment and configuration, see:
- **[README_XWIFT.md](README_XWIFT.md)** - Xwift Quick Start Guide
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Complete Deployment Instructions
- **[DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)** - Full Documentation Index

## Table of Contents

  - [About Xwift](#about-xwift)
  - [Key Differences from Monero](#key-differences-from-monero)
  - [Network Configuration](#network-configuration)
  - [Building Xwift](#building-xwift)
    - [Dependencies](#dependencies)
    - [Build Instructions](#build-instructions)
  - [Running Xwift](#running-xwift)
  - [License](#license)
  - [Contributing](#contributing)

## About Xwift

Xwift maintains Monero's core privacy and security features while implementing a custom economic model and faster block times:

**Privacy:** Xwift uses ring signatures, stealth addresses, and RingCT to ensure transactions remain private by default.

**Security:** Using distributed peer-to-peer consensus, every transaction is cryptographically secured. Wallets use 25-word mnemonic seeds.

**Untraceability:** Ring signatures ensure transactions cannot be easily tied back to individual users.

**Decentralization:** Anyone can run Xwift software and participate in network consensus using consumer-grade hardware.

## Key Differences from Monero

Xwift is a customized fork with these critical changes:

- **Block Time**: 30 seconds (vs Monero's 120 seconds)
- **Emission Schedule**: 72.5M base supply over 8 years + 1.2 XFT/block tail emission
- **Consensus Tuning**: 60-block maturity, 72-block difficulty window
- **Network Ports**: 19080/19081/19082 (mainnet), 29080/29081/29082 (testnet)
- **Unique Network IDs**: Separate network identifiers and genesis blocks
- **Binary Names**: `xwiftd`, `xwift-wallet-cli`, `xwift-wallet-rpc`

## Network Configuration

### Mainnet
- **P2P Port**: 19080
- **RPC Port**: 19081
- **ZMQ Port**: 19082
- **Network ID**: XWIFT unique identifier
- **Address Prefix**: 65

### Testnet
- **P2P Port**: 29080
- **RPC Port**: 29081
- **ZMQ Port**: 29082
- **Network ID**: XWIFT testnet identifier
- **Address Prefix**: 85

## Building Xwift

### Dependencies

The following table summarizes the tools and libraries required to build:

| Dep          | Min. version  | Vendored | Debian/Ubuntu pkg    | Arch pkg     | Void pkg           | Fedora pkg          | Optional | Purpose         |
| ------------ | ------------- | -------- | -------------------- | ------------ | ------------------ | ------------------- | -------- | --------------- |
| GCC          | 7             | NO       | `build-essential`    | `base-devel` | `base-devel`       | `gcc`               | NO       |                 |
| CMake        | 3.10          | NO       | `cmake`              | `cmake`      | `cmake`            | `cmake`             | NO       |                 |
| pkg-config   | any           | NO       | `pkg-config`         | `base-devel` | `base-devel`       | `pkgconf`           | NO       |                 |
| Boost        | 1.66          | NO       | `libboost-all-dev`   | `boost`      | `boost-devel`      | `boost-devel`       | NO       | C++ libraries   |
| OpenSSL      | basically any | NO       | `libssl-dev`         | `openssl`    | `openssl-devel`    | `openssl-devel`     | NO       | sha256 sum      |
| libzmq       | 4.2.0         | NO       | `libzmq3-dev`        | `zeromq`     | `zeromq-devel`     | `zeromq-devel`      | NO       | ZeroMQ library  |
| libunbound   | 1.4.16        | NO       | `libunbound-dev`     | `unbound`    | `unbound-devel`    | `unbound-devel`     | NO       | DNS resolver    |
| libsodium    | ?             | NO       | `libsodium-dev`      | `libsodium`  | `libsodium-devel`  | `libsodium-devel`   | NO       | cryptography    |
| libunwind    | any           | NO       | `libunwind8-dev`     | `libunwind`  | `libunwind-devel`  | `libunwind-devel`   | YES      | Stack traces    |
| liblzma      | any           | NO       | `liblzma-dev`        | `xz`         | `liblzma-devel`    | `xz-devel`          | YES      | For libunwind   |
| libreadline  | 6.3.0         | NO       | `libreadline6-dev`   | `readline`   | `readline-devel`   | `readline-devel`    | YES      | Input editing   |
| expat        | 1.1           | NO       | `libexpat1-dev`      | `expat`      | `expat-devel`      | `expat-devel`       | YES      | XML parsing     |
| GTest        | 1.5           | YES      | `libgtest-dev`       | `gtest`      | `gtest-devel`      | `gtest-devel`       | YES      | Test suite      |
| ccache       | any           | NO       | `ccache`             | `ccache`     | `ccache`           | `ccache`            | YES      | Compil. cache   |
| Doxygen      | any           | NO       | `doxygen`            | `doxygen`    | `doxygen`          | `doxygen`           | YES      | Documentation   |
| Graphviz     | any           | NO       | `graphviz`           | `graphviz`   | `graphviz`         | `graphviz`          | YES      | Documentation   |
| lrelease     | ?             | NO       | `qttools5-dev-tools` | `qt5-tools`  | `qt5-tools`        | `qt5-linguist`      | YES      | Translations    |
| libhidapi    | ?             | NO       | `libhidapi-dev`      | `hidapi`     | `hidapi-devel`     | `hidapi-devel`      | YES      | Hardware wallet |
| libusb       | ?             | NO       | `libusb-1.0-0-dev`   | `libusb`     | `libusb-devel`     | `libusbx-devel`     | YES      | Hardware wallet |
| libprotobuf  | ?             | NO       | `libprotobuf-dev`    | `protobuf`   | `protobuf-devel`   | `protobuf-devel`    | YES      | Hardware wallet |
| protoc       | ?             | NO       | `protobuf-compiler`  | `protobuf`   | `protobuf`         | `protobuf-compiler` | YES      | Hardware wallet |
| libudev      | ?             | NO       | `libudev-dev`        | `systemd`    | `eudev-libudev-devel` | `systemd-devel`  | YES      | Hardware wallet |

Install all dependencies at once on Debian/Ubuntu:

```bash
sudo apt update && sudo apt install build-essential cmake pkg-config libssl-dev libzmq3-dev libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev libexpat1-dev qttools5-dev-tools libhidapi-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler libudev-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev libboost-regex-dev libboost-serialization-dev libboost-system-dev libboost-thread-dev python3 ccache doxygen graphviz git curl autoconf libtool gperf
```

### Build Instructions

#### On Linux and macOS

Clone the repository recursively:

```bash
git clone --recursive https://github.com/yourusername/xwift
cd xwift
```

Build Xwift:

```bash
make release
```

For parallel builds (faster):

```bash
make -j$(nproc)
```

The resulting executables can be found in `build/release/bin`:
- `xwiftd` - daemon
- `xwift-wallet-cli` - command-line wallet
- `xwift-wallet-rpc` - RPC wallet server

#### Build and Run Tests

```bash
make release-test
```

*NOTE*: `core_tests` may take a few hours to complete.

#### Debug Build

```bash
make debug
```

#### Build Documentation

```bash
HAVE_DOT=YES doxygen Doxyfile
```

#### Windows Build

See detailed Windows build instructions in the original documentation sections below.

## Running Xwift

### Start the daemon (mainnet):

```bash
./xwiftd
```

Or in detached mode:

```bash
./xwiftd --detach
```

### Start the daemon (testnet):

```bash
./xwiftd --testnet
```

### Create a wallet:

```bash
./xwift-wallet-cli --generate-new-wallet mywallet
```

### Connect to RPC:

```bash
# Mainnet
curl http://localhost:19081/get_info

# Testnet
curl http://localhost:29081/get_info
```

## License

See [LICENSE](LICENSE).

This project is based on Monero and maintains the same BSD-3-Clause license. Xwift-specific modifications are also released under BSD-3-Clause.

## Contributing

Contributions are welcome! Please ensure:

1. Code follows existing style conventions
2. Changes are well-tested
3. Commit messages are clear and descriptive
4. PRs target the appropriate branch

For major changes, please open an issue first to discuss what you would like to change.

---

## Additional Documentation

For detailed information on specific topics, see:

- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Production deployment
- **[TESTNET_VALIDATION_GUIDE.md](TESTNET_VALIDATION_GUIDE.md)** - Testnet validation
- **[CONSENSUS_CHANGES_SUMMARY.md](CONSENSUS_CHANGES_SUMMARY.md)** - Consensus modifications
- **[EMISSION_SCHEDULE.md](EMISSION_SCHEDULE.md)** - Token economics
- **[DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)** - Complete documentation list

---

## Advanced Build Topics

### Raspberry Pi Build

Tested on Raspberry Pi 5B with Debian 12:

```bash
sudo apt-get update && sudo apt-get upgrade
# Install dependencies (see table above)
git clone --recursive https://github.com/yourusername/xwift
cd xwift
USE_SINGLE_BUILDDIR=1 make release
```

### Windows Build (MSYS2)

1. Install [MSYS2](https://www.msys2.org)
2. Update packages: `pacman -Syu`
3. Install dependencies:

```bash
pacman -S mingw-w64-x86_64-toolchain make mingw-w64-x86_64-cmake mingw-w64-x86_64-boost mingw-w64-x86_64-openssl mingw-w64-x86_64-zeromq mingw-w64-x86_64-libsodium mingw-w64-x86_64-hidapi mingw-w64-x86_64-unbound
```

4. Clone and build:

```bash
git clone --recursive https://github.com/yourusername/xwift
cd xwift
make release-static -j $(nproc)
```

### FreeBSD Build

```bash
pkg install git gmake cmake pkgconf boost-libs libzmq4 libsodium unbound
git clone --recursive https://github.com/yourusername/xwift
cd xwift
gmake
```

Note: If running in a jail, add `sysvsem="new"` to jail configuration.

### OpenBSD Build

```bash
pkg_add cmake gmake zeromq libiconv boost libunbound
git clone --recursive https://github.com/yourusername/xwift
cd xwift
gmake
```

If you encounter "LLVM ERROR: out of memory", increase data ulimit:

```bash
ulimit -d 2000000
```

### Cross Compiling

Use the `depends` system for cross-compilation:

```bash
# 64-bit Linux
make depends target=x86_64-linux-gnu

# 64-bit Windows
make depends target=x86_64-w64-mingw32

# Intel macOS
make depends target=x86_64-apple-darwin

# Apple Silicon macOS
make depends target=arm64-apple-darwin
```

See `contrib/depends/README.md` for more details.

---

**For the most up-to-date Xwift-specific information, always refer to [README_XWIFT.md](README_XWIFT.md) and [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md).**
