language core;

extend with #let-bindings;

fn Nat::add(n : Nat) -> fn(Nat) -> Nat {
    return fn(m : Nat) {
        return Nat::rec(n, m, fn(i : Nat) {
         return fn(r : Nat) {
          return succ(r)
      }
     })
    }
}

fn square(n : Nat) -> Nat {
    return Nat::rec(n, 0, fn(i : Nat) {
        return fn(r : Nat) {
         return let double = Nat::add(i)(i) in Nat::add(double)(succ(r))
     }
    })
}

fn main(n : Nat) -> Nat {
    return square(n)
}