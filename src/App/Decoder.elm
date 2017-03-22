module App.Decoder exposing (..)

import Race.Model
import Result.Model
import Rider.Model
import Comment.Model
import Json.Decode
import Json.Decode.Extra
import Json.Decode.Pipeline
import Date


decodeCategory : String -> Json.Decode.Decoder Race.Model.Category
decodeCategory string =
    Json.Decode.succeed (category string)


category : String -> Race.Model.Category
category string =
    case string of
        "Klassieker" ->
            Race.Model.Classic

        "Criterium" ->
            Race.Model.Criterium

        "Regiocross" ->
            Race.Model.Regiocross

        "Other" ->
            Race.Model.Other

        _ ->
            Race.Model.Unknown


decodeLicence : String -> Json.Decode.Decoder (Maybe Rider.Model.Licence)
decodeLicence string =
    Json.Decode.succeed (licence string)


licenceDecoder : String -> Json.Decode.Decoder Rider.Model.Licence
licenceDecoder string =
    case string of
        "elite" ->
            Json.Decode.succeed Rider.Model.Elite

        "amateurs" ->
            Json.Decode.succeed Rider.Model.Amateurs

        "basislidmaatschap" ->
            Json.Decode.succeed Rider.Model.Basislidmaatschap

        "other" ->
            Json.Decode.succeed Rider.Model.Other

        _ ->
            Json.Decode.succeed Rider.Model.Other
            -- Json.Decode.fail <| string ++ " licence does not exists."


raceCategoryDecoder : String -> Json.Decode.Decoder Race.Model.Category
raceCategoryDecoder string =
    case string of
        "classic" ->
            Json.Decode.succeed Race.Model.Classic

        "criterum" ->
            Json.Decode.succeed Race.Model.Criterium

        "regiocross" ->
            Json.Decode.succeed Race.Model.Regiocross

        "other" ->
            Json.Decode.succeed Race.Model.Other

        "unknown" ->
            Json.Decode.succeed Race.Model.Unknown

        _ ->
            Json.Decode.succeed Race.Model.Unknown


resultCategoryDecoder : String -> Json.Decode.Decoder Result.Model.ResultCategory
resultCategoryDecoder string =
    case string of
        "amateurs" ->
            Json.Decode.succeed Result.Model.Amateurs

        "basislidmaatschap" ->
            Json.Decode.succeed Result.Model.Basislidmaatschap

        "cata" ->
            Json.Decode.succeed Result.Model.CatA

        "catb" ->
            Json.Decode.succeed Result.Model.CatB

        "unknown" ->
            Json.Decode.succeed Result.Model.Unknown

        _ ->
            Json.Decode.succeed Result.Model.Unknown


riderDecoder : Json.Decode.Decoder Rider.Model.Rider
riderDecoder =
    Json.Decode.Pipeline.decode Rider.Model.Rider
        |> Json.Decode.Pipeline.required "id" Json.Decode.int
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "licence"
            (Json.Decode.string
                |> Json.Decode.andThen licenceDecoder
                |> Json.Decode.nullable
            )


raceDecoder : Json.Decode.Decoder Race.Model.Race
raceDecoder =
    Json.Decode.Pipeline.decode Race.Model.Race
        |> Json.Decode.Pipeline.required "id" Json.Decode.int
        |> Json.Decode.Pipeline.required "name" Json.Decode.string
        |> Json.Decode.Pipeline.required "date" date
        |> Json.Decode.Pipeline.required "category"
            (Json.Decode.string
                |> Json.Decode.andThen raceCategoryDecoder
            )


date : Json.Decode.Decoder (Maybe Date.Date)
date =
    let
        convert : String -> Json.Decode.Decoder (Maybe Date.Date)
        convert raw =
            case Date.fromString raw of
                Ok date ->
                    Json.Decode.succeed <| Just date

                Err error ->
                    Json.Decode.succeed Nothing
    in
        Json.Decode.string
            |> Json.Decode.andThen convert


