module BetaGouv.DSFR.Input exposing (InputConfig, InputType(..), MandatoryInputConfig, OptionalInputConfig, date, defaultOptions, email, input, new, number, password, textArea, textDisplay, view, withDisabled, withError, withExtraAttrs, withHint, withOptions, withReadonly, withType)

import Accessibility as Html exposing (Attribute, Html)
import Accessibility.Aria as Aria
import BetaGouv.DSFR.Typography
import Html as Root
import Html.Attributes as Attr
import Html.Attributes.Extra exposing (empty)
import Html.Events as Events
import Html.Extra exposing (nothing)
import Json.Encode as Encode


input : MandatoryInputConfig msg -> Html msg
input config =
    view { mandatory = config, optional = defaultOptions }


type InputType
    = TextInput
    | EmailInput
    | PasswordInput
    | TextArea (Maybe Int)
    | DateInput
    | NumberInput
    | TextDisplay


new : MandatoryInputConfig msg -> InputConfig msg
new mandatory =
    { mandatory = mandatory, optional = defaultOptions }


withOptions : OptionalInputConfig msg -> InputConfig msg -> InputConfig msg
withOptions optional config =
    { config | optional = optional }


withHint : List (Html Never) -> InputConfig msg -> InputConfig msg
withHint hint { mandatory, optional } =
    { mandatory = mandatory, optional = { optional | hint = hint } }


withError : Maybe (List (Html msg)) -> InputConfig msg -> InputConfig msg
withError errorMsg { mandatory, optional } =
    { mandatory = mandatory, optional = { optional | errorMsg = errorMsg } }


withDisabled : Bool -> InputConfig msg -> InputConfig msg
withDisabled disabled { mandatory, optional } =
    { mandatory = mandatory, optional = { optional | disabled = disabled } }


withReadonly : Bool -> InputConfig msg -> InputConfig msg
withReadonly readonly { mandatory, optional } =
    { mandatory = mandatory, optional = { optional | readonly = readonly } }


withType : InputType -> InputConfig msg -> InputConfig msg
withType type_ { mandatory, optional } =
    { mandatory = mandatory, optional = { optional | type_ = type_ } }


textArea : Maybe Int -> InputConfig msg -> InputConfig msg
textArea rows =
    withType <| TextArea rows


email : InputConfig msg -> InputConfig msg
email =
    withType <| EmailInput


password : InputConfig msg -> InputConfig msg
password =
    withType <| PasswordInput


textDisplay : InputConfig msg -> InputConfig msg
textDisplay =
    withType TextDisplay


date : InputConfig msg -> InputConfig msg
date =
    withType DateInput


number : InputConfig msg -> InputConfig msg
number =
    withType NumberInput


withExtraAttrs : List (Attribute Never) -> InputConfig msg -> InputConfig msg
withExtraAttrs extraAttrs { mandatory, optional } =
    { mandatory = mandatory, optional = { optional | extraAttrs = extraAttrs } }


type alias InputConfig msg =
    { mandatory : MandatoryInputConfig msg
    , optional : OptionalInputConfig msg
    }


type alias MandatoryInputConfig msg =
    { value : String
    , onInput : String -> msg
    , label : Html Never
    , name : String
    }


type alias OptionalInputConfig msg =
    { disabled : Bool
    , readonly : Bool
    , validMsg : Maybe (List (Html msg))
    , errorMsg : Maybe (List (Html msg))
    , hint : List (Html Never)
    , icon : Maybe String
    , type_ : InputType
    , extraAttrs : List (Attribute Never)
    }


defaultOptions : OptionalInputConfig msg
defaultOptions =
    { disabled = False
    , readonly = False
    , validMsg = Nothing
    , errorMsg = Nothing
    , hint = []
    , icon = Nothing
    , type_ = TextInput
    , extraAttrs = []
    }


view : InputConfig msg -> Html msg
view { mandatory, optional } =
    let
        { label, onInput, value } =
            mandatory

        name =
            "input-" ++ mandatory.name

        { errorMsg, validMsg, disabled, readonly, hint, icon, type_, extraAttrs } =
            optional

        defaultInputAttrs =
            [ Attr.class "fr-input"
            , Attr.classList
                [ ( "fr-input--valid", validMsg /= Nothing )
                , ( "fr-input--error", errorMsg /= Nothing )
                ]
            , Html.Attributes.Extra.attributeIf (Nothing /= validMsg) <|
                Aria.describedBy [ name ++ "-desc-valid" ]
            , Html.Attributes.Extra.attributeIf (Nothing /= errorMsg) <|
                Aria.describedBy [ name ++ "-desc-error" ]
            , Attr.id name
            , Attr.name name
            , Attr.value value
            , Attr.disabled disabled
            , Attr.readonly readonly
            , Events.onInput onInput
            , Attr.property "autocomplete" <| Encode.string name
            ]

        iconWrapper =
            case icon of
                Nothing ->
                    identity

                Just iconName ->
                    List.singleton
                        >> Html.div [ Attr.class "fr-input-wrap", Attr.class iconName ]

        inp =
            case type_ of
                TextInput ->
                    Html.inputText name <|
                        (defaultInputAttrs ++ [ Attr.type_ "text" ])

                EmailInput ->
                    Html.inputText name <|
                        (defaultInputAttrs ++ [ Attr.type_ "email" ])

                PasswordInput ->
                    Html.inputText name <|
                        (defaultInputAttrs ++ [ Attr.type_ "password" ])

                TextArea rows ->
                    Html.textarea ((rows |> Maybe.map Attr.rows |> Maybe.withDefault empty) :: defaultInputAttrs) []

                DateInput ->
                    Root.input (defaultInputAttrs ++ [ Attr.type_ "date" ]) []

                NumberInput ->
                    Html.inputNumber name <|
                        (defaultInputAttrs ++ [ Attr.type_ "number", Attr.attribute "inputmode" "numeric", Attr.pattern "[0-9]*" ])

                TextDisplay ->
                    Html.div [ Attr.class "mt-[0.5rem] py-[0.5rem]", DSFR.Typography.textBold ]
                        [ Html.text <|
                            if value == "" then
                                "-"

                            else
                                value
                        ]
    in
    Html.div
        (Attr.class "fr-input-group"
            :: Attr.classList
                [ ( "fr-input-group--valid", Nothing /= validMsg )
                , ( "fr-input-group--error", Nothing /= errorMsg )
                , ( "fr-input-group--disabled", disabled )
                ]
            :: extraAttrs
        )
        [ Html.labelBefore [ Attr.class "h-full" ]
            (Html.label
                [ Attr.class "fr-label"
                , Attr.for name
                ]
                [ label
                , case hint of
                    [] ->
                        nothing

                    hints ->
                        Html.span [ Attr.class "fr-hint-text" ] hints
                ]
            )
            (iconWrapper <|
                inp
            )
        , Html.Extra.viewMaybe
            (Html.p
                [ Attr.id <| name ++ "-desc-valid"
                , Attr.class "fr-valid-text"
                ]
            )
            validMsg
        , Html.Extra.viewMaybe
            (Html.p
                [ Attr.id <| name ++ "-desc-error"
                , Attr.class "fr-error-text"
                ]
            )
            errorMsg
        ]
