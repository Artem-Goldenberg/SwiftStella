language core;

extend with #tuples;

fn foo(x : Nat) -> fn(Nat) -> {Nat, Nat} {
    return fn(i : Nat) {
        return {i, i, i}
    }
}

fn main(n : Nat) -> {Nat, Nat} {
    return foo(n)(n)
}