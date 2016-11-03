module Selenium.Remote where

import Control.Monad.Eff (Eff)
import Selenium.Types

foreign import fileDetector ∷ ∀ e. Eff (selenium ∷ SELENIUM | e) FileDetector
