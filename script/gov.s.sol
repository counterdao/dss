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

import {CTR} from "../src/gov/ctr.sol";
import {DssSpell} from "../src/gov/spell.sol";
import {DSToken} from "ds-token/token.sol";
import {DSChief} from "ds-chief/chief.sol";
import {DSPause, DSPauseProxy} from "ds-pause/pause.sol";

interface VmLike {
    function startBroadcast() external;
    function stopBroadcast() external;
    function envAddress(string calldata key) external returns (address value);
}

interface SumLike {
    function rely(address) external;
    function deny(address) external;
}

contract DeployGov {

    // Can't use forge-std Script here
    bool public IS_SCRIPT = true;
    address private constant VM_ADDRESS = address(bytes20(uint160(uint256(keccak256('hevm cheat code')))));
    VmLike public constant vm = VmLike(VM_ADDRESS);

    uint256 public constant MAX_YAYS = 5;
    uint256 public constant DELAY    = 172_800;

    function deployGov(address sum) public {
        address            me = address(this);
        CTR               ctr = new CTR();
        DSToken           iou = new DSToken('IOU');
        DSChief         chief = new DSChief(ctr, iou, MAX_YAYS);
        DSPause         pause = new DSPause(DELAY, address(0), address(chief));
        DSPauseProxy    proxy = pause.proxy();

        // Renounce CTR ownership
        ctr.setOwner(address(0));

        // Transfer IOU ownership to Chief
        iou.setOwner(address(chief));

        // Grant Sum access to Pause proxy
        SumLike(sum).rely(address(proxy));

        // Revoke Sum access from deployer
        SumLike(sum).deny(msg.sender);
    }

    function run() external {
        vm.startBroadcast();

        address sum = vm.envAddress("DSS_SUM_ADDRESS");
        deployGov(sum);

        vm.stopBroadcast();
    }
}
