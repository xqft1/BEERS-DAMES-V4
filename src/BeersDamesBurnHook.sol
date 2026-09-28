// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*

██████╗ ███████╗███████╗██████╗ ███████╗
██╔══██╗██╔════╝██╔════╝██╔══██╗██╔════╝
██████╔╝█████╗  █████╗  ██████╔╝███████╗
██╔══██╗██╔══╝  ██╔══╝  ██╔══██╗╚════██║
██████╔╝███████╗███████╗██║  ██║███████║
╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝

              ×

██████╗  █████╗ ███╗   ███╗███████╗███████╗
██╔══██╗██╔══██╗████╗ ████║██╔════╝██╔════╝
██║  ██║███████║██╔████╔██║█████╗  ███████╗
██║  ██║██╔══██║██║╚██╔╝██║██╔══╝  ╚════██║
██████╔╝██║  ██║██║ ╚═╝ ██║███████╗███████║
╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝

        damesofrobinhood.com

*/

import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";

import {PoolKey} from "v4-core/types/PoolKey.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";

import {
    BeforeSwapDelta,
    BeforeSwapDeltaLibrary,
    toBeforeSwapDelta
} from "v4-core/types/BeforeSwapDelta.sol";

import {Currency} from "v4-core/types/Currency.sol";

contract BeersDamesBurnHook is IHooks {
    uint256 public constant BURN_BPS = 100; // 1%
    uint256 public constant BPS = 10_000;

    address public constant DEAD =
        0x000000000000000000000000000000000000dEaD;

    IPoolManager public immutable poolManager;

    error NotPoolManager();
    error HookNotEnabled();
    error ExactOutputNotSupported();
    error AmountTooLarge();

    constructor(IPoolManager _poolManager) {
        poolManager = _poolManager;

        Hooks.validateHookPermissions(
            IHooks(address(this)),
            getHookPermissions()
        );
    }

    modifier onlyPoolManager() {
        if (msg.sender != address(poolManager)) {
            revert NotPoolManager();
        }
        _;
    }

    function getHookPermissions()
        public
        pure
        returns (Hooks.Permissions memory)
    {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: true,
            afterSwapReturnDelta: true,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function beforeSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata
    )
        external
        override
        onlyPoolManager
        returns (
            bytes4,
            BeforeSwapDelta,
            uint24
        )
    {
        // Negative amountSpecified = exact-input swap.
        if (params.amountSpecified >= 0) {
            revert ExactOutputNotSupported();
        }

        uint256 amountIn =
            uint256(-params.amountSpecified);

        uint256 burnAmount =
            (amountIn * BURN_BPS) / BPS;

        if (burnAmount == 0) {
            return (
                IHooks.beforeSwap.selector,
                BeforeSwapDeltaLibrary.ZERO_DELTA,
                0
            );
        }

        if (burnAmount > uint256(uint128(type(int128).max))) {
            revert AmountTooLarge();
        }

        Currency inputCurrency =
            params.zeroForOne
                ? key.currency0
                : key.currency1;

        /*
         * Send 1% of input directly to DEAD.
         *
         * The positive specified delta removes that same amount
         * from the exact-input quantity entering the AMM.
         */
        poolManager.take(
            inputCurrency,
            DEAD,
            burnAmount
        );

        BeforeSwapDelta hookDelta =
            toBeforeSwapDelta(
                int128(uint128(burnAmount)),
                0
            );

        return (
            IHooks.beforeSwap.selector,
            hookDelta,
            0
        );
    }

    function afterSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata
    )
        external
        override
        onlyPoolManager
        returns (
            bytes4,
            int128
        )
    {
        /*
         * exact-input:
         *
         * zeroForOne = true  -> currency1 is output
         * zeroForOne = false -> currency0 is output
         */
        int128 amountOut =
            params.zeroForOne
                ? delta.amount1()
                : delta.amount0();

        if (amountOut <= 0) {
            return (
                IHooks.afterSwap.selector,
                0
            );
        }

        uint256 burnAmount =
            (uint256(uint128(amountOut)) * BURN_BPS)
                / BPS;

        if (burnAmount == 0) {
            return (
                IHooks.afterSwap.selector,
                0
            );
        }

        if (burnAmount > uint256(uint128(type(int128).max))) {
            revert AmountTooLarge();
        }

        Currency outputCurrency =
            params.zeroForOne
                ? key.currency1
                : key.currency0;

        // Send 1% of actual AMM output to DEAD.
        poolManager.take(
            outputCurrency,
            DEAD,
            burnAmount
        );

        // Reduce amount ultimately received by trader by 1%.
        return (
            IHooks.afterSwap.selector,
            int128(uint128(burnAmount))
        );
    }

    /*
     * These callbacks are disabled by the hook-address flags.
     * They exist only to satisfy IHooks.
     */

    function beforeInitialize(
        address,
        PoolKey calldata,
        uint160
    )
        external
        override
        onlyPoolManager
        returns (bytes4)
    {
        revert HookNotEnabled();
    }

    function afterInitialize(
        address,
        PoolKey calldata,
        uint160,
        int24
    )
        external
        override
        onlyPoolManager
        returns (bytes4)
    {
        revert HookNotEnabled();
    }

    function beforeAddLiquidity(
        address,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    )
        external
        override
        onlyPoolManager
        returns (bytes4)
    {
        revert HookNotEnabled();
    }

    function afterAddLiquidity(
        address,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        BalanceDelta,
        BalanceDelta,
        bytes calldata
    )
        external
        override
        onlyPoolManager
        returns (
            bytes4,
            BalanceDelta
        )
    {
        revert HookNotEnabled();
    }

    function beforeRemoveLiquidity(
        address,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    )
        external
        override
        onlyPoolManager
        returns (bytes4)
    {
        revert HookNotEnabled();
    }

    function afterRemoveLiquidity(
        address,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        BalanceDelta,
        BalanceDelta,
        bytes calldata
    )
        external
        override
        onlyPoolManager
        returns (
            bytes4,
            BalanceDelta
        )
    {
        revert HookNotEnabled();
    }

    function beforeDonate(
        address,
        PoolKey calldata,
        uint256,
        uint256,
        bytes calldata
    )
        external
        override
        onlyPoolManager
        returns (bytes4)
    {
        revert HookNotEnabled();
    }

    function afterDonate(
        address,
        PoolKey calldata,
        uint256,
        uint256,
        bytes calldata
    )
        external
        override
        onlyPoolManager
        returns (bytes4)
    {
        revert HookNotEnabled();
    }
}