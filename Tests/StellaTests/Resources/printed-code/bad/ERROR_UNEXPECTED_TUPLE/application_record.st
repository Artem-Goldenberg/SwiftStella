language core;

extend with #tuples;

fn foo(x : Nat) -> Nat {
    return x
}

fn main(n : Nat) -> Nat {
    return foo({0, false})
}