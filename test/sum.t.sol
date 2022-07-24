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

contract TestSum is Test {
    Sum internal sum;

    address me = address(this);

    function setUp() public {
        sum = new Sum();
    }

    function test_boot() public {
        sum.boot(me);

        (uint256 net, uint256 tab, uint256 tax, uint256 num, uint256 hop) = sum.incs(me);

        assertEq(net, 0);
        assertEq(tab, 0);
        assertEq(tax, 0);
        assertEq(num, 0);
        assertEq(hop, 1);
    }

    function test_boot_already_init() public {
        sum.boot(me);

        vm.expectRevert("Sum/inc-already-init");
        sum.boot(me);
    }

    function test_frob_inc() public {
        sum.boot(me);

        sum.frob(me, 1);
        (uint256 net, uint256 tab, uint256 tax, uint256 num, uint256 hop) = sum.incs(me);

        assertEq(net, 1);
        assertEq(tab, 1);
        assertEq(tax, 0);
        assertEq(num, 1);
        assertEq(hop, 1);

        sum.frob(me, 1);
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 2);
        assertEq(tab, 2);
        assertEq(tax, 0);
        assertEq(num, 2);
        assertEq(hop, 1);

        sum.frob(me, 1);
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 3);
        assertEq(tab, 3);
        assertEq(tax, 0);
        assertEq(num, 3);
        assertEq(hop, 1);
    }

    function test_frob_dec_underflow() public {
        sum.boot(me);

        vm.expectRevert("Sum/not-safe-hop");
        sum.frob(me, -1);
    }

    function test_frob_dec() public {
        sum.boot(me);

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

        sum.frob(me, -1);
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 4);
        assertEq(tab, 5);
        assertEq(tax, 1);
        assertEq(num, 6);
        assertEq(hop, 1);

        sum.frob(me, -1);
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 3);
        assertEq(tab, 5);
        assertEq(tax, 2);
        assertEq(num, 7);
        assertEq(hop, 1);

        sum.frob(me, -1);
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 2);
        assertEq(tab, 5);
        assertEq(tax, 3);
        assertEq(num, 8);
        assertEq(hop, 1);

        sum.frob(me, -1);
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 1);
        assertEq(tab, 5);
        assertEq(tax, 4);
        assertEq(num, 9);
        assertEq(hop, 1);

        sum.frob(me, -1);
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 0);
        assertEq(tab, 5);
        assertEq(tax, 5);
        assertEq(num, 10);
        assertEq(hop, 1);

        vm.expectRevert("Sum/not-safe-hop");
        sum.frob(me, -1);
    }

    function test_frob_uninitialized_inc() public {
        vm.expectRevert("Sum/inc-not-init");
        sum.frob(me, 1);
    }

    function test_frob_invalid_sinc(int sinc) public {
        vm.assume(sinc != 1);
        vm.assume(sinc != -1);

        vm.expectRevert("Sum/not-allowed-sinc");
        sum.frob(me, sinc);
    }

    function test_zero() public {
        sum.boot(me);

        sum.frob(me, 1);
        (uint256 net, uint256 tab, uint256 tax, uint256 num, uint256 hop) = sum.incs(me);

        assertEq(net, 1);
        assertEq(tab, 1);
        assertEq(tax, 0);
        assertEq(num, 1);
        assertEq(hop, 1);

        sum.zero(me);
        (net, tab, tax, num, hop) = sum.incs(me);

        assertEq(net, 0);
        assertEq(tab, 0);
        assertEq(tax, 0);
        assertEq(num, 2);
        assertEq(hop, 1);
    }

    function test_file_one() public {
        sum.file("One", 2);

        sum.boot(me);
        sum.frob(me, 1);
        (uint256 net, uint256 tab, uint256 tax, uint256 num, uint256 hop) = sum.incs(me);

        assertEq(net, 2);
        assertEq(tab, 2);
        assertEq(tax, 0);
        assertEq(num, 1);
        assertEq(hop, 2);
    }

    function test_file_invalid_one() public {
        vm.expectRevert("Sum/not-allowed-one");
        sum.file("One", 0);
    }

    function test_file_unrecognized_param() public {
        vm.expectRevert("Sum/file-unrecognized-param");
        sum.file("Wat", 0);
    }

    function test_cage() public {
        sum.boot(me);

        sum.cage();

        vm.expectRevert("Sum/not-live");
        sum.file("One", 1);

        vm.expectRevert("Sum/not-live");
        sum.boot(me);

        vm.expectRevert("Sum/not-live");
        sum.zero(me);

        vm.expectRevert("Sum/not-live");
        sum.frob(me, 1);

        vm.expectRevert("Sum/not-live");
        sum.rely(me);

        vm.expectRevert("Sum/not-live");
        sum.deny(me);
    }

    function test_free() public {
        sum.boot(me);

        sum.cage();

        vm.expectRevert("Sum/not-live");
        sum.file("One", 1);

        vm.expectRevert("Sum/not-live");
        sum.boot(me);

        vm.expectRevert("Sum/not-live");
        sum.zero(me);

        vm.expectRevert("Sum/not-live");
        sum.frob(me, 1);

        vm.expectRevert("Sum/not-live");
        sum.rely(me);

        vm.expectRevert("Sum/not-live");
        sum.deny(me);

        sum.free();

        sum.file("One", 1);
        sum.zero(me);
        sum.frob(me, 1);
        sum.rely(me);
        sum.deny(me);
    }

    function test_rely_deny() public {
        address guy = address(1);

        sum.rely(guy);
        assertEq(sum.wards(me), 1);

        sum.deny(guy);
        assertEq(sum.wards(guy), 0);
    }

    function test_deny_unauthorized() public {
        sum.deny(me);

        vm.expectRevert("Sum/not-authorized");
        sum.rely(me);
    }

    function test_default_parameters() public {
        assertEq(sum.One(), 1);
        assertEq(sum.live(), 1);
    }
}
