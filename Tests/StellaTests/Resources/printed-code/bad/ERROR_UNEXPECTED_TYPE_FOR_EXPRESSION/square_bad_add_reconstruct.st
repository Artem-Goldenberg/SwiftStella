language core;

extend with #type-reconstruction;

fn Nat::add(n : auto) -> auto {
    return fn(m : auto) {
        return Nat::rec(n, m, fn(i : auto) {
         return succ(i)
     })
    }
}

fn square(n : auto) -> auto {
    return Nat::rec(n, 0, fn(i : auto) {
        return fn(r : auto) {
         return Nat::add(i)(Nat::add(i)(succ(r)))
     }
    })
}

fn main(n : auto) -> auto {
    return square(n)
}