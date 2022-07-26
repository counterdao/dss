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

import {DSS} from "../src/dss.sol";
import {Sum} from "../src/sum.sol";
import {Use} from "../src/use.sol";
import {Hitter} from "../src/hit.sol";
import {Dipper} from "../src/dip.sol";
import {Nil} from "../src/nil.sol";
import {Spy} from "../src/spy.sol";

contract DeployDSS is Script {

    function deployDSS() public {
        Sum sum = new Sum();
        Use use = new Use(address(sum));
        Nil nil = new Nil(address(sum));
        Spy spy = new Spy(address(sum));

        Hitter hitter = new Hitter(address(sum));
        Dipper dipper = new Dipper(address(sum));

        new DSS(
            address(sum),
            address(use),
            address(spy),
            address(hitter),
            address(dipper),
            address(nil)
        );
    }

    function run() external {
        vm.startBroadcast();

        deployDSS();

        vm.stopBroadcast();
    }
}
