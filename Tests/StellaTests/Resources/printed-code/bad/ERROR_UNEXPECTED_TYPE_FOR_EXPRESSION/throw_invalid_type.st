language core;

extend with #exceptions, #natural-literals, #exception-type-declaration;

exception type = Nat

fn main(n : Nat) -> Nat {
    return throw(true)
}