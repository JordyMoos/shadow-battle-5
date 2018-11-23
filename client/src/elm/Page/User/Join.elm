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
import Html.Layout as Layout


type alias Model =
    {}


type Msg
    = NoOp


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div
        []
        [ h1 [] [ text "Sign up" ]
        , div
            [ class "frame" ]
            [ div [ class "register" ]
                [ form []
                    [ table []
                        [ formUsername model
                        , formSubmit
                        ]
                    ]
                ]
            ]
        ]
        |> Layout.default


formUsername : Model -> Html Msg
formUsername model =
    tr
        []
        [ td
            []
            [ label [ Attr.for "username" ] [ text "Username" ]
            ]
        , td
            []
            [ input [ Attr.id "username", Attr.type_ "text", Attr.name "username", Attr.value "" ] []
            ]
        ]


formSubmit : Html Msg
formSubmit =
    tr
        []
        [ td [] [ text "" ]
        , td
            []
            [ button [] [ text "Join" ]
            ]
        ]
