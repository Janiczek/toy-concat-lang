module Lang.Emit exposing (emit)

import Json.Encode
import Lang.Common exposing (CompileInput, CompileOutput)
import Lang.Error exposing (Error(..))
import Lang.Token as Token exposing (Token)
import SourceMap exposing (SourceMap)


type alias State =
    { js : String
    , currentLine : Int
    , sourceMap : SourceMap
    , inputPath : String
    }


initState : CompileInput -> State
initState input =
    { js = jsPreamble
    , currentLine = List.length (String.lines jsPreamble) + 1
    , sourceMap =
        SourceMap.empty
            |> SourceMap.withFile input.outputJsPath
            |> SourceMap.withSourceRoot "http://localhost:8000/"
    , inputPath = input.inputPath
    }


jsPreamble : String
jsPreamble =
    """
let a, b, el;
let stack = [];
const pop = () => stack.pop();
const push = (x) => stack.push(x);
"""


emitToken : Token -> State -> State
emitToken token =
    addJs token <|
        case token.type_ of
            Token.Int int ->
                [ "push({INT});" |> String.replace "{INT}" (String.fromInt int)
                ]

            Token.String string ->
                [ "push({STRING});" |> String.replace "{STRING}" (quote (escape string))
                ]

            Token.Log ->
                [ "b = pop();"
                , "a = pop();"
                , "console.log(`${b}: ${a}`);"
                , "push(a);"
                ]

            Token.Print ->
                [ "a = pop();"
                , "el = document.createElement('div');"
                , "el.append(a);"
                , "document.body.append(el);"
                ]

            Token.Add ->
                [ "a = pop();"
                , "push(pop() + a);"
                ]

            Token.Multiply ->
                [ "a = pop();"
                , "push(pop() * a);"
                ]


quote : String -> String
quote string =
    "\"" ++ string ++ "\""


escape : String -> String
escape string =
    string
        |> String.replace "\n" "\\n"
        |> String.replace "\u{000D}" "\\r"
        |> String.replace "\t" "\\t"
        |> String.replace "\\" "\\\\"


addJs : Token -> List String -> State -> State
addJs token strings state =
    let
        length : Int
        length =
            List.length strings

        mappings : List SourceMap.Mapping
        mappings =
            List.range state.currentLine (state.currentLine + length)
                |> List.map
                    (\line ->
                        { generatedLine = line
                        , generatedColumn = 1
                        , source = state.inputPath
                        , originalLine = token.line
                        , originalColumn = token.column
                        , name = Nothing
                        }
                    )
    in
    { state
        | js = state.js ++ "\n" ++ String.join "\n" strings
        , sourceMap = SourceMap.addMappings mappings state.sourceMap
        , currentLine = state.currentLine + length
    }


emit : CompileInput -> List Token -> CompileOutput
emit input tokens =
    List.foldl emitToken (initState input) tokens
        |> finalize input


finalize : CompileInput -> State -> CompileOutput
finalize input state =
    { js = state.js
    , sourceMap = SourceMap.toString state.sourceMap
    }
