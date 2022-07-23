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

import {DSS, DSSProxy, DSSLike} from "../src/dss.sol";
import {Sum} from "../src/sum.sol";
import {Use} from "../src/use.sol";
import {Hitter} from "../src/hit.sol";
import {Dipper} from "../src/dip.sol";
import {Nil} from "../src/nil.sol";
import {Spy} from "../src/spy.sol";

contract DSSTest is Test {
    Sum internal sum;
    Use internal use;
    Nil internal nil;
    Spy internal spy;

    Hitter internal hitter;
    Dipper internal dipper;

    DSS internal dss;

    address me    = address(this);
    address guy   = mkaddr('guy');
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
        vm.startPrank(guy);
        sum = new Sum();
        use = new Use(address(sum));
        nil = new Nil(address(sum));
        spy = new Spy(address(sum));

        hitter = new Hitter(address(sum));
        dipper = new Dipper(address(sum));

        dss = new DSS(
            address(sum),
            address(use),
            address(spy),
            address(hitter),
            address(dipper),
            address(nil)
        );
        vm.stopPrank();
    }
}

contract Examples is DSSTest {

    function test_example_create_basic_counter() public {
        // This example demonstrates creating a
        // basic counter.

        // Deploy a DSSProxy with Bob as admin
        address proxy = dss.build("", bob);

        // Our current address is authorized
        // to call the proxy and interact with
        // the DSS protocol. We can now create
        // a Counter.
        DSSLike inc = DSSLike(proxy);

        // First we call bless to authorize
        // core DSS modules to call the Sum
        // on our behalf.
        inc.bless();

        // Next, we create a new counter.
        inc.use();

        // Our counter starts at zero.
        assertEq(inc.see(), 0);

        // We can increment:
        inc.hit();
        inc.hit();
        inc.hit();
        assertEq(inc.see(), 3);

        // And decrement:
        inc.dip();
        assertEq(inc.see(), 2);

        // As well as reset to zero:
        inc.nil();
        assertEq(inc.see(), 0);
    }

    function test_example_create_custom_counter_up_only() public {
        // This example demonstrates creating a
        // custom counter that cannot be decremnted
        // or reset.

        // Deploy a DSSProxy with Bob as admin
        address proxy = dss.build("", bob);

        // Our current address is authorized
        // to call the proxy and interact with
        // the DSS protocol. We can now create
        // a Counter.
        DSSLike inc = DSSLike(proxy);

        // First we call bless to authorize
        // core DSS modules to call the Sum
        // on our behalf.
        inc.bless();

        // Disable the decrement module
        inc.nope(address(dipper));

        // Disable the reset module
        inc.nope(address(nil));

        // Create a new counter.
        inc.use();

        // Our counter starts at zero.
        assertEq(inc.see(), 0);

        // We can increment:
        inc.hit();
        inc.hit();
        inc.hit();
        assertEq(inc.see(), 3);

        // We cannot decrement:
        vm.expectRevert('Sum/not-allowed');
        inc.dip();

        // Nor reset to zero:
        vm.expectRevert('Sum/not-allowed');
        inc.nil();
    }

    function test_example_proxy_authorization() public {
        // This example demonstrates proxy auth.
        // The proxy owner may authorize multiple
        // callers to interact with DSS.

        // Deploy a DSSProxy with Bob as admin
        address proxy = dss.build("", bob);

        // Our current address is authorized
        // to call the proxy and interact with
        // the DSS protocol. We can now create
        // a Counter.
        DSSLike inc = DSSLike(proxy);

        // First we call bless to authorize
        // core DSS modules to call the Sum
        // on our behalf.
        inc.bless();

        // Next, we create a new counter.
        inc.use();

        // Our counter starts at zero.
        assertEq(inc.see(), 0);

        // We can increment:
        inc.hit();
        assertEq(inc.see(), 1);

        // As the owner of our DSSProxy, Bob
        // can authorize other addressess to
        // interact with our Counter. However,
        // he must use a DSSProxy interface to
        // access the authorization functions.
        DSSProxy admin = DSSProxy(proxy);

        // Bob grants access to Alice's address
        vm.prank(bob);
        admin.rely(alice);

        // Now Alice may also increment our Counter.
        vm.prank(alice);
        inc.hit();
        assertEq(inc.see(), 2);

        // This flexible multi-owner authentication
        // system can enable us to create immutable but
        // modular contracts that interact with our
        // Counter.
    }
}

