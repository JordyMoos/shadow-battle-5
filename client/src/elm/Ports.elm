port module Ports exposing (receive, sendToWebSocket)

import Json.Encode as Encode


port sendToWebSocket : Encode.Value -> Cmd msg


port receive : (Encode.Value -> msg) -> Sub msg
