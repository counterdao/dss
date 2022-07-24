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

pragma solidity 0.5.16;

import {DSTest} from "ds-test/test.sol";

import {Sum} from "../../src/sum.sol";
import {CTR} from "../../src/gov/ctr.sol";
import {DSToken} from "ds-token/token.sol";
import {DSChief, DSChiefFab} from "ds-chief/chief.sol";
import {DSPause, DSPauseProxy} from "ds-pause/pause.sol";

interface VmLike {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function expectRevert(bytes calldata) external;
    function expectRevert(bytes4) external;
    function expectRevert() external;
    function label(address, string calldata) external;
}

contract TestGov is DSTest {

    // Can't use forge-std Test here
    address constant private VM_ADDRESS = address(bytes20(uint160(uint256(keccak256('hevm cheat code')))));
    VmLike public constant vm = VmLike(VM_ADDRESS);

    Sum internal sum;
    CTR internal ctr;
    DSChiefFab internal chiefFab;
    DSChief internal chief;
    DSPause internal pause;
    DSPauseProxy internal pauseProxy;

    address me = address(this);

    address alice = mkaddr('alice');
    address bob   = mkaddr('bob');
    address carol = mkaddr('carol');
    address dan   = mkaddr('dan');
    address eve   = mkaddr('eve');

    function mkaddr(string memory name) public returns (address addr) {
        addr = address(uint160(uint256(keccak256(abi.encodePacked(name)))));
        vm.label(addr, name);
    }

    function setUp() public {
        sum = new Sum();
        ctr = new CTR();
        chiefFab = new DSChiefFab();
        chief = chiefFab.newChief(ctr, 5);

        pause = new DSPause(172800, address(0), address(chief));
        pauseProxy = pause.proxy();
    }

    function test_governance_deployment() public {
        // Chief has no owner
        assertEq(chief.owner(), address(0));

        // Deployer address is ward of Sum
        assertEq(sum.wards(me), 1);

        // Deployer can call privileged operations on Sum
        sum.file("One", 2);
        assertEq(sum.One(), 2);

        sum.file("One", 1);
        assertEq(sum.One(), 1);

        // Authorize Pause proxy
        sum.rely(address(pauseProxy));

        // Pause proxy address is ward of Sum
        assertEq(sum.wards(address(pauseProxy)), 1);

        // Pause proxy can call privileged operations on Sum
        vm.startPrank(address(pauseProxy));
        sum.file("One", 2);
        assertEq(sum.One(), 2);

        sum.file("One", 1);
        assertEq(sum.One(), 1);
        vm.stopPrank();

        // Renounce deployer access to Sum
        sum.deny(me);

        // Deployer address is no longer ward of Sum
        assertEq(sum.wards(me), 0);

        // Cannot call privileged operations on Sum
        vm.expectRevert("Sum/not-authorized");
        sum.file("One", 2);

        // Deployer address holds full CTR supply
        assertEq(ctr.balanceOf(me), ctr.totalSupply());

        // Transfer to Alice
        ctr.push(alice, 100_000);

        // Transfer to Bob
        ctr.push(alice, 200_000);

        // Transfer to Carol
        ctr.push(alice, 300_000);
    }

}
