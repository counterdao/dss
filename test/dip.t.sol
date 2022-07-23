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
import {Dipper} from "../src/dip.sol";

contract TestDip is Test {
    Sum internal sum;
    Dipper internal dipper;

    address me = address(this);

    function setUp() public {
        sum = new Sum();
        dipper = new Dipper(address(sum));

        sum.boot(me);
        sum.hope(address(dipper));
    }

    function test_dip() public {
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

        dipper.dip();
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 4);
        assertEq(tab, 5);
        assertEq(tax, 1);
        assertEq(num, 6);
        assertEq(hop, 1);

        dipper.dip();
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 3);
        assertEq(tab, 5);
        assertEq(tax, 2);
        assertEq(num, 7);
        assertEq(hop, 1);

        dipper.dip();
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 2);
        assertEq(tab, 5);
        assertEq(tax, 3);
        assertEq(num, 8);
        assertEq(hop, 1);

        dipper.dip();
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 1);
        assertEq(tab, 5);
        assertEq(tax, 4);
        assertEq(num, 9);
        assertEq(hop, 1);

        dipper.dip();
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 0);
        assertEq(tab, 5);
        assertEq(tax, 5);
        assertEq(num, 10);
        assertEq(hop, 1);

        vm.expectRevert("Sum/not-safe-hop");
        dipper.dip();
    }
}
