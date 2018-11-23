module Page.Home exposing (Model, Msg(..), init, update, view)

import Html exposing (Html)
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
    Html.text "Home page"
        |> Layout.default
