#!/bin/sh

set -e

echo -n "Enter your file number: "
read number

pattern="${number}-*"
directory=$(find .. -maxdepth 1 -type d -name "$pattern")

if [ -n "$directory" ]; then
    # Change directory
    cd "$directory/circuits" 
    echo "found file: $(basename "$directory")"
else
    echo "Directory not found for number: $number"
    exit
fi

name="${directory#*-}"

circom="$name.circom"
r1cs="$name.r1cs"
sym="$name.sym"
wasm="$name.wasm"
witness="$name.witness"
zkey=""$name"_0001.zkey"
ptau="pot12_final.ptau"

main() {
    compile_circom
    cd ../build/"$name"_js
    compute_witness
    cd ../
    p_tau
    generate_proof
    verify
    generate_solidity
    echo "Mission Completed."
}

compile_circom() {
    echo "compiling circom file..."
    mkdir -p ../build
    circom $circom --r1cs --wasm --sym -o ../build
    if [ $? -ne 0 ]; then
        echo "Error: compilation error"
    fi
}

compute_witness() {
    echo "computing witness..."
    node generate_witness.js $wasm ../../circuits/input.json $witness
    if [ $? -ne 0 ]; then
        echo "Error: witness generation error"
    else
        echo "witness generated: $witness"
    fi
    mv $witness ../
}

p_tau() {
    # echo "powers of tau ceromony executing..."
    # snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
    # snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
    # snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
    
    snarkjs groth16 setup $r1cs ../../p_tau/$ptau "$name"_0000.zkey
    snarkjs zkey contribute "$name"_0000.zkey "$name"_0001.zkey --name="1st Contributor Name" -v
    snarkjs zkey export verificationkey "$name"_0001.zkey verification_key.json
}

generate_proof() {
    echo "Generating proof..."
    snarkjs groth16 prove $zkey $witness proof.json public.json
    if [ $? -ne 0 ]; then
        echo "Error: generate proof error"
    else
        echo "proof generated: proof.json, public.json"
    fi
}

verify() {
    echo "Proving..."
    snarkjs groth16 verify verification_key.json public.json proof.json
    if [ $? -ne 0 ]; then
        echo "Error: Verification error"
    else
        echo "You saved the world, verification done successfully."
    fi
}

generate_solidity() {
    snarkjs zkey export solidityverifier $zkey verifier.sol
    if [ $? -ne 0 ]; then
        echo "Error: Solidity generation error"
    else
        echo "Verifier.sol generated successfully."
    fi
}

main