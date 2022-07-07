module Result.Extra exposing (traverse, try)


sequence : List (Result x a) -> Result x (List a)
sequence =
    List.foldr (Result.map2 (::)) (Ok [])


traverse : (a -> Result e b) -> List a -> Result e (List b)
traverse fn inputs =
    sequence (List.map fn inputs)


try : (() -> Result e a) -> Result e a -> Result e a
try thunk current =
    case current of
        Err _ ->
            thunk ()

        Ok _ ->
            current
