# Mirocana Token, Presale & Crowdsale contracts

This contracts implement MIRO token (more at [official Mirocana site](https://mirocana.com)), open tokens presale and crowdsale.

## Dependenies
To complete tests on this contracts you need.

* testrpc
* truffle

## Run test
In separate tab start `testrpc` with command:
```sh
$ testrpc
```

On first tab from project folder run:
```sh
$ cd miro-token
$ truffle compile
$ truffle migrate
$ truffle test
```

In next time you can use only `truffle test` command.
