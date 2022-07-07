module Parser.Extra exposing
    ( many
    , nonempty
    , simpleKeyword
    )

import Parser exposing ((|.), (|=), Parser, Step(..))


many : Parser () -> Parser a -> Parser (List a)
many spaces p =
    Parser.loop [] (manyHelp spaces p)


manyHelp : Parser () -> Parser a -> List a -> Parser (Step (List a) (List a))
manyHelp spaces p vs =
    Parser.oneOf
        [ Parser.succeed (\v -> Loop (v :: vs))
            |= p
            |. spaces
        , Parser.succeed ()
            |> Parser.map (\_ -> Done (List.reverse vs))
        ]


nonempty : Parser a -> Parser a
nonempty p =
    Parser.succeed
        (\before x after ->
            if before == after then
                Parser.problem "Did not chomp anything"

            else
                Parser.succeed x
        )
        |= Parser.getOffset
        |= p
        |= Parser.getOffset
        |> Parser.andThen identity


simpleKeyword : String -> a -> Parser a
simpleKeyword string value =
    Parser.succeed value
        |. Parser.keyword string
