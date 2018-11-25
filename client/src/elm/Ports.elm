port module Ports exposing (receive, send)

import Json.Encode as Encode


port send : Encode.Value -> Cmd msg


port receive : (Encode.Value -> msg) -> Sub msg
