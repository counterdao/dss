// SPDX-License-Identifier: AGPL-3.0-or-later

/// dss.sol -- Decentralized Summation System

// Copyright (C) 2022 Horsefacts <horsefacts@terminally.online>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity ^0.8.15;

import {DSSProxy} from "./proxy/proxy.sol";

interface DSSLike {
    function use() external;
    function see() external view returns (uint256);
    function hit() external;
    function dip() external;
    function nil() external;
    function hope(address) external;
    function nope(address) external;
    function bless() external;
}

interface SumLike {
    function hope(address) external;
    function nope(address) external;
}

interface UseLike {
    function use() external;
}

interface SpyLike {
    function see() external view returns (uint256);
}

interface HitterLike {
    function hit() external;
}

interface DipperLike {
    function dip() external;
}

interface NilLike {
    function nil() external;
}

contract DSS {
    // --- Data ---
    SumLike    immutable public _sum;
    UseLike    immutable public _use;
    SpyLike    immutable public _spy;
    HitterLike immutable public _hitter;
    DipperLike immutable public _dipper;
    NilLike    immutable public _nil;

    // --- Init ---
    constructor(
        address sum_,
        address use_,
        address spy_,
        address hitter_,
        address dipper_,
        address nil_)
    {
        _sum    = SumLike(sum_);        // Core ICV engine
        _use    = UseLike(use_);        // Creation module
        _spy    = SpyLike(spy_);        // Read module
        _hitter = HitterLike(hitter_);  // Increment module
        _dipper = DipperLike(dipper_);  // Decrement module
        _nil    = NilLike(nil_);        // Reset module
    }

    // --- DSS Operations ---
    function use() external {
        _use.use();
    }

    function see() external view returns (uint256) {
        return _spy.see();
    }

    function hit() external {
        _hitter.hit();
    }

    function dip() external {
        _dipper.dip();
    }

    function nil() external {
        _nil.nil();
    }

    function hope(address usr) external {
        _sum.hope(usr);
    }

    function nope(address usr) external {
        _sum.nope(usr);
    }

    function bless() external {
        _sum.hope(address(_use));
        _sum.hope(address(_hitter));
        _sum.hope(address(_dipper));
        _sum.hope(address(_nil));
    }

    function build(bytes32 wit, address god) external returns (address proxy) {
        proxy = address(new DSSProxy{ salt: wit }(address(this), msg.sender, god));
    }
}
