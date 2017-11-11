port module Main exposing (..)

import Navigation
import Json.Decode
import App.Model exposing (App)
import App.Routing
import App.Msg exposing (Msg(..))
import App.Update
import App.UrlUpdate
import App.View
import App.Flags exposing (Flags)
import App.OutsideInfo

port setRaces : (Json.Decode.Value -> msg) -> Sub msg
port setResults : (Json.Decode.Value -> msg) -> Sub msg

port raceAdded : (Json.Decode.Value -> msg) -> Sub msg
port riderAdded : (Json.Decode.Value -> msg) -> Sub msg
port resultAdded: (Json.Decode.Value -> msg) -> Sub msg

main : Program Flags App Msg
main =
    Navigation.programWithFlags
        parser
        { init = init
        , update = App.Update.update
        , subscriptions = subscriptions
        , view = App.View.view
        }


parser : Navigation.Location -> Msg
parser location =
    UrlUpdate (App.Routing.routeParser location)


init : Flags -> Navigation.Location -> ( App, Cmd Msg )
init flags location =
    let
        route =
            App.Routing.routeParser location

        initialApp =
            App.Model.initial flags

        ( app, cmd ) =
            App.UrlUpdate.urlUpdate route initialApp
    in
        ( app, cmd )


subscriptions : App -> Sub Msg
subscriptions app =
    Sub.batch
        [ setRaces RacesJson
        , setResults ResultsJson
        , raceAdded RaceAddedJson
        , riderAdded RiderAddedJson
        , resultAdded ResultAddedJson
        , App.OutsideInfo.getInfoFromOutside App.Msg.Outside App.Msg.LogErr
        ]
