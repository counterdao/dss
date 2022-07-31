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
pragma solidity ^0.8.15;

import "forge-std/Script.sol";

interface CTRLike {
    function balanceOf(address) external view returns (uint256);
    function push(address, uint256) external;
}

contract SendCTR is Script {

    function sendCTR(address ctr, address dst) public {
        CTRLike token = CTRLike(ctr);
        token.push(dst, 50_000 ether);
    }

    function run() external {
        vm.startBroadcast();

        address ctr = vm.envAddress("DSS_CTR_ADDRESS");
        address dst = vm.envAddress("CTR_DST_ADDRESS");
        sendCTR(ctr, dst);

        vm.stopBroadcast();
    }
}
