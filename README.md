# Decentralized Summation System

This repository contains the core smart contract code for the Decentralized
Summation System (`dss`). This is a high level description of the system, assuming
familiarity with the basic counting mechanics as described in the
[whitepaper](https://archive.org/details/arithmeticespri00peangoog/page/n6/mode/2up).

## System Diagram

![DSS System Diagram](/doc/dss-diagram.png?raw=true)

## Design Considerations

- Client agnostic
  - system doesn't care about the implementation of external contracts
  - can operate entirely independently of other systems

- Verifiable
  - designed from the bottom up to be amenable to formal verification
  - the core ICV and counter database makes *no* external calls and
    contains *no* precision loss (i.e. no division)

- Modular
  - multi contract core system is made to be very adaptable to changing
    requirements.
  - allows for the addition of novel counter types (e.g. count-by-threes, fibonacci)

## Usage

See the test cases in [`dss.t.sol`](https://github.com/counterdao/dss/blob/aa7809965a314a5c8fdf7e6b5d39a92bf0901c3f/test/dss.t.sol#L76) for annotated examples that demonstrate how to interact with `dss` from your own contracts.

## Sum — Counter Engine

The `Sum` is the core Counter engine of `dss`. It stores Counters and tracks
all the associated values. It also defines the rules by which Counters and values
can be manipulated. The rules defined in the `Sum` are immutable, so in some
sense, the rules in the `Sum` can be viewed as the constitution of `dss`.

Within the `Sum` an `Inc` represents a stored ICV (Integer Counter Value). The
attributes of an `Inc` are:
- `net`: The counter value.
- `tab`: The sum of all counter increment values.
- `tax`: The sum of all counter decrement values.
- `num`: Total number of counter operations, i.e. count of all `frob` and `zero` calls to this `Inc`.
- `hop`: The counter's increment unit.

Functions:
- `boot`: Register a new Counter.
- `zero`: Reset a Counter.
- `frob`: General function for manipulating a Counter.
  - `sinc`: "Sign of increment." 1 for increment, -1 for decrement.
- `wish`: Check whether an address is allowed to modify another address's Counter.
  - `hope`: enable `wish` for a pair of addresses.
  - `nope`: disable `wish` for a pair of addresses.

## Use — Counter creation module

The `Use` creates new Counters.

Functions:
- `use`: Initializes a new `Inc` associated with the caller's address.

## Hitter — Increment module

The `Hitter` is used to increment an initialized Counter.

Functions:
- `hit`: Increases a Counter's `net` and `tab` by one `hop`. Increments `num`.

## Dipper — Decrement module

The `Dipper` is used to decrement an initialized Counter.

Functions:
- `dip`: Decreases a Counter's `net` and `tax` by one `hop`. Increments `num`.

## Nil — Reset module

`Nil` is used to reset an initialized counter.

Functions:
- `nil`: Resets a Counter's `net`, `tab`, and `tax` to zero. Increments `num`.

## Spy — Counter read module

The `Spy` is used to read counter values.

Functions:
- `see`: Returns a Counter's `net`. View only function.

## DSS — Protocol interface module

The `DSS` module is an interface contract that composes other modules in
the `dss` system and provides a unified interface to the protocol.

Functions:
- `build`: Create a new `DSSProxy` with this `DSS` module as its target implementation. Authorizes
  `msg.sender` to interact with the proxy.
  - `wit`: A `bytes32` salt for the `create2` constructor.
  - `god`: Proxy owner address, authorized to update the implementation and manage `wards`.
- `bless`: Authorize the core `dss` modules (`Use`, `Hitter`, `Dipper`, and `Nil`).
- `use`: Create a new Counter.
- `see`: Read a Counter value.
- `hit`: Increment a Counter.
- `dip`: Decrement a Counter.
- `nil`: Reset a Counter.
- `hope`: Authorize a module to manipulate a Counter.
- `nope`: Revoke a module's authorization. This may be used to customize Counter
  behavior, e.g. disabling decrements and resets.

In most cases users should not interact directly with the `DSS` module, but instead use a `DSSProxy`.

## DSSProxy — Execute DSS actions

A `DSSProxy` is a transparent proxy contract that targets the `DSS` interface module as its
implementation. This enables callers to execute DSS actions through a persistent identity.
In most cases, users should create and interact with Counters through a `DSSProxy`.

In the event of a protocol upgrade, the `DSSProxy` owner may choose to `upgrade` their proxy to
target the latest `DSS` interface module.

`DSSProxy` includes a flexible authorization mechanism that allows multiple callers to interact
with a Counter through the proxy's persistent identity. This enables the creation of Counters
that may be shared by multiple contracts simultaneously, or used by many different contracts
over time.

Functions:
- `upgrade`: Set a new address as the target implementation. Only callable by the proxy `owner`
- `rely`: Authorize an address to call the proxy and interact with a Counter.
- `deny`: Revoke authorization from an address.

## System parameters

CTR token holders govern the core parameter of the DSS protocol, namely `One`.
The value of `One` represents the global counter increment unit. Newly initialized Counters
store the active `One` as their `hop` at creation time.

**Note:** The value of `One` is a **critical** system parameter and **must be set carefully by governance**.
An incorrect value of `One` may have unintended and far reaching consequences for
the DSS protocol and the systems that depend on it.

## Acknowledgments

- [shrugs](https://github.com/shrugs), author of the one and only[`Counters.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol).
- [karmacoma](https://github.com/karmacoma-eth), for creating [`enterprise-counters`](https://github.com/karmacoma-eth/enterprise-counters) and putting me up to this.
- [dapphub](https://github.com/dapphub) and [Maker](https://github.com/makerdao) for the greatest contracts of all time.
