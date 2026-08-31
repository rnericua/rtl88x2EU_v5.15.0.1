# rtl88x2EU v5.15.0.1 — Kernel 7.0.0-30-generic port

Out-of-tree Realtek driver for RTL8812EU / RTL8822EU USB adapters.
This tree is the [rnericua/rtl88x2EU_v5.15.0.1](https://github.com/rnericua/rtl88x2EU_v5.15.0.1)
base driver with compatibility changes required to build against
**Linux 7.0.0-30-generic** (and other 6.13–7.2 kernels).

The produced module name is `88x2eu.ko` (see `MODULE_NAME` in the Makefile).

## Compatibility changes applied

| Kernel | API | Files |
| --- | --- | --- |
| 6.8+ | `strlcpy` removed; mapped to `strscpy` | `os_dep/linux/os_intfs.c` |
| 6.13+ | `set_monitor_channel()` gained `struct net_device *` | `os_dep/linux/ioctl_cfg80211.c` |
| 6.13+ | `MODULE_IMPORT_NS("...")` string form | `os_dep/linux/os_intfs.c` |
| 6.14+ | `get_tx_power()` gained `link_id` | `os_dep/linux/ioctl_cfg80211.c` |
| 6.15+ | `del_timer_sync` / `del_timer` → `timer_delete_sync` / `timer_delete` | `include/osdep_service_linux.h` |
| 6.16+ | `from_timer()` → `timer_container_of()` | `include/osdep_service_linux.h` |
| 6.17+ | cfg80211 `radio_idx` on `set_wiphy_params`, `set_tx_power`, `get_tx_power` | `os_dep/linux/ioctl_cfg80211.c` |
| 6.18+ | local SHA-256 symbols prefixed with `rtw_` to avoid kernel crypto clashes | `core/crypto/*`, `core/rtw_swcrypto.c` |
| 6.15+/7.0 | `EXTRA_CFLAGS` also exported as `ccflags-y` | `Makefile` |

Version checks are retained so the same tree can still be built on older 5.x/6.x kernels.

## Build on Ubuntu / kernel 7.0.0-30-generic

```bash
sudo apt-get update
sudo apt-get install --yes build-essential dkms git \
    linux-headers-7.0.0-30-generic

# If you are already running that kernel:
#   sudo apt-get install --yes linux-headers-$(uname -r)

cd rtl88x2EU_v5.15.0.1-kernel7
make clean
make -j"$(nproc)"
sudo make install
sudo depmod -a
sudo modprobe 88x2eu
```

Confirm:

```bash
uname -r          # expect 7.0.0-30-generic
lsmod | grep 88x2
dmesg | tail
```

### DKMS (rebuilds after kernel upgrades)

```bash
sudo ./dkms-install.sh
dkms status
```

Remove with `sudo ./dkms-remove.sh`.

### Platform notes

Default `Makefile` target is x86_64 PC (`CONFIG_PLATFORM_I386_PC = y`).
For 32-bit ARM:

```bash
sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/' Makefile
sed -i 's/CONFIG_PLATFORM_ARM_RPI = n/CONFIG_PLATFORM_ARM_RPI = y/' Makefile
```

For ARM64:

```bash
sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/' Makefile
sed -i 's/CONFIG_PLATFORM_ARM64_RPI = n/CONFIG_PLATFORM_ARM64_RPI = y/' Makefile
```

Secure Boot: the module must be signed, or Secure Boot disabled, or the
signing key enrolled. DKMS on Ubuntu will sign with the Machine Owner Key
when one is configured (`mokutil --sb-state`).

## Known limits

This is a vendor-style cfg80211 driver, not the in-tree `rtw88` stack.
Monitor-mode and injection behaviour depend on the original Realtek code
paths; this port only addresses kernel API breakage.

If `make` still fails, capture the first error (not the last `Error 2`)
and the output of `uname -r` and `gcc --version`.
