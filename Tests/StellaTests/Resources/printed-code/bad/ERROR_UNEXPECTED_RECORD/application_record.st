language core;

extend with #records;

fn foo(x : Nat) -> Nat {
    return x
}

fn main(n : Nat) -> Nat {
    return foo({a = 0, b = false})
}