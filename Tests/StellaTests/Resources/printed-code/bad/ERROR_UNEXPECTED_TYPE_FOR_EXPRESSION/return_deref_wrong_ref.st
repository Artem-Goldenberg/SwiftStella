language core;

extend with #references;

fn foo(n : Nat) -> Nat {
    return 0
}

fn main(n : Nat) -> Bool {
    return *new(foo(0))
}