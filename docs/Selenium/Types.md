## Module Selenium.Types

#### `Builder`

``` purescript
data Builder :: *
```

#### `SELENIUM`

``` purescript
data SELENIUM :: !
```

#### `Driver`

``` purescript
data Driver :: *
```

#### `Window`

``` purescript
data Window :: *
```

#### `Until`

``` purescript
data Until :: *
```

#### `Element`

``` purescript
data Element :: *
```

#### `Locator`

``` purescript
data Locator :: *
```

#### `ActionSequence`

``` purescript
data ActionSequence :: *
```

#### `MouseButton`

``` purescript
data MouseButton :: *
```

#### `ChromeOptions`

``` purescript
data ChromeOptions :: *
```

#### `ControlFlow`

``` purescript
data ControlFlow :: *
```

#### `FirefoxOptions`

``` purescript
data FirefoxOptions :: *
```

#### `IEOptions`

``` purescript
data IEOptions :: *
```

#### `LoggingPrefs`

``` purescript
data LoggingPrefs :: *
```

#### `OperaOptions`

``` purescript
data OperaOptions :: *
```

#### `ProxyConfig`

``` purescript
data ProxyConfig :: *
```

#### `SafariOptions`

``` purescript
data SafariOptions :: *
```

#### `ScrollBehaviour`

``` purescript
data ScrollBehaviour :: *
```

#### `FileDetector`

``` purescript
data FileDetector :: *
```

#### `WindowHandle`

``` purescript
data WindowHandle :: *
```

#### `Method`

``` purescript
data Method
  = DELETE
  | GET
  | HEAD
  | OPTIONS
  | PATCH
  | POST
  | PUT
  | MOVE
  | COPY
  | CustomMethod String
```

Copied from `purescript-affjax` because the only thing we
need from `affjax` is `Method`

##### Instances
``` purescript
Eq Method
IsForeign Method
```

#### `XHRState`

``` purescript
data XHRState
  = Stale
  | Opened
  | Loaded
```

##### Instances
``` purescript
Eq XHRState
IsForeign XHRState
```

#### `Location`

``` purescript
type Location = { x :: Int, y :: Int }
```

#### `Size`

``` purescript
type Size = { width :: Int, height :: Int }
```

#### `ControlKey`

``` purescript
newtype ControlKey
  = ControlKey String
```

#### `XHRStats`

``` purescript
type XHRStats = { method :: Method, url :: String, async :: Boolean, user :: Maybe String, password :: Maybe String, state :: XHRState }
```


