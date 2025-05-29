language core;

fn main(n : Nat) -> Nat {
    return Nat::rec(n, succ(0), fn(i : Bool) {
        return fn(r : Nat) {
         return 0
     }
    })
}