language core;

extend with #nested-function-declarations;

fn main(n : Bool) -> Nat {
    fn nested(n : Nat) -> Bool {
        return if n then n else false
    }
    return if nested(0) then 0 else succ(0)
}