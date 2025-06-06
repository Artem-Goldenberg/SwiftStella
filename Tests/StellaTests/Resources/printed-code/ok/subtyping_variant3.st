language core;

extend with #variants, #natural-literals, #top-type, #bottom-type, #structural-subtyping;

fn fail(n : Nat) -> <|failure : Top, value : Nat|> {
    return <|failure = 1|>
}

fn main(n : Nat) -> Top {
    return fail(n)
}