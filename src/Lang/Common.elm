module Lang.Common exposing (CompileInput, CompileOutput)


type alias CompileInput =
    { inputPath : String
    , inputContents : String
    , outputJsPath : String
    }


type alias CompileOutput =
    { js : String
    , sourceMap : String
    }
