module Lang.Token exposing (Token, Type(..))


type alias Token =
    { line : Int -- 1-based
    , column : Int -- 1-based
    , type_ : Type
    }


type Type
    = Int Int
    | String String
    | Log
    | Print
    | Add
    | Multiply
