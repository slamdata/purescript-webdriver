## Module Selenium.Builder

#### `Build`

``` purescript
newtype Build a
```

##### Instances
``` purescript
instance functorBuild :: Functor Build
instance applyBuild :: Apply Build
instance bindBuild :: Bind Build
instance applicativeBuild :: Applicative Build
instance monadBuild :: Monad Build
```

#### `browser`

``` purescript
browser :: Browser -> Build Unit
```

#### `forBrowser`

``` purescript
forBrowser :: Browser -> String -> String -> Build Unit
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

#### `build`

``` purescript
build :: forall e. Build Unit -> Aff (selenium :: SELENIUM | e) Driver
```


