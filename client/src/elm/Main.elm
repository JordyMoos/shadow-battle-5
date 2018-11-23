port module Main exposing (main)

import Browser
import Html exposing (Html)
import Page.Home as Home


type alias Model =
    { pageState : PageState
    }


type PageState
    = HomePage Home.Model


type Msg
    = HomeMsg Home.Msg


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( homeModel, homeCmd ) =
            Home.init
    in
    ( { pageState = HomePage homeModel
      }
    , Cmd.map HomeMsg homeCmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.pageState ) of
        ( HomeMsg pageMsg, HomePage pageModel ) ->
            ( model, Cmd.none )



--        ( _, _ ) ->
--            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model.pageState of
        HomePage homeModel ->
            Home.view homeModel
                |> Html.map HomeMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
