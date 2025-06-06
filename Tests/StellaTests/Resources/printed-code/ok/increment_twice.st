language core;

fn increment_twice(n : Nat) -> Nat {
    return succ(succ(n))
}

fn main(n : Nat) -> Nat {
    return increment_twice(n)
}