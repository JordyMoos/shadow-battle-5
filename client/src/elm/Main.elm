port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Page.Faq as Faq
import Page.Home as Home
import Route
import Url exposing (Url)


type alias Model =
    { url : Url
    , key : Nav.Key
    , pageState : PageState
    }


type PageState
    = HomePage Home.Model
    | FaqPage Faq.Model


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | HomeMsg Home.Msg
    | FaqMsg Faq.Msg
    | NoOp


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( homeModel, homeCmd ) =
            Home.init
    in
    ( { url = url
      , key = key
      , pageState = HomePage homeModel
      }
    , Cmd.map HomeMsg homeCmd
    )


changeRouteTo : Maybe Route.Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        _ =
            Debug.log "route" (Debug.toString maybeRoute)
    in
    case maybeRoute of
        Nothing ->
            ( model, Cmd.none )

        Just Route.Home ->
            let
                ( pageModel, pageCmd ) =
                    Home.init
            in
            ( { model | pageState = HomePage pageModel }
            , Cmd.map HomeMsg pageCmd
            )

        Just Route.Faq ->
            let
                ( pageModel, pageCmd ) =
                    Faq.init
            in
            ( { model | pageState = FaqPage pageModel }
            , Cmd.map FaqMsg pageCmd
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.pageState ) of
        ( HomeMsg pageMsg, HomePage pageModel ) ->
            ( model, Cmd.none )

        ( FaqMsg pageMsg, FaqPage pageModel ) ->
            ( model, Cmd.none )

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    let
                        _ =
                            Debug.log "url" (Debug.toString url)
                    in
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( _, _ ) ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Shadow Battle"
    , body =
        [ case model.pageState of
            HomePage pageModel ->
                Home.view pageModel
                    |> Html.map HomeMsg

            FaqPage pageModel ->
                Faq.view pageModel
                    |> Html.map FaqMsg
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
