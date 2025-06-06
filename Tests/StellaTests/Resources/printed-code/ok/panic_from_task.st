language core;

extend with #panic, #pairs, #fixpoint-combinator;

fn dec(n : Nat) -> Nat {
    return Nat::rec(n, {0, 0}, fn(k : Nat) {
        return fn(p : {Nat, Nat}) {
         return {succ(p.1), p.1}
     }
    }).2
}

fn sub(n : Nat) -> fn(Nat) -> Nat {
    return fn(m : Nat) {
        return Nat::rec(m, n, fn(k : Nat) {
         return dec
     })
    }
}

fn mkdiv(div : fn(Nat) -> fn(Nat) -> Nat) -> fn(Nat) -> fn(Nat) -> Nat {
    return fn(n : Nat) {
        return fn(m : Nat) {
         return if Nat::iszero(n) then 0 else succ(div(sub(n)(m))(m))
     }
    }
}

fn div(n : Nat) -> fn(Nat) -> Nat {
    return fn(m : Nat) {
        return if Nat::iszero(m) then panic! else fix(mkdiv)(n)(m)
    }
}

fn main(n : Nat) -> Nat {
    return div(n)(n)
}