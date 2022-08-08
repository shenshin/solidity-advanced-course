Apart from switching from `call` to `delegatecall`,
as mentioned in the other answer,
there is a more "manual" approach:

Do not use `call` altogether, and instead invoke the functions by name.
This can be accomplished using an `if ... else` control structure that compares
the `selector` parameter with the intended function selector (`purchase`):

```solidity
  function onTransferReceived(
    address from,
    uint tokensPaid,
    bytes4 selector
  ) public acceptedTokenOnly {
    if (selector == this.purchase.selector) {
      purchase(from, tokensPaid);
    } else {
      revert("Call of an unknown function");
    }
  }
```

While this is more tedious to do, it might be preferable from a security point of view.
For example, if you wish to white-list the functions that you allow to be called through
this mechanism.
Note that the approach using `call`/ `delegatecall` exposes a potential vulnerability
for arbitrary (and possibly unintended) function execution.