module Page.Faq exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, div, h1, h2, li, ol, text)
import Html.Attributes exposing (class)
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
        [ h1 [] [ text "FAQ" ]
        , div
            [ class "frame" ]
            [ text "Awesome F.A.Q. page"
            ]
        ]
        |> Layout.default
