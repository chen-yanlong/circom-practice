pragma circom 2.0.0;

template Square() {
    signal input in;
    signal output out;

    out <== in * in;
}

template useSquare() {
    signal input a;
    signal input b;
    signal output c;

    component sq1 = Square();
    component sq2 = Square();

    sq1.in <== a;
    sq2.in <== b;
    c <== sq1.out + sq2.out;
}

component main {public [a]} = useSquare();