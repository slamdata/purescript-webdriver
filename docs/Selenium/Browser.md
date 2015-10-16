## Module Selenium.Browser

#### `Browser`

``` purescript
data Browser
  = PhantomJS
  | Chrome
  | FireFox
  | IE
  | Opera
  | Safari
```

#### `browser2str`

``` purescript
browser2str :: Browser -> String
```

#### `str2browser`

``` purescript
str2browser :: String -> Maybe Browser
```

#### `browserCapabilities`

``` purescript
browserCapabilities :: Browser -> Capabilities
```

#### `versionCapabilities`

``` purescript
versionCapabilities :: String -> Capabilities
```

#### `platformCapabilities`

``` purescript
platformCapabilities :: String -> Capabilities
```


