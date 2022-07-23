// SPDX-License-Identifier: AGPL-3.0-or-later

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

pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {Sum} from "../src/sum.sol";
import {Hitter} from "../src/hit.sol";

contract TestHit is Test {
    Sum internal sum;
    Hitter internal hitter;

    address me = address(this);

    function setUp() public {
        sum = new Sum();
        hitter = new Hitter(address(sum));

        sum.boot(me);
        sum.hope(address(hitter));
    }

    function test_hit() public {
        hitter.hit();
        (uint256 net, uint256 tab, uint256 tax, uint256 num, uint256 hop) = sum.incs(me);

        assertEq(net, 1);
        assertEq(tab, 1);
        assertEq(tax, 0);
        assertEq(num, 1);
        assertEq(hop, 1);

        hitter.hit();
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 2);
        assertEq(tab, 2);
        assertEq(tax, 0);
        assertEq(num, 2);
        assertEq(hop, 1);

        hitter.hit();
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 3);
        assertEq(tab, 3);
        assertEq(tax, 0);
        assertEq(num, 3);
        assertEq(hop, 1);
    }
}
