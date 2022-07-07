module Lang.Parser exposing (parse)

import Lang.Error exposing (Error(..))
import Lang.Token as Token exposing (Token)
import Parser exposing ((|.), (|=), Parser)
import Parser.Extra as Parser
import Result.Extra as Result


parse : String -> Result Error (List Token)
parse input =
    Parser.run parser input
        |> Result.mapError ParserError


parser : Parser (List Token)
parser =
    Parser.many whitespaceParser tokenParser


whitespaceParser : Parser ()
whitespaceParser =
    Parser.nonempty Parser.spaces


tokenParser : Parser Token
tokenParser =
    Parser.succeed Token
        |= Parser.getRow
        |= Parser.getCol
        |= tokenTypeParser


tokenTypeParser : Parser Token.Type
tokenTypeParser =
    Parser.oneOf
        [ Parser.simpleKeyword "log" Token.Log
        , Parser.simpleKeyword "print" Token.Print
        , Parser.simpleKeyword "+" Token.Add
        , Parser.simpleKeyword "*" Token.Multiply
        , Parser.map Token.Int Parser.int
        , stringParser
        ]


stringParser : Parser Token.Type
stringParser =
    Parser.succeed identity
        |. Parser.symbol "\""
        |= (Parser.chompUntil "\""
                |> Parser.getChompedString
           )
        |. Parser.symbol "\""
        |> Parser.map Token.String
