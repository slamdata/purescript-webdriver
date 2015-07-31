module Selenium.Types where 

foreign import data Builder :: *
foreign import data SELENIUM :: !
foreign import data Driver :: *
foreign import data Until :: *
foreign import data Element :: *
foreign import data Locator :: *
foreign import data ActionSequence :: *
foreign import data MouseButton :: *
foreign import data ChromeOptions :: *
foreign import data ControlFlow :: *
foreign import data FirefoxOptions :: *
foreign import data IEOptions :: *
foreign import data LoggingPrefs :: *
foreign import data OperaOptions :: *
foreign import data ProxyConfig :: *
foreign import data SafariOptions :: *
foreign import data ScrollBehaviour :: *
foreign import data Capabilities :: *


type Location =
  { x :: Number
  , y :: Number
  }

newtype ControlKey = ControlKey String
