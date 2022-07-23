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
import {Nil} from "../src/nil.sol";

contract TestNil is Test {
    Sum internal sum;
    Nil internal nil;

    address me = address(this);

    function setUp() public {
        sum = new Sum();
        nil = new Nil(address(sum));

        sum.boot(me);
        sum.hope(address(nil));
    }

    function test_nil() public {
        sum.frob(me, 1);
        sum.frob(me, 1);
        sum.frob(me, 1);
        sum.frob(me, 1);
        sum.frob(me, 1);

        (uint256 net, uint256 tab, uint256 tax, uint256 num, uint256 hop) = sum.incs(me);

        assertEq(net, 5);
        assertEq(tab, 5);
        assertEq(tax, 0);
        assertEq(num, 5);
        assertEq(hop, 1);

        nil.nil();
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 0);
        assertEq(tab, 0);
        assertEq(tax, 0);
        assertEq(num, 6);
        assertEq(hop, 1);
    }
}
