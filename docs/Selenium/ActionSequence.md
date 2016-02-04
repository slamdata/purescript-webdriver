## Module Selenium.ActionSequence

DSL for building action sequences

#### `Sequence`

``` purescript
newtype Sequence a
```

##### Instances
``` purescript
Functor Sequence
Apply Sequence
Bind Sequence
Applicative Sequence
Monad Sequence
```

#### `click`

``` purescript
click :: MouseButton -> Element -> Sequence Unit
```

#### `leftClick`

``` purescript
leftClick :: Element -> Sequence Unit
```

#### `doubleClick`

``` purescript
doubleClick :: MouseButton -> Element -> Sequence Unit
```

#### `hover`

``` purescript
hover :: Element -> Sequence Unit
```

#### `mouseDown`

``` purescript
mouseDown :: MouseButton -> Element -> Sequence Unit
```

#### `mouseUp`

``` purescript
mouseUp :: MouseButton -> Element -> Sequence Unit
```

#### `sendKeys`

``` purescript
sendKeys :: String -> Sequence Unit
```

#### `mouseToLocation`

``` purescript
mouseToLocation :: Location -> Sequence Unit
```

#### `keyDown`

``` purescript
keyDown :: ControlKey -> Sequence Unit
```

This function is used only with special keys (META, CONTROL, etc)
It doesn't emulate __keyDown__ event

#### `keyUp`

``` purescript
keyUp :: ControlKey -> Sequence Unit
```

This function is used only with special keys (META, CONTROL, etc)
It doesn't emulate __keyUp__ event

#### `sequence`

``` purescript
sequence :: forall e. Driver -> Sequence Unit -> Aff (selenium :: SELENIUM | e) Unit
```


