port module Main exposing (main)

import Lang.Common exposing (CompileInput, CompileOutput)
import Lang.Emit as Emit
import Lang.Error exposing (Error(..))
import Lang.Parser as Parser
import Platform


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


port stderr : String -> Cmd msg


port writeFileWithConfirmation : { path : String, contents : String } -> Cmd msg


type alias Flags =
    CompileInput


type alias Model =
    ()


type alias Msg =
    Never


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        result : Result Error CompileOutput
        result =
            compile flags
    in
    ( ()
    , case result of
        Err err ->
            stderr (Debug.toString result)

        Ok out ->
            Cmd.batch
                [ writeFileWithConfirmation
                    { path = flags.outputJsPath
                    , contents = out.js ++ "\n" ++ sourceMapComment flags.outputJsPath
                    }
                , writeFileWithConfirmation
                    { path = sourceMapPath flags.outputJsPath
                    , contents = out.sourceMap
                    }
                ]
    )


sourceMapPath : String -> String
sourceMapPath outputJsPath =
    outputJsPath ++ ".map"


sourceMapComment : String -> String
sourceMapComment outputJsPath =
    "//# sourceMappingURL=http://localhost:8000/" ++ sourceMapPath outputJsPath


compile : CompileInput -> Result Error CompileOutput
compile input =
    input.inputContents
        |> Parser.parse
        |> Debug.log "parsed"
        |> Result.map (Emit.emit input >> Debug.log "emitted")