commentDecoder : Json.Decode.Decoder Comment.Model.Comment
commentDecoder =
    Json.Decode.Pipeline.decode Comment.Model.Comment
        |> Json.Decode.Pipeline.required "id" Json.Decode.int
        |> Json.Decode.Pipeline.required "updatedAt" date
        |> Json.Decode.Pipeline.required "raceId" Json.Decode.int
        |> Json.Decode.Pipeline.required "riderId" Json.Decode.int
        |> Json.Decode.Pipeline.required "text" Json.Decode.string


resultDecoder : Json.Decode.Decoder Result.Model.Result
resultDecoder =
    Json.Decode.Pipeline.decode Result.Model.Result
        |> Json.Decode.Pipeline.required "id" Json.Decode.int
        |> Json.Decode.Pipeline.required "riderId" Json.Decode.int
        |> Json.Decode.Pipeline.required "raceId" Json.Decode.int
        |> Json.Decode.Pipeline.required "result" Json.Decode.string
        |> Json.Decode.Pipeline.required "category"
            (Json.Decode.string
                |> Json.Decode.andThen resultCategoryDecoder
            )
        |> Json.Decode.Pipeline.required "strava"
            (Json.Decode.string
                |> Json.Decode.nullable
            )


licence : String -> Maybe Rider.Model.Licence
licence string =
    case string of
        "elite" ->
            Just Rider.Model.Elite

        "amateurs" ->
            Just Rider.Model.Amateurs

        "basislidmaatschap" ->
            Just Rider.Model.Basislidmaatschap

        _ ->
            Nothing


rider : Json.Decode.Decoder Rider.Model.Rider
rider =
    Json.Decode.map3 Rider.Model.Rider
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "licence"
            (Json.Decode.andThen decodeLicence Json.Decode.string)
        )


comment : Json.Decode.Decoder Comment.Model.Comment
comment =
    Json.Decode.map5 Comment.Model.Comment
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "updatedAt" date)
        --(Json.Decode.field "updatedAt" Json.Decode.string)
        (Json.Decode.field "raceId" Json.Decode.int)
        (Json.Decode.field "riderId" Json.Decode.int)
        (Json.Decode.field "text" Json.Decode.string)


decodeResultCategory : String -> Json.Decode.Decoder Result.Model.ResultCategory
decodeResultCategory string =
    Json.Decode.succeed (resultCategory string)


resultCategory : String -> Result.Model.ResultCategory
resultCategory string =
    case string of
        "amateurs" ->
            Result.Model.Amateurs

        "basislidmaatschap" ->
            Result.Model.Basislidmaatschap

        "cata" ->
            Result.Model.CatA

        "catb" ->
            Result.Model.CatB

        _ ->
            Result.Model.Unknown


result : Json.Decode.Decoder Result.Model.Result
result =
    Json.Decode.map6 Result.Model.Result
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "riderId" Json.Decode.int)
        (Json.Decode.field "raceId" Json.Decode.int)
        (Json.Decode.field "result" Json.Decode.string)
        (Json.Decode.field "category"
            (Json.Decode.string
                |> Json.Decode.andThen decodeResultCategory
            )
        )
        (Json.Decode.field "strava" (Json.Decode.maybe Json.Decode.string))


page : Json.Decode.Decoder String
page =
    Json.Decode.field "page" Json.Decode.string


type alias App =
    { page : String
    , riders :
        List Rider.Model.Rider
        --, races : List Race.Model.Race
    , comments : List Comment.Model.Comment
    , results : List Result.Model.Result
    }


app : Json.Decode.Decoder App
app =
    Json.Decode.map4 App
        (Json.Decode.field "page" Json.Decode.string)
        (Json.Decode.field "riders" (Json.Decode.list rider))
        --(Json.Decode.field "races" (Json.Decode.list race))
        (Json.Decode.field "comments" (Json.Decode.list comment))
        (Json.Decode.field "results" (Json.Decode.list result))
