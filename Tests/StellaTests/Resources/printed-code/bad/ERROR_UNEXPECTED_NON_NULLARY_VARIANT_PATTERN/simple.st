language core;

extend with #structural-patterns, #natural-literals, #variants, #nullary-variant-labels;

fn main(n : <|a : Nat, b, c|>) -> Nat {
    return match n {
        <|b = t|> => 0
        | m => 0
    }
}