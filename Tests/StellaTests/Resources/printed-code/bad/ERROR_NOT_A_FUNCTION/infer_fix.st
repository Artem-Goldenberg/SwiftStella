language core;

extend with #fixpoint-combinator;

fn foo(a : Nat) -> Nat {
    return 0
}

fn main(n : Nat) -> Nat {
    return (fn(a : Nat) {
        return fix(0)
    })(0)
}