pragma circom 2.0.0;

template PublicInputs () {
    signal input a;
    signal input b;
    signal input c;
    signal output d;

    signal e;
    e <== a * b;
    d <== e * c;
}

component main {public [a,b]}= PublicInputs();