## Module Selenium.Monad

Most functions of `Selenium` use `Driver` as an argument
This module supposed to make code a bit cleaner through
putting `Driver` to `ReaderT`

#### `Selenium`

``` purescript
type Selenium e o a = ReaderT { driver :: Driver | o } (Aff (console :: CONSOLE, selenium :: SELENIUM, dom :: DOM | e)) a
```

`Driver` is field of `ReaderT` context
Usually selenium tests are run with tons of configs (i.e. xpath locators,
timeouts) all those configs can be putted to `Selenium e o a`

#### `getDriver`

``` purescript
getDriver :: forall e o. Selenium e o Driver
```

get driver from context

#### `apathize`

``` purescript
apathize :: forall e o a. Selenium e o a -> Selenium e o Unit
```

#### `attempt`

``` purescript
attempt :: forall e o a. Selenium e o a -> Selenium e o (Either Error a)
```

#### `later`

``` purescript
later :: forall e o a. Int -> Selenium e o a -> Selenium e o a
```

#### `get`

``` purescript
get :: forall e o. String -> Selenium e o Unit
```

#### `wait`

``` purescript
wait :: forall e o. Selenium e o Boolean -> Int -> Selenium e o Unit
```

#### `byCss`

``` purescript
byCss :: forall e o. String -> Selenium e o Locator
```

#### `byXPath`

``` purescript
byXPath :: forall e o. String -> Selenium e o Locator
```

#### `byId`

``` purescript
byId :: forall e o. String -> Selenium e o Locator
```

#### `byName`

``` purescript
byName :: forall e o. String -> Selenium e o Locator
```

#### `byClassName`

``` purescript
byClassName :: forall e o. String -> Selenium e o Locator
```

#### `locator`

``` purescript
locator :: forall e o. (Element -> Selenium e o Element) -> Selenium e o Locator
```

get element by action returning an element
```purescript
locator \el -> do 
  commonElements <- byCss ".common-element" >>= findElements el 
  flaggedElements <- traverse (\el -> Tuple el <$> isVisible el) commonElements
  maybe err pure $ foldl foldFn Nothing flaggedElements
  where
  err = throwError $ error "all common elements are not visible"
  foldFn Nothing (Tuple el true) = Just el
  foldFn a _ = a 
```

#### `findElement`

``` purescript
findElement :: forall e o. Locator -> Selenium e o (Maybe Element)
```

Tries to find element and return it wrapped in `Just` 

#### `findElements`

``` purescript
findElements :: forall e o. Locator -> Selenium e o (List Element)
```

#### `findChild`

``` purescript
findChild :: forall e o. Element -> Locator -> Selenium e o (Maybe Element)
```

Tries to find child and return it wrapped in `Just`

#### `findChildren`

``` purescript
findChildren :: forall e o. Element -> Locator -> Selenium e o (List Element)
```

#### `getInnerHtml`

``` purescript
getInnerHtml :: forall e o. Element -> Selenium e o String
```

#### `isDisplayed`

``` purescript
isDisplayed :: forall e o. Element -> Selenium e o Boolean
```

#### `isEnabled`

``` purescript
isEnabled :: forall e o. Element -> Selenium e o Boolean
```

#### `getCssValue`

``` purescript
getCssValue :: forall e o. Element -> String -> Selenium e o String
```

#### `getAttribute`

``` purescript
getAttribute :: forall e o. Element -> String -> Selenium e o String
```

#### `clearEl`

``` purescript
clearEl :: forall e o. Element -> Selenium e o Unit
```

#### `sendKeysEl`

``` purescript
sendKeysEl :: forall e o. String -> Element -> Selenium e o Unit
```

#### `script`

``` purescript
script :: forall e o. String -> Selenium e o Foreign
```

#### `getCurrentUrl`

``` purescript
getCurrentUrl :: forall e o. Selenium e o String
```

#### `navigateBack`

``` purescript
navigateBack :: forall e o. Selenium e o Unit
```

#### `navigateForward`

``` purescript
navigateForward :: forall e o. Selenium e o Unit
```

#### `navigateTo`

``` purescript
navigateTo :: forall e o. String -> Selenium e o Unit
```

#### `setFileDetector`

``` purescript
setFileDetector :: forall e o. FileDetector -> Selenium e o Unit
```

#### `getTitle`

``` purescript
getTitle :: forall e o. Selenium e o String
```

#### `sequence`

``` purescript
sequence :: forall e o. Sequence Unit -> Selenium e o Unit
```

Run sequence of actions 

#### `actions`

``` purescript
actions :: forall e o. ({ driver :: Driver | o } -> Sequence Unit) -> Selenium e o Unit
```

Same as `sequence` but takes function of `ReaderT` as an argument

#### `stop`

``` purescript
stop :: forall e o. Selenium e o Unit
```

Stop computations

#### `refresh`

``` purescript
refresh :: forall e o. Selenium e o Unit
```

#### `quit`

``` purescript
quit :: forall e o. Selenium e o Unit
```

#### `takeScreenshot`

``` purescript
takeScreenshot :: forall e o. Selenium e o String
```

#### `findExact`

``` purescript
findExact :: forall e o. Locator -> Selenium e o Element
```

Tries to find element, if has no success throws an error

#### `childExact`

``` purescript
childExact :: forall e o. Element -> Locator -> Selenium e o Element
```

Tries to find child, if has no success throws an error

#### `startSpying`

``` purescript
startSpying :: forall e o. Selenium e o Unit
```

#### `stopSpying`

``` purescript
stopSpying :: forall e o. Selenium e o Unit
```

#### `clearLog`

``` purescript
clearLog :: forall e o. Selenium e o Unit
```

#### `getXHRStats`

``` purescript
getXHRStats :: forall e o. Selenium e o (List XHRStats)
```


