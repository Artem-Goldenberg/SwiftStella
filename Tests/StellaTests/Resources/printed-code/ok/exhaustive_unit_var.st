language core;

extend with #structural-patterns, #unit-type;

fn main(n : Nat) -> Nat {
    return match unit {
        a => 0
    }
}