module Selenium.Remote where

import Control.Monad.Eff (Eff)
import Selenium.Types

foreign import fileDetector :: forall e. Eff (selenium :: SELENIUM | e) FileDetector