contract TestDSS is DSSTest {

    function test_dss() public {
        // Authorize core modules
        dss.bless();

        // Create a new Counter
        dss.use();

        // Read counter
        assertEq(dss.see(), 0);

        // Increment counter
        dss.hit();
        assertEq(dss.see(), 1);

        dss.hit();
        assertEq(dss.see(), 2);

        dss.hit();
        assertEq(dss.see(), 3);

        // Reset counter
        dss.nil();
        assertEq(dss.see(), 0);

        // Increment counter
        dss.hit();
        assertEq(dss.see(), 1);

        dss.hit();
        assertEq(dss.see(), 2);

        // Decrement counter
        dss.dip();
        assertEq(dss.see(), 1);

        dss.dip();
        assertEq(dss.see(), 0);

        vm.expectRevert("Sum/not-safe-hop");
        dss.dip();
    }

    function test_nope_hitter() public {
        // Authorize core modules
        dss.bless();

        // Create a new Counter
        dss.use();

        // Revoke Hitter
        dss.nope(address(hitter));

        vm.expectRevert("Sum/not-allowed");
        dss.hit();
    }

    function test_nope_dipper() public {
        // Authorize core modules
        dss.bless();

        // Create a new Counter
        dss.use();

        // Revoke Hitter
        dss.nope(address(dipper));

        vm.expectRevert("Sum/not-allowed");
        dss.dip();
    }

    function test_nope_nil() public {
        // Authorize core modules
        dss.bless();

        // Create a new Counter
        dss.use();

        // Revoke Hitter
        dss.nope(address(nil));

        vm.expectRevert("Sum/not-allowed");
        dss.nil();
    }

    function test_dss_proxy() public {
        // Alice is proxy usr, Bob is proxy god
        vm.startPrank(alice);
        address proxyAddr = dss.build("", bob);
        DSSProxy proxy = DSSProxy(proxyAddr);
        DSSLike inc = DSSLike(address(proxy));
        vm.stopPrank();

        // Bob cannot call fallback
        vm.prank(bob);
        vm.expectRevert("DSSProxy/not-authorized");
        inc.bless();

        // Eve cannot call fallback
        vm.prank(eve);
        vm.expectRevert("DSSProxy/not-authorized");
        inc.bless();

        // Alice can call fallback as ward
        vm.startPrank(alice);

        // Authorize core modules
        inc.bless();

        // Create a new Counter
        inc.use();

        // Read counter
        assertEq(inc.see(), 0);

        // Increment counter
        inc.hit();
        assertEq(inc.see(), 1);

        inc.hit();
        assertEq(inc.see(), 2);

        inc.hit();
        assertEq(inc.see(), 3);

        // Reset counter
        inc.nil();
        assertEq(inc.see(), 0);

        // Increment counter
        inc.hit();
        assertEq(inc.see(), 1);

        inc.hit();
        assertEq(inc.see(), 2);

        // Decrement counter
        inc.dip();
        assertEq(inc.see(), 1);

        inc.dip();
        assertEq(inc.see(), 0);

        vm.expectRevert("Sum/not-safe-hop");
        inc.dip();

        vm.stopPrank();

        // Deploy new DSS module
        DSS upgraded = new DSS(
            address(sum),
            address(use),
            address(spy),
            address(hitter),
            address(dipper),
            address(nil)
        );

        // Alice cannot upgrade
        vm.expectRevert("ds-auth-unauthorized");
        vm.prank(alice);
        proxy.upgrade(address(upgraded));

        // Eve cannot upgrade
        vm.expectRevert("ds-auth-unauthorized");
        vm.prank(eve);
        proxy.upgrade(address(upgraded));

        // Bob can upgrade
        vm.prank(bob);
        proxy.upgrade(address(upgraded));

        // Allow access

        // Alice cannot add ward
        vm.expectRevert("ds-auth-unauthorized");
        vm.prank(alice);
        proxy.rely(carol);

        // Eve cannot upgrade
        vm.expectRevert("ds-auth-unauthorized");
        vm.prank(eve);
        proxy.rely(carol);

        // Bob can add ward
        vm.prank(bob);
        proxy.rely(carol);

        // Carol can interact with counter
        vm.startPrank(carol);
        assertEq(inc.see(), 0);

        inc.hit();
        assertEq(inc.see(), 1);

        inc.nil();
        assertEq(inc.see(), 0);

        inc.hit();
        assertEq(inc.see(), 1);

        inc.dip();
        assertEq(inc.see(), 0);

        vm.stopPrank();

        // Alice can interact with counter
        vm.startPrank(alice);
        assertEq(inc.see(), 0);

        inc.hit();
        assertEq(inc.see(), 1);

        vm.stopPrank();

        // Eve cannot interact with counter
        vm.expectRevert("DSSProxy/not-authorized");
        vm.prank(eve);
        inc.hit();

        // Revoke Alice's access
        vm.prank(bob);
        proxy.deny(alice);

        // Alice cannot interact with counter
        vm.expectRevert("DSSProxy/not-authorized");
        vm.prank(alice);
        inc.hit();

        // Carol can still interact with counter
        vm.startPrank(carol);

        inc.hit();
        assertEq(inc.see(), 2);

        vm.stopPrank();

        // Proxy ownership transfer

        // Alice cannot transfer
        vm.prank(alice);
        vm.expectRevert("ds-auth-unauthorized");
        proxy.setOwner(dan);

        // Eve cannot transfer
        vm.prank(eve);
        vm.expectRevert("ds-auth-unauthorized");
        proxy.setOwner(dan);

        // Bob can transfer
        vm.prank(bob);
        proxy.setOwner(dan);

        // Dan is now owner
        assertEq(proxy.owner(), dan);

        // Bob cannot transfer
        vm.prank(bob);
        vm.expectRevert("ds-auth-unauthorized");
        proxy.setOwner(bob);

        // Dan can transfer
        vm.prank(dan);
        proxy.setOwner(bob);

        // Bob is now owner
        assertEq(proxy.owner(), bob);
    }
}
