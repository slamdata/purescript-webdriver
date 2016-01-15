## Module Selenium.Builder

#### `Build`

``` purescript
newtype Build a
```

##### Instances
``` purescript
Functor Build
Apply Build
Bind Build
Applicative Build
Monad Build
```

#### `version`

``` purescript
version :: String -> Build Unit
```

#### `platform`

``` purescript
platform :: String -> Build Unit
```

#### `usingServer`

``` purescript
usingServer :: String -> Build Unit
```

#### `scrollBehaviour`

``` purescript
scrollBehaviour :: ScrollBehaviour -> Build Unit
```

#### `withCapabilities`

``` purescript
withCapabilities :: Capabilities -> Build Unit
```

#### `browser`

``` purescript
browser :: Browser -> Build Unit
```

#### `build`

``` purescript
build :: forall e. Build Unit -> Aff (selenium :: SELENIUM | e) Driver
```


