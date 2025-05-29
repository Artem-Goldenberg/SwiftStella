language core;

extend with #sum-types;

fn main(succeed : Bool) -> Nat + Bool {
    return inl(true)
}