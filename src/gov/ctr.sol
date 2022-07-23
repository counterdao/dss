// SPDX-License-Identifier: AGPL-3.0-or-later

/// ctr.sol -- Counter governance token

// Copyright (C) 2022 Horsefacts <horsefacts@terminally.online>
// Copyright (C) 2015, 2016, 2017  DappHub, LLC
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

import {DSToken} from "ds-token/token.sol";

contract CTR is DSToken {

    constructor() DSToken("CTR") public {
        setName("Counter");
        mint(msg.sender, 1_000_000 ether);
    }

}
