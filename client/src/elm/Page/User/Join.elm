module Page.User.Join exposing (Model, Msg(..), init, update, view)

import Html
    exposing
        ( Html
        , button
        , div
        , form
        , h1
        , h2
        , input
        , label
        , li
        , ol
        , table
        , td
        , text
        , tr
        )
import Html.Attributes as Attr exposing (class)
import Html.Events as Events
import Html.Layout as Layout
import Json.Encode as Encode
import Ports


type alias Model =
    { username : String
    }


type Msg
    = SetUsername String
    | Submit


init : ( Model, Cmd Msg )
init =
    ( { username = ""
      }
    , Cmd.none
    )


type alias Register =
    { username : String }


registerEncoder : Register -> Encode.Value
registerEncoder register =
    Encode.object
        [ ( "register"
          , Encode.object
                [ ( "username", Encode.string register.username )
                ]
          )
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetUsername username ->
            ( { model | username = username }, Cmd.none )

        Submit ->
            let
                _ =
                    Debug.log "Calling" "Ports.sendToWebSocket"
            in
            ( model
            , registerEncoder { username = model.username } |> Ports.sendToWebSocket
            )


view : Model -> Html Msg
view model =
    div
        []
        [ h1 [] [ text "Sign up" ]
        , div
            [ class "frame" ]
            [ div [ class "register" ]
                [ form [ Events.onSubmit Submit ]
                    [ table []
                        [ formUsername model.username
                        , formSubmit
                        ]
                    ]
                ]
            ]
        ]
        |> Layout.default


formUsername : String -> Html Msg
formUsername username =
    tr
        []
        [ td [] [ label [ Attr.for "username" ] [ text "Username" ] ]
        , td []
            [ input
                [ Attr.id "username"
                , Attr.value username
                , Events.onInput SetUsername
                ]
                []
            ]
        ]


formSubmit : Html Msg
formSubmit =
    tr
        []
        [ td [] [ text "" ]
        , td
            []
            [ button [ Attr.type_ "submit", Events.onClick Submit ] [ text "Join" ]
            ]
        ]
