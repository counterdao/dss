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
import {Spy} from "../src/spy.sol";

contract TestSpy is Test {
    Sum internal sum;
    Spy internal spy;

    address me = address(this);

    function setUp() public {
        sum = new Sum();
        spy = new Spy(address(sum));

        sum.boot(me);
    }

    function test_spy() public {
        sum.frob(me, 1);
        assertEq(spy.see(), 1);

        sum.frob(me, 1);
        assertEq(spy.see(), 2);

        sum.frob(me, 1);
        assertEq(spy.see(), 3);

        sum.frob(me, -1);
        assertEq(spy.see(), 2);

        sum.frob(me, -1);
        assertEq(spy.see(), 1);

        sum.frob(me, -1);
        assertEq(spy.see(), 0);
    }
}
