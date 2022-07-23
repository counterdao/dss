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

pragma solidity >=0.4.23 <0.7.0;

import "forge-std/Test.sol";

import {CTR} from "../../src/gov/ctr.sol";

contract TestCTR is Test {
    CTR internal ctr;

    address me = address(this);

    function setUp() public {
        ctr = new CTR();
    }

    function test_symbol() public {
        assertEq(ctr.symbol(), "CTR");
    }

    function test_name() public {
        assertEq(ctr.name(), "Counter");
    }

    function test_supply() public {
        assertEq(ctr.balanceOf(me), ctr.totalSupply());
        assertEq(ctr.totalSupply(), 1_000_000 ether);
    }

}
