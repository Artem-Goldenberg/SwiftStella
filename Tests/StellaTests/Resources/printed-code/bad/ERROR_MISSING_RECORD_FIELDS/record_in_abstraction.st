language core;

extend with #records;

fn foo(n : Nat) -> fn(Nat) -> {current : Nat, next : Nat} {
    return fn(i : Nat) {
        return {next = succ(n)}
    }
}

fn main(n : Nat) -> Nat {
    return foo(0)(succ(0)).next
}