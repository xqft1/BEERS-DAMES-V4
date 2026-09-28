# BEERS / DAMES V4

**Ale for the tavern. Valour for the DAMES.**

BEERS / DAMES V4 is an experimental Uniswap v4 liquidity project on **Robinhood Chain**, built around a deliberately reusable custom hook that sends a portion of every supported swap to the dead address.

DAMES and BEERS belong together.

One is valour, mischief and medieval rebellion. The other is exactly what should be waiting at the tavern when the fighting is done.

> **DAMES bringeth the valour. BEERS bringeth the ale. The hook bringeth the fire.**

## DAMES

DAMES is a Robinhood Chain token built around a 21,000,000 maximum supply, ETH minting, liquidity staking and community ownership.

Explore DAMES:

**https://damesofrobinhood.com/**

DAMES contract:

```text
0x831A3962e31037cf4Eb8847cb7eA05aaC1Db35B6
```

## BEERS + DAMES

The BEERS / DAMES pair is a separate Uniswap v4 experiment built for the tavern.

The idea is simple:

- DAMES is the medieval Robinhood asset.
- BEERS is the tavern currency.
- DAMES and BEERS trade together in a Uniswap v4 pool.
- A custom hook removes a portion of both sides of every exact-input swap from circulation by sending tokens to the standard dead address.

The result is a pool with an intentionally destructive swap mechanic: trading continuously pushes small amounts of both assets into an inaccessible sink.


## BundleCatAI $BUN

BEERS was launched on **$PON**, with **BundleCatAI $BUN** as the base layer.

Why $BUN?

Because we simply love BUN.

$BUN sits underneath the BEERS story as the launch base, while BEERS and DAMES bring the tavern, the valour and the chaos on top.

```text
$BUN
  |
  v
$PON
  |
  v
BEERS
  +
DAMES
```

**BUN is the base. BEERS is the ale. DAMES bring the valour.**

## The BEERS / DAMES Burn Hook

Deployed hook:

```text
0x0Fcb47DCFBD8365f9cC3D34fC6E6595485FAC0cc
```

Robinhood Chain PoolManager:

```text
0x8366a39CC670B4001A1121B8F6A443A643e40951
```

The hook is configured for:

```text
beforeSwap
afterSwap
beforeSwapReturnDelta
afterSwapReturnDelta
```

Permission mask:

```text
0xCC
```

### What the hook does

For supported **exact-input swaps**, the hook is designed to route:

```text
1% of the input currency
+
1% of the output currency
```

to:

```text
0x000000000000000000000000000000000000dEaD
```

The dead-address transfer is an economic sink. Unless the underlying ERC-20 implements special burn behaviour, transferring tokens to the dead address does **not** reduce the ERC-20 `totalSupply()` value itself.

Exact-output swaps are intentionally unsupported.

## Intentionally Multipurpose

Despite the project name, the hook is **not hard-coded to BEERS or DAMES**.

The contract reads `currency0` and `currency1` directly from the Uniswap v4 `PoolKey`. That means the same deployed hook can intentionally be used with other compatible Uniswap v4 pools.

There are no BEERS or DAMES token addresses embedded in the hook.

This is deliberate.

BEERS / DAMES is the first tavern built around it, but the hook itself is designed as reusable infrastructure for other normal ERC-20 pairs that want the same dead-address sink mechanic.

Users should review token behaviour before using the hook with fee-on-transfer, rebasing or otherwise non-standard assets.

## Initial BEERS / DAMES Position

The initial BEERS / DAMES Uniswap v4 liquidity position can be viewed here:

**https://robin.etherscan.io/nft/0x58daec3116aae6d93017baaea7749052e8a04fa7/3375781**

Position NFT:

```text
3375781
```

Position manager / NFT contract:

```text
0x58daec3116aae6d93017baaea7749052e8a04fa7
```

The intention is for this initial BEERS / DAMES position to eventually be sent to **Indefinite V4**, making the liquidity position permanent.

Indefinite V4:

**https://indefinitev4.com/**

## Why Indefinite V4?

Liquidity should not depend forever on one wallet deciding whether to stay.

The long-term goal is to place the BEERS / DAMES liquidity position beyond discretionary withdrawal by transferring the position to Indefinite V4.

Once that step is completed, this repository can be updated with the relevant on-chain proof.

## Architecture

```text
            BEERS / DAMES
                 |
                 v
        Uniswap v4 PoolManager
                 |
                 v
      BeersDamesBurnHook (0x...C0cc)
           |               |
           | beforeSwap    | afterSwap
           v               v
      1% input sink    1% output sink
           |               |
           +-------+-------+
                   |
                   v
          0x0000...dEaD
```

## Hook Philosophy

This project intentionally keeps the hook small.

No owner-controlled fee destination.

No treasury address.

No BEERS-only logic.

No DAMES-only logic.

No upgrade switch.

The pool determines the currencies. The hook applies the same mechanic.

## Important Notes

This repository contains experimental DeFi software.

- The hook is designed around Uniswap v4 exact-input swaps.
- Exact-output swaps revert.
- Dead-address transfers generally do not alter ERC-20 `totalSupply()`.
- Non-standard ERC-20 behaviour may be incompatible.
- Anyone integrating the hook should review the code and understand Uniswap v4 hook accounting before providing liquidity.
- Smart-contract deployment and liquidity provision involve risk.

## Robinhood Chain

Chain ID:

```text
4663
```

## Links

**DAMES:** https://damesofrobinhood.com/

**DAMES on X:** https://x.com/robinhooddames

**BEERS / DAMES Hook:**  
https://robin.etherscan.io/address/0x0Fcb47DCFBD8365f9cC3D34fC6E6595485FAC0cc

**Initial BEERS / DAMES Position:**  
https://robin.etherscan.io/nft/0x58daec3116aae6d93017baaea7749052e8a04fa7/3375781

**Indefinite V4:** https://indefinitev4.com/

---

## THE TAVERN OF ROBINHOOD

```text
      _______________________________
     /                               \
    /      THE TAVERN OF ROBINHOOD    \
   /___________________________________\
          |                     |
          |   BEERS     DAMES    |
          |                     |
          |   ALE & VALOUR      |
          |_____________________|
                 |       |
                 |       |
              ___|_______|___
             /               \
            /   0x0000...dEaD \
           /___________________\
```

**Raise the BEERS. Back the DAMES. Burn a little on the way.**
