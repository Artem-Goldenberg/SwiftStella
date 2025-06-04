language core;

extend with #type-reconstruction;

fn Nat::add(n : auto) -> auto {
    return fn(m : auto) {
        return Nat::rec(n, m, fn(i : auto) {
         return fn(r : auto) {
          return succ(r)
      }
     })
    }
}

fn square(n : auto) -> auto {
    return Nat::rec(n, 0, fn(i : auto) {
        return Nat::add(i)(Nat::add(i)(succ(i)))
    })
}

fn main(n : auto) -> auto {
    return square(n)
}