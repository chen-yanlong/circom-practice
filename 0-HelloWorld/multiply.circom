// Example of circom document

pragma circom 2.0.0;

//in each template, we first declare its signals, and after that, the associated constraints.
template Multiply () {
    signal input a;
    signal input b;
    signal output c;

    c <== a * b;
}

component main = Multiply();