port module Page.Race.Update exposing (..)

import App.Msg exposing (Msg(..))
import App.Model exposing (App)
import App.Page
import App.Helpers
import Page.Race.Add.Model as RaceAdd
import Date
import Date.Extra
import Task
import App.Helpers
import App.Routing
import Json.Encode
import Json.Decode
import Date.Extra.Format
import Date.Extra.Config.Config_nl_nl exposing (config)
import Date
import Json.Decode.Extra
import Data.RaceType as RaceType exposing (RaceType)
import Data.Race exposing (Race)


port addRace : Json.Encode.Value -> Cmd msg


addPage2 : App.Msg.Msg -> App.Page.Page -> App.Page.Page
addPage2 msg page =
    case page of
        App.Page.RaceAdd raceAdd ->
            case msg of
                RaceName name ->
                    App.Page.RaceAdd <| addName name raceAdd

                RaceAddRaceType raceType ->
                    App.Page.RaceAdd <| addRaceType raceType raceAdd

                _ ->
                    page

        _ ->
            page


addPage : App.Msg.Msg -> Maybe RaceAdd.Model -> Maybe RaceAdd.Model
addPage msg maybeRaceAdd =
    case maybeRaceAdd of
        Just raceAdd ->
            case msg of
                RaceName name ->
                    Just <| addName name raceAdd

                RaceAddRaceType raceType ->
                    Just <| addRaceType raceType raceAdd

                _ ->
                    Nothing

        Nothing ->
            Nothing


addName : String -> RaceAdd.Model -> RaceAdd.Model
addName newName raceAdd =
    { raceAdd | name = newName }


addRaceType : RaceType -> RaceAdd.Model -> RaceAdd.Model
addRaceType raceType raceAdd =
    { raceAdd | raceType = raceType }


dateFormat : Date.Date -> String
dateFormat date =
    Date.Extra.Format.format config "%Y-%m-%d 00:00:00" date


addSubmit : RaceAdd.Model -> App.Model.App -> ( App, Cmd Msg )
addSubmit raceAdd app =
    let
        dateString =
            dateFormat raceAdd.calendar.value

        payload =
            Json.Encode.object
                [ ( "name", Json.Encode.string raceAdd.name )
                , ( "date", Json.Encode.string dateString )
                , ( "category", Json.Encode.string <| raceTypeToString raceAdd.raceType )
                ]
    in
        ( app, addRace payload )


raceType : String -> RaceType
raceType string =
    case string of
        "classic" ->
            RaceType.Classic

        "criterium" ->
            RaceType.Criterium

        "regiocross" ->
            RaceType.Regiocross

        "other" ->
            RaceType.Other

        _ ->
            RaceType.Other


raceTypeToString : RaceType -> String
raceTypeToString category =
    case category of
        RaceType.Classic ->
            "classic"

        RaceType.Criterium ->
            "criterium"

        RaceType.Regiocross ->
            "regiocross"

        RaceType.Other ->
            "other"

        RaceType.Unknown ->
            "unknown"


raceTypeDecoder : String -> Json.Decode.Decoder RaceType
raceTypeDecoder string =
    Json.Decode.succeed (raceType string)


race : Json.Decode.Decoder Race
race =
    Json.Decode.map4
        Race
        (Json.Decode.field "key" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "date" Json.Decode.Extra.date)
        (Json.Decode.field "category"
            (Json.Decode.andThen raceTypeDecoder Json.Decode.string)
        )


racesDecoder : Json.Decode.Decoder (List Race)
racesDecoder =
    Json.Decode.list race


racesJson : Json.Decode.Value -> App -> ( App, Cmd Msg )
racesJson json app =
    let
        nextRacesResult =
            Json.Decode.decodeValue racesDecoder json
    in
        case nextRacesResult of
            Ok races ->
                ( { app | races = Just races }
                , Cmd.none
                )

            _ ->
                ( app, Cmd.none )
