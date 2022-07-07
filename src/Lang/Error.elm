module Lang.Error exposing (Error(..))

import Parser


type Error
    = ParserError (List Parser.DeadEnd)
    | NotImplemented
