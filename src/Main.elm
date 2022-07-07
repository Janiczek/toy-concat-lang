port module Main exposing (main)

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


type alias CompileInput =
    { inputPath : String
    , inputContents : String
    , outputJsPath : String
    }


type CompileError
    = NotImplemented


type alias CompileOutput =
    { js : String
    , sourceMap : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        result : Result CompileError CompileOutput
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
    "//# sourceMappingURL=localhost:8000/" ++ sourceMapPath outputJsPath


compile : CompileInput -> Result CompileError CompileOutput
compile input =
    Ok
        { js = "js"
        , sourceMap = "sourceMap"
        }
